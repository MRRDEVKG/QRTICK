import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarNotifier extends ChangeNotifier{
  int _speed = 120;

  void increase(){
    _speed += 5;

    notifyListeners();
  }

  void hitBreak(){
    _speed = max(0, _speed - 30);

    notifyListeners();
  }
}
final changeNotifier = ChangeNotifierProvider<CarNotifier>((ref) => CarNotifier());
class ChangeNotifierPage extends ConsumerWidget {
  const ChangeNotifierPage({Key? key}) : super(key: key);

  Widget buildButtons(BuildContext context, CarNotifier car){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: car.increase, child: const Text('Increase +5'),),
        const SizedBox(height: 12,),
        TextButton(onPressed: car.hitBreak, child: const Text('Hit Brake -30'),),
      ],
    );

  }

  @override
  Widget build(BuildContext context, ref) {
    final car = ref.watch(changeNotifier);

    return Scaffold(
      appBar: AppBar(
        title:const Text('Change Notifier Provider'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Speed: ${car._speed}'),
            const SizedBox(height: 8,),
            buildButtons(context, car),
          ],
        )
      ),
    );
  }
}
