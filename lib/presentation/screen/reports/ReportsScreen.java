import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rento/domain/cubit/expense_cubit.dart';
import 'package:rento/domain/cubit/payment_cubit.dart';
import 'package:rento/utils/theme/app_colors.dart';
import 'package:rento/utils/theme/app_styles.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<String> _reportTypes = ['شهري', 'سنوي'];
  String _selectedReportType = 'شهري';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    items: _reportTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReportType = value!;
                      });
                    },
                    decoration: AppStyles.inputDecoration(
                      labelText: 'نوع التقرير',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _selectedReportType == 'شهري'
                          ? DateFormat('yyyy-MM').format(_selectedDate)
                          : DateFormat('yyyy').format(_selectedDate),
                    ),
                    readOnly: true,
                    decoration: AppStyles.inputDecoration(
                      labelText: _selectedReportType == 'شهري' ? 'الشهر' : 'السنة',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateReport,
                child: const Text('إنشاء تقرير'),
              ),
            ),
            const SizedBox(height: 32),
            _buildReportSummary(),
            const SizedBox(height: 32),
            _buildCharts(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _generateReport() {
    // TODO: Implement report generation
  }

  Widget _buildReportSummary() {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, paymentState) {
        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            double totalIncome = 0;
            double totalExpenses = 0;

            if (paymentState is PaymentLoaded) {
              totalIncome = paymentState.payments.fold(
                  0, (sum, payment) => sum + payment.amount);
            }

            if (expenseState is ExpenseLoaded) {
              totalExpenses = expenseState.expenses.fold(
                  0, (sum, expense) => sum + expense.amount);
            }

            final profitLoss = totalIncome - totalExpenses;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('إجمالي الإيجارات', totalIncome),
                    _buildSummaryRow('إجمالي المصاريف', totalExpenses),
                    const Divider(),
                    _buildSummaryRow(
                      profitLoss >= 0 ? 'الأرباح' : 'الخسائر',
                      profitLoss.abs(),
                      isProfitLoss: true,
                      isPositive: profitLoss >= 0,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, double value,
      {bool isProfitLoss = false, bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppStyles.bodyText1.copyWith(
              fontWeight: FontWeight.bold,
              color: isProfitLoss
                  ? isPositive
                      ? AppColors.success
                      : AppColors.danger
                  : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(2)} ر.ي',
            style: AppStyles.bodyText1.copyWith(
              color: isProfitLoss
                  ? isPositive
                      ? AppColors.success
                      : AppColors.danger
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الإيجارات الشهرية', style: AppStyles.heading3),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BlocBuilder<PaymentCubit, PaymentState>(
                    builder: (context, state) {
                      if (state is PaymentLoaded) {
                        final monthlyRents =
                            state.payments.fold<Map<String, double>>(
                          {},
                          (map, payment) {
                            map.update(
                              payment.month,
                              (value) => value + payment.amount,
                              ifAbsent: () => payment.amount,
                            );
                            return map;
                          },
                        );

                        return SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries>[
                            ColumnSeries<MapEntry<String, double>, String>(
                              dataSource: monthlyRents.entries.toList(),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              color: AppColors.primary,
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('توزيع المصاريف', style: AppStyles.heading3),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BlocBuilder<ExpenseCubit, ExpenseState>(
                    builder: (context, state) {
                      if (state is ExpenseLoaded) {
                        final expensesByType =
                            state.expenses.fold<Map<String, double>>(
                          {},
                          (map, expense) {
                            map.update(
                              expense.type,
                              (value) => value + expense.amount,
                              ifAbsent: () => expense.amount,
                            );
                            return map;
                          },
                        );

                        return SfCircularChart(
                          series: <CircularSeries>[
                            PieSeries<MapEntry<String, double>, String>(
                              dataSource: expensesByType.entries.toList(),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}