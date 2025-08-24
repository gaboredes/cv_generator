import 'package:flutter/material.dart';
import 'package:cv_generator/models/oneletrajz_adatok.dart';

/// Ez az osztály tartalmazza a teljes önéletrajz adatokat és a választott színt,
/// ami a PDF generálásához szükséges.
class SzinesAdatok {
  final OneletrajzAdatok oneletrajz;
  final Color szin;

  SzinesAdatok({required this.oneletrajz, required this.szin});
}
