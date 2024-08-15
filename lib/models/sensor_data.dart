class SensorData {
  double temperature = 0.0;
  double heartRate = 0.0;

  void updateFromRawData(List<int> rawData) {
    // Example parsing, adjust based on your sensor's data format
    temperature = rawData[0].toDouble();
    heartRate = rawData[1].toDouble();
  }
}
