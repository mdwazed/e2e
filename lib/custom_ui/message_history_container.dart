import 'package:e2e/model/message_model.dart';
import 'package:flutter/material.dart';
import 'message_history_card.dart';

class MessageHistoryContainer extends StatefulWidget {
  final MessageList allMessages;

  const MessageHistoryContainer(this.allMessages, {Key? key}) : super(key: key);

  @override
  State<MessageHistoryContainer> createState() =>
      _MessageHistoryContainerState();
}

class _MessageHistoryContainerState extends State<MessageHistoryContainer> {
  @override
  Widget build(BuildContext context) {
    // print('rendering history');
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(widget.allMessages.messages.length, (index) {
            return MessageHistoryCard(
              widget.allMessages.messages[index].message,
              widget.allMessages.messages[index].isOwnMsg,
              widget.allMessages.messages[index].encryptedMsg,
            );
          }),
        ),
      ),
    );
  }
}
