import 'package:flutter/material.dart';

class CardContato extends StatelessWidget {
  final Map<String, dynamic> data;

  CardContato(this.data);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(data['foto']),
        radius: 20,
      ),
      title: Text(data['nome']),
    );
  }
}
