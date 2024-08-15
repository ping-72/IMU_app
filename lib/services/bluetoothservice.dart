import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sensor_data.dart';

class AppBluetoothProvider with ChangeNotifier {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  SensorData _sensorData = SensorData();
  bool _isScanning = false;
  List<BluetoothDevice> _nearbyDevices = [];

  SensorData get sensorData => _sensorData;
  bool get isScanning => _isScanning;
  List<BluetoothDevice> get nearbyDevices => _nearbyDevices;

  // Start scanning for Bluetooth devices
  Future<void> startScan() async {
    final bluetoothPermissionStatus = await Permission.bluetoothScan.request();
    final connectPermissionStatus = await Permission.bluetoothConnect.request();

    if (bluetoothPermissionStatus.isGranted && connectPermissionStatus.isGranted) {
      _isScanning = true;
      _nearbyDevices.clear(); // Clear previous scan results
      notifyListeners();

      _flutterBlue.startScan(timeout: Duration(seconds: 10));

      _flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_nearbyDevices.contains(result.device)) {
            _nearbyDevices.add(result.device);
            print('Found device: ${result.device.name} with ID: ${result.device.id}');
          }
        }
        notifyListeners();
      }).onDone(() {
        _isScanning = false;
        notifyListeners();
      });
    } else {
      // Handle permission denial
      _isScanning = false;
      notifyListeners();
    }
  }

  // Connect to the Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _device = device;
      await _device?.connect();

      // Discover services and characteristics
      List<BluetoothService> services = await _device?.discoverServices() ?? [];
      for (BluetoothService service in services) {
        // Log that the Bluetooth has scanned and discovery is going on
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == "your-sensor-characteristic-uuid") {
            _listenToCharacteristic(characteristic);
          }
        }
      }
    } catch (e) {
      print("Failed to connect to device: $e");
    }
  }

  // Listen to characteristic changes
  void _listenToCharacteristic(BluetoothCharacteristic characteristic) {
    characteristic.value.listen((value) {
      // Process the value to get sensor data
      _sensorData.updateFromRawData(value);
      notifyListeners();
    }).onError((error) {
      print("Error reading characteristic: $error");
    });

    characteristic.setNotifyValue(true).catchError((error) {
      print("Failed to set notify value: $error");
    });
  }

  // Disconnect from the Bluetooth device
  Future<void> disconnectFromDevice() async {
    try {
      await _device?.disconnect();
      _device = null;
      _sensorData = SensorData(); // Reset sensor data
      notifyListeners();
    } catch (e) {
      print("Failed to disconnect: $e");
    }
  }
}
