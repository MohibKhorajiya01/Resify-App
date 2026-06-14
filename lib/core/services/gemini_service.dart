import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  static Future<Map<String, dynamic>> generateResumeFromPrompt(String prompt) async {
    try {
      final String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

      final instructions = '''
You are an expert ATS-friendly resume writer. 
Based on the following user input, generate a highly professional, comprehensive, and detailed ATS-optimized resume.
The user wants a clean, highly professional, and structured ATS-optimized resume. Do NOT write giant paragraphs.
Keep the professional summary concise, maximum 1-2 short sentences.
For EACH experience role, create 3-4 sharp, impactful bullet points. Do NOT generate dense paragraphs for responsibilities.
Add 6-8 relevant industry skills. Organize everything cleanly category-wise.

The output MUST be a valid JSON object matching this exact structure:
{
  "title": "Professional Title (e.g., Senior Software Engineer)",
  "field": "General Field (e.g., IT & Tech)",
  "summary": "A concise, 1-2 sentence professional summary highlighting key achievements.",
  "skills": ["Skill 1", "Skill 2", "Skill 3", "Skill 4", "Skill 5", "Skill 6", "Skill 7", "Skill 8"],
  "experience": [
    {
      "role": "Job Title",
      "company": "Company Name",
      "startDate": "Month Year",
      "endDate": "Month Year or Present",
      "responsibilities": [
        "Action-oriented bullet point 1 with metrics if possible (Long and detailed)",
        "Action-oriented bullet point 2 (Long and detailed)",
        "Action-oriented bullet point 3",
        "Action-oriented bullet point 4"
      ]
    }
  ],
  "education": [
    {
      "degree": "Degree Name",
      "school": "University/School",
      "startDate": "Year",
      "endDate": "Year",
      "description": "Optional GPA, relevant coursework, or honors"
    }
  ],
  "projects": [
    {
      "name": "Project Name",
      "description": "Detailed description of what it does, the impact, and the technologies used.",
      "technologies": "Tech stack used",
      "link": "URL if any"
    }
  ],
  "atsScore": 92
}

If the user input is missing information (like dates, companies, or specific duties), INVENT plausible professional placeholders or elaborate extensively on the role they mentioned. Make the bullet points extremely impactful using action verbs and industry-standard keywords.
If the user input is complete gibberish, nonsense, or completely unrelated to a resume, and you absolutely cannot extract any professional context, return EXACTLY this JSON:
{"error": "bad_prompt"}

IMPORTANT INSTRUCTIONS:
1. For 'responsibilities', provide clean text ONLY. DO NOT include any bullet characters (like -, *, or •) at the start of the lines.
2. Ensure the resume has substantial content and does NOT look empty. Add relevant soft skills and technical skills if not explicitly provided, but keep them aligned with the user's role.
3. For 'skills', extract the skills explicitly mentioned AND add highly relevant industry skills to make it robust.
User Input:
"""
$prompt
"""
''';

      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": instructions}
            ]
          }
        ],
        "generationConfig": {
          "responseMimeType": "application/json",
          "temperature": 0.7
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty && 
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
              
          final String responseText = responseData['candidates'][0]['content']['parts'][0]['text'];
          
          // Parse the JSON response text
          final String jsonString = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
          final Map<String, dynamic> data = jsonDecode(jsonString);
          
          if (data.containsKey('error') && data['error'] == 'bad_prompt') {
            throw Exception('BAD_PROMPT');
          }
          
          return data;
        } else {
          throw Exception("Failed to generate content: Invalid response structure");
        }
      } else {
        final errorStr = response.body.toLowerCase();
        if (response.statusCode == 429 || 
            response.statusCode == 503 || 
            errorStr.contains('quota exceeded') || 
            errorStr.contains('high demand') || 
            errorStr.contains('unavailable')) {
          throw Exception('RATE_LIMIT');
        }
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } on FormatException catch (_) {
      throw Exception('BAD_PROMPT');
    } catch (e) {
      if (e.toString() == 'Exception: BAD_PROMPT' || e.toString() == 'Exception: RATE_LIMIT') {
        rethrow;
      }
      print('Gemini API Error: $e');
      throw Exception('Failed to generate resume from AI: $e');
    }
  }
}
