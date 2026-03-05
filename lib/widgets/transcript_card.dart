import 'package:flutter/material.dart';

import '../models/transcript_item.dart';

class TranscriptCard extends StatelessWidget {
  const TranscriptCard({
    super.key,
    required this.item,
    required this.onRead,
    required this.onPdf,
    required this.onDelete,
  });

  final TranscriptItem item;
  final VoidCallback onRead;
  final VoidCallback onPdf;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '${item.sourceType.toUpperCase()} - ${item.createdAt.toLocal()}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              item.displayText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: onRead,
                  child: const Text('Lukutila'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: onPdf,
                  child: const Text('PDF'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
