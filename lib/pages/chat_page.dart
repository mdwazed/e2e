import 'package:e2e/custom_ui/recent_contact_card.dart';
import "package:flutter/material.dart";

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<String> userList = ['Wazed', 'Jhone', 'Bob'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: List.generate(userList.length, (index) => RecentContactCard(username: userList[index])),
      ),
    );
  }
}
