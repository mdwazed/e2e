import 'package:flutter/material.dart';


class MessageHistoryCard extends StatelessWidget {
  final String message;
  const MessageHistoryCard(this.message, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
          child: ListTile(
            title: Text(message),
          ),
          elevation: 1,
        )
    );
  }
}