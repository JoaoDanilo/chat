
import 'dart:io';

import 'package:chat/textComposer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void _sendMessage({String text, File imgFile}) async {

    Map<String, dynamic> data = {};

    if(imgFile != null){
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;

      String url = await taskSnapshot.ref.getDownloadURL();

      data['imgUrl'] = url;
    }

    if(text != null) data['text'] = text;

    Firestore.instance.collection('messages').add(data);
  }

  Widget main(){
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: <Widget>[
          messagesView(),
          TextComposer(_sendMessage),

        ],
      ) 
    );
  }

  Widget appBar(){
    return AppBar(
      title: Text("Hello"),
      elevation: 0,
    );
  }

  Widget messagesView(){
    return Expanded(
      child: StreamBuilder(
        stream: Firestore.instance.collection('messages').snapshots(),
        builder: (context, snapshot) {

          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
          
            default:
              List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();

              return ListView.builder(
                itemCount: documents.length,
                reverse: true,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(documents[index].data['text']),
                  );
                },
              );
          }
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return main();
  }
}

