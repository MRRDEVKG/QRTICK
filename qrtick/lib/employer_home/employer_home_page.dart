import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrtick/employer_home/AddUser.dart';
import 'package:qrtick/login/login_page.dart';
import 'package:qrtick/models/work_schedule.dart';
import 'package:qrtick/app_colors.dart' as app_colors;
import 'package:qrtick/employer_home/employer_attendance_list_page.dart';
import 'package:qrtick/http_requests.dart';
import 'package:qrtick/models/sliver_persistent_header_delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrtick/main.dart';
import 'package:http/http.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';

class EmployerHomePage extends ConsumerStatefulWidget {
  static const routeName = '/employer_home';
  const EmployerHomePage({Key? key}) : super(key: key);

  @override
  _EmployerHomePageState createState() => _EmployerHomePageState();
}

class _EmployerHomePageState extends ConsumerState<EmployerHomePage> {
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

  String user_arrival_departure_id = '';
  String qr_code_update = '';

  final _arrival_departure_FormKey = GlobalKey<FormState>();
  final _qr_code_FormKey = GlobalKey<FormState>();

  Future<void> updatePieChart() async {
    String day = DateTime.now().day.toString().padLeft(2, '0');
    String month = DateTime.now().month.toString().padLeft(2, '0');
    String year = DateTime.now().year.toString();

    double absent = 0.019,
        present = 0.019,
        late_coming = 0.019,
        early_leaving = 0.019;

    String token = ref.read(sharedPreferencesProvider).getString('token')!;
    Response response = await getUsersDailyAttendance(token, day, month, year);
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
      initializeScreen();
    }
  }

  Future<void> changeTime(
      {required int index, required bool is_leading}) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: 15),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (newTime != null) {
      String token = ref.read(sharedPreferencesProvider).getString('token')!;
      Response response =
          await updateWorkSchedule(index, token, newTime, is_leading);
      if (response.statusCode == 200) {
        await ref.read(sharedPreferencesProvider).remove('date');
        initializeScreen();
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Something went wrong...")));
      }
    }
  }

  Future<void> changeIsDayOff(
      {required int index, required bool is_day_off}) async {
    String token = ref.read(sharedPreferencesProvider).getString('token')!;
    Response response = await updateIsDayOff(index, token, is_day_off);
    if (response.statusCode == 200) {
      await ref.read(sharedPreferencesProvider).remove('date');
      initializeScreen();
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong...")));
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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
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
                        padding: EdgeInsets.all(screenWidth / 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              " $date ",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            Form(
                              key: _arrival_departure_FormKey,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.perm_identity_outlined),
                                  labelText: 'ID',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter ID';
                                  } else if (value.length != 7) {
                                    return 'ID must be 7 characters long';
                                  } else {
                                    return null;
                                  }
                                },
                                maxLength: 7,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => setState(() =>
                                    user_arrival_departure_id =
                                        value.toString()),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        onPressed: () async {
                                          if (_arrival_departure_FormKey
                                              .currentState!
                                              .validate()) {
                                            _arrival_departure_FormKey
                                                .currentState!
                                                .save();

                                            String token = ref
                                                .read(sharedPreferencesProvider)
                                                .getString('token')!;
                                            Response response = await arrivedAt(
                                                user_arrival_departure_id,
                                                token,
                                                true);
                                            if (response.statusCode == 200) {
                                              showDialog(
                                                  barrierColor:
                                                      Colors.transparent,
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                              252,
                                                              225,
                                                              251,
                                                              0.9),
                                                      content: SizedBox(
                                                        height:
                                                            screenHeight / 2,
                                                        width: screenWidth *
                                                                (2.5 / 3) +
                                                            25,
                                                        child: Column(
                                                          children: [
                                                            Flexible(
                                                              child: Lottie.asset(
                                                                  "assets/images/successfully_scanned.json"),
                                                            ),
                                                            Text(
                                                              "Successful",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  fontSize: 22),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Text(
                                                              "Arrival time: " +
                                                                  jsonDecode(response
                                                                              .body)[
                                                                          'arrival_time']
                                                                      .toString()
                                                                      .substring(
                                                                          0, 8),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .deepPurpleAccent,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Text(
                                                              "Time difference: " +
                                                                  jsonDecode(response
                                                                              .body)[
                                                                          "arrival_time_difference"]
                                                                      .toString() +
                                                                  " min",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .deepPurpleAccent,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        Center(
                                                            child:
                                                                FloatingActionButton(
                                                          onPressed: () async{
                                                            await ref.read(sharedPreferencesProvider).remove('date');
                                                            initializeScreen();
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop();
                                                          },
                                                          child: Text('OK'),
                                                        )),
                                                      ],
                                                    );
                                                  });
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  child: Icon(
                                    Icons.qr_code,
                                    size: 60,
                                    color: Colors.greenAccent,
                                  ),
                                  onPressed: () async {
                                    showDialog(
                                        barrierColor: Colors.transparent,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            final GlobalKey globalKey =
                                                GlobalKey();
                                            File? file;

                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      252, 225, 251, 0.9),
                                              content: SizedBox(
                                                height: screenHeight / 2.5,
                                                width: screenWidth * (2.5 / 3) +
                                                    25,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                        child: RepaintBoundary(
                                                      key: globalKey,
                                                      child: Container(
                                                        child: QrImage(
                                                            data:
                                                                qr_code_update,
                                                            gapless: false,
                                                            embeddedImage:
                                                                AssetImage(
                                                                    'assets/icons/app_icon_transparentbg.png'),
                                                            embeddedImageStyle:
                                                                QrEmbeddedImageStyle(
                                                              size:
                                                                  Size(50, 50),
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                            version:
                                                                QrVersions.auto,
                                                            size: screenWidth /
                                                                1.8),
                                                      ),
                                                    )),
                                                    SizedBox(
                                                      height: screenWidth / 40,
                                                    ),
                                                    Form(
                                                      key: _qr_code_FormKey,
                                                      child: TextFormField(
                                                        initialValue: '',
                                                        decoration:
                                                            const InputDecoration(
                                                          prefixIcon: Icon(
                                                              Icons.qr_code),
                                                          labelText: 'QR Code',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'Enter QR code';
                                                          } else if (value
                                                                  .length <
                                                              10) {
                                                            return 'QR Code must be at least 10 characters long';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        maxLength: 200,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        onChanged: (value) {
                                                          qr_code_update =
                                                              value.toString();
                                                          setState(() {});
                                                        },
                                                        onSaved: (value) {
                                                          qr_code_update =
                                                              value.toString();
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  ],
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
                                                          qr_code_update = "";
                                                          Navigator.of(context,
                                                                  rootNavigator:
                                                                      true)
                                                              .pop();
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      FloatingActionButton(
                                                        onPressed: () async {
                                                          if (_qr_code_FormKey
                                                              .currentState!
                                                              .validate()) {
                                                            _qr_code_FormKey
                                                                .currentState!
                                                                .save();
                                                            String token = ref
                                                                .read(
                                                                    sharedPreferencesProvider)
                                                                .getString(
                                                                    'token')!;
                                                            Response response =
                                                                await updateQRCode(
                                                                    qr_code_update,
                                                                    token);
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .removeCurrentSnackBar();
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text("QR Code successfully updated...")));

                                                              try {
                                                                final RenderRepaintBoundary
                                                                    boundary =
                                                                    globalKey
                                                                            .currentContext!
                                                                            .findRenderObject()
                                                                        as RenderRepaintBoundary;

                                                                final image =
                                                                    await boundary
                                                                        .toImage();
                                                                ByteData?
                                                                    byteData =
                                                                    await image.toByteData(
                                                                        format:
                                                                            ImageByteFormat.png);
                                                                Uint8List
                                                                    pngBytes =
                                                                    byteData!
                                                                        .buffer
                                                                        .asUint8List();

                                                                final tempDir =
                                                                    await getTemporaryDirectory();

                                                                var datetime =
                                                                    DateTime
                                                                        .now();

                                                                file = await File(
                                                                        '${tempDir.path}/$datetime.png')
                                                                    .create();

                                                                await file
                                                                    ?.writeAsBytes(
                                                                        pngBytes);

                                                                final path =
                                                                    '${tempDir.path}/$datetime.png';

                                                                await GallerySaver
                                                                    .saveImage(
                                                                        path);
                                                              } catch (e) {
                                                                print(e
                                                                    .toString());
                                                              }

                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .removeCurrentSnackBar();
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text("Try again! Something went wrong...")));
                                                            }
                                                          }
                                                        },
                                                        child: Text('Save'),
                                                      ),
                                                    ])
                                              ],
                                            );
                                          });
                                        });
                                  },
                                ),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          onPressed: () async {
                                            if (_arrival_departure_FormKey
                                                .currentState!
                                                .validate()) {
                                              _arrival_departure_FormKey
                                                  .currentState!
                                                  .save();
                                              String token = ref
                                                  .read(
                                                      sharedPreferencesProvider)
                                                  .getString('token')!;
                                              Response response =
                                                  await arrivedAt(
                                                      user_arrival_departure_id,
                                                      token,
                                                      false);
                                              if (response.statusCode == 200) {
                                                showDialog(
                                                    barrierColor:
                                                        Colors.transparent,
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            const Color
                                                                    .fromRGBO(
                                                                252,
                                                                225,
                                                                251,
                                                                0.9),
                                                        content: SizedBox(
                                                          height:
                                                              screenHeight / 2,
                                                          width: screenWidth *
                                                                  (2.5 / 3) +
                                                              25,
                                                          child: Column(
                                                            children: [
                                                              Flexible(
                                                                child: Lottie.asset(
                                                                    "assets/images/successfully_scanned.json"),
                                                              ),
                                                              Text(
                                                                "Successful",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    fontSize:
                                                                        22),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Text(
                                                                "Departure time: " +
                                                                    jsonDecode(response.body)[
                                                                            'departure_time']
                                                                        .toString()
                                                                        .substring(
                                                                            0,
                                                                            8),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .deepPurpleAccent,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Text(
                                                                "Time difference: " +
                                                                    jsonDecode(response.body)[
                                                                            "departure_time_difference"]
                                                                        .toString() +
                                                                    " min",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .deepPurpleAccent,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Center(
                                                              child:
                                                                  FloatingActionButton(
                                                            onPressed: ()async {
                                                              await ref.read(sharedPreferencesProvider).remove('date');
                                                              initializeScreen();
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            },
                                                            child: Text('OK'),
                                                          )),
                                                        ],
                                                      );
                                                    });
                                              }
                                            }
                                          })
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
                                  color:
                                      const Color.fromRGBO(252, 225, 251, 0.9),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: OutlinedButton(
                                        onPressed: () => Navigator.pushNamed(
                                            context,
                                            EmployerAttendanceListPage
                                                .routeName),
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
                                        onPressed: () => Navigator.pushNamed(
                                            context,
                                            AddUserPage.routeName),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: bigWidthPadding),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: screenWidth / 30),
                        child: Card(
                          child: ListTile(
                              selected: day_schedule.day_of_week == day_of_week,
                              selectedColor: Colors.orange,
                              leading: IconButton(
                                onPressed: day_schedule.is_day_off
                                    ? null
                                    : () {
                                        changeTime(
                                            index: index, is_leading: true);
                                      },
                                icon: Icon(
                                  Icons.timer,
                                  size: 40,
                                  color: day_schedule.is_day_off
                                      ? null
                                      : Colors.greenAccent,
                                ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  Switch(
                                      value: !day_schedule.is_day_off,
                                      onChanged: (is_day_off) {
                                        changeIsDayOff(
                                            index: index,
                                            is_day_off: !is_day_off);
                                      }),
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
                              trailing: IconButton(
                                  onPressed: day_schedule.is_day_off
                                      ? null
                                      : () {
                                          changeTime(
                                              index: index, is_leading: false);
                                        },
                                  icon: Icon(
                                    Icons.timer_off,
                                    size: 40,
                                    color: day_schedule.is_day_off
                                        ? null
                                        : Colors.greenAccent,
                                  ))),
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
      ),
    );
  }
}
