import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  try {
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    for (var model in data['models']) {
      print(model['name']);
    }
  } catch(e) {
    print(e);
  }
}
