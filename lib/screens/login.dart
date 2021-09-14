import 'package:flutter/material.dart';
import 'package:todo_foxbrain/screens/signup.dart';
import 'package:todo_foxbrain/service/auth.dart';

import 'home_screen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool isLoading = false;

  _signin() async {
    try {
      setState(() {
        isLoading = true;
        Navigator.of(context).pop();
      });
      var result = await _auth.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
      /*.then((result) {
        String _userId = result.user!.uid;
        FirebaseService().initializeUserModel(_userId);*/
      if (result == null) {
        isLoading = false;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('could not sign in'),
        ));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(hintText: "Email"),
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              const SizedBox(
                height: 40,
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: "Password"),
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      child: const Text("Log In"),
                      onPressed: _signin,
                    ),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? SizedBox()
                  : InkWell(
                      onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Signup())),
                      child: Container(
                          height: 30, width: 50, child: const Text("Signup")),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
