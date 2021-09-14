import 'package:cloud_firestore/cloud_firestore.dart';

class UserId {
  late String uid;

  UserId({required this.uid});
}

class UserModel {
  late String? id;
  late String userName;
  late String email;
  late String password;

  UserModel(
      {required this.id,
      required this.email,
      required this.password,
      required this.userName});

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    print(snapshot['userName']);
    print(snapshot.data());
    userName = snapshot['userName'];
    email = snapshot['email'];
    id = snapshot['id'];
    password = snapshot['password'];
  }
}
