import 'package:flutter/material.dart';
import 'package:eios/data/models/message.dart';
import 'package:intl/intl.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final dynamic currentUserId;
  final VoidCallback? onDelete;

  const MessageItem({
    super.key,
    required this.message,
    required this.currentUserId,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMyMessage = currentUserId.toString() == message.user?.id.toString();
    final isTeacher = message.isTeacher ?? false;

    DateTime? messageDate;
    try {
      if (message.createDate != null) {
        messageDate = DateTime.parse(message.createDate!);
      }
    } catch (e) {
      debugPrint('Error parsing date: ${message.createDate}');
    }

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    final photoUrl = message.user?.photo?.urlMedium;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    debugPrint('My ID: $currentUserId, Message User ID: ${message.user?.id}');
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMyMessage
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMyMessage
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          color: isMyMessage
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : isTeacher
              ? Colors.orange[50]
              : Colors.grey[100],
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: isMyMessage ? onDelete : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isTeacher
                            ? Colors.orange
                            : isMyMessage
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                        backgroundImage: hasPhoto
                            ? NetworkImage(photoUrl)
                            : null,
                        child: !hasPhoto
                            ? Text(
                                _getInitials(message.user?.fio),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    message.user?.fio ?? 'Неизвестный',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isTeacher) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Преподаватель',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (messageDate != null)
                              Text(
                                dateFormat.format(messageDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isMyMessage)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 20,
                          color: Colors.red[400],
                          onPressed:
                              onDelete,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.text ?? '',
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
