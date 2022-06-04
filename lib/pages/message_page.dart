import 'package:e2e/json/messages_list.dart';
import 'package:flutter/material.dart';

import '../custom_ui/message_history_container.dart';
import '../custom_ui/new_message_form.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.50,
                child: MessageHistoryContainer(messages),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 10,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter a message',
                    prefixIcon: const Padding(
                      padding: EdgeInsetsDirectional.only(start: 12.0),
                      child: Icon(Icons.chat),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          messages.add({'text': _controller.text});
                        });
                        _controller.text = '';
                        print(_controller.text);
                        print(messages);
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
