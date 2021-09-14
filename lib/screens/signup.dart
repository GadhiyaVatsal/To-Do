import 'package:flutter/material.dart';
import 'package:todo_foxbrain/service/auth.dart';

import 'home_screen.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool isLoading = false;

  _signup() async {
    try {
      setState(() {
        isLoading = true;
        Navigator.of(context).pop();
      });
      var result = await _auth.registerUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        userName: nameController.text.trim(),
      );
      if (result == null) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('could not sign up'),
          ));
        });
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(hintText: "Full Name"),
                    controller: nameController,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: "Email"),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(hintText: "Password"),
                    obscureText: true,
                    controller: passwordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          child: const Text("Sign Up"),
                          onPressed: _signup,
                        ),
                  const SizedBox(
                    height: 20,
                  ),
                  isLoading
                      ? SizedBox()
                      : InkWell(
                          onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Login())),
                          child: Container(
                              height: 30,
                              width: 50,
                              child: const Text("Login")),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
