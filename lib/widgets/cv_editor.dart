import 'package:flutter/material.dart';
import '../models/oneletrajz_adatok.dart'; // Relatív import javítva

class CvEditor extends StatefulWidget {
  final OneletrajzAdatok oneletrajz;
  final ValueChanged<OneletrajzAdatok> onChanged;

  const CvEditor({
    super.key,
    required this.oneletrajz,
    required this.onChanged,
  });

  @override
  State<CvEditor> createState() => _CvEditorState();
}

class _CvEditorState extends State<CvEditor> {
  late OneletrajzAdatok _localOneletrajz;

  @override
  void initState() {
    super.initState();
    _localOneletrajz = widget.oneletrajz;
  }

  @override
  void didUpdateWidget(covariant CvEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.oneletrajz != oldWidget.oneletrajz) {
      _localOneletrajz = widget.oneletrajz;
    }
  }

  void _updateAndNotify() {
    widget.onChanged(_localOneletrajz);
  }

  /*void _removeExperience(Experience experience) {
    final updatedList = List.of(_localOneletrajz.tapasztalatok);
    updatedList.remove(experience);
    setState(() {
      _localOneletrajz = _localOneletrajz.copyWith(tapasztalatok: updatedList);
    });
    _updateAndNotify();
  }

  void _removeEducation(int index) {
    final updatedList = List.of(_localOneletrajz.vegzettsegek);
    updatedList;
    updatedList.removeAt(index);
    setState(() {
      _localOneletrajz = _localOneletrajz.copyWith(vegzettsegek: updatedList);
    });
    _updateAndNotify();
  }

  void _removeSkill(String skill) {
    final updatedList = List.of(_localOneletrajz.kepessegek);
    updatedList.remove(skill);
    setState(() {
      _localOneletrajz = _localOneletrajz.copyWith(kepessegek: updatedList);
    });
    _updateAndNotify();
  }*/

  Widget _buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged, {
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          //color: _selectedColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Személyes adatok'),
          _buildTextField('Teljes név', _localOneletrajz.teljesnev, (value) {
            _localOneletrajz = _localOneletrajz.copyWith(teljesnev: value);
            _updateAndNotify();
          }),
          _buildTextField('Email', _localOneletrajz.email, (value) {
            _localOneletrajz = _localOneletrajz.copyWith(email: value);
            _updateAndNotify();
          }),
          _buildTextField('Telefonszám', _localOneletrajz.telefonszam, (value) {
            _localOneletrajz = _localOneletrajz.copyWith(telefonszam: value);
            _updateAndNotify();
          }),
          _buildTextField('Lakhely (város)', _localOneletrajz.lakcim, (value) {
            _localOneletrajz = _localOneletrajz.copyWith(lakcim: value);
            _updateAndNotify();
          }),
          const SizedBox(height: 20),
          _buildSectionHeader('Szakmai tapasztalatok'),
          ..._localOneletrajz.tapasztalatok.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;

            return Padding(
              key: ValueKey('experience_$index'),
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField('Beosztás', exp.beosztas, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.tapasztalatok,
                          );
                          updatedList[index] = exp.copyWith(beosztas: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            tapasztalatok: updatedList,
                          );
                          _updateAndNotify();
                        }),
                        _buildTextField('Cégnév', exp.cegnev, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.tapasztalatok,
                          );
                          updatedList[index] = exp.copyWith(cegnev: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            tapasztalatok: updatedList,
                          );
                          _updateAndNotify();
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'Kezdő dátum',
                                exp.kezdodatum,
                                (value) {
                                  final updatedList = List.of(
                                    _localOneletrajz.tapasztalatok,
                                  );
                                  updatedList[index] = exp.copyWith(
                                    kezdodatum: value,
                                  );
                                  _localOneletrajz = _localOneletrajz.copyWith(
                                    tapasztalatok: updatedList,
                                  );
                                  _updateAndNotify();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                'Záró dátum',
                                exp.zarodatum,
                                (value) {
                                  final updatedList = List.of(
                                    _localOneletrajz.tapasztalatok,
                                  );
                                  updatedList[index] = exp.copyWith(
                                    zarodatum: value,
                                  );
                                  _localOneletrajz = _localOneletrajz.copyWith(
                                    tapasztalatok: updatedList,
                                  );
                                  _updateAndNotify();
                                },
                              ),
                            ),
                          ],
                        ),
                        _buildTextField('Leírás', exp.leiras, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.tapasztalatok,
                          );
                          updatedList[index] = exp.copyWith(leiras: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            tapasztalatok: updatedList,
                          );
                          _updateAndNotify();
                        }, maxLines: 3),
                      ],
                    ),
                  ),
                  /*IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExperience(exp),
                  ),*/
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildSectionHeader('Tanulmányok'),
          ..._localOneletrajz.vegzettsegek.asMap().entries.map((entry) {
            final index = entry.key;
            final edu = entry.value;

            return Padding(
              key: ValueKey('education_$index'),
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField('Végzettség', edu.vegzettseg, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.vegzettsegek,
                          );
                          updatedList[index] = edu.copyWith(vegzettseg: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            vegzettsegek: updatedList,
                          );
                          _updateAndNotify();
                        }),
                        _buildTextField('Intézmény', edu.intezmeny, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.vegzettsegek,
                          );
                          updatedList[index] = edu.copyWith(intezmeny: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            vegzettsegek: updatedList,
                          );
                          _updateAndNotify();
                        }),
                        _buildTextField('Záró dátum', edu.zarodatum, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.vegzettsegek,
                          );
                          updatedList[index] = edu.copyWith(zarodatum: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            vegzettsegek: updatedList,
                          );
                          _updateAndNotify();
                        }),
                        _buildTextField('Leírás', edu.leiras, (value) {
                          final updatedList = List.of(
                            _localOneletrajz.vegzettsegek,
                          );
                          updatedList[index] = edu.copyWith(leiras: value);
                          _localOneletrajz = _localOneletrajz.copyWith(
                            vegzettsegek: updatedList,
                          );
                          _updateAndNotify();
                        }, maxLines: 3),
                      ],
                    ),
                  ),
                  /*IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEducation(index),
                  ),*/
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildSectionHeader('Képességek'),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _localOneletrajz.kepessegek.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;

              return Chip(
                key: ValueKey('skill_$index'),
                label: IntrinsicWidth(
                  child: TextFormField(
                    initialValue: skill,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final updatedList = List.of(_localOneletrajz.kepessegek);
                      updatedList[index] = value;
                      _localOneletrajz = _localOneletrajz.copyWith(
                        kepessegek: updatedList,
                      );
                      _updateAndNotify();
                    },
                  ),
                ),
                /*onDeleted: () => _removeSkill(skill),*/
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
