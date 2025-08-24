import 'package:cv_generator/models/oneletrajz_adatok.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

extension HexColor on Color {
  String toHex() {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}

class MotivaciosLevelSablon {
  static pw.Widget buildPdf({
    required String motivaciosLevel,
    required Color fejlecSzinkod,
    required OneletrajzAdatok oneletrajz,
    required pw.Font font,
  }) {
    final accentColor = PdfColor.fromHex(fejlecSzinkod.toHex());
    return pw.DefaultTextStyle(
      style: pw.TextStyle(font: font),
      child: pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 16,
              ),
              color: accentColor,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    oneletrajz.teljesnev,
                    style: pw.TextStyle(
                      fontSize: 24,
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '${oneletrajz.email} | ${oneletrajz.telefonszam} | ${oneletrajz.lakcim}',
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Padding(
              padding: pw.EdgeInsets.all(16),
              child: pw.Text(
                motivaciosLevel,
                style: pw.TextStyle(
                  fontSize: 12,
                  font: font,
                  color: PdfColor.fromHex('#333333'),
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
