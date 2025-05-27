import 'dart:io';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/models/ai_chat.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class AiMentorPage extends StatefulWidget {
  const AiMentorPage({super.key});

  @override
  State<AiMentorPage> createState() => _AiMentorPageState();
}

class _AiMentorPageState extends State<AiMentorPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final AiChatService _chatService = AiChatService(
    apiKey:
        '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',
    siteUrl: 'https://yourwebsite.com',
    siteName: 'Almentor Clone',
  );

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Hello! I'm your AI mentor. How can I help you today?",
          isUser: false,
        ));
      });
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        _handleFileSelection(File(file.path!));
      }
    } catch (e) {
      _showError('Failed to pick file: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _handleFileSelection(File(image.path));
      }
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _handleFileSelection(File file) async {
    setState(() {
      _messages.add(ChatMessage(
        text: '',
        isUser: true,
        file: file,
        fileName: path.basename(file.path),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      String fileContent;
      if (file.path.toLowerCase().endsWith('.pdf')) {
        fileContent = '[PDF file uploaded: ${path.basename(file.path)}]';
        // In a real app, you'd extract text from PDF using a package like pdf_text
      } else {
        // For images, we'll just send a description since we can't send raw images to most APIs
        fileContent = '[Image uploaded: ${path.basename(file.path)}]';
      }

      final response = await _chatService.sendMessage(
        'I uploaded a file: ${path.basename(file.path)}\n$fileContent',
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to process file: ${e.toString()}');
    } finally {
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
      ));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(userMessage);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      _showError('Sorry, I encountered an error. Please try again.');
    } finally {
      _scrollToBottom();
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
      ));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mentor'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: colors.primary,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 64,
                          color: colors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'How can I help you today?',
                          style: TextStyle(
                            fontSize: 18,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _messages[index];
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(
                color: colors.primary,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file, color: colors.primary),
                      onPressed: _pickFile,
                      tooltip: 'Attach file',
                    ),
                    IconButton(
                      icon: Icon(Icons.image, color: colors.primary),
                      onPressed: _pickImage,
                      tooltip: 'Attach image',
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withOpacity(0.4),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: colors.primary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final File? file;
  final String? fileName;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.file,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (file != null) _buildFilePreview(context),
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    final isImage = fileName?.toLowerCase().endsWith('.png') ??
        fileName?.toLowerCase().endsWith('.jpg') ??
        fileName?.toLowerCase().endsWith('.jpeg') ??
        false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          if (!isImage)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName ?? 'File',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            fileName ?? 'File',
            style: TextStyle(
              fontSize: 12,
              color: isUser
                  ? Colors.white70
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
