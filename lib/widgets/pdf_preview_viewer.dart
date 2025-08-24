import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewViewer extends StatelessWidget {
  final String? filePath;

  const PdfPreviewViewer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    if (filePath != null) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: 0.0,
          horizontal: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width / 4
              : 0.0,
        ),
        child: SfPdfViewer.file(File(filePath!)),
      );
    } else {
      return const Center(
        child: Text(
          'A legutóbb mentett PDF előnézete itt jelenik meg.\nGeneráláshoz kattints a "Mentés PDF-be" gombra.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
  }
}
