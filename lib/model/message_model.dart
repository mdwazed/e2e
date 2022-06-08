class Message {
  final String message;
  final String user;

  Message({required this.message, required this.user});

  toJSONEncodable() {
    Map<String, String> m = Map();
    m['text'] = message;
    m['user'] = user;
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