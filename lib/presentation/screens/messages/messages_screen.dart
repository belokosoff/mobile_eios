import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eios/presentation/screens/messages/widgets/message_item.dart';
import 'package:eios/presentation/screens/messages/widgets/message_input.dart';

import 'bloc/messages_bloc.dart';
import 'bloc/messages_event.dart';
import 'bloc/messages_state.dart';

class MessagesScreen extends StatelessWidget {
  final int disciplineId;
  final String disciplineName;

  const MessagesScreen({
    super.key,
    required this.disciplineId,
    required this.disciplineName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MessagesBloc(disciplineId: disciplineId)
            ..add(const MessagesStarted()),
      child: _MessagesView(disciplineName: disciplineName),
    );
  }
}

class _MessagesView extends StatefulWidget {
  final String disciplineName;

  const _MessagesView({required this.disciplineName});

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
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

  void _showDeleteDialog(BuildContext context, int messageId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<MessagesBloc>().add(MessageDeleted(messageId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          BlocBuilder<MessagesBloc, MessagesState>(
            buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: state.isLoading
                  ? null
                  : () => context.read<MessagesBloc>().add(
                      const MessagesRefreshed(),
                    ),
            ),
          ),
        ],
      ),
      body: BlocListener<MessagesBloc, MessagesState>(
        listenWhen: (prev, curr) =>
            curr.snackBarMessage != null ||
            curr.shouldScrollToBottom != prev.shouldScrollToBottom,
        listener: (context, state) {
          if (state.snackBarMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.snackBarMessage!),
                backgroundColor: state.snackBarIsError
                    ? Colors.red
                    : Colors.green,
                action: state.snackBarIsError
                    ? SnackBarAction(
                        label: 'OK',
                        textColor: Colors.white,
                        onPressed: () {},
                      )
                    : null,
              ),
            );
            context.read<MessagesBloc>().add(const MessagesSnackBarDismissed());
          }

          if (state.shouldScrollToBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }

          if (!state.isSending &&
              state.snackBarMessage == null &&
              state.isLoaded) {
            _messageController.clear();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<MessagesBloc>().add(const MessagesRefreshed());
          },
          child: Column(
            children: [
              Expanded(child: _buildContent()),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildContent() {
    return BlocBuilder<MessagesBloc, MessagesState>(
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.messages != curr.messages ||
          prev.errorMessage != curr.errorMessage,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text('Ошибка', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<MessagesBloc>().add(
                      const MessagesStarted(),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Попробовать снова'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Нет сообщений',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Будьте первым, кто напишет',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final message = state.messages[index];
            return MessageItem(
              message: message,
              currentUserId: state.currentUserId,
              onDelete: () => _showDeleteDialog(context, message.id!),
            );
          },
        );
      },
    );
  }

  Widget _buildInput() {
    return BlocBuilder<MessagesBloc, MessagesState>(
      buildWhen: (prev, curr) => prev.isSending != curr.isSending,
      builder: (context, state) => MessageInput(
        controller: _messageController,
        onSend: (text) => context.read<MessagesBloc>().add(MessageSent(text)),
        isLoading: state.isSending,
      ),
    );
  }
}
