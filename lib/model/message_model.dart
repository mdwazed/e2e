class Message {
  final String message;

  Message({required this.message});

  toJSONEncodable() {
    Map<String, String> m = Map();
    m['text'] = message;
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