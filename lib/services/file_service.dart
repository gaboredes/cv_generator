import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:doc_text_extractor/doc_text_extractor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';

class FileService {
  final TextExtractor _textExtractor = TextExtractor();
  // A MethodChannel a Dart és a natív kód közötti kommunikációs csatorna
  static const MethodChannel _channel = MethodChannel(
    'com.example.cv_generator/file_manager',
  );

  Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      return result?.files.single;
    } catch (e) {
      // It's good practice to throw a more specific exception or return null on error.
      return null;
    }
  }

  Future<String> readContentFromDocument(PlatformFile? file) async {
    if (file == null || file.path == null) {
      throw Exception("No file was selected.");
    }

    final String extension = file.extension?.toLowerCase() ?? '';

    if (!['pdf', 'doc', 'docx'].contains(extension)) {
      throw Exception(
        "Unsupported file format. Please choose a PDF, DOC, or DOCX file.",
      );
    }

    try {
      final result = await _textExtractor.extractText(file.path!, isUrl: false);
      return result.text;
    } catch (e) {
      throw Exception(
        "An error occurred while processing the file. It may be corrupted or in an unsupported format. Details: $e",
      );
    }
  }

  Future<String?> saveFile(String content, String fileName) async {
    try {
      final Directory directory = await _getDocumentsDirectory();

      final cvGeneratorDirectory = Directory('${directory.path}/CV Generator');
      if (!await cvGeneratorDirectory.exists()) {
        await cvGeneratorDirectory.create(recursive: true);
      }

      final file = File('${cvGeneratorDirectory.path}/$fileName');
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      throw Exception('Error saving file: $e');
    }
  }

  static Future<String?> savePdfDocument(
    Uint8List content,
    String fileName,
  ) async {
    try {
      final Directory directory = await _getDocumentsDirectory();

      final cvGeneratorDirectory = Directory('${directory.path}/CV Generator');
      if (!await cvGeneratorDirectory.exists()) {
        await cvGeneratorDirectory.create(recursive: true);
      }

      final file = File('${cvGeneratorDirectory.path}/$fileName');
      await file.writeAsBytes(content);

      return file.path;
    } catch (e) {
      throw Exception('Error saving file: $e');
    }
  }

  Future<String?> loadSavedDocument() async {
    try {
      final directory = await _getDocumentsDirectory();
      final filePath = '${directory.path}/CV Generator/generalt_oneletrajz.txt';
      final file = File(filePath);

      if (await file.exists()) {
        return await file.readAsString();
      }

      return null;
    } catch (e) {
      throw Exception('Hiba a file betöltése közben: $e');
    }
  }

  static Future<String?> openDocumentDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Natív Kotlin kód hívása a mappanevet tartalmazó argumentummal
        final String? result = await _channel.invokeMethod('openFileManager', {
          'directoryName': 'CV Generator',
        });
        return result;
      } else {
        // Windows-on és más platformokon megmaradhat a korábbi logika
        final directory = await getApplicationDocumentsDirectory();
        final cvGeneratorDirectory = Directory(
          '${directory.path}/CV Generator',
        );
        if (!await cvGeneratorDirectory.exists()) {
          await cvGeneratorDirectory.create(recursive: true);
        }
        final result = await OpenFilex.open(cvGeneratorDirectory.path);
        return result.message;
      }
    } on PlatformException catch (e) {
      return "Hiba a natív kódból: ${e.message}";
    } catch (e) {
      return "Hiba a mappa megnyitásakor: $e";
    }
  }

  static Future<Directory> _getDocumentsDirectory() async {
    if (Platform.isAndroid) {
      // A getExternalStorageDirectory() elavult, de a kérésnek megfelelően ezt a hívást meghagytuk a többi metódus számára.
      // Ezt a függvényt a natív réteg váltja ki, ami sokkal megbízhatóbb.
      var status = await Permission.storage.request();
      if (status.isDenied) {
        throw Exception("Hozzáférés mappához megtagadva.");
      }
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Nyilvános dokumentum mappa elérése sikertelen.");
      }
      return directory;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
}
