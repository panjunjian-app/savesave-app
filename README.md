# 省省钱，存存钱（savesave）

本地优先的记账与储蓄目标管理 App（Android 首版，后续 iOS / 鸿蒙）。Flutter 3.x + Riverpod + Drift(SQLite)，纯本地存储，不依赖服务端。

## 快速开始

环境要求：

- Flutter 3.x / Dart 3.14+（`pubspec.yaml` 声明 `sdk: >=3.13.0 <4.0.0`）
- Android Studio / Xcode Command Line Tools（用于 Android SDK / iOS 工具链）
- JDK 17（Android Gradle Plugin）

```bash
cd savesave-app
flutter pub get
dart run build_runner build                               # 生成 Drift / Freezed 代码
flutter analyze
flutter run                                               # 连接真机或模拟器
```

> 注：新版 `build_runner` 已移除并忽略 `--delete-conflicting-outputs`，无需再传该参数。

> 首次运行前必须先执行 `build_runner`：`*.g.dart`（Drift / json_serializable）与 `*.freezed.dart` 均由代码生成产生，不手写。

## 目录结构

```
lib/
├── main.dart                    应用入口（ProviderScope + MaterialApp.router）
├── core/
│   ├── config.dart              微信 AppID / 包名 / AI 端点等占位配置
│   ├── theme.dart               墨绿 #1F6F5C + 暖金 #C6A15B Material3 主题
│   ├── router.dart              go_router 路由表（含登录 redirect 与全部业务页）
│   ├── money.dart               金额解析/格式化（分整数，Decimal 防误差）
│   └── uuid.dart                UUID v4 生成器
├── data/
│   ├── tables.dart              Drift 表定义（9 张表，金额均为 INTEGER 分）
│   ├── database.dart            AppDatabase，schemaVersion = 3
│   ├── migrations.dart          v1→v2（历史存入归档）+ v2→v3（AI 报告表）
│   ├── dao/                     user / goal / ledger / bill / category / balance / analysis_report
│   └── services/
│       ├── ai_client.dart       BYOK AiClient 契约与实现（三种能力）
│       └── ai_failures.dart     五类 AiFailure + 取消信号
├── domain/
│   ├── models/                  freezed 不可变模型
│   └── services/
│       ├── balance_service.dart         结余/进度/里程碑唯一权威（分整数）
│       ├── period_range_resolver.dart   周/月/季/年自然边界唯一真源
│       ├── goal_accelerator.dart        每月需多存量化与三策略
│       └── key_store.dart               flutter_secure_storage Key 封装
├── state/                       Riverpod providers（Widget → Provider → Service → DAO）
└── features/                    业务页面（auth/home/goal/ledger/bill/stats/settings/analysis/common）
android/                          Android 原生工程（Gradle Kotlin DSL + release 签名模板）
ios/                              iOS 原生工程（Runner + URL Scheme + 导出配置模板）
```

## 关键约定

1. **金额一律用「分」整数的 `int`**，字段名以 `Cents` 结尾，禁止 double 存储；技术保护上限 15 位有效数字。
2. 结余 = Σ(绑定账本收入 − 支出)，可为负但进度展示 clamp 到 0%；超额封顶 100% 并保留 `surplusCents`。
3. 进度不落库；流水变更必须调用 `BalanceService.invalidate(ledgerIds)`，冷启动全量重算保证一致。
4. 时间边界全部在设备本地时区计算，`bill_date` 是 `YYYY-MM-DD` 本地日历串，禁止 UTC 转换。
5. AI Key 只存 `flutter_secure_storage`；UI 只见掩码；dio 拦截器做脱敏，禁止打印完整 payload。
6. AI 数字由本地计算，AI 只产文案（占位符回填），详见 v2.1 架构文档 §4.4。

## 需要用户填写的配置

编辑 `lib/core/config.dart`：

- `AppConfig.wechatAppId`：微信开放平台 AppID（当前为占位符 `YOUR_WECHAT_APP_ID`）
- `AppConfig.androidApplicationId` / `iosBundleId`：最终包名 / Bundle ID（须与 `android/app/build.gradle.kts`、`ios/Runner.xcodeproj/project.pbxproj` 同步修改）
- 微信回调 URL Scheme：`ios/Runner/Info.plist` 的 `CFBundleURLSchemes` 占位符 `YOUR_WECHAT_APP_ID` 需与 `wechatAppId` 一致
- Android 签名：复制 `android/key.properties.example` 为 `android/key.properties` 并填入 keystore 信息；真实 `key.properties` 与 `*.jks` 不入库，所有正式包必须使用同一证书
- iOS 导出：复制 `ios/ExportOptions.plist.example` 为 `ios/ExportOptions.plist` 并填入 Team ID

AI 接口端点、模型 ID、超时等常量也在同文件的 `AiConfig` 中，模型固定 `glm-4.6v-flash`，Key 由用户在「设置 → AI 接口配置」自行填写（BYOK）。

## 主要页面

| 路由 | 页面 | 说明 |
| --- | --- | --- |
| `/login` | 微信登录 / 游客模式 | 协议勾选后登录，本地无服务端 |
| `/home` | 首页目标总览 | 结余进度环、目标卡片、快捷入口 |
| `/goals/create`、`/goals/edit/:id` | 目标表单 | 金额（分）、截止日期、图标主题色、账本多选 |
| `/goals/:id` | 目标详情 | 结余构成、绑定账本、里程碑 |
| `/ledgers`、`/ledgers/create` | 账本管理 | 账本列表、新建、内置分类初始化 |
| `/bills`、`/bills/new`、`/bills/:id` | 账单 | 明细、记一笔（小票 AI 填充需人工审核）、详情 |
| `/stats` | 统计报表 | 周/月/季/年切换，fl_chart 分类饼图 |
| `/analysis/report` | AI 收支分析报告 | 本地算数 + AI 文案 + 三层防编造校验 + 缓存 |
| `/settings`、`/settings/ai-config`、`/profile` | 设置 | BYOK Key、脱敏授权、清空数据 |

## 打包与分发

```bash
# Android 正式包（未配置 key.properties 时回退 debug 签名，仅用于本地验证）
flutter build apk --release

# iOS（需 Apple 开发者账号与 ExportOptions.plist）
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

- 包名 / Bundle ID 与微信开放平台登记必须一致；正式包必须始终使用同一 release keystore。
- `android/key.properties`、`*.jks` 不入库；签名指纹登记在 `docs/signing.md`（用户提供材料后补充）。
- iOS 推荐 TestFlight；企业签名/超级签名有封号掉签风险，不使用。

## 当前批次

- 第一批：项目骨架、Drift 数据层与迁移、freezed 模型、核心领域服务、Riverpod 骨架。
- 第二批：核心业务页面（登录 / 目标 / 账本 / 记账 / 统计 / 设置）。
- 第三批：C4 AI 收支分析报告、防编造校验、报告缓存、双端打包配置。
