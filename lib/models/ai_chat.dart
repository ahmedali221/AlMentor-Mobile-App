import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class AiChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isProcessing;

  AiChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.isProcessing = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiChatMessage.fromUser({
    required String content,
  }) {
    return AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
    );
  }

  factory AiChatMessage.fromAi({
    required String content,
  }) {
    return AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
    );
  }

  factory AiChatMessage.processing() {
    return AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      isUser: false,
      isProcessing: true,
    );
  }
}

class AiChatService {
  final String _apiKey;
  final String? _siteUrl;
  final String? _siteName;
  final String _model;

  AiChatService({
    required String apiKey,
    String? siteUrl,
    String? siteName,
    String model = 'deepseek/deepseek-chat-v3-0324:free',
  })  : _apiKey = apiKey,
        _siteUrl = siteUrl,
        _siteName = siteName,
        _model = model;

  Future<String> sendMessage(String message, {File? file}) async {
    try {
      String content = message;

      if (file != null) {
        // final fileContent = await _extractFileContent(file);
        // content = '$message\n\n[File content]:\n$fileContent';
      }

      final response = await _sendToOpenRouter(content);
      return response;
    } catch (e) {
      throw Exception('Failed to get response: ${e.toString()}');
    }
  }

  // Future<String> _extractFileContent(File file) async {
  //   final fileName = path.basename(file.path);
  //   final extension = path.extension(file.path).toLowerCase();

  //   try {
  //     if (extension == '.pdf') {
  //       return await _extractPdfText(file);
  //     } else if (['.jpg', '.jpeg', '.png'].contains(extension)) {
  //       return '[Image: $fileName] (Describe this image in your response)';
  //     } else if (['.txt', '.md'].contains(extension)) {
  //       return await file.readAsString();
  //     } else {
  //       return '[File: $fileName] (Unsupported file type)';
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to process file: ${e.toString()}');
  //   }
  // }

  // Future<String> _extractPdfText(File file) async {
  //   try {
  //     final pdfDoc = await PDFDoc.fromPath(file.path);
  //     final text = await pdfDoc.text;
  //     return text.isNotEmpty
  //         ? text
  //         : '[PDF: ${path.basename(file.path)}] (Could not extract text)';
  //   } catch (e) {
  //     throw Exception('PDF processing failed: ${e.toString()}');
  //   }
  // }

  Future<String> _sendToOpenRouter(String content) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
      if (_siteUrl != null) 'HTTP-Referer': _siteUrl,
      if (_siteName != null) 'X-Title': _siteName,
    };

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful AI mentor. Analyze any provided files and give helpful responses.'
        },
        {'role': 'user', 'content': content}
      ],
      'temperature': 0.7,
      'max_tokens': 2000,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(
          'OpenRouter Error: ${response.statusCode} - ${response.body}');
    }
  }
}
