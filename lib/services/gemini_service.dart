import 'dart:convert';
import 'package:cv_generator/services/file_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cv_generator/models/generalt_dokumentumok.dart';
import 'package:cv_generator/models/oneletrajz_adatok.dart';
import 'package:cv_generator/services/key_storage_service.dart';

class GeminiService {
  static const String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent";
  static final KeyStorageService _keyStorage = KeyStorageService();

  /// Generates a structured CV object, a new CV summary, and a cover letter
  /// by extracting data from a raw text file and a job ad.
  ///
  /// This function reads the 'generalt_oneletrajz.txt' file from the
  /// application's documents directory, sends its raw content and the
  /// job ad to the Gemini API, and expects a structured JSON response.
  static Future<GeneraltDokumentumok> generateDocuments({
    required String jobAd,
  }) async {
    final apiKey = await _keyStorage.readKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("Hiányzik a Gemini API kulcs a secure storage-ból!");
    }

    // A 'generalt_oneletrajz.txt' fájl beolvasása az alkalmazás dokumentumkönyvtárából
    String? baseCvContent;
    try {
      baseCvContent = await FileService().loadSavedDocument();
    } catch (e) {
      throw Exception(
        "Hiba a 'generalt_oneletrajz.txt' fájl beolvasásakor. Győződj meg róla, hogy a fájl létezik az alkalmazás dokumentumkönyvtárában.",
      );
    }

    // A prompt, amelyben utasítjuk az AI-t az adatok kinyerésére és generálására
    final prompt =
        """
      A következő nyers önéletrajz szöveg és álláshirdetés alapján végezd el a következő feladatokat:
      1. Strukturáld a nyers önéletrajz szövegben található adatokat egy JSON objektumba.
      3. Generálj egy motivációs levelet az álláshirdetéshez igazítva.
      Fokozottan ügyelj arra, hogy csak azt a végzettséget, képességet, munkatapasztalatot stb írd bele, ami a pozíció szempontjából releváns A munkatapasztalatok és tanulmányok leírását is úgy fogalmazd meg, hogy az álláshirdetés szempontjából releváns tartalom kerüljön csak bele. 
      Olyan dolgot ne írj le, ami nem szerepel egyátalán az önéletrajz szövegben, mert azzal hitelteleníted az önéletrajzot.
      A motívációs levélben ne írj a végzettségről és munkatapasztalatokról. Inkább emeld ki azt, miért szeretnél ott dolgozni, mi az ami szimpatikus a cégben. Mindezt az álláshirdetés alapján, ne pedig alaptalanul.
      A képességeknél soft skilleket is sorolj fel.
      Ahol az elvárt végzettségi szint alacsonyabb, mint felsőoktatás, ott ne írj bele egyetemet sem fúiskolát, mert túlképzettnek minősíthetik a munkavállalót.
      Ahol le van írva, hogy melyik nyelven írj írj ott írd azon a myelven a motívációs levelet és a Cv-t is. Más esetben hagyatkozz az álláshirdetés és a hirdetőoldal nyelvére.
      Őrizd meg a szöveg alapján a kommunikációs stílusát, szóhasználatát a jelentkezőnek.
      Az önéletrajzban kerek mondatok helyett használj vázlatpontokat. Max 5 vázlatpont legyen minden tapasztalatnál.
      egyes szám első személyben fogalmazz, mintha magadról írnád és ne fényezd túl a pályázót.
      
      A válaszodnak egyetlen JSON objektumnak kell lennie, a következő pontosan meghatározott struktúrával:
      
      ```json
      {
        "motivacios_level": "string",
        "kinyert_adatok": {
          "allasEsCegFileNevSzeruen": "string",
          "teljesnev": "string",
          "email": "string",
          "telefonszam": "string",
          "lakcim": "string",
          "osszegzes": "string",
          "kepessegek": ["string", "string"],
          "tapasztalatok": [{
            "beosztas": "string",
            "cegnev": "string",
            "kezdodatum": "string",
            "zarodatum": "string",
            "leiras": "string"
          }],
          "vegzettsegek": [{
            "vegzettseg": "string",
            "intezmeny": "string",
            "zarodatum": "string",
            "leiras": "string"
          }]
        }
      }
      ```
      
      ---
      Nyers önéletrajz dokumentum tartalma:
      $baseCvContent
      ---

      Álláshirdetés:
      $jobAd
    """;

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt},
          ],
        },
      ],
      "generationConfig": {"responseMimeType": "application/json"},
    });

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$apiKey'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedText =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        final parsedGeneratedContent = jsonDecode(generatedText);

        // Adatok kinyerése az API válaszából
        final extractedCvData = OneletrajzAdatok.fromJson(
          parsedGeneratedContent['kinyert_adatok'],
        );
        final newSummary = parsedGeneratedContent['oneletrajz_osszegzes'];
        final newCoverLetter = parsedGeneratedContent['motivacios_level'];

        // A végleges CV objektum létrehozása az új összefoglalóval
        final finalCvData = extractedCvData.copyWith(osszegzes: newSummary);

        return GeneraltDokumentumok(
          oneletrajz: finalCvData,
          motivaciosLevel: newCoverLetter,
        );
      } else {
        throw Exception(
          'Hiba a Gemini API hívásakor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error in Gemini API call: $e');
      throw Exception('Hiba történt a kommunikáció során a Gemini API-val.');
    }
  }
}
