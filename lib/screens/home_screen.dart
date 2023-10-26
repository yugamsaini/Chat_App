import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/api/apis.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/profile_screen.dart';
//import 'package:chatapp/widgets/chat_user_card.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: const Text('We Chat'),
        actions: [
          //search user button
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          //more button :
          IconButton(onPressed: () {

            Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user: list[0])));
          }, icon: const Icon(Icons.more_vert))
        ],
      ),

//bottom right corner flaoting button
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Icon(Icons.add_comment_rounded)),
      ),

      //stream builder dynamically add the data
      body: StreamBuilder(
        //from where it will take data
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          //data is loading or have been loading
          switch (snapshot.connectionState) {
            //if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

            //if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              final data =
                  snapshot.data?.docs; // question mark agr data null na ho
              list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if(list.isNotEmpty){
                return ListView.builder(
                  itemCount: list.length,

                  //adding margin frm the top
                  padding: EdgeInsets.only(top: mq.height * .01),

                  //bouncing on scrolling
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(user: list[index]);

                   // return Text('Name : ${list[index]}');
                  });
              } else {
                return const Center(child: Text('No Connection Found!', style: TextStyle(fontSize: 20)));
              }
          }
        },
      ),
    );
  }
}
