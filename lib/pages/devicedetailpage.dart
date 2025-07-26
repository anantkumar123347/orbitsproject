import 'dart:convert';
import 'dart:async'; // Add this import for Timer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/error_logger.dart'; // Make sure this path is correct

class DeviceDetailPage extends StatefulWidget {
  final String deviceId;

  const DeviceDetailPage({super.key, required this.deviceId});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  Map<String, dynamic>? deviceData;
  bool isLoading = true;
  DateTime? lastUpdated;
  Timer? _refreshTimer; // Add a Timer variable

  @override
  void initState() {
    super.initState();
    fetchDeviceData();
    // Start the automatic refresh timer
    _startAutoRefresh();
  }

  // Add method to start auto-refresh
  void _startAutoRefresh() {
    // Cancel any existing timer first
    _refreshTimer?.cancel();
    // Create a new timer that fires every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchDeviceData();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchDeviceData() async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://13.203.214.225:3000/find');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_view': widget.deviceId}),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          deviceData = data.isNotEmpty ? data[0] : null;
          lastUpdated = DateTime.now();
          isLoading = false;
        });
      } else {
        final errorMessage =
            'Failed to load device data. Status code: ${response.statusCode}';
        await ErrorLogger.logError(
          'DeviceDetailPage -> fetchDeviceData',
          errorMessage,
          '',
        );
        setState(() => isLoading = false);
      }
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        'DeviceDetailPage -> fetchDeviceData',
        e.toString(),
        stackTrace.toString(),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> changeStatus() async {
    if (deviceData == null) return;

    final currentStatus = deviceData!['Status'];
    final newStatus = currentStatus == 1 ? 0 : 1;

    final urlChange = Uri.parse('http://13.203.214.225:3000/change');
    final urlRelayChange = Uri.parse('http://13.203.214.225:3000/relayChange');
    final body = jsonEncode({'st': newStatus, 'id': widget.deviceId});

    try {
      // First call the /change API
      final response = await http.post(
        urlChange,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Then call the /relayChange API (fire-and-forget, but log errors)
      http
          .post(
            urlRelayChange,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .catchError((e, stackTrace) async {
            await ErrorLogger.logError(
              'DeviceDetailPage -> relayChange',
              e.toString(),
              stackTrace.toString(),
            );
          });

      if (response.statusCode == 200 && response.body == 'Done') {
        await fetchDeviceData(); // Refresh data after status change
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status changed successfully!')));
      } else {
        final errorMessage =
            'Unexpected response: statusCode=${response.statusCode}, body=${response.body}';
        await ErrorLogger.logError(
          'DeviceDetailPage -> changeStatus',
          errorMessage,
          '',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to change status')));
      }
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        'DeviceDetailPage -> changeStatus',
        e.toString(),
        stackTrace.toString(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final indoorTemp = deviceData?['Indoor_Temp']?.toStringAsFixed(1) ?? '--';
    final outdoorTemp = deviceData?['Outdoor_Temp']?.toStringAsFixed(1) ?? '--';
    final power = deviceData?['Power']?.toString() ?? '0';
    final headCount = deviceData?['Head_Count']?.toString() ?? '0';
    final rpm = deviceData?['RPM']?.toString() ?? '0';

    final isOnline = deviceData != null;
    final statusRaw = deviceData?['Status'];
    final status = statusRaw == 1 ? 'ON' : 'OFF';
    final statusColor = statusRaw == 1 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Device ID : ${widget.deviceId}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isOnline ? "\u{1F7E2} Online" : "\u{1F534} Offline",
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          infoCircle(
                            "$indoorTemp °C",
                            "Indoor Temp",
                            Icons.thermostat,
                          ),
                          infoCircle(
                            status,
                            "Status",
                            Icons.power_settings_new,
                            statusColor,
                          ),
                          infoCircle(
                            "$outdoorTemp °C",
                            "Outdoor Temp",
                            Icons.settings,
                          ),
                          infoCircle(
                            headCount,
                            "Head Count",
                            Icons.door_front_door,
                          ),
                          infoCircle(rpm, "RPM", Icons.speed),
                          infoCircle(power, "Power", Icons.electrical_services),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          actionButton(
                            "Change Status",
                            Colors.orange,
                            changeStatus,
                          ),
                          actionButton(
                            "Refresh",
                            Colors.green,
                            fetchDeviceData,
                          ),
                          actionButton("See Records", Colors.red),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Last Updated Data on : ${lastUpdated != null ? lastUpdated.toString() : "N/A"}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget infoCircle(
    String value,
    String label,
    IconData icon, [
    Color? circleColor,
  ]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: circleColor ?? Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }

  Widget actionButton(String text, Color color, [VoidCallback? onPressed]) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: onPressed ?? () {},
      child: Text(text),
    );
  }
}
