import 'package:flutter/material.dart';
import 'api_service.dart';

class WeedInfoScreen extends StatefulWidget {
  final String taskId;

  const WeedInfoScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _WeedInfoScreenState createState() => _WeedInfoScreenState();
}

class _WeedInfoScreenState extends State<WeedInfoScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _weedData = [];
  Map<String, int> _weedCounts = {};
  int _totalWeeds = 0;

  @override
  void initState() {
    super.initState();
    _loadWeedData();
  }

  Future<void> _loadWeedData() async {
    try {
      print('\n==========================================');
      print('🔍 LOADING WEED DATA');
      print('==========================================');
      print('📋 Task ID: ${widget.taskId}');
      print('==========================================\n');

      final response = await AuthService.authenticatedRequest(
        'getWeed',
        method: 'POST',
        body: {'task_id': widget.taskId},
      );

      print('\n==========================================');
      print('📥 API RESPONSE');
      print('==========================================');
      print('Response: $response');
      print('==========================================\n');

      // Check for the nested data structure
      if (response['success'] == true && response['data'] != null) {
        final nestedData = response['data'];
        if (nestedData['status'] == true && nestedData['data'] != null) {
          print('\n==========================================');
          print('✅ SUCCESSFUL RESPONSE');
          print('==========================================');
          print('Status: ${nestedData['status']}');
          print('Data exists: ${nestedData['data'] != null}');
          print('==========================================\n');

          setState(() {
            _weedData = List<dynamic>.from(nestedData['data']);
            _calculateWeedStats();
            _isLoading = false;
          });
        } else {
          print('\n==========================================');
          print('❌ ERROR IN NESTED RESPONSE');
          print('==========================================');
          print('Status: ${nestedData['status']}');
          print('Message: ${nestedData['message']}');
          print('Data exists: ${nestedData['data'] != null}');
          print('==========================================\n');

          setState(() {
            _errorMessage = nestedData['message'] ?? 'Failed to load weed data';
            _isLoading = false;
          });
        }
      } else {
        print('\n==========================================');
        print('❌ ERROR IN RESPONSE');
        print('==========================================');
        print('Success: ${response['success']}');
        print('Message: ${response['message']}');
        print('Data exists: ${response['data'] != null}');
        print('==========================================\n');

        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load weed data';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('\n==========================================');
      print('🚨 ERROR OCCURRED');
      print('==========================================');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('==========================================\n');

      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateWeedStats() {
    _weedCounts.clear();
    _totalWeeds = _weedData.length;

    for (var weed in _weedData) {
      String type = weed['type'] ?? 'Unknown';
      _weedCounts[type] = (_weedCounts[type] ?? 0) + 1;
    }
  }

  Color _getWeedColor(String weedType) {
    switch (weedType.toLowerCase()) {
      case 'chenopodium album':
        return Colors.orange[700]!;
      case 'amaranthus tuberculatusl':
        return Colors.red[700]!;
      case 'taraxacum officinale':
        return Colors.yellow[700]!;
      case 'xanthium strumarium':
        return Colors.brown[700]!;
      case 'amaranthus palmeri':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _formatWeedName(String weedType) {
    // Convert snake_case or space-separated to Title Case
    return weedType
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weed Analysis Report'),
        backgroundColor: Colors.green[700],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Field Analysis Summary',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Total Weed Spots Found: $_totalWeeds',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Treatment Status: Completed',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Weed Distribution
                    Text(
                      'Weed Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._weedCounts.entries.map((entry) {
                      double percentage = (entry.value / _totalWeeds) * 100;
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatWeedName(entry.key),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getWeedColor(entry.key),
                                    ),
                                  ),
                                  Text(
                                    '${entry.value} spots',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: entry.value / _totalWeeds,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getWeedColor(entry.key),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${percentage.toStringAsFixed(1)}% of total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 24),

                    // Farm Information
                    if (_weedData.isNotEmpty &&
                        _weedData[0]['task']?['farms'] != null)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Farm Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildInfoRow(
                                'Farm Name',
                                _weedData[0]['task']['farms']['name'],
                              ),
                              _buildInfoRow(
                                'Location',
                                _weedData[0]['task']['farms']['location'],
                              ),
                              _buildInfoRow(
                                'Area',
                                '${_weedData[0]['task']['farms']['area']} m²',
                              ),
                              _buildInfoRow(
                                'Number of Lines',
                                _weedData[0]['task']['farms']['number_of_lines'],
                              ),
                              _buildInfoRow(
                                'Line Length',
                                '${_weedData[0]['task']['farms']['line_length']} m',
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
