import 'dart:ffi';

class Message {
  final String message;
  final String encryptedMsg;
  final String sender;
  final bool isOwnMsg;

  Message({
    required this.message,
    required this.encryptedMsg,
    required this.sender,
    required this.isOwnMsg,
  });

  toJSONEncodable() {
    Map<String, String> m = Map();
    m['text'] = message;
    m['encryptedMsg'] = encryptedMsg;
    m['sender'] = sender;
    return m;
  }
}

class MessageList {
  List<Message> messages = [];

  toJSONEncodable() {
    return messages.map((message) {
      return message.toJSONEncodable();
    }).toList();
  }
}
