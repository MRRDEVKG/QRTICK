import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final futureProvider = FutureProvider.autoDispose<int>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return 20;
});

class FutureProviderPage extends ConsumerWidget {
  const FutureProviderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final future = ref.watch(futureProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Provider'),
      ),
      body: Center(
        child: future.when(
            data: (value) => Text(value.toString()),
            error: (e, stack) => Text("Error: $e"),
            loading: () => const CircularProgressIndicator()),
      ),
    );
  }
}
