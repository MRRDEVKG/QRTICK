import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scopedProvider = ScopedProvider<int>((ref) => 0);

class ScopedProviderPage extends StatelessWidget{
  const ScopedProviderPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Provider'),
      ),
      body: Center(
        child: buildScoped(42),)
    );
  }
}