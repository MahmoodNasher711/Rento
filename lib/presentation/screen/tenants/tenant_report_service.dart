import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rento/data/models/tenant_model.dart';
import 'package:rento/data/models/payment_model.dart';

class TenantReportService {
  static Future<void> generateTenantReport({
    required TenantModel tenant,
    required BuildContext context,
    required List<PaymentModel> payments,
  }) async {
    try {
      await initializeDateFormatting('ar');

      final arabicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Amiri-Bold.ttf'),
      );

      Uint8List? contractImageBytes;
      if (tenant.contractImagePath != null) {
        if (tenant.contractImagePath!.startsWith('assets/')) {
          contractImageBytes = (await rootBundle.load(tenant.contractImagePath!)).buffer.asUint8List();
        } else {
          contractImageBytes = await File(tenant.contractImagePath!).readAsBytes();
        }
      }
      final contractImage = contractImageBytes != null ? pw.MemoryImage(contractImageBytes) : null;

      final pdf = pw.Document();

      // صفحة بيانات المستأجر مع حساب المبالغ
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildTenantInfoPage(tenant, arabicFont, contractImage, payments);
          },
        ),
      );

      // صفحة المدفوعات (إن وجدت)
      if (payments.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return _buildPaymentsPage(tenant, payments, arabicFont);
            },
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إنشاء التقرير: ${e.toString()}')),
        );
      }
    }
  }

  static pw.Widget _buildTenantInfoPage(
      TenantModel tenant,
      pw.Font font,
      pw.MemoryImage? contractImage,
      List<PaymentModel> payments,
      ) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final currencyFormat = NumberFormat.currency(locale: 'ar', symbol: 'ر.ي ');

    // طباعة لفحص الدفعات
    debugPrint('عدد الدفعات: ${payments.length}');
    for (var p in payments) {
      debugPrint('دفعة: مبلغ=${p.amount}, تاريخ=${p.paymentDate}');
    }

    double totalPaid = payments.fold(0, (sum, p) => sum + p.amount);
    debugPrint('إجمالي المدفوع: $totalPaid');

    final months = (tenant.contractEndDate.year - tenant.contractStartDate.year) * 12 +
        tenant.contractEndDate.month -
        tenant.contractStartDate.month +
        1;
    double totalDue = months * tenant.rentAmount;
    double remaining = totalDue - totalPaid;

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'تقرير المستأجر',
                style: pw.TextStyle(font: font, fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInfoRow('الاسم الكامل', tenant.fullName, font),
            _buildInfoRow('رقم الشقة', tenant.apartmentNumber, font),
            _buildInfoRow('رقم الجوال', tenant.phoneNumber, font),
            _buildInfoRow('قيمة الإيجار', currencyFormat.format(tenant.rentAmount), font),
            _buildInfoRow('تاريخ بداية العقد', dateFormat.format(tenant.contractStartDate), font),
            _buildInfoRow('تاريخ نهاية العقد', dateFormat.format(tenant.contractEndDate), font),
            pw.Divider(),
            _buildInfoRow('إجمالي الإيجار المستحق', currencyFormat.format(totalDue), font),
            _buildInfoRow('المبلغ المدفوع', currencyFormat.format(totalPaid), font),
            _buildInfoRow(
              'المتبقي',
              currencyFormat.format(remaining),
              font,
              valueColor: remaining > 0 ? PdfColors.red : PdfColors.green,
            ),
            pw.Divider(),
            if (tenant.notes != null && tenant.notes!.isNotEmpty)
              _buildInfoRow('ملاحظات', tenant.notes!, font),
            if (contractImage != null) ...[
              pw.SizedBox(height: 20),
              pw.Text('صورة العقد', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Image(contractImage, height: 200),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildPaymentsPage(
      TenantModel tenant,
      List<PaymentModel> payments,
      pw.Font font,
      ) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final currencyFormat = NumberFormat.currency(locale: 'ar', symbol: 'ر.ي ');

    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'سجل الدفع',
              style: pw.TextStyle(font: font, fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildTableHeader('التاريخ', font),
                    _buildTableHeader('المبلغ', font),
                    _buildTableHeader('الوصف', font),
                  ],
                ),
                ...payments.map((payment) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(dateFormat.format(payment.paymentDate), font),
                      _buildTableCell(currencyFormat.format(payment.amount), font),
                      _buildTableCell(payment.notes ?? '-', font),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Padding _buildTableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Padding _buildTableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(font: font)),
    );
  }

  static pw.Padding _buildInfoRow(
      String label,
      String value,
      pw.Font font, {
        PdfColor? valueColor,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 14, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
