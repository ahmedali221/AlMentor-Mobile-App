import 'dart:io';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/models/ai_chat.dart';
import 'package:almentor_clone/services/chat_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final List<ChatMessage> _messages = [];
  List<dynamic> _chatHistory = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _currentChatId;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final ChatService _chatService = ChatService();
  final AiChatService _aiChatService = AiChatService(
    apiKey:
        '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',
    siteUrl: 'https://yourwebsite.com',
    siteName: 'Almentor Clone',
  );

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _addWelcomeMessage();

    // Listen to text changes for send button state
    _messageController.addListener(() {
      setState(() {}); // Rebuild to update send button state
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Hello! I'm your AI mentor. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  Future<void> _loadChatHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final chats = await _chatService.getUserChats();
      setState(() {
        _chatHistory = chats;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
      _showSnackBar('Failed to load chat history: ${e.toString()}');
    }
  }

  Future<void> _loadChat(String chatId) async {
    setState(() => _isLoading = true);
    try {
      final chatData = await _chatService.getChatById(chatId);
      setState(() {
        _currentChatId = chatId;
        _messages.clear();

        // Convert chat messages to ChatMessage objects
        final messages = chatData['messages'] as List<dynamic>;
        for (var message in messages) {
          _messages.add(ChatMessage(
            text: message['message'] ?? '',
            isUser: message['role'] == 'user',
            timestamp: DateTime.parse(
                message['timestamp'] ?? DateTime.now().toIso8601String()),
          ));
        }
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load chat: ${e.toString()}');
    }
  }

  Future<void> _startNewChat() async {
    setState(() {
      _currentChatId = null;
      _messages.clear();
    });
    _addWelcomeMessage();
    await _loadChatHistory();
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      if (_currentChatId == chatId) {
        _startNewChat();
      } else {
        await _loadChatHistory();
      }
      _showSnackBar('Chat deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete chat: ${e.toString()}');
    }
  }

  Future<void> _updateChatTitle(String chatId, String newTitle) async {
    try {
      await _chatService.updateChatTitle(chatId, newTitle);
      await _loadChatHistory();
      _showSnackBar('Chat title updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update chat title: ${e.toString()}');
    }
  }

  void _showEditTitleDialog(String chatId, String currentTitle) {
    final titleController = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Chat Title'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Chat Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateChatTitle(chatId, titleController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String chatId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(chatId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      _showSnackBar('Failed to pick file: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _handleFileSelection(File(image.path));
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _handleFileSelection(File file) async {
    final fileName = path.basename(file.path);
    final userMessage = ChatMessage(
      text: '',
      isUser: true,
      file: file,
      fileName: fileName,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Save user message to backend
      if (_currentChatId != null) {
        await _chatService.saveChat(
          chatId: _currentChatId,
          message: 'File uploaded: $fileName',
          role: 'user',
        );
      }

      String fileContent;
      if (file.path.toLowerCase().endsWith('.pdf')) {
        fileContent = '[PDF file uploaded: $fileName]';
      } else {
        fileContent = '[Image uploaded: $fileName]';
      }

      final response = await _aiChatService.sendMessage(
        'I uploaded a file: $fileName\n$fileContent',
      );

      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      // Save AI response to backend
      final savedChat = await _chatService.saveChat(
        chatId: _currentChatId,
        message: response,
        role: 'assistant',
      );

      if (_currentChatId == null) {
        setState(() => _currentChatId = savedChat['_id']);
        await _loadChatHistory();
      }
    } catch (e) {
      _showSnackBar('Failed to process file: ${e.toString()}');
      setState(() => _isLoading = false);
    } finally {
      _scrollToBottom();
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessageText = _messageController.text.trim();
    final userMessage = ChatMessage(
      text: userMessageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      // Save user message to backend
      if (_currentChatId != null) {
        await _chatService.saveChat(
          chatId: _currentChatId,
          message: userMessageText,
          role: 'user',
        );
      }

      final response = await _aiChatService.sendMessage(userMessageText);

      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      // Save AI response to backend
      final savedChat = await _chatService.saveChat(
        chatId: _currentChatId,
        message: response,
        role: 'assistant',
      );

      if (_currentChatId == null) {
        setState(() => _currentChatId = savedChat['_id']);
        await _loadChatHistory();
      }
    } catch (e) {
      _showSnackBar('Sorry, I encountered an error. Please try again.');
      setState(() => _isLoading = false);
    } finally {
      _scrollToBottom();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  List<dynamic> get _filteredChats {
    if (_searchController.text.isEmpty) return _chatHistory;
    return _chatHistory.where((chat) {
      final title = chat['title']?.toString().toLowerCase() ?? '';
      final query = _searchController.text.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  Widget _buildDrawerContent(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'AI Mentor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startNewChat();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: Icon(Icons.search,
                    color: colors.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: colors.outline.withOpacity(0.3)),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Chat history list
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _filteredChats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: colors.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No chats yet',
                              style: TextStyle(
                                color: colors.onSurface.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = _filteredChats[index];
                          final isSelected = _currentChatId == chat['_id'];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primaryContainer.withOpacity(0.7)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                chat['title'] ?? 'New Chat',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(
                                    chat['updatedAt'] ?? chat['createdAt']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurface.withOpacity(0.6),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                _loadChat(chat['_id']);
                              },
                              trailing: PopupMenuButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: colors.onSurface.withOpacity(0.6),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit,
                                            size: 18, color: colors.primary),
                                        const SizedBox(width: 8),
                                        const Text('Edit Title'),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => _showEditTitleDialog(chat['_id'],
                                          chat['title'] ?? 'New Chat'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => _showDeleteConfirmDialog(
                                          chat['_id'],
                                          chat['title'] ?? 'New Chat'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mentor'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
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
      drawer: _buildDrawerContent(context),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            size: 64,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'How can I help you today?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation with your AI mentor',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurface.withOpacity(0.7),
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
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('AI is thinking...',
                      style:
                          TextStyle(color: colors.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.outline.withOpacity(0.2)),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Attachment buttons row
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.attach_file,
                              color: colors.primary, size: 20),
                          onPressed: _pickFile,
                          tooltip: 'Attach file',
                          padding: const EdgeInsets.all(8),
                          constraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.image,
                              color: colors.primary, size: 20),
                          onPressed: _pickImage,
                          tooltip: 'Attach image',
                          padding: const EdgeInsets.all(8),
                          constraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Message input row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colors.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(
                                color: colors.onSurface.withOpacity(0.5),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.onSurface,
                            ),
                            textInputAction: TextInputAction.newline,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: _messageController.text.trim().isNotEmpty
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: _messageController.text.trim().isNotEmpty
                                ? Colors.white
                                : colors.onSurface.withOpacity(0.4),
                            size: 20,
                          ),
                          onPressed: _messageController.text.trim().isNotEmpty
                              ? _sendMessage
                              : null,
                          padding: const EdgeInsets.all(12),
                          constraints:
                              const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final File? file;
  final String? fileName;
  final DateTime timestamp;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.file,
    this.fileName,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
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
                  color: isUser ? Colors.white : colors.onSurface,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isUser
                    ? Colors.white.withOpacity(0.7)
                    : colors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isImage = fileName?.toLowerCase().endsWith('.png') ??
        fileName?.toLowerCase().endsWith('.jpg') ??
        fileName?.toLowerCase().endsWith('.jpeg') ??
        false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                file!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          if (!isImage)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.white.withOpacity(0.2) : colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: isUser ? Colors.white : colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName ?? 'File',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isUser ? Colors.white : colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
