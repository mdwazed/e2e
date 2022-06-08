import 'package:flutter/material.dart';


class MessageHistoryCard extends StatelessWidget {
  final String message;
  final String user;
  const MessageHistoryCard(this.message, this.user, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
          child: ListTile(
            title: Text(message),
            subtitle: Text(user),
          ),
          elevation: 1,
        )
    );
  }
}