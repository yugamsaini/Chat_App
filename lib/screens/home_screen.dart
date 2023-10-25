import 'package:chatapp/api/apis.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: const Text('We Chat'),
        actions: [
          //search user button
          IconButton(onPressed: (){}, icon: const Icon(Icons.search)),
          //more button :
          IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert))

        ],
      ),

//bottom right corner flaoting button
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(onPressed: () async {
  await APIs.auth.signOut();
  await GoogleSignIn().signOut();

        },child: const Icon(Icons.add_comment_rounded)),
      ),
    );
  }
}