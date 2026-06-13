import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

enum EmptyStateType {
  tenants,
  apartments,
  payments,
  expenses,
  reports,
  search,
  notifications,
  generic,
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getConfig();
    final color = accentColor ?? config.color;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.1 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: _IllustrationPainter(type: type, color: color),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title ?? config.title,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle ?? config.subtitle,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  actionLabel!,
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyConfig _getConfig() {
    switch (type) {
      case EmptyStateType.tenants:
        return _EmptyConfig(
          color: AppColors.primary,
          title: 'لا يوجد مستأجرون',
          subtitle: 'لم تقم بإضافة أي مستأجر بعد.\nابدأ بإضافة مستأجرك الأول الآن.',
        );
      case EmptyStateType.apartments:
        return _EmptyConfig(
          color: AppColors.info,
          title: 'لا توجد شقق مسجّلة',
          subtitle: 'أضف شققك لتتمكن من إدارة\nالإيجارات والمستأجرين.',
        );
      case EmptyStateType.payments:
        return _EmptyConfig(
          color: AppColors.success,
          title: 'لا توجد مدفوعات',
          subtitle: 'لم يتم تسجيل أي دفعة إيجار بعد.\nسجّل الدفعة الأولى الآن.',
        );
      case EmptyStateType.expenses:
        return _EmptyConfig(
          color: AppColors.secondary,
          title: 'لا توجد مصاريف',
          subtitle: 'لم تقم بتسجيل أي مصروف بعد.\nابدأ بتتبع مصاريفك.',
        );
      case EmptyStateType.reports:
        return _EmptyConfig(
          color: AppColors.accent,
          title: 'لا توجد بيانات',
          subtitle: 'لا توجد بيانات للفترة المحددة.\nجرّب تغيير الفترة الزمنية.',
        );
      case EmptyStateType.search:
        return _EmptyConfig(
          color: AppColors.textTertiary,
          title: 'لا توجد نتائج',
          subtitle: 'لم يتم العثور على نتائج مطابقة.\nجرّب كلمات بحث مختلفة.',
        );
      case EmptyStateType.notifications:
        return _EmptyConfig(
          color: AppColors.primary,
          title: 'لا توجد تنبيهات',
          subtitle: 'أنت محدّث! لا توجد\nتنبيهات مهمة اليوم.',
        );
      default:
        return _EmptyConfig(
          color: AppColors.grey,
          title: 'لا توجد بيانات',
          subtitle: 'لم يتم العثور على أي بيانات.',
        );
    }
  }
}

class _EmptyConfig {
  final Color color;
  final String title;
  final String subtitle;
  const _EmptyConfig({required this.color, required this.title, required this.subtitle});
}

class _IllustrationPainter extends CustomPainter {
  final EmptyStateType type;
  final Color color;
  _IllustrationPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case EmptyStateType.tenants:
        _drawPerson(canvas, size);
      case EmptyStateType.apartments:
      case EmptyStateType.reports:
        _drawHouse(canvas, size);
      case EmptyStateType.payments:
        _drawWallet(canvas, size);
      case EmptyStateType.expenses:
        _drawReceipt(canvas, size);
      case EmptyStateType.search:
        _drawSearch(canvas, size);
      default:
        _drawHouse(canvas, size);
    }
  }

  Paint get _stroke => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fill => Paint()
    ..color = color.withValues(alpha: 0.2)
    ..style = PaintingStyle.fill;

  void _drawPerson(Canvas canvas, Size s) {
    final cx = s.width / 2;
    canvas.drawCircle(Offset(cx, s.height * 0.28), s.width * 0.17, _fill);
    canvas.drawCircle(Offset(cx, s.height * 0.28), s.width * 0.17, _stroke);
    final body = Path()
      ..moveTo(cx, s.height * 0.48)
      ..lineTo(cx, s.height * 0.72)
      ..moveTo(cx - s.width * 0.22, s.height * 0.54)
      ..lineTo(cx + s.width * 0.22, s.height * 0.54)
      ..moveTo(cx, s.height * 0.72)
      ..lineTo(cx - s.width * 0.18, s.height * 0.88)
      ..moveTo(cx, s.height * 0.72)
      ..lineTo(cx + s.width * 0.18, s.height * 0.88);
    canvas.drawPath(body, _stroke);
    final plusP = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + s.width * 0.3, s.height * 0.18), Offset(cx + s.width * 0.3, s.height * 0.38), plusP);
    canvas.drawLine(Offset(cx + s.width * 0.2, s.height * 0.28), Offset(cx + s.width * 0.4, s.height * 0.28), plusP);
  }

  void _drawHouse(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final roof = Path()
      ..moveTo(cx, s.height * 0.12)
      ..lineTo(s.width * 0.12, s.height * 0.44)
      ..lineTo(s.width * 0.88, s.height * 0.44)
      ..close();
    canvas.drawPath(roof, _fill);
    canvas.drawPath(roof, _stroke);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.18, s.height * 0.43, s.width * 0.64, s.height * 0.42),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, _fill);
    canvas.drawRRect(body, _stroke);
    final door = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - s.width * 0.1, s.height * 0.6, s.width * 0.2, s.height * 0.25),
      const Radius.circular(4),
    );
    canvas.drawRRect(door, _stroke);
  }

  void _drawWallet(Canvas canvas, Size s) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.08, s.height * 0.26, s.width * 0.84, s.height * 0.5),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, _fill);
    canvas.drawRRect(body, _stroke);
    final coin = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.54, s.height * 0.36, s.width * 0.3, s.height * 0.3),
      const Radius.circular(6),
    );
    canvas.drawRRect(coin, _stroke);
    canvas.drawCircle(
      Offset(s.width * 0.69, s.height * 0.51),
      s.width * 0.065,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(s.width * 0.14, s.height * 0.41),
      Offset(s.width * 0.46, s.height * 0.41),
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawReceipt(Canvas canvas, Size s) {
    final receiptPath = Path()
      ..moveTo(s.width * 0.2, s.height * 0.08)
      ..lineTo(s.width * 0.8, s.height * 0.08)
      ..lineTo(s.width * 0.8, s.height * 0.82)
      ..lineTo(s.width * 0.65, s.height * 0.72)
      ..lineTo(s.width * 0.5, s.height * 0.82)
      ..lineTo(s.width * 0.35, s.height * 0.72)
      ..lineTo(s.width * 0.2, s.height * 0.82)
      ..close();
    canvas.drawPath(receiptPath, _fill);
    canvas.drawPath(receiptPath, _stroke);
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(s.width * 0.32, s.height * (0.26 + i * 0.14)),
        Offset(s.width * 0.68, s.height * (0.26 + i * 0.14)),
        linePaint,
      );
    }
  }

  void _drawSearch(Canvas canvas, Size s) {
    final searchPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(s.width * 0.42, s.height * 0.42), s.width * 0.26, searchPaint);
    canvas.drawLine(
      Offset(s.width * 0.61, s.height * 0.61),
      Offset(s.width * 0.82, s.height * 0.82),
      searchPaint,
    );
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) => old.type != type || old.color != color;
}
