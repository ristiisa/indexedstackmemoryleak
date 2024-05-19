import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(home: LeakSample()));
}

class LeakSample extends StatefulWidget {
  @override
  State<LeakSample> createState() => _LeakSampleState();
}

class _LeakSampleState extends State<LeakSample> {
  Stream<int>? value;
  int lastValue = 0;

  @override
  initState() {
    super.initState();

    value = Stream.periodic(const Duration(milliseconds: 1000), (_) => lastValue++);
  }
  int index = 0;

  MethodChannel? channel;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: [
      const Center(child: Text("Check memory usage")),
      StreamBuilder<int>(stream: value, builder: (context, snapshot) => UiKitView(
        viewType: "TestView",
        key: ValueKey(lastValue),
        creationParams: { "value": lastValue },
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.translucent,
        onPlatformViewCreated: (id) {
          channel = MethodChannel("com.example/testview_$id");
          channel?.setMethodCallHandler((call) async {
            dev.log(call.arguments, name: call.method);
          });
        },
      ))
    ]),
    bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.looks_one),
          label: "Tab 1",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.looks_two),
          label: "Tab 2",
        ),
      ],
      currentIndex: index,
      onTap: (v) => setState(() => index = v),
    )
  );
}