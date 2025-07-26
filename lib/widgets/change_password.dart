import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_logger.dart';

void showChangePasswordDialog(BuildContext context) {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              passwordController,
              "New Password",
              isPassword: true,
            ),
            _buildTextField(
              confirmPasswordController,
              "Confirm Password",
              isPassword: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newPassword = passwordController.text.trim();
              String confirmPassword = confirmPasswordController.text.trim();

              if (newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Both fields are required!")),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match!")),
                );
                return;
              }

              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? username = prefs.getString('username');

              if (username == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Username not found in local storage!"),
                  ),
                );
                await ErrorLogger.logError(
                  "ChangePassword Error",
                  "Username not found in local storage",
                );
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse('http://13.203.214.225:3000/change-password'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "username": username,
                    "newpass": newPassword,
                    "confpass": confirmPassword,
                  }),
                );

                if (response.statusCode == 200 &&
                    response.body.toLowerCase().contains("successfully")) {
                  Navigator.pop(context); // Close the dialog

                  // Show success confirmation
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Password Changed"),
                        content: const Text(
                          "Your password has been successfully updated.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  String errorMsg = "API error: ${response.body}";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed: ${response.body}")),
                  );
                  await ErrorLogger.logError(
                    "ChangePassword API failed",
                    errorMsg,
                    "Username: $username",
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
                await ErrorLogger.logError(
                  "Exception in change password request",
                  e.toString(),
                  "Username: $username",
                );
              }
            },
            child: const Text("Change"),
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
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(labelText: label),
    ),
  );
}
