import 'package:openpgp/openpgp.dart';
import 'package:e2e/model/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import '../custom_ui/message_history_container.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _controller = TextEditingController();
  final MessageList list = MessageList();

  IO.Socket socket = IO.io('http://192.168.1.71:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoconnect': false,
  });

  _connect() {
    print('establishing connection...');
    socket.connect();
    socket.onConnect((data) {
      print('connected ${socket.id}');
    });
    socket.on('msg', (data) async {
      var dMsg = await OpenPGP.decryptSymmetric(
        data['msg'],
        "thisismysupersecretkey",
      );
      print('received message data $data');
      setState((){
        const isOwnMsg = false;
        list.messages.add(Message(message: dMsg, sender: data['sender'], isOwnMsg: isOwnMsg),);
      });
    });
  }

  void sendEncMsg(_controller) async {
    var rawMsg = _controller.text;
    var sender = socket.id;
    var encMsg = await OpenPGP.encryptSymmetric(
      rawMsg, // message
      "thisismysupersecretkey",
    );
    socket.emit('msg', {'msg': encMsg, 'sender': sender});
    print('sent encrypted message ${encMsg}');
    setState((){
      const isOwnMsg = true;
      list.messages.add(
        Message(message: rawMsg, sender: sender.toString(), isOwnMsg: isOwnMsg)
      );
    });
    _controller.text = '';

  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    socket.disconnect();
    print('disconnected');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _connect());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MessageHistoryContainer(list),
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
                  sendEncMsg(_controller);
                },
                icon: const Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
