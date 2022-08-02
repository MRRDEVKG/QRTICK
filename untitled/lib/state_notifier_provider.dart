import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class Car{
  final int speed;
  final int doors;

  Car({this.speed = 120, this.doors = 4});

  Car copy({int? speed, int? doors}){
    return Car(speed: speed ?? this.speed, doors: doors ?? this.doors);
  }
}

class CarNotifier extends StateNotifier<Car>{
  CarNotifier() : super(Car());

  void setDoors(int doors){
    final newState = state.copy(doors: doors);
    state = newState;
  }

  void increaseSpeed(){
    final speed = state.speed + 5;
    final newState = state.copy(speed: speed);
    state = newState;
  }

  void hitBrake(){
    final speed = max(0, state.speed -30);
    final newState = state.copy(speed: speed);
    state = newState;
  }
}

final stateNotifier = StateNotifierProvider<CarNotifier, Car>((ref) => CarNotifier());

class StateNotifierPage extends ConsumerWidget {
  const StateNotifierPage({Key? key}) : super(key: key);

  Widget buildButtons(BuildContext context,  CarNotifier car){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: car.increaseSpeed, child: const Text('Increase +5'),),
        const SizedBox(height: 12,),
        TextButton(onPressed: car.hitBrake, child: const Text('Hit Brake -30'),),
      ],
    );

  }

  @override
  Widget build(BuildContext context, ref) {
    final car2 = ref.watch(stateNotifier.notifier);
    final car = ref.watch(stateNotifier);
    final speed = car.speed;
    final doors = car.doors;

    return Scaffold(
      appBar: AppBar(
        title:const Text('Change Notifier Provider'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Speed: $speed'),
              const SizedBox(height: 8,),
              Text('Speed: $doors'),
              const SizedBox(height: 32,),
              buildButtons(context, car2),
              const SizedBox(height: 32,),
              Slider(value: doors.toDouble(), onChanged: (value) => car2.setDoors(value.toInt()), max: 5,)
            ],
          )
      ),
    );
  }
}
