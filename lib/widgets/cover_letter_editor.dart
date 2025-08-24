import 'package:flutter/material.dart';

class CoverLetterEditor extends StatefulWidget {
  final String coverLetter;
  final ValueChanged<String> onChanged;

  const CoverLetterEditor({
    super.key,
    required this.coverLetter,
    required this.onChanged,
  });

  @override
  State<CoverLetterEditor> createState() => _CoverLetterEditorState();
}

class _CoverLetterEditorState extends State<CoverLetterEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.coverLetter);
  }

  @override
  void didUpdateWidget(covariant CoverLetterEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coverLetter != oldWidget.coverLetter) {
      _controller.text = widget.coverLetter;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              'MOTIVÁCIÓS LEVÉL',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextFormField(
              controller: _controller,
              maxLines: 20,
              decoration: const InputDecoration(
                labelText: 'Teljes levél szövege',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
