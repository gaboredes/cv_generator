import 'package:flutter/material.dart';
import 'package:cv_generator/services/key_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GeminiKeyScreen extends StatefulWidget {
  const GeminiKeyScreen({super.key});

  @override
  State<GeminiKeyScreen> createState() => _GeminiKeyScreenState();
}

class _GeminiKeyScreenState extends State<GeminiKeyScreen> {
  bool _isObscured = true;
  final TextEditingController _controller = TextEditingController();
  final KeyStorageService _keyStorageService = KeyStorageService();
  bool _isLoading = true;

  // Az útmutatóban használt URL a Gemini API kulcs igényléséhez
  final Uri _geminiApiKeyUrl = Uri.parse(
    'https://aistudio.google.com/app/apikey',
  );

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  // Betölti a kulcsot a secure storage-ból
  Future<void> _loadKey() async {
    try {
      final String? key = await _keyStorageService.readKey();
      if (key != null) {
        _controller.text = key;
      }
    } catch (e) {
      _showSnackBar('Hiba történt a kulcs betöltésekor.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mentés gomb funkciója
  Future<void> _saveKey() async {
    final String key = _controller.text;
    if (key.isNotEmpty) {
      await _keyStorageService.writeKey(key);
      _showSnackBar('Kulcs mentve!');
    } else {
      _showSnackBar('A kulcs nem lehet üres.');
    }
  }

  // Törlés gomb funkciója
  Future<void> _deleteKey() async {
    _controller.clear();
    await _keyStorageService.deleteKey();
    _showSnackBar('Kulcs törölve!');
  }

  // Megnyitja a Google AI Studio weboldalát
  Future<void> _launchUrl() async {
    if (!await launchUrl(
      _geminiApiKeyUrl,
      mode: LaunchMode.externalApplication,
    )) {
      _showSnackBar('Hiba történt az oldal megnyitása közben.');
    }
  }

  // Visszajelzést adó snackbar
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // A fókusz elvétele az aktuális mezőről
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Gemini API kulcs kezelése')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        obscureText: _isObscured,
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Másold be ide a Gemini kulcsodat',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _saveKey,
                            child: const Text('Mentés'),
                          ),
                          OutlinedButton(
                            onPressed: _deleteKey,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Törlés'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hogyan igényelj ingyenes Gemini API kulcsot?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'A CV-generátor használatához szükséged lesz egy Gemini API kulcsra, amelyet könnyedén igényelhetsz. Kövesd az alábbi lépéseket:',
                              ),
                              const SizedBox(height: 16),
                              _buildStep(
                                '1. lépés:',
                                'Kattints az alábbi gombra, vagy látogass el a Google AI Studio weboldalára.',
                              ),
                              const SizedBox(height: 8),
                              _buildStep(
                                '2. lépés:',
                                'Jelentkezz be a Google-fiókoddal.',
                              ),
                              const SizedBox(height: 8),
                              _buildStep(
                                '3. lépés:',
                                'Hozd létre az új API kulcsodat. A kulcs generálása ingyenes, és azonnal megkapod.',
                              ),
                              const SizedBox(height: 8),
                              _buildStep(
                                '4. lépés:',
                                'Másold ki a kulcsot, és illeszd be a fenti mezőbe.',
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: _launchUrl,
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Gemini kulcs igénylése'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Segítő widget a lépések formázásához
  Widget _buildStep(String title, String description) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' $description'),
        ],
      ),
    );
  }
}
