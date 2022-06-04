import 'package:flutter/material.dart';

class MessageHistoryCard extends StatelessWidget {
  const MessageHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: ListTile(
          title: Text("Codesinsider.com"),
        ),
        elevation: 1,
      )
    );
  }
}