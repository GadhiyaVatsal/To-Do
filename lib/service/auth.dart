import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_foxbrain/models/user.dart';

import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserId? _userFromFirebaseUser(User user) {
    return user != null ? UserId(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserId?> get user {
    var status = _auth.authStateChanges();
    return status.map((event) => _userFromFirebaseUser(event!));
  }

  //login
  Future signIn({required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign up
  Future registerUser(
      {required String email,
      required String password,
      required String userName}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      // create a new document for the user with the uid
      await DatabaseService(uid: user?.uid).addUser(email, password, userName);
      return _userFromFirebaseUser(user!);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  //log out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
