import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/error_logger.dart';

// Helper function to show errors in an alert dialog
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
  );
}

class EditDeviceDialog extends StatefulWidget {
  const EditDeviceDialog({super.key});

  @override
  State<EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<EditDeviceDialog> {
  final TextEditingController macController = TextEditingController();
  final TextEditingController deviceController = TextEditingController();
  final TextEditingController wifiNameController = TextEditingController();
  final TextEditingController wifiPassController = TextEditingController();
  final TextEditingController clientController = TextEditingController();

  bool loading = false;
  bool showEditForm = false;

  Future<void> fetchDeviceData() async {
    // Validate MAC address format before fetching
    final mac = macController.text.trim();
    if (mac.isEmpty) {
      _showErrorDialog(context, "MAC Address is required");
      return;
    }

    if (mac.length != 17) {
      _showErrorDialog(
        context,
        "Invalid Mac-Address Provided (Ensure there are no extra spaces before and after the written id)",
      );
      return;
    }

    setState(() => loading = true);
    final url = Uri.parse('http://13.203.214.225:3000/devicecheck');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": mac}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        deviceController.text = data['device-name'] ?? '';
        wifiNameController.text = data['wifi_name'] ?? '';
        wifiPassController.text = data['wifi_password'] ?? '';
        clientController.text = data['client_select'] ?? '';

        setState(() {
          showEditForm = true;
        });
      } else {
        await ErrorLogger.logError(
          "Device fetch failed",
          "Status: ${response.statusCode}",
          "MAC: ${mac}",
        );
        _showErrorDialog(context, "Device not found");
      }
    } catch (e) {
      await ErrorLogger.logError(
        "Exception during device fetch",
        e.toString(),
        "MAC: ${mac}",
      );
      _showErrorDialog(context, "Error: ${e.toString()}");
    }
    setState(() => loading = false);
  }

  Future<void> updateDeviceData() async {
    final mac = macController.text.trim();
    final client = clientController.text.trim();
    final device = deviceController.text.trim();
    final wifiName = wifiNameController.text.trim();
    final wifiPass = wifiPassController.text.trim();

    // Check if any field is empty
    if ([mac, client, device, wifiName, wifiPass].any((e) => e.isEmpty)) {
      _showErrorDialog(context, "All fields are required!");
      return;
    }

    // Validate MAC address format
    if (mac.length != 17) {
      _showErrorDialog(
        context,
        "Invalid Mac-Address Provided (Ensure there are no extra spaces before and after the written id)",
      );
      return;
    }

    // Validate device name format
    if (device.length != 8 || !RegExp(r'^\d+$').hasMatch(device)) {
      _showErrorDialog(
        context,
        "Invalid Device-name provided. Ensure the format is MMYYSSSS (M-> Month, Y-> Year, S-> Serial Number) and all the letters are digits only",
      );
      return;
    }

    final url = Uri.parse('http://13.203.214.225:3000/add-data');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "macAddress": mac,
          "client": client,
          "device_name": device,
          "wifi_name": wifiName,
          "wifi_pass": wifiPass,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close dialog on success
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Success"),
                content: const Text("Device updated successfully"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      } else {
        await ErrorLogger.logError(
          "Device update failed",
          "Status: ${response.statusCode}",
          "MAC: ${mac}",
        );
        _showErrorDialog(context, "Failed to update device");
      }
    } catch (e) {
      await ErrorLogger.logError(
        "Exception during device update",
        e.toString(),
        "MAC: ${mac}",
      );
      _showErrorDialog(context, "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Device'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: macController,
              decoration: const InputDecoration(labelText: 'MAC Address'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loading ? null : fetchDeviceData,
              child:
                  loading
                      ? const CircularProgressIndicator()
                      : const Text('Fetch Device'),
            ),
            if (showEditForm) ...[
              const SizedBox(height: 20),
              TextField(
                controller: deviceController,
                decoration: const InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: wifiNameController,
                decoration: const InputDecoration(labelText: 'WiFi Name'),
              ),
              TextField(
                controller: wifiPassController,
                decoration: const InputDecoration(labelText: 'WiFi Password'),
              ),
              TextField(
                controller: clientController,
                decoration: const InputDecoration(labelText: 'Client'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: updateDeviceData,
                child: const Text('Save Changes'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ Call this function to open the dialog
void showUpdateDeviceDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const EditDeviceDialog());
}
