import 'package:flutter/material.dart';
import 'package:qrtick/app_colors.dart' as app_colors;
import 'package:qrtick/design.dart';
import 'package:qrtick/models/user_model.dart';

class EmployeeProfilePage extends StatefulWidget {
  static const routeName = '/employee_profile';
  const EmployeeProfilePage({Key? key}) : super(key: key);

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = (MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height >
        1)
        ? (2 / 3) * MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width;
    final screenHeight = (19.5 / 9) * screenWidth;

    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
        backgroundColor: const Color.fromRGBO(252, 225, 251, 0.9),
        appBar: AppBar(
          //automaticallyImplyLeading: true,
          //  iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          //InteractiveViewer(
          //constrained: false,
          //scrollDirection: Axis.horizontal,
          child: Center(
            child: SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: screenHeight / 2.5,
                    child: Container(
                      color: app_colors.chartBlueBackground,
                    ),
                  ),
                  Positioned(
                    top: screenHeight / 10,
                    left: (screenWidth - screenWidth / 3) / 2,
                    width: screenWidth / 3,
                    child: Center(
                        child: ProfileWidget(
                          imagePath: user.imagePath != null ? user.imagePath : '',
                          onClicked: () {},
                          size: screenWidth / 3.5,
                        )),
                  ),
                  Positioned(
                    top: screenHeight / 3.8,
                    left: (screenWidth - screenWidth / 1.5) / 2,
                    width: screenWidth / 1.5,
                    child: Center(
                      child: Text(
                        user.name + ' ' + user.surname,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight / 3.4,
                    left: (screenWidth - screenWidth / 2) / 2,
                    width: screenWidth / 2,
                    child: Center(
                      child: Text(
                        user.designation,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                      top: screenHeight/3.05,
                      left: screenWidth/15,
                      right: screenWidth/15,
                      height: screenHeight/5.4,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth / 25),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(252, 225, 251, 0.9),
                            borderRadius: BorderRadius.circular(40)),
                        child: Column(
                          children: [
                            Text("About Me", style: TextStyle(color: Colors.blueGrey, fontSize: 25),),
                            Text(
                              user.aboutMe != null ? user.aboutMe! : '',
                              overflow: TextOverflow.visible,

                              style: TextStyle(color: Colors.blueGrey),),
                          ],
                        ),
                      )),
                  Positioned(
                    top: screenHeight / 1.9,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth/40),
                      child: Container(
                        padding: EdgeInsets.all(screenWidth / 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        //color: Colors.green,
                        child: Table(
                          columnWidths: const <int, TableColumnWidth>{
                            0: IntrinsicColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "ID:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.user_id)),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Department:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.department)),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Designation:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.designation)),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Employed since:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.employedDate != null ? user.employedDate! : '')),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Email:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.email != null ? user.email! : '',
                                style: TextStyle(color: Colors.blueAccent),)),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Phone number:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.phone != null ? user.phone! : '',
                                style: TextStyle(color: Colors.blueAccent),)),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Address:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.address != null ? user.address! : '',
                                style: TextStyle(color: Colors.blueAccent),)),
                            ]),
                            TableRow(children: [
                              TableCell(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: screenHeight / 25,
                                  child: Text(
                                    "Date of birth:  ",
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                              TableCell(child: Text(user.dob != null ? user.dob! : '',
                                style: TextStyle(color: Colors.blueAccent),)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ));
  }
}
