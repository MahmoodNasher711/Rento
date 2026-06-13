import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rento/main.dart';
import 'package:rento/data/models/payment_model.dart';
import 'package:rento/data/models/today_alert_model.dart';
import 'package:rento/domain/cubit/dashboard_cubit.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import 'package:rento/domain/cubit/tenant_cubit.dart';
import 'package:rento/domain/cubit/apartment_cubit.dart';
import 'package:rento/domain/cubit/expense_cubit.dart';
import 'package:rento/domain/cubit/contract_cubit.dart';
import 'package:rento/data/repository/firestore_tenant_repository.dart';
import 'package:rento/data/repository/firestore_payment_repository.dart';
import 'package:rento/data/repository/firestore_expense_repository.dart';
import 'package:rento/data/repository/firestore_apartment_repository.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../widget/dashboard_card.dart';
import '../widget/shimmer_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final globalPaymentCubit = context.read<PaymentCubit>();
    final globalTenantCubit = context.read<TenantCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(
            tenantRepository: context.read<FirestoreTenantRepository>(),
            paymentRepository: context.read<FirestorePaymentRepository>(),
            expenseRepository: context.read<FirestoreExpenseRepository>(),
            apartmentRepository: context.read<FirestoreApartmentRepository>(),
          )..loadDashboardData(),
        ),
        BlocProvider(
          create: (context) => PaymentCubit(context.read<FirestorePaymentRepository>())..loadRecentPayments(),
        ),
        BlocProvider(
          create: (context) => TenantCubit(context.read<FirestoreTenantRepository>())..loadTodayAlerts(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ApartmentCubit, ApartmentState>(
            listener: (context, state) {
              if (state is ApartmentAdded || state is ApartmentUpdated || state is ApartmentDeleted) {
                _refreshDashboard(context);
              }
            },
          ),
          BlocListener<PaymentCubit, PaymentState>(
            bloc: globalPaymentCubit,
            listener: (context, state) {
              if (state is PaymentAdded || state is PaymentUpdated || state is PaymentDeleted) {
                _refreshDashboard(context);
              }
            },
          ),
          BlocListener<TenantCubit, TenantState>(
            bloc: globalTenantCubit,
            listener: (context, state) {
              if (state is TenantAdded || state is TenantUpdated || state is TenantDeleted) {
                _refreshDashboard(context);
              }
            },
          ),
          BlocListener<ExpenseCubit, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseAdded || state is ExpenseUpdated || state is ExpenseDeleted) {
                _refreshDashboard(context);
              }
            },
          ),
          BlocListener<ContractCubit, ContractState>(
            listener: (context, state) {
              if (state is ContractAdded || state is ContractUpdated || state is ContractDeleted) {
                _refreshDashboard(context);
              }
            },
          ),
        ],
        child: const _DashboardView(),
      ),
    );
  }

  void _refreshDashboard(BuildContext context) {
    context.read<DashboardCubit>().loadDashboardData();
    context.read<PaymentCubit>().loadRecentPayments();
    context.read<TenantCubit>().loadTodayAlerts();
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardError) {
          return _DashboardError(message: state.message);
        } else if (state is DashboardLoaded) {
          return _DashboardLayout(state: state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final DashboardLoaded state;
  const _DashboardLayout({required this.state});

  Future<void> _refreshData(BuildContext context) async {
    await Future.wait([
      context.read<DashboardCubit>().loadDashboardData(),
      context.read<PaymentCubit>().loadRecentPayments(),
      context.read<TenantCubit>().loadTodayAlerts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    
    final totalApartments = state.rentedApartmentsCount + state.vacantApartmentsCount;
    final occupancyRate = totalApartments > 0
        ? (state.rentedApartmentsCount / totalApartments * 100).round()
        : 0;

    return RefreshIndicator(
      onRefresh: () => _refreshData(context),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Fake Header
            Container(
              color: AppColors.primary,
              child: _DashboardHeader(
                rentedCount: state.rentedApartmentsCount,
                totalCount: totalApartments,
                occupancyRate: occupancyRate,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2x2 Stats Grid
                  _StatsGrid(state: state),
                  const SizedBox(height: AppSpacing.md),

                  // KPI Row
                  _KPIRow(
                    totalRents: state.totalRents,
                    totalExpenses: state.totalExpenses,
                    occupancyRate: occupancyRate,
                    endingContracts: state.endingContractsCount,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Financial Summary Card
                  _FinancialSummaryCard(
                    totalRents: state.totalRents,
                    totalExpenses: state.totalExpenses,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Today's Alerts
                  _SectionTitle(title: 'تنبيهات اليوم', icon: Icons.notifications_active_rounded, color: AppColors.warning),
                  const SizedBox(height: AppSpacing.sm),
                  const _AlertsSection(),
                  const SizedBox(height: AppSpacing.md),

                  // Recent Transactions
                  _SectionTitle(title: 'آخر العمليات', icon: Icons.receipt_long_rounded, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  const _TransactionsSection(),
                  const SizedBox(height: AppSpacing.xxl), // FAB clearance
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header Widget ──────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final int rentedCount;
  final int totalCount;
  final int occupancyRate;

  const _DashboardHeader({
    required this.rentedCount,
    required this.totalCount,
    required this.occupancyRate,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير 🌤️';
    if (hour < 17) return 'مساء النور ☀️';
    return 'مساء الخير 🌙';
  }

  @override
  Widget build(BuildContext context) {
    
    String dateStr;
    try {
      dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());
    } catch (e) {
      dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.headerGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.of(context).padding.top + AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  'مدير العقارات',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          // Occupancy Ring
          _OccupancyRing(rate: occupancyRate, total: totalCount, rented: rentedCount),
        ],
      ),
    );
  }
}

// ─── Occupancy Ring ──────────────────────────────────────────────────────────

class _OccupancyRing extends StatelessWidget {
  final int rate;
  final int total;
  final int rented;

  const _OccupancyRing({required this.rate, required this.total, required this.rented});

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: rate / 100,
            strokeWidth: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rate%',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              Text(
                'إشغال',
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stats Grid ──────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final DashboardLoaded state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'شقة مؤجرة',
                value: state.rentedApartmentsCount.toString(),
                icon: Icons.home_work_rounded,
                gradient: AppColors.primaryGradient,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DashboardCard(
                title: 'شقة فارغة',
                value: state.vacantApartmentsCount.toString(),
                icon: Icons.home_outlined,
                gradient: AppColors.infoGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'متأخرات',
                value: state.latePaymentsCount.toString(),
                icon: Icons.warning_amber_rounded,
                gradient: AppColors.warningGradient,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DashboardCard(
                title: 'تنتهي قريباً',
                value: state.endingContractsCount.toString(),
                icon: Icons.calendar_month_rounded,
                gradient: AppColors.purpleGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── KPI Row ──────────────────────────────────────────────────────────────────

class _KPIRow extends StatelessWidget {
  final double totalRents;
  final double totalExpenses;
  final int occupancyRate;
  final int endingContracts;

  const _KPIRow({
    required this.totalRents,
    required this.totalExpenses,
    required this.occupancyRate,
    required this.endingContracts,
  });

  @override
  Widget build(BuildContext context) {
    
    NumberFormat formatter;
    try {
      formatter = NumberFormat.compact(locale: 'ar');
    } catch (e) {
      try {
        formatter = NumberFormat.compact(locale: 'en_US');
      } catch (e) {
        formatter = NumberFormat.compact();
      }
    }
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _KPICard(
            label: 'الإيرادات',
            value: '${formatter.format(totalRents)} ر.ي',
            icon: Icons.trending_up_rounded,
            color: AppColors.success,
            trend: '+',
          ),
          const SizedBox(width: AppSpacing.sm),
          _KPICard(
            label: 'المصاريف',
            value: '${formatter.format(totalExpenses)} ر.ي',
            icon: Icons.trending_down_rounded,
            color: AppColors.danger,
            trend: '-',
          ),
          const SizedBox(width: AppSpacing.sm),
          _KPICard(
            label: 'صافي الدخل',
            value: '${formatter.format(totalRents - totalExpenses)} ر.ي',
            icon: Icons.account_balance_wallet_rounded,
            color: (totalRents - totalExpenses) >= 0 ? AppColors.success : AppColors.danger,
            trend: (totalRents - totalExpenses) >= 0 ? '+' : '-',
          ),
          const SizedBox(width: AppSpacing.sm),
          _KPICard(
            label: 'عقود تنتهي',
            value: '$endingContracts عقد',
            icon: Icons.event_busy_rounded,
            color: endingContracts > 0 ? AppColors.warning : AppColors.success,
            trend: endingContracts > 0 ? '!' : '✓',
          ),
        ],
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _KPICard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    
    
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Financial Summary ───────────────────────────────────────────────────────

class _FinancialSummaryCard extends StatelessWidget {
  final double totalRents;
  final double totalExpenses;

  const _FinancialSummaryCard({
    required this.totalRents,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    
    
    final netIncome = totalRents - totalExpenses;
    NumberFormat formatter;
    try {
      formatter = NumberFormat('#,##0.00', 'ar');
    } catch (e) {
      formatter = NumberFormat('#,##0.00');
    }
    final maxValue = totalRents > totalExpenses ? totalRents : totalExpenses;

    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.divider,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: (Theme.of(context).brightness == Brightness.dark) ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'الملخص المالي الشهري',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Revenue bar
          _FinancialBar(
            label: 'الإيرادات',
            value: totalRents,
            maxValue: maxValue,
            color: AppColors.success,
            formattedValue: '${formatter.format(totalRents)} ر.ي',
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Expenses bar
          _FinancialBar(
            label: 'المصاريف',
            value: totalExpenses,
            maxValue: maxValue,
            color: AppColors.danger,
            formattedValue: '${formatter.format(totalExpenses)} ر.ي',
            icon: Icons.arrow_downward_rounded,
          ),

          Divider(height: AppSpacing.lg, color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.divider),

          // Net income
          Row(
            children: [
              Icon(
                netIncome >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: netIncome >= 0 ? AppColors.success : AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'صافي الدخل',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${formatter.format(netIncome)} ر.ي',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: netIncome >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final String formattedValue;
  final IconData icon;

  const _FinancialBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.formattedValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    
    
    final ratio = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              formattedValue,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionTitle({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Alerts Section ───────────────────────────────────────────────────────────

class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<TenantCubit, TenantState>(
      builder: (context, state) {
        if (state is TodayAlertsLoaded) {
          if (state.alerts.isEmpty) return _noAlertsWidget(context);
          return _AlertsList(alerts: state.alerts);
        } else if (state is TodayAlertsEmpty) {
          return _noAlertsWidget(context);
        } else if (state is TenantError) {
          return _DashboardError(message: state.message);
        }
        return const ShimmerCard(height: 80);
      },
    );
  }

  Widget _noAlertsWidget(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'لا توجد تنبيهات اليوم ✨',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsList extends StatelessWidget {
  final List<TodayAlert> alerts;
  const _AlertsList({required this.alerts});

  @override
  Widget build(BuildContext context) {
    
    
    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: alerts.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.divider,
        ),
        itemBuilder: (context, index) => _AlertItem(alert: alerts[index]),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final TodayAlert alert;
  const _AlertItem({required this.alert});

  @override
  Widget build(BuildContext context) {
    
    
    final isContract = alert.isContractAlert;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isContract ? AppColors.warningLight : AppColors.infoLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isContract ? Icons.assignment_late_rounded : Icons.payments_rounded,
          color: isContract ? AppColors.warning : AppColors.info,
          size: 20,
        ),
      ),
      title: Text(
        alert.title,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${alert.apartmentNumber} — ${alert.tenantName}',
        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textTertiary),
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkTextSecondary : AppColors.textTertiary,
      ),
      onTap: () async {
        // Fetch the tenant by name and apartment number, then navigate
        final cubit = context.read<TenantCubit>();
        final allTenants = await cubit.tenantRepository.getAllTenants();
        final tenant = allTenants.firstWhere(
          (t) => t.fullName == alert.tenantName && t.apartmentNumber == alert.apartmentNumber,
        );
        if (context.mounted) {
          Navigator.pushNamed(context, AppRoutes.tenantDetails, arguments: tenant);
        }
      },
    );
  }
}

// ─── Transactions Section ─────────────────────────────────────────────────────

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is RecentPaymentsLoaded) {
          if (state.payments.isEmpty) return _emptyTransactions(context);
          return _TransactionsList(payments: state.payments);
        } else if (state is PaymentError) {
          return _DashboardError(message: state.message);
        }
        return const ShimmerCard(height: 200);
      },
    );
  }

  Widget _emptyTransactions(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'لا توجد عمليات حديثة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final List<PaymentModel> payments;
  const _TransactionsList({required this.payments});

  @override
  Widget build(BuildContext context) {
    
    
    final displayPayments = payments.take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayPayments.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.divider,
          indent: 64,
        ),
        itemBuilder: (context, index) => _TransactionItem(payment: displayPayments[index]),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final PaymentModel payment;
  const _TransactionItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    
    DateFormat dateFormat;
    try {
      dateFormat = DateFormat('dd/MM/yyyy');
    } catch (e) {
      dateFormat = DateFormat('yyyy-MM-dd');
    }
    final isExpense = payment.paymentMethod.toLowerCase() == 'expense';
    final color = isExpense ? AppColors.danger : AppColors.success;
    final bgColor = isExpense ? AppColors.dangerLight : AppColors.successLight;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(
          isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        'دفعة ${payment.month}',
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        dateFormat.format(payment.paymentDate),
        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textTertiary),
      ),
      trailing: Text(
        '${payment.amount.toStringAsFixed(0)} ر.ي',
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Error Widget ─────────────────────────────────────────────────────────────

class _DashboardError extends StatelessWidget {
  final String message;
  const _DashboardError({required this.message});

  @override
  Widget build(BuildContext context) {
    
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkCard : AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(color: AppColors.danger, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
