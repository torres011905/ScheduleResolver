import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  // Siguraduhing valid ang API Key na ito
  final String _apiKey = 'AIzaSyDXOgwoYx1qBCSZZeEaJr7ti7MPqoAf5a8';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // In-update sa gemini-2.5-flash base sa iyong request
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final taskJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt = '''
      You are an expert student scheduling assistant. Analyze these tasks provided in JSON: $taskJson
      
      Identify overlaps, prioritize based on urgency/importance, and suggest a better timeline.
      
      Provide exactly 4 sections of markdown text:
      ### Detected Conflicts
      ### Ranked Tasks
      ### Recommended Schedule
      ### Explanation
      
      Ensure the markdown is well-formatted. Do not include extra text outside of these headers.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        _currentAnalysis = _parseResponse(response.text!);
      } else {
        _errorMessage = 'Ang AI ay hindi nagbigay ng response.';
      }
    } catch (e) {
      _errorMessage = 'Failed: $e';
      print('AI Error: $e'); // Para makita mo ang error sa console
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "No conflicts detected.",
        ranked = "No data.",
        recommended = "No schedule generated.",
        explanation = "No explanation provided.";

    // Hatiin ang text base sa headers
    final sections = fullText.split('###');

    for (var section in sections) {
      final text = section.trim();
      if (text.toLowerCase().startsWith('detected conflicts')) {
        conflicts = text.replaceFirst(RegExp('detected conflicts', caseSensitive: false), '').trim();
      } else if (text.toLowerCase().startsWith('ranked tasks')) {
        ranked = text.replaceFirst(RegExp('ranked tasks', caseSensitive: false), '').trim();
      } else if (text.toLowerCase().startsWith('recommended schedule')) {
        recommended = text.replaceFirst(RegExp('recommended schedule', caseSensitive: false), '').trim();
      } else if (text.toLowerCase().startsWith('explanation')) {
        explanation = text.replaceFirst(RegExp('explanation', caseSensitive: false), '').trim();
      }
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: ranked,
      recommendedSchedule: recommended,
      explanation: explanation,
    );
  }
}