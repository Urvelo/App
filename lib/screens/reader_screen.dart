import 'package:flutter/material.dart';

import '../models/transcript_item.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.item});

  final TranscriptItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            item.displayText,
            style: const TextStyle(fontSize: 17, height: 1.55),
          ),
        ),
      ),
    );
  }
}
