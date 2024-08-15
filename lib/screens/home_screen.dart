import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:icar_app/services/bluetoothservice.dart';
import 'sensor_data_screen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<AppBluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              bluetoothProvider.startScan();
            },
            child: Text('Scan for Devices'),
          ),
          if (bluetoothProvider.isScanning)
            LinearProgressIndicator(),
          Expanded(
            child: Consumer<AppBluetoothProvider>(
              builder: (context, provider, child) {
                return StreamBuilder<List<ScanResult>>(
                  stream: FlutterBlue.instance.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Text('Scanning...'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView(
                        children: snapshot.data!
                            .map((result) => ListTile(
                          title: Text(result.device.name),
                          subtitle: Text(result.device.id.toString()),
                          onTap: () {
                            bluetoothProvider.connectToDevice(result.device);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SensorDataScreen(),
                              ),
                            );
                          },
                        ))
                            .toList(),
                      );
                    } else {
                      return Center(child: Text('No devices found'));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
