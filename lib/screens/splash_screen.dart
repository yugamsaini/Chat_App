import 'dart:developer';
//import 'dart:js_interop';

import 'package:chatapp/api/apis.dart';
import 'package:chatapp/screens/auth/login_screen.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SplashScreen> {
 bool _isAnimated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //our splash will show only for 1.5 second and then it will move to the HOme screen
    Future.delayed(const Duration(seconds: 2),(){
//exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white)
      );

//if the user is already login then it should show the home screen
      if(APIs.auth.currentUser != null){
      log('\nUser: ${FirebaseAuth.instance.currentUser}');
      log('\nUserAdditionalInfo: ${APIs.auth.currentUser}');
        //navigate to home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
      } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));
      }
      // setState(() {
      //   _isAnimated=true;
      // });

      //navigate to home screen
     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));
    });
  }


  @override
  Widget build(BuildContext context) {

//initialising media query(for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
       automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
        
      ),

//stack wrap with widget ->position to give
//top and width to the chat icon
      body: Stack(children: [
        //app logo

        Positioned(
          //upar se 15% k gap prr
          top:mq.height* .15,

          //left se margin
          //agr animate true hai to icon centre mein hoga
          //agr false hai to wo screen pr unvisible hoga
          right:  mq.width* .25,
          width:mq.width* .5,
          //duration:const Duration(seconds: 1),
          child: Image.asset('images/chaticon.png')),

          Positioned(
          //bottom se 15% k gap prr
          bottom:mq.height* .15,
         
          width:mq.width,
          
          child: Center(
            child: Text('MADE BY YUGAM',style: TextStyle(fontSize: 16,
            color:Colors.black87,
            letterSpacing: .5),),
          )
           ),
          ],)
    );
  }
}