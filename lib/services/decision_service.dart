import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/decision_result.dart';


class DecisionService extends ChangeNotifier {

  DecisionResult? currentResult;
  bool isLoading = false;
  String? errorMessage;

  final String _apiKey = 'AIzaSyB3yxrLg4B7CgUZfBjMpiM5WJtMzINnCOs';


  Future<void> analyzeDecision(String decisionPrompt) async {

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final prompt = '''
        
        You are an expert decision-making assistant. The user is trying to make a decision: "$decisionPrompt".
        Please provide exactly 3 sections of markdown:
        1. ### Pros and Cons
        Provide a detailed pros and cons list/
        
        2. ### Comparison table
        If applicable, provide a comparison table comparing the main alternatives
        
        3. ### SWOT Analysis
        Provide a SWOT (Strengths, Weaknesses, Opportunities, Threats) analysis for the decision
        
        Ensure the markdown is well-formatted and easy to read.
        Do not include extra text outside of these headers.
        ''';

      final response = await model.generateContent([Content.text(prompt)]);
      currentResult = _parseResponse(response.text ?? '' , decisionPrompt);
    } catch (e) {
      errorMessage = 'Failed: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }

  }
  DecisionResult _parseResponse(String text, String decision) {
    final parts = text.split('###');
    return DecisionResult(
      decision: decision,
      prosAndCons: parts.length> 1 ? parts[1]: text,
      comparisonTable: parts.length> 2 ? parts[2]: "No Table",
      swotAnalysis: parts.length> 3 ? parts[3]: "No SWOT",
    );
  }
}