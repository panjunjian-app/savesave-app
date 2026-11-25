import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/api_config.dart';

/// 一个可下载的版本描述（由服务端 `/apk/latest.json` 提供）。
class AppRelease {
  const AppRelease({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    required this.notes,
    this.sizeBytes = 0,
    this.sha256 = '',
    this.force = false,
  });

  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String notes;
  final int sizeBytes;
  final String sha256;
  final bool force;

  /// 解析服务端 JSON；字段缺失或版本号非法返回 null（不阻断使用）。
  static AppRelease? fromJson(Map<String, dynamic> json) {
    final code = json['versionCode'];
    final versionCode = code is int ? code : int.tryParse('${code ?? ''}');
    final versionName = '${json['versionName'] ?? ''}'.trim();
    final apkUrl = '${json['apkUrl'] ?? ''}'.trim();
    if (versionCode == null || versionCode <= 0 || versionName.isEmpty || apkUrl.isEmpty) {
      return null;
    }
    return AppRelease(
      versionCode: versionCode,
      versionName: versionName,
      apkUrl: apkUrl,
      notes: '${json['notes'] ?? ''}'.trim(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      sha256: '${json['sha256'] ?? ''}'.trim(),
      force: json['force'] == true,
    );
  }

  String get sizeLabel {
    if (sizeBytes <= 0) {
      return '';
    }
    final mb = sizeBytes / 1024 / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// 应用内更新的状态（供 UI 展示）。
enum UpdatePhase { idle, checking, upToDate, available, downloading, verifying, ready, installing, failed }

class UpdateState {
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.currentVersion = '',
    this.release,
    this.progress = 0,
    this.message,
    this.localApkPath,
  });

  final UpdatePhase phase;
  final String currentVersion;
  final AppRelease? release;
  final double progress;
  final String? message;
  final String? localApkPath;

  UpdateState copyWith({
    UpdatePhase? phase,
    String? currentVersion,
    AppRelease? release,
    double? progress,
    String? message,
    String? localApkPath,
  }) {
    return UpdateState(
      phase: phase ?? this.phase,
      currentVersion: currentVersion ?? this.currentVersion,
      release: release ?? this.release,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      localApkPath: localApkPath ?? this.localApkPath,
    );
  }
}

/// 应用内更新服务（仅 Android 生效）。
///
/// 流程：读 `https://<站点>/apk/latest.json` → 与本地 versionCode 比较
/// → 下载 APK（走 Cloudflare CDN，国内速度好）→ 校验 sha256
/// → 交给系统安装器（`OpenFilex`），用户只需点「安装」确认。
///
/// Web 端不需要此能力：页面刷新即是最新版。
class UpdateService {
  UpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final StreamController<UpdateState> _controller =
      StreamController<UpdateState>.broadcast();

  UpdateState _state = const UpdateState();

  Stream<UpdateState> get stream => _controller.stream;
  UpdateState get state => _state;

  /// 当前平台是否支持应用内更新。
  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// 版本清单地址（静态文件，随每次发布 APK 一起部署）。
  String get _manifestUrl =>
      '${ApiConfig.baseUrl}/apk/latest.json?v=${DateTime.now().millisecondsSinceEpoch}';

  void _emit(UpdateState next) {
    _state = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  /// 读取本地版本号。
  Future<String> currentVersion() async {
    if (!isSupported && !kIsWeb) {
      return '';
    }
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  /// 读取本地版本号并写入状态（进入页面时先展示当前版本，避免显示"读取中"）。
  Future<void> primeVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _emit(_state.copyWith(
        currentVersion: '${info.version}（${info.buildNumber}）',
      ));
    } catch (_) {
      // 版本信息读取失败不影响使用
    }
  }

