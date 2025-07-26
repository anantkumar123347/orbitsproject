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

void showAddDeviceDialog(BuildContext context) {
  TextEditingController macAddressController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController deviceNameController = TextEditingController();
  TextEditingController wifiNameController = TextEditingController();
  TextEditingController wifiPassController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add a Device"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(macAddressController, "MAC Address"),
              _buildTextField(clientNameController, "Client Name"),
              _buildTextField(deviceNameController, "Device Name"),
              _buildTextField(wifiNameController, "WiFi Name"),
              _buildTextField(
                wifiPassController,
                "WiFi Password",
                isPassword: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final mac = macAddressController.text.trim();
              final client = clientNameController.text.trim();
              final device = deviceNameController.text.trim();
              final wifiName = wifiNameController.text.trim();
              final wifiPass = wifiPassController.text.trim();

              if ([
                mac,
                client,
                device,
                wifiName,
                wifiPass,
              ].any((e) => e.isEmpty)) {
                _showErrorDialog(context, "All fields are required!");
                return;
              }

              if (mac.length != 17) {
                _showErrorDialog(
                  context,
                  "Invalid Mac-Address Provided (Ensure there are no extra spaces before and after the written id)",
                );
                return;
              }

              if (device.length != 8 || !RegExp(r'^\d+$').hasMatch(device)) {
                _showErrorDialog(
                  context,
                  "Invalid Device-name provided. Ensure the format is MMYYSSSS (M-> Month, Y-> Year, S-> Serial Number) and all the letters are digits only",
                );
                return;
              }

              final url = Uri.parse("http://13.203.214.225:3000/add-data");

              final body = {
                "macAddress": mac,
                "client": client,
                "device_name": device,
                "wifi_name": wifiName,
                "wifi_pass": wifiPass,
              };

              try {
                final response = await http.post(
                  url,
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(body),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Success"),
                          content: const Text("Device added successfully."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                  );
                } else {
                  final errMsg = "AddDevice API failed: ${response.body}";
                  _showErrorDialog(context, "Failed to add device");
                  await ErrorLogger.logError(
                    "AddDevice API error",
                    errMsg,
                    jsonEncode(body),
                  );
                }
              } catch (e) {
                final errorDetails = "AddDevice Exception: ${e.toString()}";
                _showErrorDialog(context, "Error: ${e.toString()}");
                await ErrorLogger.logError(
                  "AddDevice Exception",
                  errorDetails,
                  jsonEncode(body),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool isPassword = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
