import 'package:cv_generator/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart'; // Hozzáadva a hiányzó import
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// Relatív importok javítva a fájlok elhelyezkedése alapján
import '../models/generalt_dokumentumok.dart';
import '../models/oneletrajz_adatok.dart';
import '../templates/classic_cv_template.dart';
import '../templates/motivacios_level_sablon.dart';
import '../widgets/cv_editor.dart';
import '../widgets/cover_letter_editor.dart';
import '../widgets/pdf_preview_viewer.dart';

class DocumentViewerPage extends StatefulWidget {
  final GeneraltDokumentumok documents;

  const DocumentViewerPage({super.key, required this.documents});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  late GeneraltDokumentumok _currentDocuments;
  Color _selectedColor = Color(0xff111827);
  bool _isGeneratingPdf = false;
  bool _isFontLoaded = false;
  late pw.Font _font;

  String? _savedCvPdfPath;
  String? _savedCoverLetterPdfPath;

  @override
  void initState() {
    super.initState();
    _currentDocuments = widget.documents;
    _loadFont();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/inter.ttf');
      _font = pw.Font.ttf(fontData);
      if (!mounted) return;
      setState(() {
        _isFontLoaded = true;
      });
      _generateAndSavePdfs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: Text('Hiba a betűtípus betöltésekor: $e'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<Uint8List> _generatePdfData(int tabIndex) async {
    if (!_isFontLoaded) {
      return Uint8List(0);
    }
    final pdf = pw.Document();
    if (tabIndex == 0) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) => ClassicCvTemplate.buildPdf(
            oneletrajz: _currentDocuments.oneletrajz,
            szin: _selectedColor,
            font: _font,
          ),
        ),
      );
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) => MotivaciosLevelSablon.buildPdf(
            motivaciosLevel: _currentDocuments.motivaciosLevel,
            fejlecSzinkod: _selectedColor,
            oneletrajz: _currentDocuments.oneletrajz,
            font: _font,
          ),
        ),
      );
    }
    return pdf.save();
  }

  void _generateAndSavePdfs() async {
    if (!_isFontLoaded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: const Text('A betűtípus még töltődik, kérlek várj...'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfCvBytes = await _generatePdfData(0);
      final pdfCoverLetterBytes = await _generatePdfData(1);

      //await cvFile.writeAsBytes(pdfCvBytes);
      String? cvFilePath = await FileService().savePdfDocument(
        pdfCvBytes,
        "${_currentDocuments.oneletrajz.allasEsCegFileNevSzeruen}-oneletrajz.pdf",
      );
      //await coverLetterFile.writeAsBytes(pdfCoverLetterBytes);
      String? coverLetterFilePath = await FileService().savePdfDocument(
        pdfCoverLetterBytes,
        "${_currentDocuments.oneletrajz.allasEsCegFileNevSzeruen}-motivacios_level.pdf",
      );
      if (!mounted) return;
      setState(() {
        _savedCvPdfPath = cvFilePath;
        _savedCoverLetterPdfPath = coverLetterFilePath;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: Text(
            'Sikeresen generálva: Önéletrajz: $cvFilePath, Motivációs levél: $coverLetterFilePath',
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hiba a PDF generálásakor: $e'),
          duration: Duration(hours: 1),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Válassz színt'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              children: [
                for (var color in [
                  Color(0xff111827),
                  Colors.green,
                  Colors.purple,
                  Colors.red,
                  Colors.orange,
                  Color(0xff004d40),
                  Color(0xff6a1b9a),
                  Color(0xffb71c1c),
                  Color(0xffe65100),
                  Color(0xff00695c),
                  Color(0xff4a148c),
                  Color(0xffd50000),
                  Color(0xffbf360c),
                  Color(0xff263238),
                  Color(0xff3e2723),
                  Color(0xfff57f17),
                  Color(0xff0d47a1),
                ])
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      _generateAndSavePdfs();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateCvData(OneletrajzAdatok updatedCv) {
    setState(() {
      _currentDocuments = _currentDocuments.copyWith(oneletrajz: updatedCv);
    });
  }

  void _updateCoverLetter(String updatedText) {
    setState(() {
      _currentDocuments = _currentDocuments.copyWith(
        motivaciosLevel: updatedText,
      );
    });
  }

  void _showEditorSheet(int tabIndex) {
    showModalBottomSheet(
      sheetAnimationStyle: AnimationStyle(duration: Duration(seconds: 1)),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.95, // Adjust height as needed
            width: MediaQuery.of(context).size.width * 0.95,
            child: tabIndex == 0
                ? CvEditor(
                    oneletrajz: _currentDocuments.oneletrajz,
                    onChanged: (updatedCv) {
                      _updateCvData(updatedCv);
                      // A PDF generálása az adatok frissítése után
                    },
                  )
                : CoverLetterEditor(
                    coverLetter: _currentDocuments.motivaciosLevel,
                    onChanged: (updatedText) {
                      _updateCoverLetter(updatedText);
                      // A PDF generálása az adatok frissítése után
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _showColorPicker,
            icon: const Icon(Icons.color_lens),
          ),
          IconButton(
            onPressed: () async {
              await FileService.openDocumentDirectory();
            },
            icon: const Icon(Icons.folder),
          ),
          IconButton(
            onPressed: (_isGeneratingPdf || !_isFontLoaded)
                ? null
                : _generateAndSavePdfs,
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Önéletrajz'),
                Tab(text: 'Motivációs levél'),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          _showEditorSheet(0);
                        },
                        child: Text("Szerkesztés"),
                      ),
                      Expanded(
                        child: Center(
                          child: PdfPreviewViewer(filePath: _savedCvPdfPath),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          _showEditorSheet(1);
                        },
                        child: Text("Szerkesztés"),
                      ),
                      Expanded(
                        child: PdfPreviewViewer(
                          filePath: _savedCoverLetterPdfPath,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
