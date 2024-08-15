import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icar_app/services/bluetoothservice.dart';
import '../models/sensor_data.dart';

class SensorDataDisplay extends StatelessWidget {
  final SensorData sensorData;

  const SensorDataDisplay({Key? key, required this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Temperature: ${sensorData.temperature}°C'),
        Text('Heart Rate: ${sensorData.heartRate} bpm'),
      ],
    );
  }
}
