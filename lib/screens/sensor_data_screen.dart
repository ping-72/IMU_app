import 'package:flutter/material.dart';
import 'package:icar_app/widgets/sensor_data_display.dart';
import 'package:provider/provider.dart';
import 'package:icar_app/services/bluetoothservice.dart';

class SensorDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<AppBluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data'),
      ),
      body: Center(
        child: SensorDataDisplay(sensorData: bluetoothService.sensorData),
      ),
    );
  }
}
