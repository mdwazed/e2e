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

  IO.Socket socket = IO.io('http://192.168.0.102:3000', <String, dynamic>{
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
        list.messages.add(Message(message: dMsg, user: data['user']));
      });
    });
  }

  void sendEncMsg(_controller) async {
    var encMsg = await OpenPGP.encryptSymmetric(
      _controller.text, // message
      "thisismysupersecretkey",
    );
    socket.emit('msg', {'msg': encMsg, 'user': socket.id});
    print('sent encrypted message ${encMsg}');
    // list.messages.add(Message(message: _controller.text));
    // print(list.toJSONEncodable());
    _controller.text = '';

  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
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
