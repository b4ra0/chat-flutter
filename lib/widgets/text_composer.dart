import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  Function({String text, File imgFile}) sendMessage;

  TextComposer(this.sendMessage);

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;

  TextEditingController _messageController = TextEditingController();

  void _reset(){
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () async{
              final _picker = ImagePicker();
              final XFile? imgFile = await _picker.pickImage(source: ImageSource.camera);
              final File file = File(imgFile!.path);
              if (imgFile == null) return;
                widget.sendMessage(imgFile: file);
            },
            icon: Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                if (_messageController.text.isNotEmpty){
                  widget.sendMessage(text: text);
                  _reset();
                }
              },
            ),
          ),
          IconButton(
            onPressed: _isComposing ? () {
              widget.sendMessage(text: _messageController.text);
              _reset();
            } : null,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
