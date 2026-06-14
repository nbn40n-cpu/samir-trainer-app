import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'app_theme.dart';
import 'reports.dart';
import 'prices_screen.dart';
import 'dashboard_screen.dart';

class SmartAssistantWidget extends StatefulWidget {
  const SmartAssistantWidget({super.key});

  @override
  State<SmartAssistantWidget> createState() => _SmartAssistantWidgetState();
}

class _SmartAssistantWidgetState extends State<SmartAssistantWidget> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _lastCommand = "";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ar");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    if (_isListening) return;
    bool available = await _speech.initialize();
    if (!available) {
      _speak("الميكروفون غير متاح");
      return;
    }
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) async {
        String command = result.recognizedWords;
        setState(() => _isListening = false);
        await _processCommand(command);
      },
      listenOptions: SpeechListenOptions(
        localeId: "ar_SA",
        listenFor: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _processCommand(String command) async {
    String lower = command.toLowerCase();
    setState(() => _lastCommand = command);

    if (lower.contains("تقرير")) {
      await _speak("جاري فتح التقارير");
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsMenuScreen()));
    } else if (lower.contains("ادخال") || lower.contains("اليومي")) {
      await _speak("جاري فتح الادخال اليومي");
      Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else if (lower.contains("سعر")) {
      await _speak("جاري فتح الأسعار");
      Navigator.push(context, MaterialPageRoute(builder: (_) => PricesScreen()));
    } else if (lower.contains("مرحباً")) {
      await _speak("أهلاً بك، كيف يمكنني مساعدتك؟");
    } else {
      await _speak("عذراً، لم أفهم الأمر: $command");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 32, color: AppTheme.purple),
            onPressed: _startListening,
          ),
          Expanded(
            child: Text(
              _lastCommand.isEmpty ? "انقر على الميكروفون وتحدث" : "آخر أمر: $_lastCommand",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}