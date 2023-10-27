
import 'package:chatapp/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs{

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accesing cloud firebase database
    static FirebaseFirestore firestore = FirebaseFirestore.instance;


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
}