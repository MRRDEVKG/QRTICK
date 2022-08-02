import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stateProvider = StateProvider.autoDispose<int>((ref) => 0);

class StateProviderPage extends ConsumerWidget{
  const StateProviderPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, ref){
    final provider = ref.watch(stateProvider.state);
    final counter = provider.state.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Provider'),
      ),
      body: Center(
        child: Text(counter, style: const TextStyle(fontSize: 20),),
      ),
        floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
          onPressed: (){
            provider.state++;
          },
    ),
    );
  }
}