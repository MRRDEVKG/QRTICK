import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qrtick/employee_home/employee_home_page.dart';
import 'package:qrtick/employer_home/employer_home_page.dart';

import 'package:qrtick/http_requests.dart';
import 'package:qrtick/app_colors.dart' as app_colors;

import 'package:qrtick/main.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _userType = 'employee';
  String _user_id = '';
  String _password = '';

  Widget buildId() => TextFormField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.perm_identity_outlined),
          labelText: 'ID',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Enter an ID';
          } else {
            return null;
          }
        },
        maxLength: 15,
        keyboardType: TextInputType.text,
        onSaved: (value) => setState(() => _user_id = value.toString()),
      );

  Widget buildPassword() => TextFormField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.lock_outlined),
          labelText: 'Password',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value!.length < 7) {
            return 'Password must be at least 7 characters long';
          } else {
            return null;
          }
        },
        onSaved: (value) => setState(() => _password = value.toString()),
        maxLength: 30,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
      );

  Widget buildSubmit(double screenWidth, double screenHeight) => ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.greenAccent),
        child: const Text("Login"),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            Response response = await getToken(_user_id, _password);
            if (response.statusCode == 200) {
              Response response1 = await getUserType(
                  _user_id, jsonDecode(response.body)['token']);
              if (response1.statusCode == 200) {
                await ref
                    .read(sharedPreferencesProvider)
                    .setBool('signed_in', true);
                await ref
                    .read(sharedPreferencesProvider)
                    .setString('token', jsonDecode(response.body)['token']);
                await ref
                    .read(sharedPreferencesProvider)
                    .setString('user_id', _user_id);
                await ref
                    .read(sharedPreferencesProvider)
                    .setString('user_type', _userType);

                if (jsonDecode(response1.body)['message'] == true &&
                    _userType == 'employer') {

                  Navigator.pushNamed(context, EmployerHomePage.routeName);

                } else if (jsonDecode(response1.body)['message'] == false &&
                    _userType == 'employee') {

                  Navigator.pushNamed(context, EmployeeHomePage.routeName);

                } else {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("No $_userType with $_user_id id...")));
                }
              } else {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Something went wrong...")));
              }
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Try again...")));
            }
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final screenWidth = (MediaQuery.of(context).size.width /
                MediaQuery.of(context).size.height >
            1)
        ? (2 / 3) * MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width;
    final screenHeight = (19.5 / 9) * screenWidth;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(252, 225, 251, 0.9),
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                height: screenHeight,
                width: screenWidth,
                child: Form(
                  key: _formKey,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: screenHeight / 1.8,
                        child: Container(
                          color: app_colors.chartBlueBackground,
                        ),
                      ),
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: screenHeight / 2,
                          child: Lottie.asset('assets/images/login_page.json')),
                      Positioned(
                        top: screenHeight / 2.37,
                        left: 0,
                        right: 0,
                        height: screenHeight / 2.8,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40)),
                          //color: Colors.green,
                        ),
                      ),
                      Positioned(
                        top: screenHeight / 2.2,
                        left: screenWidth / 10,
                        right: screenWidth / 10,
                        child: Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(color: Colors.black45, width: 1)),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            underline: Container(),
                            value: _userType,
                            onChanged: (String? value) {
                              setState(() {
                                _userType = value!;
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                  child: Text('Employee'), value: 'employee'),
                              DropdownMenuItem(
                                  child: Text('Employer'), value: 'employer'),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight / 1.8,
                        left: screenWidth / 10,
                        right: screenWidth / 10,
                        height: screenHeight / 10,
                        child: buildId(),
                      ),
                      Positioned(
                        top: screenHeight / 1.5,
                        left: screenWidth / 10,
                        right: screenWidth / 10,
                        height: screenHeight / 10,
                        child: buildPassword(),
                      ),
                      Positioned(
                        top: screenHeight / 1.2,
                        left: screenWidth / 10,
                        right: screenWidth / 10,
                        child: buildSubmit(screenWidth, screenHeight),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
