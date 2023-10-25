//import 'package:chatapp/screens/auth/login_screen.dart';
//import 'package:chatapp/screens/home_screen.dart';
import 'package:chatapp/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

//global object for accessing device screen size
//mq as media query
late Size mq;
void main() {
   
  WidgetsFlutterBinding.ensureInitialized();

  //to show the screen in the full screen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//for the app to work only in portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value){
    _initializeFirebase();
  runApp(const MyApp());
  });
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Chat',

      //this is the custom appbar theme
      //in every page of the app it will remain same
      //so we have define it the main file
      theme: ThemeData(
        appBarTheme: const AppBarTheme(

          centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color:Colors.black),
         titleTextStyle: TextStyle(color:Colors.black, 
         fontWeight:FontWeight.normal,
      fontSize: 19
      ),backgroundColor: Colors.white 

        )
      ),
      home:const SplashScreen(),
      //home: const MyHomePage(title: 'Flutter Demo Home '),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);
}
