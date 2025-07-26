// Keep all your imports as you already have them
import 'package:flutter/material.dart';
import 'package:orbitsproject/pages/DeviceDetailPage.dart';
import 'package:orbitsproject/widgets/CustomAppBar.dart';
import 'package:orbitsproject/widgets/app_drawer.dart';
import 'package:orbitsproject/widgets/device_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orbitsproject/utils/error_logger.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String username = '';
  String password = '';
  String userRole = '';
  bool isLoading = true;

  List<Map<String, dynamic>> allDevices = [];
  List<Map<String, dynamic>> filteredDevices = [];

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      password = prefs.getString('password') ?? '';
    });
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    setState(() => isLoading = true);

    try {
      final getNameUrl = Uri.parse('http://13.203.214.225:3000/get-name');
      final getNameResponse = await http.post(
        getNameUrl,
        body: jsonEncode({"username": username, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      if (getNameResponse.statusCode == 200) {
        final getNameData = jsonDecode(getNameResponse.body);
        final flag = getNameData["flag"];
        userRole = flag;

        Map<String, String> requestBody = {
          "cs": "",
          "ds": "",
          "cis": "",
          "ls": "",
          "dname": "",
          "refname": "",
        };

        if (flag == "client") {
          requestBody["cs"] = getNameData["name"] ?? "";
        }

        final deviceUrl = Uri.parse('http://13.203.214.225:3000/device-select');
        final deviceResponse = await http.post(
          deviceUrl,
          body: jsonEncode(requestBody),
          headers: {"Content-Type": "application/json"},
        );

        if (deviceResponse.statusCode == 200) {
          final List<dynamic> deviceList = jsonDecode(deviceResponse.body);

          final List<Map<String, dynamic>> mappedDevices =
              deviceList.map((device) {
                return {
                  "name": device["device-name"],
                  "id": device["uniqueId"],
                  "client": device["name"],
                  "district": device["district"],
                  "city": device["city"],
                  "location": device["location"],
                  "status": device["status"],
                  "emergency": device["emergency"],
                  "sector": device["sector"],
                  "state": device["state"],
                  "pincode": device["pincode"],
                };
              }).toList();

          setState(() {
            allDevices = mappedDevices;
            filteredDevices = allDevices;
            isLoading = false;
          });
        } else {
          throw Exception("Device fetch failed");
        }
      } else {
        throw Exception("Initial authentication failed");
      }
    } catch (e, stack) {
      await ErrorLogger.logError(
        "DashboardPage _fetchDevices Error: $e",
        stack.toString(),
      );
      setState(() => isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _applyFilters({
    String? deviceName,
    String? deviceId,
    String? client,
    String? district,
    String? city,
    String? location,
    String? sector,
    String? state,
    String? pincode,
  }) {
    setState(() {
      filteredDevices =
          allDevices.where((device) {
            return (deviceName == null || device["name"] == deviceName) &&
                (deviceId == null || device["id"] == deviceId) &&
                (client == null || device["client"] == client) &&
                (district == null || device["district"] == district) &&
                (city == null || device["city"] == city) &&
                (location == null || device["location"] == location) &&
                (sector == null || device["sector"] == sector) &&
                (state == null || device["state"] == state) &&
                (pincode == null || device["pincode"] == pincode);
          }).toList();
    });
  }

  void _showFilterDialog() {
    String? selectedDeviceName;
    String? selectedDeviceId;
    String? selectedClient;
    String? selectedDistrict;
    String? selectedCity;
    String? selectedLocation;
    String? selectedSector;
    String? selectedState;
    String? selectedPincode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Filter Devices"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDropdown(
                      "Device Name",
                      selectedDeviceName,
                      allDevices.map((d) => d["name"].toString()).toSet(),
                      (value) =>
                          setDialogState(() => selectedDeviceName = value),
                    ),
                    _buildDropdown(
                      "Device ID",
                      selectedDeviceId,
                      allDevices.map((d) => d["id"].toString()).toSet(),
                      (value) => setDialogState(() => selectedDeviceId = value),
                    ),
                    _buildDropdown(
                      "Client",
                      selectedClient,
                      allDevices.map((d) => d["client"].toString()).toSet(),
                      (value) => setDialogState(() => selectedClient = value),
                    ),
                    _buildDropdown(
                      "District",
                      selectedDistrict,
                      allDevices.map((d) => d["district"].toString()).toSet(),
                      (value) => setDialogState(() => selectedDistrict = value),
                    ),
                    _buildDropdown(
                      "City",
                      selectedCity,
                      allDevices.map((d) => d["city"].toString()).toSet(),
                      (value) => setDialogState(() => selectedCity = value),
                    ),
                    _buildDropdown(
                      "Location",
                      selectedLocation,
                      allDevices.map((d) => d["location"].toString()).toSet(),
                      (value) => setDialogState(() => selectedLocation = value),
                    ),
                    _buildDropdown(
                      "Sector",
                      selectedSector,
                      allDevices.map((d) => d["sector"].toString()).toSet(),
                      (value) => setDialogState(() => selectedSector = value),
                    ),
                    _buildDropdown(
                      "State",
                      selectedState,
                      allDevices.map((d) => d["state"].toString()).toSet(),
                      (value) => setDialogState(() => selectedState = value),
                    ),
                    _buildDropdown(
                      "Pincode",
                      selectedPincode,
                      allDevices.map((d) => d["pincode"].toString()).toSet(),
                      (value) => setDialogState(() => selectedPincode = value),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _applyFilters(
                          deviceName: selectedDeviceName,
                          deviceId: selectedDeviceId,
                          client: selectedClient,
                          district: selectedDistrict,
                          city: selectedCity,
                          location: selectedLocation,
                          sector: selectedSector,
                          state: selectedState,
                          pincode: selectedPincode,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    Set<String> options,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: value,
        items:
            options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  DeviceStatus _getStatusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return DeviceStatus.active;
      case 'danger':
        return DeviceStatus.danger;
      default:
        return DeviceStatus.inActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: AppDrawer(username: username, userRole: userRole),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      _buildDeviceSummary(),
                      const SizedBox(height: 10),
                      _buildDeviceGrid(context),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text("Dashboard", style: TextStyle(fontSize: 24)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.green),
          onPressed: _fetchDevices,
        ),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showFilterDialog,
        borderRadius: BorderRadius.circular(8.0),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Filter",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceSummary() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF043549),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            "Devices: ${filteredDevices.length}",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDeviceGrid(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 1,
      children:
          filteredDevices.map((device) {
            return StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeviceDetailPage(deviceId: device["id"]),
                    ),
                  );
                },
                child: DeviceCard(
                  name: device['name'] ?? '',
                  id: device['id'] ?? '',
                  client: device['client'] ?? '',
                  district: device['district'] ?? '',
                  city: device['city'] ?? '',
                  location: device['location'] ?? '',
                  sector: device['sector'] ?? '',
                  state: device['state'] ?? '',
                  pincode: device['pincode'] ?? '',
                  status: _getStatusFromString(device['status']),
                  emergency: device['emergency'] ?? false,
                ),
              ),
            );
          }).toList(),
    );
  }
}
