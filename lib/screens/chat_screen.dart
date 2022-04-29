import 'dart:io';

import 'package:chat/widgets/card_message.dart';
import 'package:chat/widgets/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      setState(() {});
    });
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication!.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;

      return user;
    } catch (error) {
      print("deu ruim doidão $error");
      return null;
    }
  }

  void _sendMessage({String? text, File? imgFile}) async {
    final User? user = await _getUser();

    Map<String, dynamic> data = {
      'uid': user!.uid,
      'senderNamer': user.displayName,
      'senderPhoto': user.photoURL,
      'time': DateTime.now().toLocal(),
      'hour': Timestamp.now()
    };

    if (imgFile != null) {
      TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      String url = await task.ref.getDownloadURL();
      data['imageUrl'] = url;
    }

    if (text != null) data['text'] = text;

    FirebaseFirestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null ? 'Olá, ${_currentUser!.displayName}' : 'Chat',
        ),
        actions: [
          _currentUser == null
              ? IconButton(
                  onPressed: () {
                    _getUser();
                  },
                  icon: Icon(Icons.login))
              : IconButton(
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
                                    Navigator.pop(context);
                                  },
                                  child: Text("Sair"),
                                ),
                              ],
                            ));
                  },
                  icon: Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
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
                      List<DocumentSnapshot> documents =
                          snapshot.data!.docs.reversed.toList();
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
                                _currentUser == null ? '' : _currentUser!.uid),
                          );
                        },
                      );
                    } catch (error) {
                      print("deu mais ruim ainda doidão $error");
                    }
                    return Center(
                      child: AlertDialog(
                        content: Text(
                            "Você precisa estar logado para visualizar o chat"),
                        actions: [
                          TextButton(onPressed: _getUser, child: Text("Logar"))
                        ],
                      ),
                    );
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
