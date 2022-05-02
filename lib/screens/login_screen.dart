import 'package:chat/screens/contatos_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> _getUser() async {
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

      Map<String, dynamic> usuario = {
        'nome': user!.displayName,
        'email': user.email,
        'foto': user.photoURL,
        'uid': user.uid,
      };

      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set(usuario);
      return user;
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            opacity: 100,
            image: NetworkImage(
              'https://static.vecteezy.com/ti/fotos-gratis/p2/1739486-pessoa-usando-um-telefone-celular-gr%C3%A1tis-foto.jpg',
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: const [
                Icon(
                  Icons.mark_chat_unread_rounded,
                  color: Colors.green,
                  size: 100,
                ),
                SizedBox(height: 10,),
                Text(
                  "Messenger",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                User? _currentUser = await _getUser();
                print(_currentUser!.displayName);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bem vindo(a) ${_currentUser.displayName}")));
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ContatosScreen(_currentUser),
                  ),
                );
              },
              child: Text("Faça login"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.green),
                overlayColor: MaterialStateProperty.all(Colors.green),
                fixedSize: MaterialStateProperty.all(Size(200, 50)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
