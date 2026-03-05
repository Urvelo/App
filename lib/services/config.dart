class AppConfig {
  const AppConfig._();

  static const transcriptApiKey = String.fromEnvironment('TRANSCRIPT_API_KEY');
  static const assemblyAiApiKey = String.fromEnvironment('ASSEMBLYAI_API_KEY');
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  static void validateTranscriptionProviders() {
    if (transcriptApiKey.isEmpty && assemblyAiApiKey.isEmpty) {
      throw StateError(
        'Missing transcription API key. Provide TRANSCRIPT_API_KEY or ASSEMBLYAI_API_KEY via --dart-define.',
      );
    }
  }
}
