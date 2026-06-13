import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
// Import screens for navigation
import '../screen/tenants/add_edit_tenant_screen.dart';
import '../screen/apartments/add_edit_apartment_screen.dart';
import '../screen/expenses/add_edit_expense_screen.dart';

class SmartFAB extends StatefulWidget {
  const SmartFAB({super.key});

  @override
  State<SmartFAB> createState() => _SmartFABState();
}

class _SmartFABState extends State<SmartFAB>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _rotation = Tween<double>(begin: 0, end: 0.625).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (_isOpen) {
      setState(() => _isOpen = false);
      _controller.reverse();
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    _close();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Backdrop
        if (_isOpen)
          GestureDetector(
            onTap: _close,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: 0,
            ),
          ),

        // Mini FABs
        AnimatedBuilder(
          animation: _scale,
          builder: (context, child) {
            return ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _MiniFABItem(
                    label: 'إضافة مستأجر',
                    icon: Icons.person_add_rounded,
                    color: AppColors.primary,
                    onTap: () => _navigate(
                      context,
                      const AddEditTenantScreen(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MiniFABItem(
                    label: 'إضافة شقة',
                    icon: Icons.home_work_rounded,
                    color: AppColors.info,
                    onTap: () => _navigate(
                      context,
                      const AddEditApartmentScreen(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MiniFABItem(
                    label: 'إضافة مصروف',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.secondary,
                    onTap: () => _navigate(
                      context,
                      const AddEditExpenseScreen(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            );
          },
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: 'main_smart_fab',
          onPressed: _toggle,
          elevation: 6,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (_, _) => Transform.rotate(
              angle: _rotation.value * 2 * 3.14159,
              child: Icon(
                _isOpen ? Icons.close_rounded : Icons.add_rounded,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniFABItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniFABItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label chip
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Mini FAB button
        SizedBox(
          width: 44,
          height: 44,
          child: FloatingActionButton.small(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 4,
            child: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}
