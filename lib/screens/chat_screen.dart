import 'dart:io';

import 'package:chat/screens/login_screen.dart';
import 'package:chat/widgets/card_message.dart';
import 'package:chat/widgets/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> contato;

  ChatScreen(this.contato);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User? _currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      setState(() {});
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _sendMessage({String? text, File? imgFile}) async {
    final User? user = _currentUser;

    Map<String, dynamic> mensagem = {
      'time': DateTime.now().toLocal(),
    };

    Map<String, dynamic> sender = {
      'name': user!.displayName,
      'uid': user.uid,
      'senderPhoto': user.photoURL,
    };

    Map<String, dynamic> dataMessage = {
      'mensagem': mensagem,
      'sender': sender,
      'reciver': widget.contato,
      'hour': Timestamp.now(),
    };

    if (imgFile != null) {
      TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      String url = await task.ref.getDownloadURL();
      mensagem['imageUrl'] = url;
    }

    if (text != null) mensagem['text'] = text;

    FirebaseFirestore.instance.collection('menssagens').add(dataMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null ? '${widget.contato['nome']}' : 'Chat',
        ),
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
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        googleSignIn.signOut();
                        Navigator.push(
                          context,
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menssagens')
                  .orderBy('hour')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    try {
                      List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            child: ChatMessage(
                              documents[index].data() as Map<String, dynamic>,
                              _currentUser == null ? '' : _currentUser!.uid,
                              widget.contato,
                            ),
                          );
                        },
                      );
                    } catch (error) {}
                    return Text('data');
                }
              },
            ),
          ),
          _currentUser != null ? TextComposer(_sendMessage) : Container(),
        ],
      ),
    );
  }
}
