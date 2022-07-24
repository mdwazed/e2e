import 'package:e2e/pages/audio_call_page.dart';
import 'package:e2e/pages/video_call_page.dart';
import "package:flutter/material.dart";

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this, initialIndex: 0);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'বিনিময়',
          style: TextStyle(
            fontFamily: 'AnekBangla',
            fontSize: 25,
            fontWeight: FontWeight.w800
          ),
        ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search)),
          PopupMenuButton(
            onSelected: (value) {
              debugPrint(value.toString());
            },
            itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                  child: Text("New Group"),
                  value: "New Group",
              ),
              const PopupMenuItem(
                child: Text("Settings"),
                value: "Settings",
              ),
            ];
          })
        ],
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(
              text: "Chats",
            ),
            Tab(
              text: "Audio Call",
            ),
            Tab(
              text: "Video Call",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          ChatPage(),
          AudioCallPage(),
          VideoCallPage(),
          // Padding(padding: EdgeInsets.all(0),)
        ],
      ),
    );
  }
}
