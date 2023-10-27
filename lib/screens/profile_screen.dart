import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screens/auth/login_screen.dart';
//import 'package:chatapp/widgets/chat_user_card.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../helper/dialogs.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),

//bottom right corner flaoting button
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(

            //color of the logout button
            backgroundColor: Colors.redAccent,
              onPressed: () async {
                Dialogs.showProgressBar(context);
            //sign out fromthe app
                await APIs.auth.signOut().then((value) async{
                  await GoogleSignIn().signOut().then((value) {

                    //for hiding the progress dialog
                    Navigator.pop(context);

                    //for moving to the home screen
                    Navigator.pop(context);
                    //after click on logout button move to the login screen
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                  });
                });
                
              },
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('Logout')
              ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            children: [
              //for adding some space
              SizedBox(
                width: mq.width,
                height: mq.height * .03,
              ),
              //for the user profile picture
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,

                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),

//adding the profile edit button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MaterialButton(onPressed: (){},
                    shape:const CircleBorder(),
                    color:Colors.white,
                    child:Icon(Icons.edit,color:Colors.blue),
                    ),
                  )
                ],
              ),

              SizedBox(height: mq.height * .03),

              //showing the user email below the profilepicture
              Text(widget.user.email,
                  style: const TextStyle(color: Colors.black54, fontSize: 16)),

              SizedBox(height: mq.height * .05),

              TextFormField(
                initialValue: widget.user.name,
                //styling the name
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'eg. Happy Singh',
                    label: Text('Name')),
              ),

              SizedBox(height: mq.height * .02),

              TextFormField(
                initialValue: widget.user.about,
                //styling the name
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    hintText: 'eg. Feeling Awesome',
                    label: Text('About')),
              ),


SizedBox(height: mq.height * .05),

              ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape:const StadiumBorder(),
              minimumSize: Size(mq.width*.5,
              mq.height * .06)
              ),
              onPressed:(){},
              icon:const Icon(Icons.edit,size:28),
               label: const Text ('UPDATE', style:TextStyle(fontSize: 16)),
               )
            ],
          ),
        ));
  }
}