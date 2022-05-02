import 'package:chat/screens/login_screen.dart';
import 'package:chat/widgets/card_contato.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ContatosScreen extends StatelessWidget {

  final User? _currentUser;

  ContatosScreen(this._currentUser);

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Contatos"),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Sair"),
                    content: Text("Você deseja mesmo sair?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Não"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          googleSignIn.signOut();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text("Sair"),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios').snapshots(),
            builder: (ctx, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator(),);
                default:
                  List<DocumentSnapshot> contatos = snapshot.data!.docs.reversed
                      .toList();
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                       return
                         _currentUser!.uid == contatos[index].id ? Container() :
                       Column(
                        children: [
                          CardContato(contatos[index].data() as Map<String, dynamic>),
                          const Divider(),
                        ],
                      );
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
