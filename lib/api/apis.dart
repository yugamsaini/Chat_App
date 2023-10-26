
import 'package:chatapp/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs{

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accesing cloud firebase database
    static FirebaseFirestore firestore = FirebaseFirestore.instance;

    //to return current user
    static User get user => auth.currentUser!;

    //for checking if user exist or not
    static Future<bool> userExists() async {
      return (await firestore.collection('users').doc(user.uid).get()).exists;
    }

    //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

      final chatUser = ChatUser(Id: user.uid,
       name: user.displayName.toString(),
        email: user.email.toString(),
        about: "hey, i am using wechat",
        image: user.photoURL.toString(),
        createdAt: time, 
        isOnline: false, 
        lastActive: time, 
        pushToken: ''
        );

      return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
    }
}