import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrtick/design.dart';
import 'package:qrtick/http_requests.dart';
import 'package:qrtick/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

class ScreenArguments {
  ScreenArguments(this.button_type);

  final String button_type;
}

class QRCodeScannerPage extends ConsumerStatefulWidget {
  const QRCodeScannerPage({Key? key}) : super(key: key);

  static const routeName = "/qr_code_scanner";

  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends ConsumerState<QRCodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  String time_type = '';
  String time_difference = '';
  String time_type_key = '';
  String time_difference_key = '';

  Widget build(BuildContext context) {
    final screenWidth =
        (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height)
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
    final screenHeight = screenWidth * (19.5 / 9);

    final ScreenArguments button_type =
        ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    if (button_type.button_type == 'arrival') {
      time_type = 'Arrival time: ';
      time_difference = 'Time difference: ';
      time_type_key = 'arrival_time';
      time_difference_key = 'arrival_time_difference';
    }

    if (button_type.button_type == 'departure') {
      time_type = 'Departure time: ';
      time_difference = 'Time difference: ';
      time_type_key = 'departure_time';
      time_difference_key = 'departure_time_difference';
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(252, 225, 251, 0.9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            allowDuplicates: false,
            onDetect: (barcode, args) async {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                debugPrint('Barcode found! $code');
                String token =
                    ref.read(sharedPreferencesProvider).getString('token')!;
                Response response = await checkQRCode(code, token);
                if (response.statusCode == 200) {
                  if (jsonDecode(response.body)['message'] == 'CORRECT') {
                    String user_id = ref
                        .read(sharedPreferencesProvider)
                        .getString('user_id')!;
                    bool is_arrival = (button_type.button_type == 'arrival');
                    Response response1 =
                        await arrivedAt(user_id, token, is_arrival);
                    if (response1.statusCode == 200) {
                      cameraController.stop();
                      if (is_arrival &&
                          ref
                                  .read(sharedPreferencesProvider)
                                  .getBool('arrival_scanned') ==
                              false)
                        await ref
                            .read(sharedPreferencesProvider)
                            .setBool('arrival_scanned', true);
                      else if (button_type.button_type == 'departure' &&
                          ref
                                  .read(sharedPreferencesProvider)
                                  .getBool('arrival_scanned') ==
                              true &&
                          ref
                                  .read(sharedPreferencesProvider)
                                  .get('departure_scanned') ==
                              false)
                        await ref
                            .read(sharedPreferencesProvider)
                            .setBool('departure_scanned', true);
                      showDialog(
                          barrierColor: Colors.transparent,
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromRGBO(252, 225, 251, 0.9),
                              content: SizedBox(
                                height: screenHeight / 2,
                                width: screenWidth * (2.5 / 3) + 25,
                                child: Column(
                                  children: [
                                    Flexible(
                                      child: Lottie.asset(
                                          "assets/images/successfully_scanned.json"),
                                    ),
                                    Text(
                                      "Successful",
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 22),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      time_type +
                                          jsonDecode(
                                                  response1.body)[time_type_key]
                                              .toString()
                                              .substring(0, 8),
                                      style: TextStyle(
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      time_difference +
                                          jsonDecode(response1.body)[
                                                  time_difference_key]
                                              .toString() +
                                          " min",
                                      style: TextStyle(
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                Center(
                                    child: FloatingActionButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                  child: Text('OK'),
                                )),
                              ],
                            );
                          }).then((exit) {
                        Navigator.pop(context);
                      });
                    } else {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Something went wrong...")));
                    }
                  } else {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Incorrect QR Code...")));
                  }
                } else {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Try again...")));
                }
              }
            },
          ),
          QRScannerOverlay(
            overlayColour: Colors.black.withOpacity(0.5),
            scanArea: screenWidth * (2.5 / 3),
          ),
          Align(
            alignment: Alignment.center,
            child: Lottie.asset("assets/images/scanning_qr_code.json"),
          )
        ],
      ),
    );
  }
}
