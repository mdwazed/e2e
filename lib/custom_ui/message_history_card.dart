import 'package:flutter/material.dart';


class MessageHistoryCard extends StatelessWidget {
  final String message;
  final bool isOwnMsg;
  const MessageHistoryCard(this.message, this.isOwnMsg, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (this.isOwnMsg) {
      return Align(
          alignment: Alignment.centerRight,
          child: Card(
            child: ListTile(
              title: Text(message, textAlign: TextAlign.right),
            ),
            elevation: 1,
          )
      );
    } else {
      return Align(
          alignment: Alignment.centerLeft,
          child: Card(
            child: ListTile(
              title: Text(message, textAlign: TextAlign.left),
            ),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),),
          )
      );
    }

  }
}