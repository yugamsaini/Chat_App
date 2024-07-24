
import 'package:cached_network_image/cached_network_image.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
//import 'package:chatapp/widgets/chat_user_card.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chat_user.dart';

//view profile screen to show the details of current login user

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding the keyboard
      //when we edit the name or about then the keyboard comes
      //and when we tap any where on the screen the keyboard will hide
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: 
          Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text('Joined On : ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 16)),
                      Text(MyDateUtil.getLastMessageTime(
                        context: context, time: widget.user.createdAt,showYear: true),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16)),
                    ],
                  ),
          

          
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //for adding some space
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  //for the user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,

                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(
                              child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  SizedBox(height: mq.height * .03),

                  //showing the user email below the profile picture
                  Text(widget.user.email,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 16)),

                  SizedBox(height: mq.height * .02),

//user about information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text('About: ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 16)),
                      Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16)),
                    ],
                  ),
                

                ], 
              ),
            ),
          )),
    );
  }

  //bottom  sheet for picking the profile picture for user
  //we will call it in position edit button
  
}
