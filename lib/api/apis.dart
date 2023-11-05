
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

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

//            PUSH NOTIFICATION

    //for accessing firebase messaging (push notification)
    static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

    //for getting the firebase messaging token
    static Future<void> getFirebaseMessagingToken()async{

      await fMessaging.requestPermission();
      await fMessaging.getToken().then((t){
        if(t!= null){
          me.pushToken = t;
          //log('push token : $t');
        }
      });

//for handling foreground messages
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   log('Got a message whilst in the foreground!');
//   log('Message data: ${message.data}');

//   if (message.notification != null) {
//     log('Message also contained a notification: ${message.notification}');
//   }
// });
    }

    //for sending the push notification
    static Future<void> sendPushNotification(ChatUser chatUser,String msg) async{
      
      try{
        final body = {
        "to" : chatUser.pushToken,
        "notification" : {
          "title" : chatUser.name,
          "body" : msg,
          "android_channel_id" : "chats" 
        },
        "data": {
    "some_data" : "User ID : ${me.Id}",
  },

      };
var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
headers: {
  HttpHeaders.contentTypeHeader : 'application/json',
  HttpHeaders.authorizationHeader :
  'key=AAAA9WgMQGo:APA91bGKQ5ZzH3TtX6kTfXRMrBlYjE3zblBgUU98xF_AwamC6oyMMGNctWxU0kNfzC4JQSRssRqJ2t3pTw4YFVwwEm2Dadx9wxc2aUOu5OBwRRipgxZHfp2hxY4a5V0KcdJlXaz2WJ7k'
},
 body: jsonEncode(body));
log('Response status: ${res.statusCode}');
log('Response body: ${res.body}');
      }
      catch(e){
log('\nsendPushNotificationE: $e');
      }
    }
    //for checking if user exist or not
    static Future<bool> userExists() async {
      return (await firestore.collection('users').doc(user.uid).get()).exists;
    }

    //for adding the chat user in our conversation
   
    static Future<bool> addChatUser(String email) async {
      final data = await firestore.collection('users').where('email', isEqualTo: email).get();

      log('data: ${data.docs}');
      if(data.docs.isNotEmpty && data.docs.first.id != user.uid){
        //user exists

log('user exists : ${data.docs.first.data()}');
        firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .doc(data.docs.first.id)
        .set({});
          return true;
      } else {
        return false;
      }
    }

     //forgetting current user info
    static Future<void> getSelfInfo() async {
      await firestore.collection('users').doc(user.uid).get().then((user) async{
        if(user.exists){
          me = ChatUser.fromJson(user.data()!);
          await getFirebaseMessagingToken();

          //for getting user status to active
     APIs.updateActiveStatus(true);
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

    //for getting specific user info
    static Stream<QuerySnapshot<Map<String,dynamic>>> getUserInfo(
      ChatUser chatUser) {
        return firestore
        .collection('users')
        .where('id',isEqualTo: chatUser.Id)
        .snapshots();
      }

      //function to update online or last active status of chat user
      static Future<void> updateActiveStatus(bool isOnline) async{
        firestore
        .collection('users')
        .doc(user.uid).update({
          'is_online' : isOnline,
          'last_active' : DateTime.now().millisecondsSinceEpoch.toString(),
          'push_token' : me.pushToken ,
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
      .orderBy('sent',descending : true)
      .snapshots();
    }

//for sending messages
static Future<void> sendMessage(ChatUser chatuser,String msg,Type type) async{
   //message sending time also used as id
   final time = DateTime.now().millisecondsSinceEpoch.toString();

   final Message message = Message(
    told: chatuser.Id, 
    msg: msg,
     read: '',
      type: type, 
      fromId: user.uid, 
      sent: time);
    final ref = 
    firestore.collection('chats/${getConversationID(chatuser.Id)}/messages/');
    //as soon as the data is set to firebase
    await ref.doc(time).set(message.toJson()).then((value)=>
    sendPushNotification(chatuser, type == Type.text ? msg : 'image'));
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

  //function to send the images in the chat
  static Future<void> sentChatImage(ChatUser chatUser,File file) async {
    //getting the file extension
      final ext = file.path.split('.').last;

    
      final ref = storage.ref().child('images/${getConversationID(chatUser.Id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      //uploading image
      await ref.putFile(file, SettableMetadata(contentType:'image/$ext'))
      .then((p0) {
        log('data referenced: ${p0.bytesTransferred/1000}kb');
      });

//updating image in firesttore database

      final imageUrl = await ref.getDownloadURL();
       await sendMessage(chatUser, imageUrl, Type.image);
  }

  //method to delete the message
  static Future<void> DeleteMessage(Message message) async {

   await firestore.collection('chats/${getConversationID(message.told)}/messages/')
      .doc(message.sent)
      .delete();

      if(message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  //method to update the message
   //method to delete the message
  static Future<void> updateMessage(Message message,String updatedMsg) async {

   await firestore.collection('chats/${getConversationID(message.told)}/messages/')
      .doc(message.sent)
      .update({'msg' : updatedMsg});

      
  }
}