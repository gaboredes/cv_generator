import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cv_generator/services/generate_basedocument.dart';
import 'package:cv_generator/services/file_service.dart';
import 'package:cv_generator/services/key_storage_service.dart';

class BaseDocumentScreen extends StatefulWidget {
  const BaseDocumentScreen({super.key});

  @override
  State<BaseDocumentScreen> createState() => _BaseDocumentScreenState();
}

class _BaseDocumentScreenState extends State<BaseDocumentScreen> {
  final TextEditingController _documentController = TextEditingController();
  final GenerateBaseDocument _geminiApiService = GenerateBaseDocument();
  final FileService _fileService = FileService();
  final KeyStorageService _keyStorageService = KeyStorageService();
  bool _isGenerating = false;
  List<PlatformFile> _uploadedFiles = [];

  // A fájlok kiválasztása
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true, // Engedélyezi több fájl kiválasztását
    );
    if (result != null) {
      setState(() {
        _uploadedFiles = result.files.toList();
      });
      _showSnackBar('${_uploadedFiles.length} fájl kiválasztva.');
    } else {
      _showSnackBar('Nem lettek fájlok kiválasztva.');
    }
  }

  // A dokumentum generálása a Gemini API segítségével
  Future<void> _generateBaseDocument() async {
    if (_uploadedFiles.isEmpty) {
      _showSnackBar('Kérlek, válassz ki legalább egy önéletrajz fájlt előbb.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    String? apiKey = await _keyStorageService.readKey();
    if (apiKey == null) {
      _showSnackBar(
        'Nincs Gemini API kulcs mentve. Kérlek, add meg a Főoldalon!',
      );
      setState(() {
        _isGenerating = false;
      });
      return;
    }

    // A prompt összeállítása a beolvasott tartalommal
    String cvContent = '';
    try {
      for (var file in _uploadedFiles) {
        cvContent += await _fileService.readContentFromDocument(file);
        cvContent += '\n\n'; // Elválasztja a különböző fájlok tartalmát
      }
    } catch (e) {
      // Ha a fájl olvasása közben hiba történik (pl. Word fájl feltöltése),
      // akkor itt kapjuk el, és értesítjük a felhasználót.
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      ); // Hibaüzenet jelölése
      setState(() {
        _isGenerating = false;
      });
      return; // Ne folytassa az AI hívást, ha hiba történt
    }

    // Alap prompt, amihez hozzáfűzzük a beolvasott CV tartalmat
    String prompt =
        "Írj egy szöveget, ami tartalmaz mindent az alábbi szövegből, megörizve az író kommunikációs stílusát, szóhasználatát: $cvContent";

    try {
      String generatedText = await _geminiApiService.generateText(
        apiKey,
        prompt,
      );
      _documentController.text = generatedText;
      _showSnackBar('Önéletrajz profil generálva a Gemini AI segítségével!');
      await _saveDocument();
    } catch (e) {
      _showSnackBar('Hiba történt a generálás során: $e', isError: true);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // A dokumentum mentése
  Future<void> _saveDocument() async {
    if (_documentController.text.isEmpty) {
      _showSnackBar('A dokumentum üres, nem menthető.');
      return;
    }

    try {
      String? filePath = await _fileService.saveFile(
        _documentController.text,
        "generalt_oneletrajz.txt",
      );
      _showSnackBar('Dokumentum mentve: $filePath');
    } catch (e) {
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  // Visszajelzést adó snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: SelectableText(
            // Másolható szöveg
            message,
            style: TextStyle(color: isError ? Colors.white : Colors.black),
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
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

  @override
  void initState() {
    super.initState();
    _loadSavedDocument();
  }

  // A mentett dokumentum betöltése
  Future<void> _loadSavedDocument() async {
    try {
      final content = await _fileService.loadSavedDocument();
      if (content != null) {
        setState(() {
          _documentController.text = content;
        });
        _showSnackBar('Korábbi dokumentum sikeresen betöltve.');
      }
    } catch (e) {
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Önéletrajz profil generálása')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('Önéletrajz feltöltése (Word/PDF)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _generateBaseDocument,
                    child: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generálás'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_uploadedFiles.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiválasztott fájlok:',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    ..._uploadedFiles.map(
                      (file) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('- ${file.name}'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _documentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Önéletrajz profil',
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                minLines: 30,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saveDocument,
                icon: const Icon(Icons.save),
                label: const Text('Változtatások mentése'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
