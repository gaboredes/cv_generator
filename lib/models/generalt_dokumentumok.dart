// cv_generator/models/generalt_dokumentumok.dart

import 'oneletrajz_adatok.dart';

class GeneraltDokumentumok {
  final OneletrajzAdatok oneletrajz;
  final String motivaciosLevel;

  const GeneraltDokumentumok({
    required this.oneletrajz,
    required this.motivaciosLevel,
  });

  // A JSON-ból való konvertáláshoz szükséges gyári konstruktor
  factory GeneraltDokumentumok.fromJson(Map<String, dynamic> json) {
    return GeneraltDokumentumok(
      oneletrajz: OneletrajzAdatok.fromJson(json['oneletrajz']),
      motivaciosLevel: json['motivaciosLevel'],
    );
  }

  // Segédfüggvény a JSON-ba való konvertáláshoz
  Map<String, dynamic> toJson() {
    return {
      'oneletrajz': oneletrajz.toJson(),
      'motivaciosLevel': motivaciosLevel,
    };
  }

  GeneraltDokumentumok copyWith({
    OneletrajzAdatok? oneletrajz,
    String? motivaciosLevel,
  }) {
    return GeneraltDokumentumok(
      oneletrajz: oneletrajz ?? this.oneletrajz,
      motivaciosLevel: motivaciosLevel ?? this.motivaciosLevel,
    );
  }
}
