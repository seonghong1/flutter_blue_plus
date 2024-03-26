import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothItem extends StatefulWidget {
  final ScanResult bluetoothData;

  const BluetoothItem.fromMap(ScanResult data, {super.key})
      : bluetoothData = data;

  @override
  State<BluetoothItem> createState() => _BluetoothItemState(bluetoothData);
}

class _BluetoothItemState extends State<BluetoothItem> {
  // 블루투스 디바이스 인스턴스
  final ScanResult bluetoothData;

  // 연결 상태 표시 문자열
  String connectionState = '';

  bool isConnected = false;

  _BluetoothItemState(bluetoothData) : bluetoothData = bluetoothData;

  @override
  initState() {
    super.initState();
    if (bluetoothData.device.isConnected) {
      setConnectionState('Connected');
      isConnected = true;
    }
  }

  setConnectionState(String txt) {
    setState(() {
      connectionState = txt;
    });
  }

  /* 연결 시작 */
  Future connect() async {
    try {
      if (bluetoothData.device.isConnected) {
        setConnectionState('Disconnecting...');
        await bluetoothData.device.disconnect();
        setConnectionState('Disconnected');
        FlutterBluePlus.connectedDevices.remove(bluetoothData.device);
        isConnected = false;
      } else {
        setConnectionState('Connecting...');
        await bluetoothData.device.connect();
        setConnectionState('Connected');
        FlutterBluePlus.connectedDevices.add(bluetoothData.device);
        isConnected = true;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(color: Color.fromRGBO(051, 102, 255, 0.1)),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(connectionState,
                  style: TextStyle(
                      color: isConnected ? Colors.blue : Colors.red,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 20),
              Text(
                bluetoothData.device.advName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          IconButton(
              style: ButtonStyle(
                  backgroundColor: isConnected
                      ? const MaterialStatePropertyAll(Colors.red)
                      : const MaterialStatePropertyAll(Colors.blue),
                  iconColor: const MaterialStatePropertyAll(Colors.white)),
              onPressed: () async {
                await connect();
              },
              icon: Icon(
                  isConnected ? Icons.bluetooth_disabled : Icons.bluetooth)),
        ],
      ),
    );
  }
}
