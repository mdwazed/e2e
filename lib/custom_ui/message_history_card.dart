import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_9.dart';


class MessageHistoryCard extends StatelessWidget {
  final String message;
  final bool isOwnMsg;
  const MessageHistoryCard(this.message, this.isOwnMsg, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (this.isOwnMsg) {
      return ChatBubble(
        clipper: ChatBubbleClipper9(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(top: 10),
        backGroundColor: Colors.cyan[50],
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            message,
            style: const TextStyle(
                fontSize: 18,
            ),
          ),
        ),
      );
    } else {
      return ChatBubble(
        clipper: ChatBubbleClipper9(type: BubbleType.receiverBubble),
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(top: 10),
        backGroundColor: Colors.cyan[100],
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }

  }
}