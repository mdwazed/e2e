import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Call extends StatefulWidget {
  const Call({Key? key}) : super(key: key);

  @override
  State<Call> createState() => _CallState();
}

class _CallState extends State<Call> {
  List users = [];
  IO.Socket socket = IO.io(
      'https://rt-comm-server.b664fshh19btg.eu-central-1.cs.amazonlightsail.com',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoconnect': false,
      });

  _connect() {
    print('establishing connection...');
    socket.connect();
    socket.onConnect((data) {
      print('connected ${socket.id}');
      setState(() {
        users.add(socket.id);
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
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
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Column(
          children: List.generate(users.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 15,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('User ${users[index]}'),
                  GestureDetector(
                    onTap: (){},
                    child: const Icon(
                      Icons.call,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
