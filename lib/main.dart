import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_test/widgets/bluetooth-item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ScanResult> bluetoothList = [];

  void startScan() {
    var subscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      if (state == BluetoothAdapterState.on) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
        // 블루투스 스캔 결과값 프린트
        FlutterBluePlus.scanResults.listen((result) async {
          if (result.isNotEmpty) {
            setState(() {
              bluetoothList = result;
            });
          }
        }, onError: (e) => print(e));
      } else {
        // await FlutterBluePlus.turnOn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: ListView(
        children: [
          for (int i = 0; bluetoothList.length > i; i++)
            if (bluetoothList[i].device.advName.isNotEmpty)
              BluetoothItem.fromMap(bluetoothList[i])
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: IconButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.blue),
              iconColor: MaterialStatePropertyAll(Colors.white)),
          icon: const Icon(
            Icons.bluetooth,
            size: 50,
          ),
          onPressed: () {
            startScan();
          },
        ),
      ),
    ));
  }
}
