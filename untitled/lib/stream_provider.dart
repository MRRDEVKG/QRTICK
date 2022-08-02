import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streamProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (count) => count);
});

class StreamProviderPage extends ConsumerWidget {
  const StreamProviderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final stream = ref.watch(streamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Provider'),
      ),
      body: Center(
        child: stream.when(
            data: (value) => Text(value.toString()),
            error: (e, stack) => Text("Error: $e"),
            loading: () => const CircularProgressIndicator()),
      ),
    );
  }
}
