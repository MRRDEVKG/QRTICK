import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qrtick/design.dart';
import 'package:qrtick/employee_home/employee_profile_page.dart';
import 'package:qrtick/http_requests.dart';
import 'package:qrtick/models/auth_model.dart';
import 'package:qrtick/models/user_model.dart';
import 'package:qrtick/app_colors.dart' as app_colors;
import 'package:qrtick/models/sliver_persistent_header_delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrtick/main.dart';
import 'package:http/http.dart';


class AddUserPage extends ConsumerStatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);
  static const routeName = '/add_user';

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends ConsumerState<AddUserPage> {
  List<dynamic> users = [];
  List<dynamic> sort_user_type = [];
  List<dynamic> employers = [];
  int _selectedIndex = 0;

  Future<void> updateTable() async {
    String token = ref.read(sharedPreferencesProvider).getString('token')!;
    Response response = await getUserAuth(token);
    if (response.statusCode == 200) {
      users = jsonDecode(response.body);
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong...")));
    }
    if (_selectedIndex == 0) {
      sort_user_type = users
          .where((element) =>
              (element['is_staff'] == false && element['profile'] != null))
          .toList();
    } else if (_selectedIndex == 1)
      sort_user_type =
          users.where((element) => (element['is_staff'] == true)).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateTable();
  }

  void _onItemTapped(int index) {
    _selectedIndex = index;
    updateTable();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double bigWidthPadding = 0;
    if (screenWidth > screenHeight) {
      screenWidth = screenWidth * (2 / 3);
      bigWidthPadding = screenWidth * (1 / 3) / 2;
    }
    screenHeight = (19.5 / 9) * screenWidth;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 225, 251, 0.9),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // backgroundColor: Colors.deepPurpleAccent,
        showUnselectedLabels: true,
        // showSelectedLabels: false,
        selectedItemColor: Colors.deepPurpleAccent,
        selectedIconTheme: IconThemeData(size: 30),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_pin_outlined,
              color: Colors.blueAccent,
            ),
            label: 'Employee',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_pin_rounded,
              color: Colors.blueAccent,
            ),
            label: 'Employer',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            // collapsedHeight: screenHeight / 15,
            expandedHeight: screenHeight / 3.75,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.all(screenWidth / 30),
                color: app_colors.chartBlueBackground,
                child: Lottie.asset('assets/images/search_profile_1.json'),
              ),
            ),
          ),
          SliverPersistentHeader(
            floating: true,
            pinned: false,
            delegate: SliverAppBarDelegate(
              minHeight: screenHeight / 10,
              maxHeight: screenHeight / 10,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 50),
                  child: Container(
                    height: screenHeight / 10,
                    child: Card(
                      child: ListTile(
                        title: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              _selectedIndex == 0
                                  ? Text(
                                      'Employee',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.blue),
                                    )
                                  : Text(
                                      'Employer',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.blue),
                                    ),
                              FloatingActionButton.small(
                                onPressed: () async {
                                  await updateTable();
                                },
                                child: Icon(
                                  Icons.refresh,
                                  size: 30,
                                ),
                                backgroundColor: Colors.greenAccent,
                              ),
                            ],
                          ),
                        ),
                        leading: SizedBox(
                          width: screenWidth / 3.4,
                          child: OutlinedButton(
                            //  alignment: Alignment.center,

                            onPressed: () {
                              showDialog(
                                  barrierColor: Colors.transparent,
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    if (_selectedIndex == 0) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        final _local_FormKey =
                                            GlobalKey<FormState>();
                                        String name = '';
                                        String surname = '';
                                        String department = '';
                                        String designation = '';

                                        return AlertDialog(
                                          backgroundColor: const Color.fromRGBO(
                                              252, 225, 251, 0.9),
                                          content: SizedBox(
                                            height: screenHeight / 2.5,
                                            width: screenWidth * (2.5 / 3) + 25,
                                            child: Form(
                                              key: _local_FormKey,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: name,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .person_outline),
                                                        labelText: 'Name',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Enter name';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 50,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (value) {
                                                        name = value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: surname,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .person_outline),
                                                        labelText: 'Surname',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Enter surname';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 50,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (value) {
                                                        surname =
                                                            value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: department,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .group_outlined),
                                                        labelText: 'Department',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Enter department';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 100,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (value) {
                                                        department =
                                                            value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: designation,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .engineering_outlined),
                                                        labelText:
                                                            'Designation',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Enter designation';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 100,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (value) {
                                                        designation =
                                                            value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  FloatingActionButton(
                                                    onPressed: () async {
                                                      if (_local_FormKey
                                                          .currentState!
                                                          .validate()) {
                                                        _local_FormKey
                                                            .currentState!
                                                            .save();
                                                        String token = ref
                                                            .read(
                                                                sharedPreferencesProvider)
                                                            .getString(
                                                                'token')!;
                                                        Response response =
                                                            await AddUser(
                                                                token: token,
                                                                name: name,
                                                                surname:
                                                                    surname,
                                                                department:
                                                                    department,
                                                                designation:
                                                                    designation);
                                                        if (response
                                                                .statusCode ==
                                                            201) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "Employee added successfully...")),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "User_id: ${jsonDecode(response.body)['user_id']}, Password: ${jsonDecode(response.body)['user_id']}")),
                                                          );

                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Try again! Something went wrong...")));
                                                        }
                                                      }
                                                    },
                                                    child: Text('Add'),
                                                  ),
                                                ])
                                          ],
                                        );
                                      });
                                    } else {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        final _local_FormKey =
                                            GlobalKey<FormState>();
                                        String user_id = '';
                                        String password = '';

                                        return AlertDialog(
                                          backgroundColor: const Color.fromRGBO(
                                              252, 225, 251, 0.9),
                                          content: SizedBox(
                                            height: screenHeight / 2.5,
                                            width: screenWidth * (2.5 / 3) + 25,
                                            child: Form(
                                              key: _local_FormKey,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: user_id,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .person_outline),
                                                        labelText: 'User id',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Enter user id';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 50,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (value) {
                                                        user_id =
                                                            value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: password,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .lock_outlined),
                                                        labelText: 'Password',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.length < 7) {
                                                          return 'Password must be at least 7 characters long';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 50,
                                                      obscureText: true,
                                                      keyboardType:
                                                          TextInputType
                                                              .visiblePassword,
                                                      onSaved: (value) {
                                                        password =
                                                            value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  FloatingActionButton(
                                                    onPressed: () async {
                                                      if (_local_FormKey
                                                          .currentState!
                                                          .validate()) {
                                                        _local_FormKey
                                                            .currentState!
                                                            .save();
                                                        String token = ref
                                                            .read(
                                                                sharedPreferencesProvider)
                                                            .getString(
                                                                'token')!;

                                                        Response response =
                                                            await AddStaff(
                                                                token: token,
                                                                user_id:
                                                                    user_id,
                                                                password:
                                                                    password);

                                                        if (response
                                                                .statusCode ==
                                                            201) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "Employer added successfully...")),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "User_id: ${jsonDecode(response.body)['user_id']}, Password: $password")),
                                                          );

                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Try again! Something went wrong...")));
                                                        }
                                                      }
                                                    },
                                                    child: Text('Add'),
                                                  ),
                                                ])
                                          ],
                                        );
                                      });
                                    }
                                  });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_add_outlined,
                                  color: Colors.greenAccent,
                                  size: screenWidth / 10,
                                ),
                                Text(
                                  "Add",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.greenAccent),
                                ),
                              ],
                            ),
                          ),
                        ),
                        trailing: SizedBox(
                          width: screenWidth / 3.4,
                          child: OutlinedButton(
                            onPressed: () {
                              showDialog(
                                  barrierColor: Colors.transparent,
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        final _local_FormKey =
                                            GlobalKey<FormState>();
                                        String user_id = '';

                                        return AlertDialog(
                                          backgroundColor: const Color.fromRGBO(
                                              252, 225, 251, 0.9),
                                          content: SizedBox(
                                            height: screenHeight / 2.5,
                                            width: screenWidth * (2.5 / 3) + 25,
                                            child: Form(
                                              key: _local_FormKey,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: TextFormField(
                                                      initialValue: user_id,
                                                      decoration:
                                                          const InputDecoration(
                                                        prefixIcon: Icon(Icons
                                                            .person_outline),
                                                        labelText: 'user_id',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return 'Enter user id';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLength: 20,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      onSaved: (value) {
                                                        user_id =
                                                            value.toString();
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  FloatingActionButton(
                                                    onPressed: () {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop();
                                                    },
                                                    child: Text('Cancel'),
                                                  ),
                                                  FloatingActionButton(
                                                    onPressed: () async {
                                                      if (_local_FormKey
                                                          .currentState!
                                                          .validate()) {
                                                        _local_FormKey
                                                            .currentState!
                                                            .save();
                                                        String token = ref
                                                            .read(
                                                                sharedPreferencesProvider)
                                                            .getString(
                                                                'token')!;
                                                        int id = users.where((element) => (element['user_id'] == user_id)).toList()[0]['id'];
                                                        Response response =
                                                            await DeleteUser(
                                                                token: token,
                                                                id:
                                                                    id);
                                                        if (response
                                                                .statusCode ==
                                                            204) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    "User with  $user_id id deleted successfully...")),
                                                          );

                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .removeCurrentSnackBar();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      "Try again! Something went wrong...")));
                                                        }
                                                      }
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                ])
                                          ],
                                        );
                                      });
                                    }
                                  );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_remove_outlined,
                                  color: Colors.greenAccent,
                                  size: screenWidth / 10,
                                ),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.greenAccent),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //  title: IconButton()
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, index) {
                dynamic user = _selectedIndex == 0
                    ? User.fromJson(sort_user_type[index]['profile'])
                    : Auth.fromJson(sort_user_type[index]);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 30),
                    child: Card(
                      child: _selectedIndex == 0
                          ? ListTile(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, EmployeeProfilePage.routeName,
                                    arguments: user);
                              },
                              leading: Container(
                                width: screenWidth / 7,
                                child: ProfileWidget(
                                  size: screenWidth / 8,
                                  imagePath: user.imagePath != null ? user.imagePath : '',
                                  onClicked: () {},
                                ),
                              ),
                              isThreeLine: true,
                              title: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.user_id,
                                    style: TextStyle(
                                        color: Colors.blueAccent, fontSize: 16),
                                  ),
                                  Text(
                                    '${user.name} ${user.surname}',
                                    style: TextStyle(
                                        color: Colors.deepPurpleAccent,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.department,
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                  Text(
                                    user.designation,
                                    style:
                                        TextStyle(color: Colors.orangeAccent),
                                  ),
                                ],
                              ),
                            )
                          : ListTile(
                              onTap: () {},
                              title: Container(
                                width: screenWidth / 7,
                                child: Text(user.user_id),
                              ),
                            ),
                    ),
                  ),
                );
              },
              childCount: sort_user_type.length,
            ),
          ),
        ],
      ),
    );
  }
}
