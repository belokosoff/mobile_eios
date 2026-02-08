import 'package:flutter/material.dart';
import 'package:eios/data/repositories/brs_repository.dart';
import 'package:eios/data/models/message.dart';
import 'package:eios/core/exceptions/app_exceptions.dart';
import 'package:eios/presentation/screens/messages/widgets/message_item.dart';
import 'package:eios/presentation/screens/messages/widgets/message_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatefulWidget {
  final int disciplineId;
  final String disciplineName;

  const MessagesScreen({
    super.key,
    required this.disciplineId,
    required this.disciplineName,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final BrsRepository _repository = BrsRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  int _currentUserId = 0;
  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Загружаем ID текущего пользователя
  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getInt('user_id') ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading current user id: $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final messages = await _repository.getMessages(
        disciplineId: widget.disciplineId,
      );
      
      // Сортируем сообщения по дате (опционально)
      messages.sort((a, b) {
        if (a.createDate == null || b.createDate == null) return 0;
        try {
          final dateA = DateTime.parse(a.createDate!);
          final dateB = DateTime.parse(b.createDate!);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } on ForbiddenException {
      setState(() {
        _errorMessage = 'У вас нет доступа к этой дисциплине';
        _isLoading = false;
      });
    } on NotFoundException {
      setState(() {
        _errorMessage = 'Дисциплина не найдена';
        _isLoading = false;
      });
    } on AppException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Произошла ошибка: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) {
      _showError('Сообщение не может быть пустым');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _repository.sendMessage(
        disciplineId: widget.disciplineId,
        messageText: text,
      );
      
      _messageController.clear();
      await _loadMessages();
    } on BadRequestException {
      _showError('Сообщение не должно быть пустым');
    } on ForbiddenException {
      _showError('У вас нет доступа к этой дисциплине');
    } on NotFoundException {
      _showError('Дисциплина не найдена');
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Ошибка отправки: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _deleteMessage(int? messageId) async {
    if (messageId == null) return;
    
    try {
      await _repository.deleteMessage(id: messageId);
      await _loadMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сообщение удалено'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ForbiddenException {
      _showError('Вы не можете удалить чужое сообщение');
    } on NotFoundException {
      _showError('Сообщение не найдено');
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Ошибка удаления: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showDeleteDialog(int? messageId) {
    if (messageId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteMessage(messageId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Форум'),
            Text(
              widget.disciplineName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadMessages,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMessages,
        child: Column(
          children: [
            Expanded(
              child: _buildContent(),
            ),
            MessageInput(
              controller: _messageController,
              onSend: _sendMessage,
              isLoading: _isSending,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadMessages,
                icon: const Icon(Icons.refresh),
                label: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет сообщений',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Будьте первым, кто напишет',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageItem(
          message: message,
          currentUserId: _currentUserId,
          onDelete: () => _showDeleteDialog(message.id),
        );
      },
    );
  }
}