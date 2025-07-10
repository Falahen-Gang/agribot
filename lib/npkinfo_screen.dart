import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class NPKInfoScreen extends StatefulWidget {
  final String taskId;

  const NPKInfoScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _NPKInfoScreenState createState() => _NPKInfoScreenState();
}

class _NPKInfoScreenState extends State<NPKInfoScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _npkData = [];

  // Reference values for NPK
  final Map<String, Map<String, double>> _referenceValues = {
    'N': {'min': 20, 'max': 50},
    'P': {'min': 15, 'max': 30},
    'K': {'min': 150, 'max': 250},
  };

  @override
  void initState() {
    super.initState();
    _loadNPKData();
  }

  Future<void> _loadNPKData() async {
    try {
      print('\n\n==========================================');
      print('🔍 STARTING NPK DATA LOAD');
      print('==========================================');
      print('📋 Task ID: ${widget.taskId}');

      final response = await AuthService.authenticatedRequest(
        'getNPK',
        method: 'POST',
        body: {'task_id': widget.taskId},
      );

      print('\n📥 API RESPONSE');
      print('------------------------------------------');
      print('Success: ${response['success']}');
      print('Data: ${response['data']}');

      if (response['success'] == true && response['data'] != null) {
        final responseData = response['data'];
        print('\n📊 DATA STRUCTURE');
        print('------------------------------------------');
        print('Type: ${responseData.runtimeType}');

        if (responseData is Map && responseData['data'] is List) {
          print('Format: Map with data array');
          setState(() {
            _npkData =
                (responseData['data'] as List).map((item) {
                  print('\n📝 Processing item:');
                  print('------------------------------------------');
                  print('Item: $item');
                  return Map<String, dynamic>.from(item);
                }).toList();
            print('\n✅ Final parsed data:');
            print('------------------------------------------');
            print(_npkData);
            _isLoading = false;
          });
        } else {
          print('\n❌ Invalid data format');
          print('------------------------------------------');
          print('Type: ${responseData.runtimeType}');
          setState(() {
            _errorMessage = 'Invalid data format received';
            _isLoading = false;
          });
        }
      } else {
        print('\n❌ API Response Error');
        print('------------------------------------------');
        print('Message: ${response['message']}');
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load NPK data';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('\n❌ ERROR OCCURRED');
      print('------------------------------------------');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
    print('\n==========================================');
    print('🏁 NPK DATA LOAD COMPLETE');
    print('==========================================\n\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NPK Analysis'),
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
                    // Header
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soil Nutrient Analysis',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Reference Values Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.green[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Reference Values',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildReferenceValueRow(
                              'Nitrogen (N)',
                              '20-50 ppm',
                              'Needed for foliage growth',
                              Colors.blue,
                            ),
                            SizedBox(height: 12),
                            _buildReferenceValueRow(
                              'Phosphorus (P)',
                              '15-30 ppm',
                              'Important for root development',
                              Colors.orange,
                            ),
                            SizedBox(height: 12),
                            _buildReferenceValueRow(
                              'Potassium (K)',
                              '150-250 ppm',
                              'Critical for fruit development',
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // NPK Graphs
                    _buildNPKGraph('N', 'n', Colors.blue),
                    SizedBox(height: 24),
                    _buildNPKGraph('P', 'p', Colors.orange),
                    SizedBox(height: 24),
                    _buildNPKGraph('K', 'k', Colors.purple),
                    SizedBox(height: 24),

                    // AI Suggestions Card (Always visible)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.amber[700],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AI Suggestions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (_npkData.isNotEmpty &&
                                _npkData[0]['task'] != null &&
                                _npkData[0]['task']['suggestions'] != null)
                              Text(
                                _npkData[0]['task']['suggestions'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'No suggestions available at the moment. Check back later for AI-powered recommendations.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget _buildReferenceValueRow(
    String title,
    String range,
    String description,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  range,
                  style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNPKGraph(String nutrient, String valueKey, Color color) {
    if (_npkData.isEmpty) {
      return Container(
        height: 200,
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No data available')),
      );
    }

    // Process all data points
    final spots =
        _npkData.asMap().entries.map((entry) {
          double distance = 0.0;
          double value = 0.0;

          if (entry.value['distance'] != null) {
            if (entry.value['distance'] is num) {
              distance = entry.value['distance'].toDouble();
            } else {
              distance =
                  double.tryParse(entry.value['distance'].toString()) ?? 0.0;
            }
          }

          if (entry.value[valueKey] != null) {
            if (entry.value[valueKey] is num) {
              value = entry.value[valueKey].toDouble();
            } else {
              value = double.tryParse(entry.value[valueKey].toString()) ?? 0.0;
            }
          }

          return FlSpot(distance, value);
        }).toList();

    final validSpots =
        spots.where((spot) => spot.x != 0 || spot.y != 0).toList();

    if (validSpots.isEmpty) {
      return Container(
        height: 200,
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No valid data points available')),
      );
    }

    // Calculate min and max values for proper scaling
    final minX = validSpots
        .map((spot) => spot.x)
        .reduce((a, b) => a < b ? a : b);
    final maxX = validSpots
        .map((spot) => spot.x)
        .reduce((a, b) => a > b ? a : b);
    final minY = validSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a < b ? a : b);
    final maxY = validSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);

    // Sample data points if there are too many
    List<FlSpot> displaySpots = validSpots;
    if (validSpots.length > 100) {
      // Calculate sampling interval
      final interval = (validSpots.length / 100).ceil();
      displaySpots = List.generate(
        (validSpots.length / interval).ceil(),
        (index) => validSpots[index * interval],
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '$nutrient Levels',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (validSpots.length > 100)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      '(${validSpots.length} points sampled)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (maxY - minY) / 5, // 5 horizontal lines
                    verticalInterval: (maxX - minX) / 5, // 5 vertical lines
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300], strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(color: Colors.grey[300], strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                        interval: (maxY - minY) / 5, // 5 labels
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}m',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                        interval: (maxX - minX) / 5, // 5 labels
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: minX,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: displaySpots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          // Only show dots for sampled points
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(2)} ppm\nat ${spot.x.toStringAsFixed(0)}m',
                            TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Optimal Range: ${_referenceValues[nutrient]!['min']} - ${_referenceValues[nutrient]!['max']} ppm',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
