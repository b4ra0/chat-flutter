import 'package:chat/screens/chat_screen.dart';
import 'package:chat/screens/image_screen.dart';
import 'package:flutter/material.dart';

class CardContato extends StatelessWidget {
  final Map<String, dynamic> data;

  CardContato(this.data);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              DialogRoute(
                builder: (context) => ImageScreen(data['foto'], data['nome']),
                context: context,
              ),
            );
          },
          child: CircleAvatar(
            foregroundImage: NetworkImage(data['foto']),
            radius: 25,
          ),
        ),
        title: Text(data['nome']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(data),
            ),
          );
        },
      ),
    );
  }
}
