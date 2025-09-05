import 'package:cv_generator/widgets/profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cv_generator/services/generate_basedocument.dart';
import 'package:cv_generator/services/file_service.dart';
import 'package:cv_generator/services/key_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _documentController = TextEditingController();
  final GenerateProfile _geminiApiService = GenerateProfile();
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: const Text('Fájlok kiválasztva.'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: const Text('Nem lettek fájlok kiválasztva.'),
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
  }

  // A dokumentum generálása a Gemini API segítségével
  Future<void> _generateProfile() async {
    if (_uploadedFiles.isEmpty) {
      _showSnackBar(
        'Kérlek, válassz ki legalább egy önéletrajz fájlt előbb.',
        context,
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    String? apiKey = await _keyStorageService.readKey();
    if (apiKey == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: const Text(
            'Nincs Gemini API kulcs mentve. Kérlek, add meg az AI kulcs menüpontban!',
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
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
        cvContent += '\n\n';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(hours: 1),
          content: Text(
            "Hiba: ${e.toString().replaceFirst('Exception: ', '')}",
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
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
      await _saveDocument();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Önéletrajz profil generálva a Gemini AI segítségével!',
          ),
          duration: Duration(hours: 1),
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
          content: Text('Hiba történt a generálás során: $e'),
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
      setState(() {
        _isGenerating = false;
      });
    }
  }

  // A dokumentum mentése
  Future<void> _saveDocument() async {
    if (_documentController.text.isEmpty) {
      _showSnackBar('A dokumentum üres, nem menthető.', context);
      return;
    }

    try {
      String? filePath = await _fileService.saveFile(
        _documentController.text,
        "generalt_oneletrajz.txt",
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dokumentum mentve: $filePath'),
          duration: Duration(hours: 1),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        context,
        isError: true,
      );
    }
  }

  // Visszajelzést adó snackbar
  void _showSnackBar(
    String message,
    BuildContext context, {
    bool isError = false,
  }) {
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
  bool get wantKeepAlive => true;

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Korábbi dokumentum sikeresen betöltve.'),
            duration: Duration(hours: 1),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          duration: Duration(hours: 1),
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
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        // A fókusz elvétele az aktuális mezőről
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Önéletrajz profil generálása')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileWidget(),
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
                      onPressed: _isGenerating ? null : _generateProfile,
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
      ),
    );
  }
}
