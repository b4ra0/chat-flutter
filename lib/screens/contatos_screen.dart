import 'package:chat/widgets/card_contato.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ContatosScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios').snapshots(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator(),);
            default:
              List<DocumentSnapshot> contatos = snapshot.data!.docs.reversed
                  .toList();
              return ListView.builder(
                itemCount: contatos.length,
                itemBuilder: (context, index) {
                  return CardContato(contatos[index].data() as Map<String, dynamic>);
                },
              );
          }
        },
      ),
    );
  }
}
