import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  final String foto;
  final String titulo;

  ImageScreen(this.foto, this.titulo);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Image.network(foto, fit: BoxFit.scaleDown),
      actions: [
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.message),
          label: Text(''),
        ),
      ],
    );
  }
}
