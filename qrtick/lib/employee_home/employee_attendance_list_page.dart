import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qrtick/http_requests.dart';
import 'package:qrtick/models/arrival_departure_model.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:qrtick/app_colors.dart' as app_colors;
import 'package:qrtick/models/sliver_persistent_header_delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrtick/main.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class EmployeeAttendanceListPage extends ConsumerStatefulWidget {
  const EmployeeAttendanceListPage({Key? key}) : super(key: key);
  static const routeName = '/employee_attendance_list';

  @override
  _EmployeeAttendanceListPageState createState() =>
      _EmployeeAttendanceListPageState();
}

class _EmployeeAttendanceListPageState
    extends ConsumerState<EmployeeAttendanceListPage> {
  List<dynamic> userMonthlyAttendance = [];
  List<dynamic> sortedMonthlyAttendance = [];
  String month = DateTime.now().month.toString().padLeft(2, '0');
  String year = DateTime.now().year.toString();
  double total = 0;
  int _selectedIndex = 0;

  Future<void> updateTable() async {
    total = 0;
    String user_id = ref.read(sharedPreferencesProvider).getString('user_id')!;
    String token = ref.read(sharedPreferencesProvider).getString('token')!;
    Response response =
        await getUserMonthlyAttendance(user_id, token, month, year);
    if (response.statusCode == 200) {
      userMonthlyAttendance = jsonDecode(response.body);
      sortedMonthlyAttendance = userMonthlyAttendance;
      for (Map<String, dynamic> daily_total in userMonthlyAttendance) {
        total += daily_total['total_time'];
      }
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong...")));
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateTable();
  }

  void _onItemTapped(int index) {
    if (index == 0)
      sortedMonthlyAttendance = userMonthlyAttendance;
    else if (index == 1)
      sortedMonthlyAttendance = userMonthlyAttendance
          .where((element) => (element['arrival_time_difference'] != null)
              ? (element['arrival_time_difference'] < 0)
              : false)
          .toList();
    else if (index == 2)
      sortedMonthlyAttendance = userMonthlyAttendance
          .where((element) => (element['departure_time_difference'] != null)
              ? (element['departure_time_difference'] < 0)
              : false)
          .toList();
    else if (index == 3)
      sortedMonthlyAttendance = userMonthlyAttendance
          .where((element) => (element['present'] == false))
          .toList();

    setState(() {
      _selectedIndex = index;
    });
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
              Icons.timer,
              color: Colors.greenAccent,
            ),
            label: 'General',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.timer_off,
              color: Colors.blueAccent,
            ),
            label: 'Late Arrive',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.timer_off,
              color: Colors.orangeAccent,
            ),
            label: 'Left Early',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.timer,
              color: Colors.redAccent,
            ),
            label: 'Absent',
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
                child: Lottie.asset('assets/images/attendance_list.json'),
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: SliverAppBarDelegate(
              minHeight: screenHeight / 5.25, // 5.4
              maxHeight: screenHeight / 5.4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth / 40),
                  child: Container(
                    height: screenHeight / 5.5,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 30),
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(252, 225, 251, 0.9),
                        borderRadius: BorderRadius.circular(40)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Flexible(
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.timer,
                                color: Colors.greenAccent,
                              ),
                              title: Text("Approved"),
                            ),
                          ),
                          Flexible(
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.timer,
                                color: Colors.redAccent,
                              ),
                              title: Text("Absent"),
                            ),
                          ),
                        ]),
                        Row(children: [
                          Flexible(
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.timer_off,
                                color: Colors.blueAccent,
                              ),
                              title: Text("Late Arrive"),
                            ),
                          ),
                          Flexible(
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.timer_off,
                                color: Colors.orangeAccent,
                              ),
                              title: Text("Left Early"),
                            ),
                          ),
                        ]),
                        //  Expanded(child:
                        Row(children: [
                          Flexible(
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.timer_off,
                                color: Colors.purpleAccent,
                              ),
                              title: Text("Late Arrive and Left Early"),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
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
                        title: Text(
                          DateFormat.MMMM()
                              .format(DateTime.parse('2022-$month-01')),
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                        subtitle: Text(
                          year,
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        ),
                        trailing: Container(
                          width: screenWidth / 2.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () async {
                                  await updateTable();
                                },
                                child: Icon(
                                  Icons.refresh,
                                  size: 30,
                                ),
                                backgroundColor: Colors.greenAccent,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Total",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    total.toStringAsFixed(2) + 'H',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.orangeAccent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        leading: OutlinedButton(
                          //  alignment: Alignment.center,
                          onPressed: () {
                            showDialog(
                                barrierColor: Colors.transparent,
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return SfDateRangePicker(
                                    backgroundColor: const Color.fromRGBO(
                                        252, 225, 251, 0.9),
                                    showActionButtons: true,
                                    navigationMode:
                                        DateRangePickerNavigationMode.snap,
                                    view: DateRangePickerView.year,
                                    showNavigationArrow: true,
                                    confirmText: '          OK          ',
                                    cancelText: '     CANCEL     ',
                                    headerHeight: 200,
                                    headerStyle: DateRangePickerHeaderStyle(
                                        textAlign: TextAlign.center,
                                        backgroundColor:
                                            app_colors.chartBlueBackground),
                                    enableMultiView: false,
                                    allowViewNavigation: false,
                                    enablePastDates: true,
                                    onSubmit: (value) async {
                                      month = value.toString().substring(5, 7);
                                      year = value.toString().substring(0, 4);
                                      _onItemTapped(0);
                                      await updateTable();
                                      Navigator.pop(context);
                                    },
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                });
                          },
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.greenAccent,
                            size: screenWidth / 9,
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
                ArrivalDeparture daily = ArrivalDeparture.fromJson(
                    sortedMonthlyAttendance[index]);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: bigWidthPadding),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 30),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.timer,
                          size: 40,
                          color: !daily.present
                              ? Colors.redAccent
                              : daily.departureTimeDifference != null
                                  ? daily.departureTimeDifference! >= 0
                                      ? daily.arrivalTimeDifference! >= 0
                                          ? Colors.greenAccent
                                          : Colors.blueAccent
                                      : daily.arrivalTimeDifference! >= 0
                                          ? Colors.orangeAccent
                                          : Colors.purpleAccent
                                  : null,
                        ),
                        isThreeLine: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              daily.date,
                              style: TextStyle(color: Colors.deepPurpleAccent),
                            ),
                            Text(
                              DateFormat.E().format(DateTime.parse(daily.date)),
                              style: TextStyle(color: Colors.deepPurpleAccent),
                            ),
                            Row(
                              children: [
                                Text("Total: "),
                                Text(
                                  daily.total_time.toStringAsFixed(2) + 'h',
                                  style: TextStyle(color: Colors.orangeAccent),
                                )
                              ],
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text("Arrival"),
                                Text(
                                  daily.arrivalTime != null
                                      ? daily.arrivalTime
                                          .toString()
                                          .substring(0, 5)
                                      : '__:__',
                                  style: TextStyle(color: Colors.blueAccent),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text("Departure"),
                                Text(
                                  daily.departureTime != null
                                      ? daily.departureTime
                                          .toString()
                                          .substring(0, 5)
                                      : '__:__',
                                  style: TextStyle(color: Colors.blueAccent),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                daily.arrivalTimeDifference != null
                                    ? (daily.arrivalTimeDifference! >= 0
                                        ? Text('Early arrive')
                                        : Text("Late arrive"))
                                    : Text('Out office'),
                                Text(
                                  daily.present
                                      ? daily.arrivalTimeDifference.toString()
                                      : "____",
                                  style: TextStyle(
                                    color: daily.arrivalTimeDifference != null
                                        ? (daily.arrivalTimeDifference! >= 0
                                            ? Colors.green
                                            : Colors.red)
                                        : null,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                daily.departureTimeDifference != null
                                    ? (daily.departureTimeDifference! >= 0
                                        ? Text('Late left')
                                        : Text("Early left"))
                                    : daily.present
                                        ? Text('In office')
                                        : Text('Out office'),
                                Text(
                                  daily.departureTimeDifference != null
                                      ? daily.departureTimeDifference.toString()
                                      : '____',
                                  style: TextStyle(
                                    color: daily.departureTimeDifference != null
                                        ? (daily.departureTimeDifference! >= 0
                                            ? Colors.green
                                            : Colors.red)
                                        : null,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: sortedMonthlyAttendance.length,
            ),
          ),
        ],
      ),
    );
  }
}
