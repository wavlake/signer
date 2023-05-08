import 'package:flutter/material.dart';
import 'package:nostr_tools/nostr_tools.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppState(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  final String anotherTitle = 'test';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    bool hasKeyStored = appState.items.length > 0;
    print('has key stored');
    print(hasKeyStored);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anotherTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please add an nsec key, or generate a new one',
            ),
            TextFormField(
              controller: appState.nsecController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "nsec"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your nsec';
                }

                if (value.length != 64) {
                  return 'Nsec must be 64 characters in length';
                }

                try {
                  final nip19 = Nip19();
                  var privateHexKey = nip19.decode(value);
                  if (privateHexKey['type'] != 'nsec') {
                    return 'Invalid key type, must be nsec';
                  }
                } catch (e) {
                  return 'Invalid value - $e';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: appState.submitUserNsec,
              child: const Text('Submit Key'),
            ),
            ElevatedButton(
              onPressed: appState.generateNewNsec,
              child: const Text('Generate Key'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
