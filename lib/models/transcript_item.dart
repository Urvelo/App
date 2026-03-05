class TranscriptItem {
  const TranscriptItem({
    required this.id,
    required this.title,
    required this.source,
    required this.sourceType,
    required this.rawText,
    required this.improvedText,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String source;
  final String sourceType;
  final String rawText;
  final String improvedText;
  final DateTime createdAt;

  String get displayText => improvedText.trim().isEmpty ? rawText : improvedText;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'sourceType': sourceType,
      'rawText': rawText,
      'improvedText': improvedText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TranscriptItem.fromJson(Map<String, dynamic> json) {
    return TranscriptItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Nimeton',
      source: json['source'] as String? ?? '',
      sourceType: json['sourceType'] as String? ?? 'url',
      rawText: json['rawText'] as String? ?? '',
      improvedText: json['improvedText'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
