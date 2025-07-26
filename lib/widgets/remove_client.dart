import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orbitsproject/utils/error_logger.dart'; // 👈 Import your logger

void showRemoveClientDialog(BuildContext context) {
  TextEditingController usernameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Remove a Client"),
            content: TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Enter Client Username",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  String username = usernameController.text.trim();

                  if (username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid username!"),
                      ),
                    );
                    return;
                  }

                  final url = Uri.parse(
                    "http://13.203.214.225:3000/delete-client",
                  );

                  try {
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"username": username}),
                    );

                    if (response.statusCode == 200 &&
                        response.body.toLowerCase().contains("ok")) {
                      Navigator.pop(context); // Close the initial dialog

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Client Removed"),
                            content: Text(
                              "Client with username '$username' has been removed successfully.",
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
                      await ErrorLogger.logError(
                        "Failed to remove client",
                        "Username: $username",
                        "Response: ${response.body}",
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to remove the client."),
                        ),
                      );
                    }
                  } catch (e, stack) {
                    await ErrorLogger.logError(
                      "Exception during client removal",
                      e.toString(),
                      stack.toString(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: const Text("Remove"),
              ),
            ],
          );
        },
      );
    },
  );
}
