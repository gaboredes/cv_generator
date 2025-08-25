import 'package:cv_generator/models/oneletrajz_adatok.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

extension HexColor on Color {
  String toHex() {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}

class ClassicCvTemplate {
  static pw.Widget buildPdf({
    required OneletrajzAdatok oneletrajz,
    required Color szin,
    required pw.Font font,
  }) {
    final accentColor = PdfColor.fromHex(szin.toHex());
    final secondaryColor = PdfColors.grey600;

    return pw.DefaultTextStyle(
      style: pw.TextStyle(font: font),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16.24),
            decoration: pw.BoxDecoration(color: accentColor),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  oneletrajz.teljesnev,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  oneletrajz.szakmaiCim,
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  '${oneletrajz.email} | ${oneletrajz.telefonszam} | ${oneletrajz.lakcim}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
            child: _buildSectionPdf(
              font,
              'Összefoglaló',
              pw.Text(
                oneletrajz.osszegzes,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#333333'),
                ),
              ),
              accentColor,
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
            child: _buildSectionPdf(
              font,
              'Szakmai tapasztalatok',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: oneletrajz.tapasztalatok.map((exp) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        exp.beosztas,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                          font: font,
                        ),
                      ),
                      pw.Text(
                        '${exp.cegnev} | ${exp.kezdodatum} - ${exp.zarodatum}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                          font: font,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        exp.leiras,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
              accentColor,
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
            child: _buildSectionPdf(
              font,
              'Tanulmányok',
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: oneletrajz.vegzettsegek.map((edu) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        edu.vegzettseg,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                          font: font,
                          fontFallback: [font],
                        ),
                      ),
                      pw.Text(
                        '${edu.intezmeny} | ${edu.zarodatum}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        edu.leiras,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#333333'),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
              accentColor,
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
            child: _buildSectionPdf(
              font,
              'Képességek',
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: oneletrajz.kepessegek.map((skill) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F2F3F4'),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      skill,
                      style: pw.TextStyle(color: accentColor, fontSize: 8),
                    ),
                  );
                }).toList(),
              ),
              accentColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionPdf(
    pw.Font font,
    String title,
    pw.Widget content,
    PdfColor color,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            font: font,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.Divider(color: color, height: 2, thickness: 1),
        pw.SizedBox(height: 8),
        content,
        pw.SizedBox(height: 16),
      ],
    );
  }
}
