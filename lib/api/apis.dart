
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs{

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accesing cloud firebase database
    static FirebaseFirestore firestore = FirebaseFirestore.instance;

}