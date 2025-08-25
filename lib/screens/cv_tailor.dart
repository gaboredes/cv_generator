import 'package:flutter/material.dart';
import 'package:cv_generator/services/gemini_service.dart';
import 'package:cv_generator/screens/document_viewer_page.dart';

// Ez az oldal felelős az álláshirdetés bekéréséért és a Gemini API hívásáért.
class CvTailorScreen extends StatefulWidget {
  const CvTailorScreen({super.key});

  @override
  State<CvTailorScreen> createState() => _CvTailorScreenState();
}

class _CvTailorScreenState extends State<CvTailorScreen> {
  final _jobAdController = TextEditingController();
  bool isLoading = false;
  String? _errorMessage;

  // Ez a metódus hívja meg a Gemini szolgáltatást a dokumentumok generálásához.
  Future<void> _generateDocuments() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await GeminiService.generateDocuments(
        jobAd: _jobAdController.text,
      );
      // Sikeres generálás után átnavigálunk az új, szerkesztő oldalra
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerPage(documents: documents),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _jobAdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // A fókusz elvétele az aktuális mezőről
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('CV Generálás')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _jobAdController,
                maxLines: 30,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Illeszd be az álláshirdetés szövegét',
                  hintText: 'Pl. "Senior Flutter fejlesztőt keresünk, ..."',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _generateDocuments,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Generálás'),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  'Hiba: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
