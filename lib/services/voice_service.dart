import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;

  // Initialize speech recognition
  Future<void> initSpeech() async {
    try {
      var status = await Permission.microphone.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.microphone.request();
        if (status.isPermanentlyDenied) {
          debugPrint('Microphone permission permanently denied. Please enable it in app settings.');
          await openAppSettings();
          return;
        }
        if (status.isDenied) {
          debugPrint('Microphone permission denied');
          return;
        }
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) => debugPrint('Error initializing speech: $error'),
      );
      if (!_speechEnabled) {
        debugPrint('Failed to initialize speech recognition. Please check if the device supports speech recognition.');
      }
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
    }
  }

  // Start listening to voice input
  Future<void> startListening(Function(String) onResult) async {
    try {
      if (!_speechEnabled) {
        await initSpeech();
        // Double-check initialization was successful
        if (!_speechEnabled) {
          debugPrint('Speech recognition initialization failed');
          return;
        }
      }

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        localeId: 'pt-BR',
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
    }
  }

  // Stop listening to voice input
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Check if speech recognition is available
  bool get isSpeechEnabled => _speechEnabled;

  // Speak text
  Future<void> speak(String text) async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.speak(text);
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Describe ticket data
  Future<void> describeTicketData(Map<String, dynamic> metrics) async {
    String description = 'Resumo dos tickets: ';
    description += 'Total de ${metrics["totalTickets"]} tickets. ';

    if (metrics["analistaCount"] != null) {
      String topAnalista = "";
      int maxCount = 0;
      metrics["analistaCount"].forEach((analista, count) {
        if (count > maxCount) {
          maxCount = count;
          topAnalista = analista;
        }
      });
      description += 'O analista com mais tickets é $topAnalista com $maxCount tickets. ';
    }

    await speak(description);
  }
}
