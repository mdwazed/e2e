import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:openpgp/openpgp.dart';

class NewMessageForm extends StatefulWidget {
  const NewMessageForm({Key? key}) : super(key: key);

  @override
  State<NewMessageForm> createState() => _NewMessageFormState();
}

class _NewMessageFormState extends State<NewMessageForm> {
  final _controller = TextEditingController();
  IO.Socket socket = IO.io('http://192.168.1.71:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoconnect': false,
  });
  _connect() {
    print('establishing connection...');
    socket.connect();
    print(socket);
    socket.onConnect((data) {
      print('connected');
      print(socket.id);
    });
    socket.on('msg', (data) {
      print(data);
    });
  }

  void sendEncMsg(msg) async {
    var encMsg = await OpenPGP.encryptSymmetric(msg, "thisismysupersecretkey");
    // print(encMsg.toString());
    socket.emit('msg', msg);
    print('message sent');
    var dMsg = await OpenPGP.decryptSymmetric(encMsg, "thisismysupersecretkey");
    print(dMsg);
  }

  void _handleInput() async {
    var rawMessage = _controller.text;
    print('last message: $rawMessage');
    sendEncMsg(rawMessage);
  }

  void initState() {
    super.initState();
    _connect();
  }

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
            onPressed: _handleInput,
            icon: const Icon(Icons.send),
          ),
        ),
      ),
    );
  }
}
