import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:doc_text_extractor/doc_text_extractor.dart';
import 'package:flutter/services.dart';

class FileService {
  final TextExtractor _textExtractor = TextExtractor();

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
      final Directory cvGeneratorDirectory = await _getDocumentsDirectory();
      if (!await cvGeneratorDirectory.exists()) {
        await cvGeneratorDirectory.create(recursive: true);
      }

      final file = File('${cvGeneratorDirectory.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      throw Exception('Hiba a file mentése közben: $e');
    }
  }

  Future<String?> savePdfDocument(Uint8List content, String fileName) async {
    try {
      final Directory cvGeneratorDirectory = await _getDocumentsDirectory();
      if (!await cvGeneratorDirectory.exists()) {
        await cvGeneratorDirectory.create(recursive: true);
      }
      final filePath = '${cvGeneratorDirectory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(content);
      bool? success = await copyFileIntoDownloadFolder(
        filePath,
        basenameWithoutExtension(filePath),
        desiredExtension: extension(filePath),
      );
      if (success != true) {
        throw Exception("File mentése nem sikerült a Letöltések mappába.");
      }

      return file.path;
    } catch (e) {
      throw Exception('Hiba a file mentése közben: $e');
    }
  }

  Future<String?> loadSavedDocument() async {
    try {
      final directory = await _getDocumentsDirectory();
      final filePath = '${directory.path}/generalt_oneletrajz.txt';
      final file = File(filePath);

      if (await file.exists()) {
        return await file.readAsString();
      }

      return null;
    } catch (e) {
      throw Exception('Hiba a file betöltése közben: $e');
    }
  }

  static Future<int> openDocumentDirectory() async {
    bool success = await openDownloadFolder();
    if (!success) {
      throw Exception("Letöltési mappa megnyitása nem sikerült.");
    }
    return 1;
  }

  static Future<Directory> _getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  void openDownloadContentFolder() async {
    bool success = await openDownloadFolder();
    if (!success) {
      throw Exception("Letöltési mappa megnyitása nem sikerült.");
    }
  }

  Future<String?> setProfilePicture() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        final pickedFile = result.files.first;
        final File file = File(pickedFile.path!);
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final String appDocumentsPath = appDocumentsDir.path;
        final String newPath = '$appDocumentsPath/onarckep.jpg';
        final File savedFile = await file.copy(newPath);
        return 'A fájl sikeresen elmentve a következő helyre: ${savedFile.path}';
      } catch (e) {
        return 'Hiba történt a fájl mentése során: $e';
      }
    } else {
      // A felhasználó nem választott ki fájlt.
      return 'Nem lett fájl kiválasztva.';
    }
  }

  Future<File?> getProfileImage() async {
    try {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      File image = File('${appDocumentsDir.path}/onarckep.jpg');
      return image;
    } catch (e) {
      return null;
    }
  }
}
