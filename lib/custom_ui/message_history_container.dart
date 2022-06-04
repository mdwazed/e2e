import 'package:flutter/material.dart';
import 'message_history_card.dart';

class MessageHistoryContainer extends StatefulWidget {
  final List<Map> allMessages;
  const MessageHistoryContainer(this.allMessages, {Key? key}) : super(key: key);
  @override
  State<MessageHistoryContainer> createState() => _MessageHistoryContainerState();
}

class _MessageHistoryContainerState extends State<MessageHistoryContainer> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(widget.allMessages.length, (index){
          return MessageHistoryCard(widget.allMessages[index]['text']);
        }),
      ),
    );
  }
}
