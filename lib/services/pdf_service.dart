import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/visitor.dart';
import '../utils/constants.dart';

class PdfService {
  Future<Uint8List> generatePass(Visitor v) async {
    final pdf = pw.Document();
    final dateFmt = DateFormat('dd MMM yyyy');
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(16),
        build: (ctx) => [
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Image(logoImage, width: 28, height: 28),
                    pw.SizedBox(width: 8),
                    pw.Text(AppStrings.collegeName,
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('VISITOR GATE PASS',
                    style: pw.TextStyle(
                        fontSize: 10, letterSpacing: 2,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue600)),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 8),
                _row('Pass ID', v.passId),
                _row('Name', v.fullName),
                _row('Phone', v.phone),
                _row('Type', v.visitorType),
                _row('Department', v.department),
                _row('Purpose', v.purpose),
                _row('Meeting', v.personToMeet),
                _row('Issued By', v.issuedBy),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 4),
                _row('Entry Date', dateFmt.format(v.entryTime)),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: v.passId,
                    width: 90,
                    height: 90,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Scan to verify pass',
                    style: const pw.TextStyle(
                        fontSize: 7, color: PdfColors.grey600)),
              ],
            ),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 70,
              child: pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 8.0, color: PdfColors.grey600)),
            ),
            pw.Expanded(
              child: pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      );

  Future<void> sharePdf(Visitor v) async {
    final pdfBytes = await generatePass(v);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/gate_pass_${v.passId}.pdf');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Gate Pass - ${v.fullName}');
  }

  Future<void> printPdf(Visitor v) async {
    final pdfBytes = await generatePass(v);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
