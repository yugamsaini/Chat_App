
import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/message.dart';

class APIs{

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accesing cloud firebase database
    static FirebaseFirestore firestore = FirebaseFirestore.instance;


//for accesing cloud firebase database
    static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing the self profile information
  static late ChatUser me;
    //to return current user
    static User get user => auth.currentUser!;

    //for checking if user exist or not
    static Future<bool> userExists() async {
      return (await firestore.collection('users').doc(user.uid).get()).exists;
    }

     //for checking if user exist or not
    static Future<void> getSelfInfo() async {
      await firestore.collection('users').doc(user.uid).get().then((user) async{
        if(user.exists){
          me = ChatUser.fromJson(user.data()!);
        } else {
         await createUser().then((value) => getSelfInfo());
        }
      });
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

//method for getting all the user from the database
    static Stream<QuerySnapshot<Map<String,dynamic>>> getAllUsers(){
      return firestore.collection('users').where('Id', isEqualTo: user.uid).snapshots();
    }

    
    //for updating the user info
    static Future<void> updateUserInfo() async {
      await firestore.collection('users').doc(user.uid).update({
        'name' : me.name,
        'about' : me.about,
        });
    }

    //update the profile picture of the user
    static Future<void> updateProfilePicture(File file) async{
      //getting the file extension
      final ext = file.path.split('.').last;
      final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

      //uploading image
      await ref.putFile(file, SettableMetadata(contentType:'image/$ext'))
      .then((p0) {
        log('data referenced: ${p0.bytesTransferred/1000}kb');
      });

//updating image in firebase database

      me.image = await ref.getDownloadURL();
       await firestore.collection('users')
       .doc(user.uid)
       .update({
        'image' : me.image,
        
        });
    }
        //chats (collection)--> conversation(doc)--> messages(collection)-->message(doc)

    //for getting conversation id
    static String getConversationID(String id)=>user.uid.hashCode<=id.hashCode
    ? '${user.uid}_$id}' : '${id}_${user.uid}';
    //for getting all messages of a specific conversation from firestore database
    static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(ChatUser user){
      return firestore.
      collection('chats/${getConversationID(user.Id)}/messages/')
      .snapshots();
    }

//for sending messages
static Future<void> sendMessage(ChatUser chatuser,String msg) async{
   //message sending time also used as id
   final time = DateTime.now().millisecondsSinceEpoch.toString();

   final Message message = Message(told: chatuser.Id, msg: msg, read: '', type: Type.text, fromId: user.uid, sent: time);
    final ref = 
    firestore.collection('chats/${getConversationID(chatuser.Id)}/messages/');
    await ref.doc(time).set(message.toJson());
}

//function to update the read status of message
static Future<void> updateMessageReadStatus(Message message) async {
      firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
      .doc(message.sent)
      .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});

}

//function to get only last message of a specific chat
static Stream<QuerySnapshot> getLastMessage(
  ChatUser user){
    return  firestore
    .collection('chats/${getConversationID(user.Id)}/messages/')
    .orderBy('sent',descending: true)
    .limit(1)
    .snapshots();
  }
}