import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/transcript_item.dart';
import '../services/assemblyai_service.dart';
import '../services/config.dart';
import '../services/openai_service.dart';
import '../services/storage_service.dart';
import '../services/transcriptapi_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _storage = const StorageService();

  String? _pickedPath;
  bool _busy = false;
  String _status = 'Valitse YouTube-linkki tai mediatiedosto.';

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'mp3',
        'm4a',
        'wav',
        'ogg',
        'flac',
        'aac',
        'mp4',
        'mov',
        'mkv',
        'webm',
      ],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _pickedPath = result.files.first.path;
      _status = 'Tiedosto valittu: ${result.files.first.name}';
    });
  }

  Future<void> _start() async {
    final rawUrl = _urlController.text.trim();
    final hasUrl = rawUrl.isNotEmpty;
    final hasFile = (_pickedPath ?? '').isNotEmpty;

    if (!hasUrl && !hasFile) {
      _show('Anna URL tai valitse tiedosto.');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Tarkistetaan API-avaimet...';
    });

    try {
      AppConfig.validateTranscriptionProviders();

      final sourceType = hasUrl ? 'url' : 'file';
      String rawText = '';

      final isYoutube = hasUrl && _isYoutube(rawUrl);

      if (isYoutube && AppConfig.transcriptApiKey.isNotEmpty) {
        setState(() {
          _status = 'Haetaan YouTube-transkriptio TranscriptAPI:sta...';
        });
        final transcriptApi =
            TranscriptApiService(apiKey: AppConfig.transcriptApiKey);
        rawText = await transcriptApi.getYoutubeTranscriptText(rawUrl);
      } else {
        if (AppConfig.assemblyAiApiKey.isEmpty) {
          throw StateError(
            'AssemblyAI API key puuttuu. Tiedostoille ja ei-YouTube URL:ille tarvitset ASSEMBLYAI_API_KEY.',
          );
        }

        final assembly = AssemblyAiService(apiKey: AppConfig.assemblyAiApiKey);
        String audioUrl = rawUrl;

        if (!hasUrl && hasFile) {
          setState(() {
            _status = 'Ladataan tiedosto transkriptiopalveluun...';
          });
          audioUrl = await assembly.uploadFile(_pickedPath!);
        }

        setState(() {
          _status = 'Kaynistetaan transkriptio...';
        });

        final transcriptId = await assembly.createTranscript(audioUrl);

        setState(() {
          _status = 'Transkriptoidaan (voi kestaa pitkissa tiedostoissa)...';
        });

        rawText = await assembly.waitForTranscriptText(transcriptId);
      }

      setState(() {
        _status = 'Parannetaan teksti AI:lla (jos avain on asetettu)...';
      });

      String improved = rawText;
      if (AppConfig.openAiApiKey.isNotEmpty) {
        final openAi = OpenAiService(apiKey: AppConfig.openAiApiKey);
        improved = await openAi.improveFinnishTranscript(rawText);
      }

      final now = DateTime.now();
      final generatedTitle = _titleController.text.trim().isEmpty
          ? 'Transkriptio ${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}'
          : _titleController.text.trim();

      final item = TranscriptItem(
        id: '${now.microsecondsSinceEpoch}_${Random().nextInt(9999)}',
        title: generatedTitle,
        source: hasUrl ? rawUrl : (_pickedPath ?? ''),
        sourceType: sourceType,
        rawText: rawText,
        improvedText: improved,
        createdAt: now,
      );

      final items = await _storage.loadItems();
      final updated = [item, ...items];
      await _storage.saveItems(updated);

      setState(() {
        _busy = false;
        _status = 'Valmis. Tallennettu listaan.';
      });

      _show('Transkriptio valmis ja tallennettu.');
    } catch (e) {
      setState(() {
        _busy = false;
        _status = 'Virhe: $e';
      });
      _show('Virhe: $e');
    }
  }

  bool _isYoutube(String value) {
    final lower = value.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(value.trim());
  }

  void _show(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transcript Pro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Syota YouTube-linkki tai valitse mediatiedosto. Sovellus transkriboi tekstin ja korjaa sen AI:lla.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Otsikko (valinnainen)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'YouTube/media URL',
              hintText: 'https://... ',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(_pickedPath == null
                ? 'Valitse tiedosto'
                : 'Tiedosto valittu'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Aloita transkriptio + AI-korjaus'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (_busy) const CircularProgressIndicator(strokeWidth: 2),
                  if (_busy) const SizedBox(width: 12),
                  Expanded(child: Text(_status)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vinkki: API-kulut riippuvat kayton maarasta (AssemblyAI + OpenAI).',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
