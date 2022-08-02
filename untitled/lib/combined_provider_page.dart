import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cityProvider = Provider<String>((ref) => 'Munich');

Future<int> fetchWeather(String city) async{
  await Future.delayed(const Duration(seconds: 2));

  return city == 'Munich2' ? 20 : 15;
}

final futureProvider = FutureProvider.autoDispose<int>((ref) async{
  final city = ref.watch(cityProvider);

  return fetchWeather(city);
});

class CombinedProviderPage extends ConsumerWidget{

  @override
  Widget build(BuildContext context, ref){
    final future = ref.watch(futureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Combining Providers'),
      ),
      body: Center(
        child: future.when(data: (value) => Text(value.toString()), error: (e, stack) => Text('Error: $e'), loading: () => const CircularProgressIndicator()),
      ),
    );
  }
}