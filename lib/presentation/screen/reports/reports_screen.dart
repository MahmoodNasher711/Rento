import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../data/models/expense_model.dart';
import '../../../data/models/payment_model.dart';
import '../../../domain/cubit/expense_cubit.dart';
import '../../../domain/cubit/payment_cubit.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<String> _reportTypes = ['شهري', 'سنوي'];
  String _selectedReportType = 'شهري';
  DateTime _selectedDate = DateTime.now();
  late TextEditingController _dateController;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _updateDateController();
    _loadData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await context.read<PaymentCubit>().loadPayments();
    if (!mounted) return;
    await context.read<ExpenseCubit>().loadExpenses();
  }

  void _updateDateController() {
    setState(() {
      _dateController.text = _selectedReportType == 'شهري'
          ? DateFormat('yyyy-MM').format(_selectedDate)
          : DateFormat('yyyy').format(_selectedDate);
    });
  }

  Future<void> _selectDate() async {
    if (_selectedReportType == 'شهري') {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = DateTime(picked.year, picked.month);
          _updateDateController();
          _loadData();
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('اختر السنة'),
            content: SizedBox(
              width: 300,
              height: 300,
              child: YearPicker(
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                selectedDate: _selectedDate,
                onChanged: (DateTime dateTime) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedDate = dateTime;
                    _updateDateController();
                    _loadData();
                  });
                },
              ),
            ),
          );
        },
      );
    }
  }

  List<PaymentModel> _filterPayments(List<PaymentModel> payments) {
    if (payments.isEmpty) return [];
    final filterDate = _selectedReportType == 'شهري'
        ? DateFormat('yyyy-MM').format(_selectedDate)
        : DateFormat('yyyy').format(_selectedDate);

    return payments.where((p) {
      final paymentDate = _selectedReportType == 'شهري'
          ? p.month
          : p.month.substring(0, 4);
      return paymentDate == filterDate;
    }).toList();
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return [];
    final filterDate = _selectedReportType == 'شهري'
        ? DateFormat('yyyy-MM').format(_selectedDate)
        : DateFormat('yyyy').format(_selectedDate);

    return expenses.where((e) {
      final expenseDate = _selectedReportType == 'شهري'
          ? DateFormat('yyyy-MM').format(e.date)
          : DateFormat('yyyy').format(e.date);
      return expenseDate == filterDate;
    }).toList();
  }

  Future<void> _generateAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final paymentState = context.read<PaymentCubit>().state;
      final expenseState = context.read<ExpenseCubit>().state;

      if (paymentState is! PaymentLoaded || expenseState is! ExpenseLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('البيانات غير متوفرة لإنشاء التقرير')),
        );
        return;
      }

      final payments = _filterPayments(paymentState.payments);
      final expenses = _filterExpenses(expenseState.expenses);

      if (payments.isEmpty && expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد بيانات متاحة للفترة المحددة')),
        );
        return;
      }

      final pdf = pw.Document(
        title: 'تقرير $_selectedReportType - ${_dateController.text}',
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfHeader(),
                  pw.SizedBox(height: 20),
                  _buildPdfSummarySection(payments, expenses),
                  pw.SizedBox(height: 30),
                  if (payments.isNotEmpty) ...[
                    _buildPdfIncomeSection(payments),
                    pw.SizedBox(height: 30),
                  ],
                  if (expenses.isNotEmpty) ...[
                    _buildPdfExpensesSection(expenses),
                  ],
                ],
              ),
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File("${output.path}/report_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'تقرير $_selectedReportType - ${_dateController.text}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إنشاء التقرير: ${e.toString()}')),
      );
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  pw.Widget _buildPdfHeader() {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('تقرير $_selectedReportType',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('الفترة: ${_dateController.text}',
              style: const pw.TextStyle(fontSize: 16)),
          pw.Divider(thickness: 2),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummarySection(
      List<PaymentModel> payments,
      List<ExpenseModel> expenses,
      ) {
    final totalIncome = _calculateTotalIncome(payments);
    final totalExpenses = _calculateTotalExpenses(expenses);
    final profitLoss = _calculateProfitLoss(payments, expenses);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ملخص التقرير',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blue700,
          ),
          headers: ['البند', 'المبلغ (ر.ي)'],
          data: [
            ['إجمالي الإيجارات', _formatCurrency(totalIncome)],
            ['إجمالي المصاريف', _formatCurrency(totalExpenses)],
            [
              profitLoss >= 0 ? 'صافي الربح' : 'صافي الخسارة',
              _formatCurrency(profitLoss.abs(), isPositive: profitLoss >= 0),
            ],
          ],
          cellStyle: const pw.TextStyle(fontSize: 12),
          cellAlignment: pw.Alignment.centerRight,
          oddRowDecoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfIncomeSection(List<PaymentModel> payments) {
    final incomeData = _prepareIncomeData(payments);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'الإيجارات ${_selectedReportType == 'شهري' ? "الشهرية" : "السنوية"}',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blue700,
          ),
          headers: ['الفترة', 'المبلغ (ر.ي)'],
          data: incomeData.entries
              .map((entry) => [entry.key, _formatCurrency(entry.value)])
              .toList(),
          cellStyle: const pw.TextStyle(fontSize: 12),
          cellAlignment: pw.Alignment.centerRight,
          oddRowDecoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfExpensesSection(List<ExpenseModel> expenses) {
    final expenseData = _prepareExpenseData(expenses);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'توزيع المصاريف',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColors.blue700,
          ),
          headers: ['نوع المصروف', 'المبلغ (ر.ي)'],
          data: expenseData.entries
              .map((entry) => [entry.key, _formatCurrency(entry.value)])
              .toList(),
          cellStyle: const pw.TextStyle(fontSize: 12),
          cellAlignment: pw.Alignment.centerRight,
          oddRowDecoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount, {bool isPositive = true}) {
    final formatted = NumberFormat.currency(
      symbol: 'ر.ي ',
      decimalDigits: 2,
    ).format(amount);

    return isPositive ? formatted : '-$formatted';
  }

  double _calculateTotalIncome(List<PaymentModel> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  double _calculateTotalExpenses(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateProfitLoss(List<PaymentModel> payments, List<ExpenseModel> expenses) {
    return _calculateTotalIncome(payments) - _calculateTotalExpenses(expenses);
  }

  Map<String, double> _prepareIncomeData(List<PaymentModel> payments) {
    final data = <String, double>{};
    for (var payment in payments) {
      final key = _selectedReportType == 'شهري'
          ? payment.month
          : payment.month.substring(0, 4);
      data.update(key, (value) => value + payment.amount,
          ifAbsent: () => payment.amount);
    }
    return data;
  }

  Map<String, double> _prepareExpenseData(List<ExpenseModel> expenses) {
    final data = <String, double>{};
    for (var expense in expenses) {
      data.update(expense.type, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<ExpenseCubit, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير'),
          actions: [
            IconButton(
              icon: _isGeneratingPdf
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.picture_as_pdf),
              onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
              tooltip: 'تصدير التقرير كPDF',
            ),
          ],
        ),
        body: _buildReportContent(),
      ),
    );
  }

  Widget _buildReportContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportControls(),
          const SizedBox(height: 32),
          _buildReportSummary(),
          const SizedBox(height: 32),
          _buildReportCharts(),
        ],
      ),
    );
  }

  Widget _buildReportControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedReportType,
                    items: _reportTypes
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReportType = value!;
                        _updateDateController();
                        _loadData();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'نوع التقرير',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _selectedReportType == 'شهري' ? 'الشهر' : 'السنة',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary() {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, paymentState) {
        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            if (paymentState is PaymentLoading || expenseState is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (paymentState is PaymentLoaded && expenseState is ExpenseLoaded) {
              final payments = _filterPayments(paymentState.payments);
              final expenses = _filterExpenses(expenseState.expenses);

              if (payments.isEmpty && expenses.isEmpty) {
                return const Center(
                  child: Text('لا توجد بيانات متاحة للفترة المحددة'),
                );
              }

              final totalIncome = _calculateTotalIncome(payments);
              final totalExpenses = _calculateTotalExpenses(expenses);
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
                        profitLoss >= 0 ? 'صافي الربح' : 'صافي الخسارة',
                        profitLoss.abs(),
                        isProfitLoss: true,
                        isPositive: profitLoss >= 0,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (paymentState is PaymentError) {
              return Center(child: Text(paymentState.message));
            }

            if (expenseState is ExpenseError) {
              return Center(child: Text(expenseState.message));
            }

            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildReportCharts() {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, paymentState) {
        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            if (paymentState is PaymentLoaded && expenseState is ExpenseLoaded) {
              final payments = _filterPayments(paymentState.payments);
              final expenses = _filterExpenses(expenseState.expenses);

              if (payments.isEmpty && expenses.isEmpty) {
                return const SizedBox();
              }

              return Column(
                children: [
                  if (payments.isNotEmpty) _buildIncomeChart(payments),
                  if (expenses.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildExpenseChart(expenses),
                  ],
                ],
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildIncomeChart(List<PaymentModel> payments) {
    final incomeData = _prepareIncomeData(payments);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإيجارات ${_selectedReportType == 'شهري' ? "الشهرية" : "السنوية"}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: _selectedReportType == 'شهري' ? -45 : 0,
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.currency(symbol: 'ر.ي '),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<MapEntry<String, double>, String>>[
                  ColumnSeries<MapEntry<String, double>, String>(
                    dataSource: incomeData.entries.toList(),
                    xValueMapper: (entry, _) => entry.key,
                    yValueMapper: (entry, _) => entry.value,
                    color: Colors.blue,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      textStyle: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(List<ExpenseModel> expenses) {
    final expenseData = _prepareExpenseData(expenses);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع المصاريف',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  PieSeries<MapEntry<String, double>, String>(
                    dataSource: expenseData.entries.toList(),
                    xValueMapper: (entry, _) => entry.key,
                    yValueMapper: (entry, _) => entry.value,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      showZeroValue: false,
                      textStyle: TextStyle(fontSize: 10),
                    ),
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '10%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      String label,
      double value, {
        bool isProfitLoss = false,
        bool isPositive = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isProfitLoss
                  ? (isPositive ? Colors.green : Colors.red)
                  : Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            NumberFormat.currency(symbol: 'ر.ي ').format(value),
            style: TextStyle(
              color: isProfitLoss
                  ? (isPositive ? Colors.green : Colors.red)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
