import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth IMO Sensor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Bluetooth IMO Sensor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      scanForDevices();
    } else {
      // Handle permission denied
    }
  }

  void scanForDevices() {
    setState(() {
      isScanning = true;
    });

    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.isNotEmpty) {
          print('Found device: ${r.device.name}');
        }
        if (r.device.name == 'IMO Sensor') {  // Replace with your sensor's name
          connectToDevice(r.device);
          flutterBlue.stopScan();
          setState(() {
            isScanning = false;
          });
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    discoverServices();
  }

  void discoverServices() async {
    if (connectedDevice != null) {
      List<BluetoothService> services = await connectedDevice!.discoverServices();
      setState(() {
        this.services = services;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isScanning
            ? CircularProgressIndicator()
            : connectedDevice == null
            ? ElevatedButton(
          onPressed: scanForDevices,
          child: Text('Scan for IMO Sensor'),
        )
            : ListView(
          children: services.map((service) {
            return ListTile(
              title: Text('Service: ${service.uuid}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: service.characteristics.map((c) {
                  return ListTile(
                    title: Text('Characteristic: ${c.uuid}'),
                    subtitle: StreamBuilder<List<int>>(
                      stream: c.value,
                      initialData: c.lastValue,
                      builder: (c, snapshot) {
                        return Text(snapshot.data.toString());
                      },
                    ),
                    onTap: () async {
                      await c.setNotifyValue(!c.isNotifying);
                    },
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: connectedDevice != null
          ? FloatingActionButton(
        onPressed: () {
          connectedDevice!.disconnect();
          setState(() {
            connectedDevice = null;
            services = [];
          });
        },
        tooltip: 'Disconnect',
        child: const Icon(Icons.bluetooth_disabled),
      )
          : null,
    );
  }
}
