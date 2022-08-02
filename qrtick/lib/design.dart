import 'package:flutter/material.dart';
import 'package:qrtick/app_colors.dart' as app_colors;

class ProfileWidget extends StatelessWidget {
  ProfileWidget(
      {required this.imagePath, this.onClicked, required this.size, Key? key})
      : super(key: key);

  final String? imagePath;
  final VoidCallback? onClicked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: Material(
                // color: Colors.transparent,
                child: Ink.image(
              image: imagePath != null ? NetworkImage(imagePath!) : NetworkImage(''),
              fit: BoxFit.cover,
              height: size,
              width: size,
              child: InkWell(
                onTap: onClicked,
              ),
            )),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipOval(
              child: Container(
                color: app_colors.chartBlueBackground,
                height: size / 3,
                width: size / 3,
                padding: EdgeInsets.all(size / 30),
                child: ClipOval(
                  child: Container(
                    color: Colors.greenAccent,
                    // height: size / 3,
                    // width: size / 3,
                    padding: EdgeInsets.all(size / 30),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: size / 6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay(
      {Key? key, required this.overlayColour, required this.scanArea})
      : super(key: key);

  final Color overlayColour;
  final double scanArea;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(overlayColour, BlendMode.srcOut),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.red, backgroundBlendMode: BlendMode.dstOut),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: scanArea,
                width: scanArea,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: BorderPainter(scanArea: scanArea),
          child: SizedBox(
            width: scanArea + 25,
            height: scanArea + 25,
          ),
        ),
      ),
    ]);
  }
}

class BorderPainter extends CustomPainter {
  const BorderPainter({required this.scanArea});
    final double scanArea;
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width/100;
    final radius = size.width/20;
    final tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rRect = RRect.fromRectAndRadius(rect,  Radius.circular(radius));
    final clippingRect0 = Rect.fromLTWH(
      0,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
