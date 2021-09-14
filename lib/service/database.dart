import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_foxbrain/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollecation =
      FirebaseFirestore.instance.collection('user');

  Future<void> addUser(String email, String password, String userName) async {
    return await userCollecation.doc(uid).set({
      'userName': userName,
      'email': email,
      'password': password,
    });
  }

  // user data from snapshots
  UserModel _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserModel(
      id: uid,
      userName: snapshot['userName'],
      email: snapshot['email'],
      password: snapshot['password'],
    );
  }

  // get user doc stream
  Stream<UserModel> get userData {
    return userCollecation.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
