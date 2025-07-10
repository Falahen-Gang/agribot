import 'package:flutter/material.dart';
import 'api_service.dart';
import 'npkinfo_screen.dart';
import 'weedinfo_screen.dart';
import 'diseaseinfo_screen.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, String>> farms = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    try {
      final farmsResult = await AuthService.authenticatedRequest('getFarms');
      if (farmsResult['success'] == true &&
          farmsResult['data'] != null &&
          farmsResult['data']['data'] != null) {
        var farmsData = farmsResult['data']['data'];
        if (farmsData is List) {
          setState(() {
            farms =
                farmsData
                    .map(
                      (farm) => {
                        "id": farm['id']?.toString() ?? "",
                        "name": farm['name']?.toString() ?? "Unknown",
                        "location": farm['location']?.toString() ?? "Unknown",
                        "area": farm['area']?.toString() ?? "0",
                        "line_length": farm['line_length']?.toString() ?? "0",
                        "number_of_lines":
                            farm['number_of_lines']?.toString() ?? "0",
                        "notes": farm['notes']?.toString() ?? "",
                      },
                    )
                    .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading farms: $e');
    }
  }

  Future<void> _loadTasks() async {
    try {
      final response = await AuthService.authenticatedRequest('getTasks');
      print('Tasks API response: $response');

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['data'] != null) {
        List<dynamic> tasksList = response['data']['data'];
        setState(() {
          tasks =
              tasksList
                  .map(
                    (task) => {
                      'id': task['id'].toString(),
                      'title': task['title'].toString(),
                      'description': task['description'].toString(),
                      'status': task['status'].toString(),
                      'type': task['type'].toString(),
                      'farm_name': task['farms']['name'].toString(),
                      'price': task['price'].toString(),
                      'created_at': task['created_at'].toString(),
                    },
                  )
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[900]!;
      case 'accepted':
        return Colors.blue[900]!;
      case 'canceled':
        return Colors.red[900]!;
      case 'finished':
        return Colors.green[900]!;
      default:
        return Colors.grey[900]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green[700]),
              SizedBox(height: 16),
              Text(
                "Loading tasks...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              SizedBox(height: 16),
              Text(
                'Error loading tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(_errorMessage),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTasks,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Active Tasks",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Manage your agricultural tasks",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AddTaskScreen(farms: farms),
                              ),
                            ).then((_) => _loadTasks());
                          },
                          icon: Icon(Icons.add, size: 18),
                          label: Text("Add Task"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tasks.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No active tasks",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : Column(
                          children:
                              tasks
                                  .map(
                                    (task) => Card(
                                      margin: EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if (task['type'] == 'npk') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => NPKInfoScreen(
                                                      taskId: task['id'],
                                                    ),
                                              ),
                                            );
                                          } else if (task['type'] == 'weed') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => WeedInfoScreen(
                                                      taskId: task['id'],
                                                    ),
                                              ),
                                            );
                                          } else if (task['type'] ==
                                              'disease') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        DiseaseInfoScreen(
                                                          taskId: task['id'],
                                                        ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      task['title'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.green[900],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                        task['status'],
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      task['status']
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: _getStatusColor(
                                                          task['status'],
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.grass,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    task['farm_name'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.category,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    task['type'].toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    '\$${task['price']}',
                                                    style: TextStyle(
                                                      color: Colors.green[700],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                task['description'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
