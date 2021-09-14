import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_foxbrain/models/todo.dart';

import 'login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController todoController = TextEditingController();
  late String id;
  CollectionReference todoCollection =
      FirebaseFirestore.instance.collection("todo");

  @override
  void initState() {
    super.initState();
    id = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    super.dispose();
    todoController.clear();
  }

  _addTodo() {
    setState(() {
      todoController.clear();
    });
    return showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 20,
            ),
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Text(
                  "Add Todo",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.grey,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            children: [
              Divider(),
              TextFormField(
                controller: todoController,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.white,
                ),
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "eg. exercise",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                    child: Text("Add"),
                    onPressed: () async {
                      if (todoController.text.isNotEmpty) {
                        Navigator.pop(context);
                        try {
                          var ref = await todoCollection
                              .doc(id)
                              .collection('todos')
                              .doc();
                          Todo todo = Todo(
                            content: todoController.text.trim(),
                            dateCreated: Timestamp.now(),
                            done: false,
                            todoId: ref.id,
                          );
                          await ref.set(todo.toJson());
                          setState(() {
                            todoController.clear();
                          });
                        } catch (e) {
                          print(e.toString());
                        }
                      }
                    }),
              )
            ],
          );
        });
  }

  List<Todo>? todoFromFirestore(QuerySnapshot snapshot) {
    if (snapshot != null) {
      return snapshot.docs.map((e) {
        return Todo(
          todoId: e.id,
          done: e.get('done'),
          dateCreated: e.get('dateCreated'),
          content: e.get('content'),
        );
      }).toList();
    } else {
      return null;
    }
  }

  showAlertDialog(BuildContext context, String todoId) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        setState(() {
          Navigator.pop(context);
        });
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed: () async {
        await todoCollection.doc(id).collection('todos').doc(todoId).delete();
        setState(() {
          Navigator.pop(context);
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Delete Dialog"),
      content: Text("Are you sure?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To Do'),
          actions: [
            InkWell(
              onTap: () async {
                auth.signOut();
                setState(() {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Login()));
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                height: 30,
                width: 50,
                child: Center(child: Text('Logout')),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<List<Todo>?>(
                  stream: firestore
                      .collection('todo')
                      .doc(id)
                      .collection('todos')
                      .orderBy('dateCreated', descending: true)
                      .snapshots()
                      .map(todoFromFirestore),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    List<Todo>? todos = snapshot.data;
                    return Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "All Todos",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 20),
                          ListView.separated(
                              separatorBuilder: (context, index) => Divider(
                                    color: Colors.grey[800],
                                  ),
                              shrinkWrap: true,
                              itemCount: todos!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onLongPress: () => showAlertDialog(
                                      context, todos[index].todoId),
                                  child: Dismissible(
                                    key: Key(todos[index].content),
                                    background: Container(
                                      padding: EdgeInsets.only(left: 20),
                                      alignment: Alignment.centerLeft,
                                      child: Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                    onDismissed: (direction) async {
                                      await todoCollection
                                          .doc(id)
                                          .collection('todos')
                                          .doc(todos[index].todoId)
                                          .delete();
                                    },
                                    child: ListTile(
                                      onTap: () {
                                        todoCollection
                                            .doc(id)
                                            .collection('todos')
                                            .doc(todos[index].todoId)
                                            .update(
                                                {"done": !todos[index].done});
                                      },
                                      leading: Container(
                                        padding: EdgeInsets.all(2),
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: todos[index].done
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                            : Container(),
                                      ),
                                      title: Text(
                                        todos[index].content,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: _addTodo,
          elevation: 0,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
