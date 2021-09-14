import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_foxbrain/screens/home_screen.dart';
import 'package:todo_foxbrain/screens/login.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    print(user);
    if (user == null) {
      return Login();
    } else {
      return HomeScreen();
    }
  }
}
