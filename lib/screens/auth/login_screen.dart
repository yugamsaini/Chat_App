import 'dart:developer';
import 'dart:io';

//import 'dart:js_interop';

import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    //to show the progress indicator
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      //for hiding progress bar after successfull login
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

//agr user exist then move to home screen
        if((await APIs.userExists()) && mounted){
          //push replacement so that user again login screen pr naaye
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            //if user doesnot exist then create the new user then move to the home screen
        }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
        
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
//to check user is connected to the internet or not
      await InternetAddress.lookup('google.com');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      
      Dialogs.showSnackbar(context, 'Something went wrong(Check Internet!)');
      return null;
    }
  }

//signout function
// _signOut() async{
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }
  @override
  Widget build(BuildContext context) {
//initialising media query(for getting device screen size)
    //mq = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Welcome to We Chat'),
        ),

//stack wrap with widget ->position to give
//top and width to the chat icon
        body: Stack(
          children: [
            //app logo

            AnimatedPositioned(
                //upar se 15% k gap prr
                top: mq.height * .15,

                //left se margin
                //agr animate true hai to icon centre mein hoga
                //agr false hai to wo screen pr unvisible hoga
                right: _isAnimated ? mq.width * .25 : -mq.width * .5,
                width: mq.width * .5,
                duration: const Duration(seconds: 1),
                child: Image.asset('images/chaticon.png')),

            Positioned(
                //bottom se 15% k gap prr
                bottom: mq.height * .15,
                //left se margin
                left: mq.width * .05,
                width: mq.width * .9,
                height: mq.height * .07,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 223, 255, 187),
                        shape: const StadiumBorder(),
                        elevation: 1),

                    //when we click login with google we
                    //will move to the home screen
                    onPressed: () {
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
                      _handleGoogleBtnClick();
                    },
                    icon: Image.asset('images/google.png',
                        height: mq.height * .04),

                    ///to write sign in with google we use rich text
                    label: RichText(
                        //rich text k andr text span hota hai jiske bhot saare children hote hai
                        text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 19),
                            children: [
                          TextSpan(text: 'Login with '),
                          TextSpan(
                              text: 'Google',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ])))),
          ],
        ));
  }
}
