import 'package:flutter/material.dart';

class Dialogs{
  static void showSnackbar(BuildContext context,String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(msg),backgroundColor: Colors.blue.withOpacity(.8),
    behavior: SnackBarBehavior.floating));
  }

//method to show the progress bar
  static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (_)=>const Center(child: CircularProgressIndicator(strokeWidth: 1,
    )));
  }
}