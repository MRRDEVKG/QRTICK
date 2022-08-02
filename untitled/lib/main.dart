import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/change_notifier_provider.dart';
import 'package:untitled/combined_provider_page.dart';
import 'package:untitled/state_notifier_provider.dart';
import 'package:untitled/stream_provider.dart';
import 'state_provider.dart';
import 'future_provider.dart';


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Widget buildStreamBuilder(ref){
    final stream = ref.watch(streamProvider.stream);
    
    return StreamBuilder<String>(
      stream: stream,
        builder: (context, snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }else{
              final counter = snapshot.data;
              return Text(snapshot.data.toString());
            }
        }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StateProviderPage())),
                child: const Text('State Provider')),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FutureProviderPage())),
                child: const Text('Future Provider')),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StreamProviderPage())),
                child: const Text('Stream Provider')),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CombinedProviderPage())),
                child: const Text('Combined Provider')),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangeNotifierPage())),
                child: const Text('Change Notifier Page')),

            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StateNotifierPage())),
                child: const Text('State Notifier Page')),
          ],
        ),
      ),
    );
  }
}
