import 'package:flutter/material.dart';

import '../custom_ui/message_history_container.dart';
import '../custom_ui/new_message_form.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MessageHistoryContainer(),
          NewMessageForm(),
        ],

      )
    );
  }
}
