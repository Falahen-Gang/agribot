import 'package:flutter/material.dart';
import 'api_service.dart';

class DiseaseInfoScreen extends StatefulWidget {
  final String taskId;

  const DiseaseInfoScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _DiseaseInfoScreenState createState() => _DiseaseInfoScreenState();
}

class _DiseaseInfoScreenState extends State<DiseaseInfoScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _diseaseData = [];
  Map<String, int> _diseaseCounts = {};
  int _totalDiseases = 0;

  @override
  void initState() {
    super.initState();
    _loadDiseaseData();
  }

  Future<void> _loadDiseaseData() async {
    try {
      print('\n==========================================');
      print('🔍 LOADING DISEASE DATA');
      print('==========================================');
      print('📋 Task ID: ${widget.taskId}');
      print('==========================================\n');

      final response = await AuthService.authenticatedRequest(
        'getDisease',
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
            _diseaseData = List<dynamic>.from(nestedData['data']);
            _calculateDiseaseStats();
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
            _errorMessage =
                nestedData['message'] ?? 'Failed to load disease data';
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
          _errorMessage = response['message'] ?? 'Failed to load disease data';
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

  void _calculateDiseaseStats() {
    _diseaseCounts.clear();
    _totalDiseases = _diseaseData.length;

    for (var disease in _diseaseData) {
      String type = disease['type'] ?? 'Unknown';
      _diseaseCounts[type] = (_diseaseCounts[type] ?? 0) + 1;
    }
  }

  Color _getDiseaseColor(String diseaseType) {
    switch (diseaseType) {
      case 'Late Blight':
        return Colors.red[700]!;
      case 'Early Blight':
        return Colors.orange[700]!;
      case 'Leaf Mold':
        return Colors.brown[700]!;
      case 'Bacterial Spot':
        return Colors.purple[700]!;
      case 'Healthy':
        return Colors.green[700]!;
      case 'Iron Deficiency':
        return Colors.amber[700]!;
      case 'Leaf_Miner':
        return Colors.blue[700]!;
      case 'Mosaic Virus':
        return Colors.indigo[700]!;
      case 'Septoria':
        return Colors.teal[700]!;
      case 'Spider Mites':
        return Colors.deepOrange[700]!;
      case 'Yellow Leaf Curl Virus':
        return Colors.yellow[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease Analysis Report'),
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
                              'Total Disease Spots Found: $_totalDiseases',
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

                    // Disease Distribution
                    Text(
                      'Disease Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._diseaseCounts.entries.map((entry) {
                      double percentage = (entry.value / _totalDiseases) * 100;
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
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getDiseaseColor(entry.key),
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
                                value: entry.value / _totalDiseases,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getDiseaseColor(entry.key),
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
                    if (_diseaseData.isNotEmpty &&
                        _diseaseData[0]['task']?['farms'] != null)
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
                                _diseaseData[0]['task']['farms']['name'],
                              ),
                              _buildInfoRow(
                                'Location',
                                _diseaseData[0]['task']['farms']['location'],
                              ),
                              _buildInfoRow(
                                'Area',
                                '${_diseaseData[0]['task']['farms']['area']} m²',
                              ),
                              _buildInfoRow(
                                'Number of Lines',
                                _diseaseData[0]['task']['farms']['number_of_lines'],
                              ),
                              _buildInfoRow(
                                'Line Length',
                                '${_diseaseData[0]['task']['farms']['line_length']} m',
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
