import 'package:flutter/material.dart';

import '../pages/message_page.dart';

class RecentContactCard extends StatelessWidget {
  const RecentContactCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessagePage()),
        );
      },
      leading: const CircleAvatar(
        radius: 25,
      ),
      title: Text(
        "wazed",
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: Text(
        'here goes the actual message',
        style: Theme.of(context).textTheme.bodyText2,
      ),
      trailing: const Text('Date'),
    );
  }
}
