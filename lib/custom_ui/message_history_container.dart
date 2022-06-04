import 'package:flutter/material.dart';

import 'message_history_card.dart';

class MessageHistoryContainer extends StatefulWidget {
  const MessageHistoryContainer({Key? key}) : super(key: key);

  @override
  State<MessageHistoryContainer> createState() => _MessageHistoryContainerState();
}

class _MessageHistoryContainerState extends State<MessageHistoryContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MessageHistoryCard(),
        MessageHistoryCard(),
        MessageHistoryCard(),
      ],
    );
  }
}
