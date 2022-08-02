import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrtick/employer_home/AddUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qrtick/employee_home/employee_attendance_list_page.dart';
import 'package:qrtick/employee_home/employee_home_page.dart';
import 'package:qrtick/employee_home/employee_profile_page.dart';

import 'package:qrtick/employer_home/employer_attendance_list_page.dart';
import 'package:qrtick/employer_home/employer_home_page.dart';

import 'package:qrtick/login/login_page.dart';
import 'package:qrtick/qr_code_scanner_page.dart';


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      // override the previous value with the new object
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String initial_route = LoginPage.routeName;

    if (ref.read(sharedPreferencesProvider).getBool('signed_in') != null) {
      if (ref.read(sharedPreferencesProvider).getBool('signed_in') == true) {
        if (ref.read(sharedPreferencesProvider).getString('user_type') ==
            'employee') {
          initial_route = EmployeeHomePage.routeName;
        }
        if (ref.read(sharedPreferencesProvider).getString('user_type') ==
            'employer') {
            initial_route = EmployerHomePage.routeName;
        }
      }
    }
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initial_route,
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),

        EmployeeHomePage.routeName: (context) => const EmployeeHomePage(),
        EmployeeProfilePage.routeName: (context) => const EmployeeProfilePage(),
        EmployeeAttendanceListPage.routeName: (context) =>
            const EmployeeAttendanceListPage(),

        EmployerHomePage.routeName: (context) => const EmployerHomePage(),
        EmployerAttendanceListPage.routeName: (context) =>
        const EmployerAttendanceListPage(),
        AddUserPage.routeName: (context) => const AddUserPage(),

        QRCodeScannerPage.routeName: (context) => const QRCodeScannerPage(),
      },
    );
  }
}
