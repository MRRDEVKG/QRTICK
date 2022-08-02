import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:qrtick/login/login_page.dart';
import 'package:qrtick/models/work_schedule.dart';
import 'package:qrtick/app_colors.dart' as app_colors;
import 'package:qrtick/employee_home/employee_attendance_list_page.dart';
import 'package:qrtick/employee_home/employee_profile_page.dart';
import 'package:qrtick/http_requests.dart';
import 'package:qrtick/models/sliver_persistent_header_delegate.dart';
import 'package:qrtick/qr_code_scanner_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrtick/main.dart';
import 'package:http/http.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:qrtick/models/user_model.dart';

class EmployeeHomePage extends ConsumerStatefulWidget {
  static const routeName = '/employee_home';
  const EmployeeHomePage({Key? key}) : super(key: key);

  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends ConsumerState<EmployeeHomePage> {
  String month_year = '';
  String date = '';
  String from_time = '';
  String to_time = '';
  String day_of_week = '';
  List<dynamic> work_schedule = [];
  Map<String, double> attendanceResults = <String, double>{
    "Absent": 0.1,
    "Present": 0.1,
    "Late coming": 0.1,
    "Early leaving": 0.1,
  };

  Future<void> updatePieChart() async {
    String month = DateTime.now().month.toString().padLeft(2, '0');
    String year = DateTime.now().year.toString();

    double absent = 0.019,
        present = 0.019,
        late_coming = 0.019,
        early_leaving = 0.019;

    String user_id = ref.read(sharedPreferencesProvider).getString('user_id')!;
    String token = ref.read(sharedPreferencesProvider).getString('token')!;
    Response response =
        await getUserMonthlyAttendance(user_id, token, month, year);
    if (response.statusCode == 200) {
      for (Map<String, dynamic> daily_total in jsonDecode(response.body)) {
        if (!daily_total['present']) {
          absent += 1;
        } else {
          present += 1;
          if (daily_total['arrival_time_difference'] < 0) late_coming += 1;

          if (daily_total['departure_time_difference'] != null &&
              daily_total['departure_time_difference'] < 0) early_leaving += 1;
        }
      }
      attendanceResults['Absent'] = absent;
      attendanceResults['Present'] = present;
      attendanceResults['Late coming'] = late_coming;
      attendanceResults['Early leaving'] = early_leaving;
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong...")));
    }
  }

  Future<void> initializeScreen() async {
    if (ref.read(sharedPreferencesProvider).getString('date') == null) {
      print("###############################################");
      String token = ref.read(sharedPreferencesProvider).getString('token')!;
      Response response = await currentSchedule(token);
      Response response_schedule = await workSchedule(token);
      await updatePieChart();
      if (response.statusCode == 200 && response_schedule.statusCode == 200) {
        month_year = jsonDecode(response.body)['month_year'];
        date = jsonDecode(response.body)['date'];
        from_time = jsonDecode(response.body)['from_time'];
        to_time = jsonDecode(response.body)['to_time'];
        day_of_week = jsonDecode(response.body)['day_of_week'];

        work_schedule = jsonDecode(response_schedule.body);

        await ref
            .read(sharedPreferencesProvider)
            .setString('date', jsonDecode(response.body)['date']);
        if (ref.read(sharedPreferencesProvider).get('arrival_scanned') ==
                null &&
            ref.read(sharedPreferencesProvider).get('departure_scanned') ==
                null) {
          await ref
              .read(sharedPreferencesProvider)
              .setBool('arrival_scanned', false);
          await ref
              .read(sharedPreferencesProvider)
              .setBool('departure_scanned', false);
        }
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Something went wrong...")));
      }

      setState(() {});
    }
  }

  Future<void> updateScreen() async {
    DateTime today = DateTime.now();
    String str_today = today.day.toString().padLeft(2, '0') +
        '-' +
        today.month.toString().padLeft(2, '0') +
        '-' +
        today.year.toString();
    if (ref.read(sharedPreferencesProvider).getString('date') != null &&
        ref.read(sharedPreferencesProvider).getString('date') != str_today) {
      print(str_today);
      await ref.read(sharedPreferencesProvider).remove('date');
      await ref
          .read(sharedPreferencesProvider)
          .setBool('arrival_scanned', false);
      await ref
          .read(sharedPreferencesProvider)
          .setBool('departure_scanned', false);
      initializeScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(sharedPreferencesProvider).remove('date');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double bigWidthPadding = 0;
    if (screenWidth > screenHeight) {
      screenWidth = screenWidth * (2 / 3);
      bigWidthPadding = screenWidth * (1 / 3) / 2;
    }
    screenHeight = (19.5 / 9) * screenWidth;

    initializeScreen();
    updateScreen();

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(animated: true);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(252, 225, 251, 0.9),
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () async {
                      await ref.read(sharedPreferencesProvider).clear();
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.routeName, (route) => false);
                    },
                    icon: Icon(Icons.logout))
              ],
              expandedHeight: screenHeight / 2.5,
              flexibleSpace: Padding(
                padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                child: FlexibleSpaceBar(
                  background: Container(
                    color: app_colors.chartBlueBackground,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight / 16,
                        ),
                        Text(
                          " $month_year ",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: screenHeight / 100,
                        ),
                        Flexible(
                          child: Stack(children: [
                            PieChart(
                              dataMap: attendanceResults,
                              chartLegendSpacing: 40,
                              legendOptions: const LegendOptions(
                                legendTextStyle: TextStyle(fontSize: 11.8),
                                showLegendsInRow: true,
                                legendPosition: LegendPosition.bottom,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                ),
                                padding: EdgeInsets.all(0),
                                onPressed: () {},
                                color: Colors.white,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                ),
                                padding: const EdgeInsets.all(0),
                                onPressed: () {},
                                color: Colors.white,
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverAppBarDelegate(
                minHeight: screenHeight / 3.5,
                maxHeight: screenHeight / 3.5,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                  child: Container(
                    height: screenHeight / 3.5,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(40)),
                      color: app_colors.chartBlueBackground,
                    ),
                    padding: EdgeInsets.all(screenWidth / 40),
                    child: Container(
                      //height: screenHeight / 4,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      from_time,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FloatingActionButton(
                                      heroTag: null,
                                      backgroundColor: Colors.greenAccent,
                                      child: const Icon(
                                          Icons.arrow_forward_rounded),
                                      onPressed: () {
                                        bool arrival_scanned = ref
                                            .read(sharedPreferencesProvider)
                                            .getBool('arrival_scanned')!;
                                        if (arrival_scanned == false) {
                                          Navigator.pushNamed(context,
                                              QRCodeScannerPage.routeName,
                                              arguments:
                                                  ScreenArguments('arrival'));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      " $date ",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Lottie.asset(
                                      'assets/images/qr_code_scanner.json',
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      to_time,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FloatingActionButton(
                                        heroTag: null,
                                        backgroundColor: Colors.greenAccent,
                                        child: const Icon(
                                            Icons.arrow_back_rounded),
                                        onPressed: () {
                                          bool arrival_scanned = ref
                                              .read(sharedPreferencesProvider)
                                              .getBool('arrival_scanned')!;
                                          bool departure_scanned = ref
                                              .read(sharedPreferencesProvider)
                                              .getBool('departure_scanned')!;
                                          if (arrival_scanned == true &&
                                              departure_scanned == false) {
                                            Navigator.pushNamed(context,
                                                QRCodeScannerPage.routeName,
                                                arguments: ScreenArguments(
                                                    'departure'));
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: SliverAppBarDelegate(
                minHeight: screenHeight / 3.3,
                maxHeight: screenHeight / 3.3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth / 40),
                    child: Column(
                      children: [
                        Container(
                            height: screenHeight / 5,
                            decoration: const BoxDecoration(
                                color: const Color.fromRGBO(252, 225, 251, 0.9),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: OutlinedButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context,
                                          EmployeeAttendanceListPage.routeName),
                                      child: const Icon(
                                        Icons.list_alt_outlined,
                                        size: 80,
                                      )),
                                ),
                                Flexible(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await ref
                                          .read(sharedPreferencesProvider)
                                          .remove('date');
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      Icons.refresh,
                                      size: 80,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: OutlinedButton(
                                      onPressed: () async {
                                        String token = ref
                                            .read(sharedPreferencesProvider)
                                            .getString('token')!;
                                        String user_id = ref
                                            .read(sharedPreferencesProvider)
                                            .getString('user_id')!;
                                        Response response = await GetUser(
                                            token: token, user_id: user_id);
                                        if (response.statusCode == 200) {
                                          User user = User.fromJson(jsonDecode(response.body));
                                          Navigator.pushNamed(context,
                                              EmployeeProfilePage.routeName,
                                          arguments: user);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Something went wrong...")));
                                        }
                                      },
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 80,
                                      )),
                                ),
                              ],
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: screenWidth / 40),
                          child: Container(
                              height: screenHeight / 15,
                              color: const Color.fromRGBO(252, 225, 251, 0.9),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 30,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    Icon(
                                      Icons.location_off_outlined,
                                      size: 30,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ])),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, index) {
                  WorkSchedule day_schedule =
                      WorkSchedule.fromJson(work_schedule[index]);
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth / 30),
                      child: Card(
                        child: ListTile(
                            selected: day_schedule.day_of_week == day_of_week,
                            selectedColor: Colors.orange,
                            leading: Icon(
                              Icons.timer,
                              size: 40,
                              color: day_schedule.is_day_off
                                  ? null
                                  : Colors.greenAccent,
                            ),
                            isThreeLine: true,
                            title: Center(
                              child: Text(
                                day_schedule.day_of_week,
                                style:
                                    TextStyle(color: Colors.deepPurpleAccent),
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text("Arrival"),
                                    Text(
                                      day_schedule.from_time != null
                                          ? day_schedule.from_time
                                              .toString()
                                              .substring(0, 5)
                                          : '__:__',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("Departure"),
                                    Text(
                                      day_schedule.to_time != null
                                          ? day_schedule.to_time
                                              .toString()
                                              .substring(0, 5)
                                          : '__:__',
                                      style:
                                          TextStyle(color: Colors.blueAccent),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.timer_off,
                              size: 40,
                              color: day_schedule.is_day_off
                                  ? null
                                  : Colors.greenAccent,
                            )),
                      ),
                    ),
                  );
                },
                childCount: work_schedule.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
