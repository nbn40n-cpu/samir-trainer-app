import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _recognizedText = '';
  String _responseText = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  _initTts() async {
    await _tts.setLanguage("ar");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
  }

  Future<void> _speak(String text) async {
    setState(() => _responseText = text);
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (!available) {
      _speak("الميكروفون غير متاح");
      return;
    }
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _isListening = false;
        });
        _processCommand(_recognizedText);
      },
      listenOptions: SpeechListenOptions(
        localeId: "ar_SA",
        listenFor: const Duration(seconds: 5),
      ),
    );
  }

  void _processCommand(String command) {
    // مثال بسيط – يمكنك تعديل المنطق حسب ما تريد
    String response = "لم أفهم الأمر";
    if (command.contains("مرحباً")) response = "أهلاً بك";
    else if (command.contains("تقرير")) response = "جارٍ فتح التقارير";
    else if (command.contains("سعر")) response = "يمكنك تعديل الأسعار من القائمة";
    _speak(response);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_recognizedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("أنتَ قلت: $_recognizedText", style: const TextStyle(fontSize: 18)),
              ),
            if (_responseText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("المساعد: $_responseText", style: const TextStyle(fontSize: 18)),
              ),
            ElevatedButton.icon(
              onPressed: _startListening,
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 40),
              label: Text(_isListening ? "جاري الاستماع..." : "اضغط لتتحدث"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}