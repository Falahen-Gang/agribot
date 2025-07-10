import 'package:flutter/material.dart';
import 'api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final List<Map<String, String>> farms;

  const AddTaskScreen({Key? key, required this.farms}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedServiceId;
  int? _selectedFarmId;
  String? _selectedDate;
  List<Map<String, dynamic>> _availableDates = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDates();
  }

  Future<void> _loadDates() async {
    try {
      final response = await AuthService.authenticatedRequest('getDates');

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        List<dynamic> datesList = response['data']['data'];
        setState(() {
          _availableDates =
              datesList.map((date) {
                return {
                  'id': date['id'].toString(),
                  'date': date['date'].toString(),
                  'formatted_date': date['date'].toString(),
                };
              }).toList();
        });
      }
    } catch (e) {
      print('Error in _loadDates: $e');
    }
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceId == null ||
        _selectedFarmId == null ||
        _selectedDate == null) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_titleController.text.isEmpty ||
          _descriptionController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all required fields';
          _isLoading = false;
        });
        return;
      }

      final selectedFarm = widget.farms.firstWhere(
        (farm) =>
            int.tryParse(farm['id']?.toString() ?? '0') == _selectedFarmId,
        orElse: () => widget.farms.first,
      );

      final farmId = int.tryParse(selectedFarm['id']?.toString() ?? '0') ?? 0;

      final requestBody = {
        'service_id': _selectedServiceId.toString(),
        'farm_id': farmId.toString(),
        'date_id': _selectedDate,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'pending',
      };

      final response = await AuthService.authenticatedRequest(
        'addTask',
        method: 'POST',
        body: requestBody,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task added successfully')));
        Navigator.pop(context);
      } else {
        final errorMsg = response['message'] ?? 'Failed to add task';
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Task"),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedServiceId,
                    decoration: InputDecoration(
                      labelText: "Service Type",
                      prefixIcon: Icon(
                        Icons.category,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 1, child: Text("NPK")),
                      DropdownMenuItem(value: 2, child: Text("Weed")),
                      DropdownMenuItem(value: 3, child: Text("Disease")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedServiceId = value;
                      });
                    },
                    validator:
                        (value) =>
                            value == null
                                ? 'Please select a service type'
                                : null,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: _selectedFarmId,
                    decoration: InputDecoration(
                      labelText: "Select Farm",
                      prefixIcon: Icon(Icons.grass, color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        widget.farms.map((farm) {
                          final farmId =
                              int.tryParse(farm['id']?.toString() ?? '0') ?? 0;
                          return DropdownMenuItem<int>(
                            value: farmId,
                            child: Text(farm["name"]!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFarmId = value;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select a farm' : null,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedDate,
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        _availableDates.map((date) {
                          return DropdownMenuItem<String>(
                            value: date['id'],
                            child: Text(date['date']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDate = value;
                      });
                    },
                    validator:
                        (value) =>
                            value == null ? 'Please select a date' : null,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      prefixIcon: Icon(Icons.title, color: Colors.green[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a title'
                                : null,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(
                        Icons.description,
                        color: Colors.green[700],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter a description'
                                : null,
                  ),
                  SizedBox(height: 24),

                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 24),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Add Task",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
