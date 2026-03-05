import 'package:flutter/material.dart';

import '../models/transcript_item.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import '../widgets/transcript_card.dart';
import 'reader_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = const StorageService();
  final _pdf = const PdfService();
  bool _loading = true;
  List<TranscriptItem> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });

    final data = await _storage.loadItems();
    if (!mounted) {
      return;
    }

    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    final updated = _items.where((e) => e.id != id).toList();
    await _storage.saveItems(updated);
    await _refresh();
  }

  void _openReader(TranscriptItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReaderScreen(item: item),
      ),
    );
  }

  Future<void> _pdfShare(TranscriptItem item) async {
    try {
      await _pdf.printOrShare(item);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF-virhe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tallennetut transkriptiot'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Text('Ei tallennettuja transkriptioita viela.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return TranscriptCard(
                      item: item,
                      onRead: () => _openReader(item),
                      onPdf: () => _pdfShare(item),
                      onDelete: () => _delete(item.id),
                    );
                  },
                ),
    );
  }
}
