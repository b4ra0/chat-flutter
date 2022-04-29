import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessage extends StatelessWidget {

  final String usuario;
  final Map<String, dynamic> dados;

  ChatMessage(this.dados, this.usuario);


  @override
  Widget build(BuildContext context) {
    final bool mine = dados['uid'] == usuario;
    return Row(
      children: [
        !mine ?
        CircleAvatar(
          foregroundImage: NetworkImage(dados['senderPhoto'], scale: 1),
        ) : Container(),
        SizedBox(width: 10),
        Expanded(
          child: Card(
            // shape: ShapeBorder(),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ListTile(
                title: dados['imageUrl'] != null ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.network(dados['imageUrl']),
                ) : Text(dados['text']),
                subtitle: Text(dados['senderNamer']),
                trailing: Text(DateFormat('kk:mm').format(dados['time'].toDate())),
              ),
            ),
          ),
        ),
        SizedBox(width: 10,),
        mine ?
        CircleAvatar(
          foregroundImage: NetworkImage(dados['senderPhoto'], scale: 1),
        ) : Container(),
      ],
    );
  }
}
