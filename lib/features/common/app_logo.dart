import 'package:flutter/material.dart';

/// 应用标记（矢量绘制，不依赖图片资源）。
///
/// 造型：墨绿账本卡片 + 三行金色账目 + 一行渐淡（省掉的一笔）+ 右下角溢出卡片
/// 的金币（存下来的钱）。三元素对应「记账 / 省钱 / 存钱」。
///
/// 几何以 1024 坐标系绘制后等比缩放，任意尺寸都锐利。金币外围那圈留白用于
/// 与卡片分离，颜色取 [surfaceColor]（默认页面底色），因此放在同色背景上时
/// 无可见描边。
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    super.key,
    this.size = 32,
    this.surfaceColor = const Color(0xFFF7F3EA),
    this.greenCard = true,
  });

  /// 视觉边长。
  final double size;

  /// 金币分离环的颜色，应与所在背景一致。
  final Color surfaceColor;

  /// true = 墨绿卡片 + 米色账目行（默认）；false = 米色卡片 + 墨绿账目行。
  final bool greenCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LogoMarkPainter(
          surfaceColor: surfaceColor,
          greenCard: greenCard,
        ),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  const _LogoMarkPainter({required this.surfaceColor, required this.greenCard});

  final Color surfaceColor;
  final bool greenCard;

  // 1024 坐标系下的真实几何（与 logo SVG 一致）
  static const double _bboxLeft = 196;
  static const double _bboxTop = 196;
  static const double _bboxWidth = 714; // 196 → 910（含金币溢出）
  static const double _bboxHeight = 632; // 196 → 828

  static const Color _green = Color(0xFF1F6F5C);
  static const Color _greenMid = Color(0xFF2A7D66);
  static const Color _greenDark = Color(0xFF123F35);
  static const Color _gold = Color(0xFFC6A15B);
  static const Color _goldLight = Color(0xFFE7CF9D);
  static const Color _cream = Color(0xFFF7F3EA);
  static const Color _faded = Color(0xFF93B3A3);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _bboxWidth;
    final dx = (size.width - _bboxWidth * scale) / 2 - _bboxLeft * scale;
    final dy = (size.height - _bboxHeight * scale) / 2 - _bboxTop * scale;

    double x(double v) => dx + v * scale;
    double y(double v) => dy + v * scale;

    final cardColor = greenCard ? null : _cream;
    final lineColor = greenCard ? const Color(0xFFE7CF9D) : _green;

    // 卡片
    final cardRect = RRect.fromLTRBR(
      x(196),
      y(196),
      x(828),
      y(828),
      Radius.circular(188 * scale),
    );
    final cardPaint = Paint()..isAntiAlias = true;
    if (cardColor != null) {
      cardPaint.color = cardColor;
    } else {
      cardPaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(0.7, 1.2),
        colors: <Color>[_greenMid, _greenDark],
      ).createShader(cardRect.outerRect);
    }
    canvas.drawRRect(cardRect, cardPaint);

    // 账目行：三行实线 + 一行渐淡（省掉的那笔）
    final rows = <(double, double, double, Color)>[
      (368, 300, 724, lineColor),
      (458, 300, 724, lineColor),
      (548, 300, 612, lineColor),
      (638, 300, 470, greenCard ? const Color(0xFF8FAE9F) : _faded),
    ];
    final strokeWidth = 32 * scale;
    for (final row in rows) {
      final paint = Paint()
        ..color = row.$4
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawLine(Offset(x(row.$2), y(row.$1)), Offset(x(row.$3), y(row.$1)), paint);
    }

    // 金币：先画分离环（与背景同色），再金币本体，最后钱孔
    final center = Offset(x(784), y(638));
    final ringPaint = Paint()
      ..color = surfaceColor
      ..isAntiAlias = true;
    canvas.drawCircle(center, 144 * scale, ringPaint);

    final coinPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[_goldLight, _gold],
      ).createShader(Rect.fromCircle(center: center, radius: 126 * scale))
      ..isAntiAlias = true;
    canvas.drawCircle(center, 126 * scale, coinPaint);

    canvas.drawCircle(
      center,
      44 * scale,
      Paint()
        ..color = greenCard ? _cream : _cream
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_LogoMarkPainter oldDelegate) =>
      oldDelegate.surfaceColor != surfaceColor || oldDelegate.greenCard != greenCard;
}
