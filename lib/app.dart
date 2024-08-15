import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sensor_data_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMU Sensor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/sensor-data': (context) => SensorDataScreen(),
      },
    );
  }
}
