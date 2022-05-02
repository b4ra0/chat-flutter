import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessage extends StatelessWidget {

  final String usuarioUid;
  final Map<String, dynamic> dadosMensagem;
  final Map<String, dynamic> contato;

  ChatMessage(this.dadosMensagem, this.usuarioUid, this.contato);


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> infoMsg = dadosMensagem['mensagem'];
    final bool mine = dadosMensagem['sender']['uid'] == usuarioUid;
    final bool related = dadosMensagem['reciver']['uid'] == usuarioUid && dadosMensagem['sender']['uid'] == contato['uid'] || mine && dadosMensagem['reciver']['uid'] == contato['uid'];
    if (related == true) {
      return Row(
        children: [
          !mine ?
          CircleAvatar(
            foregroundImage: NetworkImage(dadosMensagem['sender']['senderPhoto'], scale: 1),
          ) : Container(),
          SizedBox(width: 10),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListTile(
                  title: infoMsg['imageUrl'] != null ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Image.network(infoMsg['imageUrl']),
                  ) : Text(infoMsg['text']),
                  subtitle: Text(dadosMensagem['sender']['name']),
                  trailing: Text(
                      DateFormat('kk:mm').format(infoMsg['time'].toDate())),
                ),
              ),
            ),
          ),
          SizedBox(width: 10,),
          mine ?
          CircleAvatar(
            foregroundImage: NetworkImage(dadosMensagem['sender']['senderPhoto'], scale: 1),
          ) : Container(),
        ],
      );
    } else{
      return Container();
    }
  }
}
