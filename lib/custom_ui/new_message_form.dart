import 'package:flutter/material.dart';
class NewMessageForm extends StatefulWidget {
  final List<Map> messages;
  const NewMessageForm(this.messages, {Key? key}) : super(key: key);

  @override
  State<NewMessageForm> createState() => _NewMessageFormState();
}

class _NewMessageFormState extends State<NewMessageForm> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      child:
          TextField(
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
                    widget.messages.add({'text':_controller.text});
                  });
                  print(_controller.text);
                  print(widget.messages);
                },
                icon: const Icon(Icons.send),
              ),
            ),
          ),
      );
  }
}
