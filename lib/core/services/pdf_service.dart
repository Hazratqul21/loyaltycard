/// ==========================================================================
/// pdf_service.dart
/// ==========================================================================
/// Tranzaksiyalar tarixini PDF formatida eksport qilish xizmati.
/// ==========================================================================

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user.dart';

class PdfService {
  /// Tranzaksiyalar hisobotini yaratish
  Future<void> exportTransactionsPdf({
    required AppUser user,
    required List<Transaction> transactions,
    String? title,
  }) async {
    final pdf = pw.Document();

    // Fontlarni yuklash (Uzbek lotin uchun standart fontlar yetarli bo'lishi mumkin, 
    // lekin maxsus belgilar uchun font kerak bo'lsa shu yerda yuklanadi)
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(user, title ?? 'Tranzaksiyalar Tarixi'),
          _buildSummary(transactions),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions),
          pw.SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LoyaltyCard_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Sarlavha qismi
  pw.Widget _buildHeader(AppUser user, String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'LoyaltyCard',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepPurple,
              ),
            ),
            pw.Text(
              DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
              style: const pw.TextStyle(color: PdfColors.grey),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Foydalanuvchi: ${user.displayNameOrEmail}'),
        pw.Text('ID: ${user.uid}'),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 10),
      ],
    );
  }

  /// Statistika qismi
  pw.Widget _buildSummary(List<Transaction> transactions) {
    final totalEarned = transactions
        .where((t) => t.type == TransactionType.earn)
        .fold(0, (sum, t) => sum + t.points);
    final totalSpent = transactions
        .where((t) => t.type == TransactionType.spend)
        .fold(0, (sum, t) => sum + t.points);

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Jami tranzaksiyalar', transactions.length.toString()),
          _buildSummaryItem('Yig\'ilgan ballar', '+$totalEarned'),
          _buildSummaryItem('Sarflangan ballar', '-$totalSpent'),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  /// Tranzaksiyalar jadvali
  pw.Widget _buildTransactionTable(List<Transaction> transactions) {
    const headers = ['Sana', 'Do\'kon', 'Tur', 'Ball', 'Summa'];

    final data = transactions.map((t) {
      return [
        DateFormat('dd.MM.yyyy').format(t.date),
        t.storeName,
        t.type == TransactionType.earn ? 'Yig\'ish' : 'Sarflash',
        t.pointsDisplay,
        t.amount != null ? '${t.amount!.toStringAsFixed(0)} so\'m' : '-',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  /// Pastki qism
  pw.Widget _buildFooter() {
    return pw.Center(
      child: pw.Text(
        'LoyaltyCard orqali avtomatik yaratildi. https://loyaltycard.uz',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }
}
