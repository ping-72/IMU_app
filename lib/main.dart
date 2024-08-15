import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/bluetoothservice.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context)=>
      AppBluetoothProvider(),
      child: MyApp(),
    )
  );
}
