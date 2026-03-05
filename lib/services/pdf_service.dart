import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/transcript_item.dart';

class PdfService {
  const PdfService();

  Future<Uint8List> buildTranscriptPdf(TranscriptItem item) async {
    final doc = pw.Document();
    final now = DateTime.now().toIso8601String();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            item.title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Luotu: $now'),
          pw.Text('Lahde: ${item.source}'),
          pw.SizedBox(height: 16),
          pw.Text(item.displayText),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> printOrShare(TranscriptItem item) async {
    final bytes = await buildTranscriptPdf(item);
    await Printing.sharePdf(bytes: bytes, filename: '${item.title}.pdf');
  }
}
