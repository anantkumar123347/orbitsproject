import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/error_logger.dart';

void showAddUserDialog(BuildContext context) {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController sectorController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  String userType = 'Client';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add a New User"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Enter Username",
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Enter Password",
                    ),
                    obscureText: true,
                  ),
                  DropdownButtonFormField<String>(
                    value: userType,
                    decoration: const InputDecoration(labelText: "Select Role"),
                    items:
                        ['Admin', 'Client'].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          userType = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  if (userType == "Client") ...[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Client Name",
                      ),
                    ),
                    TextField(
                      controller: districtController,
                      decoration: const InputDecoration(labelText: "District"),
                    ),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: "City"),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: "Location"),
                    ),
                    TextField(
                      controller: pincodeController,
                      decoration: const InputDecoration(labelText: "Pincode"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: sectorController,
                      decoration: const InputDecoration(labelText: "Sector"),
                    ),
                    TextField(
                      controller: stateController,
                      decoration: const InputDecoration(labelText: "State"),
                    ),
                  ],
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
                  String username = usernameController.text.trim();
                  String password = passwordController.text.trim();
                  String name = nameController.text.trim();
                  String district = districtController.text.trim();
                  String city = cityController.text.trim();
                  String location = locationController.text.trim();
                  String pincode = pincodeController.text.trim();
                  String sector = sectorController.text.trim();
                  String state = stateController.text.trim();

                  if (username.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Username and password are required!"),
                      ),
                    );
                    return;
                  }

                  if (userType == "Client" &&
                      (name.isEmpty ||
                          district.isEmpty ||
                          city.isEmpty ||
                          location.isEmpty ||
                          pincode.isEmpty ||
                          sector.isEmpty ||
                          state.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill all client fields!"),
                      ),
                    );
                    return;
                  }

                  final body =
                      userType == "Admin"
                          ? {
                            "username": username,
                            "password": password,
                            "login": "0",
                          }
                          : {
                            "username": username,
                            "password": password,
                            "login": "Client",
                            "name": name,
                            "district": district,
                            "city": city,
                            "location": location,
                            "pincode": pincode,
                            "sector": sector,
                            "state": state,
                          };

                  try {
                    final response = await http.post(
                      Uri.parse("http://13.203.214.225:3000/add2"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode(body),
                    );

                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Success"),
                            content: Text(
                              "User added successfully as $userType!",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Done"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      await ErrorLogger.logError(
                        "Server error adding user",
                        "Status code: ${response.statusCode}",
                        response.body,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Failed to add user. Server said: ${response.body}",
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    await ErrorLogger.logError(
                      "Exception adding user",
                      e.toString(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Something went wrong. Please try again.",
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );
    },
  );
}
