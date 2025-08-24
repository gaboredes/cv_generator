// cv_generator/models/oneletrajz_adatok.dart

class OneletrajzAdatok {
  final String allasEsCegFileNevSzeruen;
  final String teljesnev;
  final String szakmaiCim;
  final String email;
  final String telefonszam;
  final String lakcim;
  String osszegzes;
  final List<String> kepessegek;
  final List<Experience> tapasztalatok;
  final List<Education> vegzettsegek;

  OneletrajzAdatok({
    required this.allasEsCegFileNevSzeruen,
    required this.teljesnev,
    required this.szakmaiCim,
    required this.email,
    required this.telefonszam,
    required this.lakcim,
    required this.osszegzes,
    required this.kepessegek,
    required this.tapasztalatok,
    required this.vegzettsegek,
  });

  // A JSON-ból való konvertáláshoz szükséges gyári konstruktor
  factory OneletrajzAdatok.fromJson(Map<String, dynamic> json) {
    var experienceList = json['tapasztalatok'] as List;
    var educationList = json['vegzettsegek'] as List;

    List<Experience> experiences = experienceList
        .map((e) => Experience.fromJson(e))
        .toList();
    List<Education> education = educationList
        .map((e) => Education.fromJson(e))
        .toList();
    List<String> skills = (json['kepessegek'] as List)
        .map((e) => e.toString())
        .toList();

    return OneletrajzAdatok(
      allasEsCegFileNevSzeruen: json['allasEsCegFileNevSzeruen'],
      teljesnev: json['teljesnev'],
      szakmaiCim: json['szakmaiCim'],
      email: json['email'],
      telefonszam: json['telefonszam'],
      lakcim: json['lakcim'],
      osszegzes: json['osszegzes'],
      kepessegek: skills,
      tapasztalatok: experiences,
      vegzettsegek: education,
    );
  }

  // Segédfüggvény a JSON-ba való konvertáláshoz
  Map<String, dynamic> toJson() {
    return {
      'teljesnev': teljesnev,
      'szakmaiCim': szakmaiCim,
      'email': email,
      'telefonszam': telefonszam,
      'lakcim': lakcim,
      'osszegzes': osszegzes,
      'kepessegek': kepessegek,
      'tapasztalatok': tapasztalatok.map((e) => e.toJson()).toList(),
      'vegzettsegek': vegzettsegek.map((e) => e.toJson()).toList(),
    };
  }

  OneletrajzAdatok copyWith({
    String? teljesnev,
    String? szakmaiCim,
    String? email,
    String? telefonszam,
    String? lakcim,
    String? osszegzes,
    List<String>? kepessegek,
    List<Experience>? tapasztalatok,
    List<Education>? vegzettsegek,
  }) {
    return OneletrajzAdatok(
      allasEsCegFileNevSzeruen: allasEsCegFileNevSzeruen,
      teljesnev: teljesnev ?? this.teljesnev,
      szakmaiCim: szakmaiCim ?? this.szakmaiCim,
      email: email ?? this.email,
      telefonszam: telefonszam ?? this.telefonszam,
      lakcim: lakcim ?? this.lakcim,
      osszegzes: osszegzes ?? this.osszegzes,
      kepessegek: kepessegek ?? this.kepessegek,
      tapasztalatok: tapasztalatok ?? this.tapasztalatok,
      vegzettsegek: vegzettsegek ?? this.vegzettsegek,
    );
  }
}

class Experience {
  final String beosztas;
  final String cegnev;
  final String kezdodatum;
  final String zarodatum;
  final String leiras;

  Experience({
    required this.beosztas,
    required this.cegnev,
    required this.kezdodatum,
    required this.zarodatum,
    required this.leiras,
  });

  // A JSON-ból való konvertáláshoz szükséges gyári konstruktor
  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      beosztas: json['beosztas'],
      cegnev: json['cegnev'],
      kezdodatum: json['kezdodatum'],
      zarodatum: json['zarodatum'],
      leiras: json['leiras'],
    );
  }

  // Segédfüggvény a JSON-ba való konvertáláshoz
  Map<String, dynamic> toJson() {
    return {
      'beosztas': beosztas,
      'cegnev': cegnev,
      'kezdodatum': kezdodatum,
      'zarodatum': zarodatum,
      'leiras': leiras,
    };
  }

  Experience copyWith({
    String? beosztas,
    String? cegnev,
    String? kezdodatum,
    String? zarodatum,
    String? leiras,
  }) {
    return Experience(
      beosztas: beosztas ?? this.beosztas,
      cegnev: cegnev ?? this.cegnev,
      kezdodatum: kezdodatum ?? this.kezdodatum,
      zarodatum: zarodatum ?? this.zarodatum,
      leiras: leiras ?? this.leiras,
    );
  }
}

class Education {
  final String vegzettseg;
  final String intezmeny;
  final String zarodatum;
  final String leiras;

  Education({
    required this.vegzettseg,
    required this.intezmeny,
    required this.zarodatum,
    required this.leiras,
  });

  // A JSON-ból való konvertáláshoz szükséges gyári konstruktor
  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      vegzettseg: json['vegzettseg'],
      intezmeny: json['intezmeny'],
      zarodatum: json['zarodatum'],
      leiras: json['leiras'],
    );
  }

  // Segédfüggvény a JSON-ba való konvertáláshoz
  Map<String, dynamic> toJson() {
    return {
      'vegzettseg': vegzettseg,
      'intezmeny': intezmeny,
      'zarodatum': zarodatum,
      'leiras': leiras,
    };
  }

  Education copyWith({
    String? vegzettseg,
    String? intezmeny,
    String? zarodatum,
    String? leiras,
  }) {
    return Education(
      vegzettseg: vegzettseg ?? this.vegzettseg,
      intezmeny: intezmeny ?? this.intezmeny,
      zarodatum: zarodatum ?? this.zarodatum,
      leiras: leiras ?? this.leiras,
    );
  }
}
