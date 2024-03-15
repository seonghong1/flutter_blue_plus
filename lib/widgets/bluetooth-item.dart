import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothItem extends StatefulWidget {
  final ScanResult bluetoothData;

  // const BluetoothItem({super.key});
  const BluetoothItem.fromMap(ScanResult data, {super.key})
      : bluetoothData = data;

  @override
  State<BluetoothItem> createState() => _BluetoothItemState(bluetoothData);
}

class _BluetoothItemState extends State<BluetoothItem> {
  final ScanResult bluetoothData;

  // 연결 상태 표시 문자열
  String stateText = '';

  // 현재 연결 상태 저장용
  BluetoothConnectionState deviceState = BluetoothConnectionState.disconnected;

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothConnectionState>? _stateListener;

  _BluetoothItemState(bluetoothData) : bluetoothData = bluetoothData;

  @override
  initState() {
    super.initState();
    // 상태 연결 리스너 등록
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      // 화면이 mounted 되었을때만 업데이트 되게 함
      super.setState(fn);
    }
  }

  /* 연결 상태 갱신 */
  setBleConnectionState(BluetoothConnectionState event) {
    switch (event) {
      case BluetoothConnectionState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        break;
      case BluetoothConnectionState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothConnectionState.connected:
        stateText = 'Connected';
        // 버튼 상태 변경
        break;
      case BluetoothConnectionState.connecting:
        stateText = 'Connecting';
        break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    setState(() {});
  }

  /* 연결 시작 */
  Future connect() async {
    /* 
      타임아웃을 10초(10000ms)로 설정 및 autoconnect 해제
       참고로 autoconnect가 true되어있으면 연결이 지연되는 경우가 있음.
     */
    if (bluetoothData.device.isConnected) {
      FlutterBluePlus.connectedDevices.remove(bluetoothData.device);
      await bluetoothData.device.disconnect();
    } else {
      setState(() {
        /* 상태 표시를 Connecting으로 변경 */
        stateText = 'Connecting';
      });

      await bluetoothData.device.connect();
      print('2 ============== > ${bluetoothData.device.isConnected}');

      FlutterBluePlus.connectedDevices.add(bluetoothData.device);
      print('1 ============== > ${bluetoothData.device.isConnected}');

      List<BluetoothService> Listservices = bluetoothData.device.servicesList;

      print('Listservices :::===> $Listservices');

      setState(() {
        /* 상태 표시를 Connecting으로 변경 */
        stateText = 'Connected';
      });
    }
  }

  /* 연결 해제 */
  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      bluetoothData.device.disconnect();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          TextButton(
              onPressed: () {
                print(bluetoothData.device.servicesList);
              },
              child: const Text('get service list')),
          Text(stateText),
          Column(
            children: [
              Text(bluetoothData.device.advName),
            ],
          ),
          IconButton(
            style: bluetoothData.device.isConnected
                ? const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                    iconColor: MaterialStatePropertyAll(Colors.white))
                : const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.blue),
                    iconColor: MaterialStatePropertyAll(Colors.white)),
            onPressed: () async {
              await connect();
            },
            icon: bluetoothData.device.isConnected
                ? const Icon(Icons.bluetooth_disabled)
                : const Icon(Icons.bluetooth),
          ),
        ],
      ),
    );
  }
}
