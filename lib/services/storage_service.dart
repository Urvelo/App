import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/transcript_item.dart';

class StorageService {
  const StorageService();

  Future<File> _getStoreFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/transcripts.json');
  }

  Future<List<TranscriptItem>> loadItems() async {
    final file = await _getStoreFile();
    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }

    final raw = jsonDecode(content) as List<dynamic>;
    return raw
        .map((e) => TranscriptItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveItems(List<TranscriptItem> items) async {
    final file = await _getStoreFile();
    final payload = jsonEncode(items.map((e) => e.toJson()).toList());
    await file.writeAsString(payload, flush: true);
  }
}
