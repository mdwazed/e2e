import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_9.dart';

class MessageHistoryCard extends StatelessWidget {
  final String message;
  final bool isOwnMsg;
  final String encryptedMsg;

  const MessageHistoryCard(this.message, this.isOwnMsg, this.encryptedMsg,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOwnMsg) {
      return ChatBubble(
        clipper: ChatBubbleClipper9(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(top: 10),
        backGroundColor: Colors.cyan[50],
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: ExpandablePanel(
            header: Text(message),
            collapsed: ExpandableButton(
              child: const Text(
                'Show Encrypted Message',
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            expanded: Text(
              encryptedMsg,
              softWrap: true,
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
          child: ExpandablePanel(
            header: ExpandableButton(child: Text(message)),
            collapsed: const Text(
              'Show Encrypted Message',
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            expanded: Text(
              encryptedMsg,
              softWrap: true,
            ),
          ),
        ),
      );
    }
  }
}