  /// 检查更新。返回值是否「有可用新版本」；异常一律静默为 false。
  Future<bool> check({bool silent = true}) async {
    if (!isSupported) {
      return false;
    }
    final info = await PackageInfo.fromPlatform();
    final currentLabel = '${info.version}（${info.buildNumber}）';
    _emit(_state.copyWith(
      phase: UpdatePhase.checking,
      currentVersion: currentLabel,
      message: null,
    ));

    try {
      final response = await _dio.get<dynamic>(
        _manifestUrl,
        options: Options(responseType: ResponseType.plain),
      );
      final raw = response.data;
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) {
        throw const FormatException('版本清单格式不正确');
      }
      final release = AppRelease.fromJson(Map<String, dynamic>.from(decoded));
      if (release == null) {
        throw const FormatException('版本清单缺少必要字段');
      }
      final localCode = int.tryParse(info.buildNumber) ?? 0;
      // 优先按语义化版本号比较（Flutter 的 versionCode 与 pubspec 的 +build
      // 并非一一对应，直接比数字容易误判）；versionCode 仅作为兜底参考。
      final newer = _compareVersion(release.versionName, info.version) > 0
          || (release.versionCode > localCode &&
              _compareVersion(release.versionName, info.version) >= 0);
      if (!newer) {
        _emit(_state.copyWith(
          phase: UpdatePhase.upToDate,
          currentVersion: currentLabel,
          message: '已是最新版本',
        ));
        return false;
      }
      _emit(_state.copyWith(
        phase: UpdatePhase.available,
        currentVersion: currentLabel,
        release: release,
        message: '发现新版本 ${release.versionName}',
      ));
      return true;
    } catch (error) {
      _emit(_state.copyWith(
        phase: silent ? UpdatePhase.idle : UpdatePhase.failed,
        currentVersion: currentLabel,
        message: silent ? null : '检查更新失败：$error',
      ));
      return false;
    }
  }

  /// 下载 APK 到应用缓存目录，校验 sha256 后返回文件。
  Future<File?> downloadApk() async {
    final release = _state.release;
    if (!isSupported || release == null) {
      return null;
    }
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/savesave-${release.versionCode}.apk');
      if (await file.exists()) {
        await file.delete();
      }
      _emit(_state.copyWith(phase: UpdatePhase.downloading, progress: 0));
      await _dio.download(
        release.apkUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _emit(_state.copyWith(
              phase: UpdatePhase.downloading,
              progress: (received / total).clamp(0.0, 1.0),
            ));
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          followRedirects: true,
        ),
      );

      _emit(_state.copyWith(phase: UpdatePhase.verifying, progress: 1));
      if (release.sha256.isNotEmpty) {
        final digest = sha256.convert(await file.readAsBytes()).toString();
        if (digest != release.sha256) {
          await file.delete();
          _emit(_state.copyWith(
            phase: UpdatePhase.failed,
            message: '安装包校验失败，请重试',
          ));
          return null;
        }
      }
      _emit(_state.copyWith(
        phase: UpdatePhase.ready,
        localApkPath: file.path,
        message: '下载完成，点击「立即安装」',
      ));
      return file;
    } catch (error) {
      _emit(_state.copyWith(
        phase: UpdatePhase.failed,
        message: '下载失败：$error',
      ));
      return null;
    }
  }

  /// 调用系统安装器（Android 会弹「允许安装未知应用」确认）。
  Future<void> installApk() async {
    final path = _state.localApkPath;
    if (path == null || path.isEmpty) {
      return;
    }
    _emit(_state.copyWith(phase: UpdatePhase.installing));
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      _emit(_state.copyWith(
        phase: UpdatePhase.failed,
        message: '无法唤起安装器（${result.message}）。'
            '请在系统设置中允许「安装未知应用」后重试。',
      ));
      return;
    }
    _emit(_state.copyWith(
      phase: UpdatePhase.idle,
      message: '已打开系统安装界面，请按提示完成安装',
    ));
  }

  void dispose() {
    _controller.close();
  }

  /// 语义化版本比较：>0 表示 [left] 比 [right] 新。
  ///
  /// 只比较点分数字段（"1.2.0" vs "1.1.10"），忽略 `-beta` 之类后缀；
  /// 任一侧解析不出数字则返回 0（视为相同，避免误报更新）。
  static int _compareVersion(String left, String right) {
    List<int> parse(String value) {
      final core = value.split('+').first.split('-').first.trim();
      return core
          .split('.')
          .map((part) => int.tryParse(part) ?? 0)
          .toList(growable: false);
    }

    final a = parse(left);
    final b = parse(right);
    if (a.isEmpty || b.isEmpty) {
      return 0;
    }
    final length = a.length > b.length ? a.length : b.length;
    for (var index = 0; index < length; index++) {
      final leftPart = index < a.length ? a[index] : 0;
      final rightPart = index < b.length ? b[index] : 0;
      if (leftPart != rightPart) {
        return leftPart > rightPart ? 1 : -1;
      }
    }
    return 0;
  }
}
