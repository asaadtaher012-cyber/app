import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/localization_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedPeriod = 'week';
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  final List<String> _periods = [
    'week',
    'month',
    'year',
  ];

  final Map<String, String> _periodNames = {
    'week': 'هذا الأسبوع',
    'month': 'هذا الشهر',
    'year': 'هذا العام',
  };

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        // Load trip reports
        final tripSnapshot = await _firestore
            .collection('trips')
            .where('userId', isEqualTo: userId)
            .get();

        // Load payment reports
        final paymentSnapshot = await _firestore
            .collection('payments')
            .where('userId', isEqualTo: userId)
            .get();

        // Load attendance reports
        final attendanceSnapshot = await _firestore
            .collection('attendance')
            .where('userId', isEqualTo: userId)
            .get();

        setState(() {
          _reports = [
            {
              'type': 'trips',
              'title': 'إجمالي الرحلات',
              'count': tripSnapshot.docs.length,
              'icon': Icons.directions_bus,
              'color': AppTheme.primaryColor,
            },
            {
              'type': 'payments',
              'title': 'إجمالي المدفوعات',
              'count': paymentSnapshot.docs.length,
              'icon': Icons.payment,
              'color': AppTheme.successColor,
            },
            {
              'type': 'attendance',
              'title': 'معدل الحضور',
              'count': _calculateAttendanceRate(attendanceSnapshot.docs),
              'icon': Icons.check_circle,
              'color': AppTheme.accentColor,
            },
          ];
        });
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل التقارير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _calculateAttendanceRate(List<QueryDocumentSnapshot> attendanceDocs) {
    if (attendanceDocs.isEmpty) return 0.0;
    
    int presentCount = 0;
    for (var doc in attendanceDocs) {
      if (doc.data()['status'] == 'present') {
        presentCount++;
      }
    }
    
    return (presentCount / attendanceDocs.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('التقارير'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Period Selector
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'الفترة: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          items: _periods.map((period) {
                            return DropdownMenuItem<String>(
                              value: period,
                              child: Text(_periodNames[period]!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                            _loadReports();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Reports Grid
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return _buildReportCard(report);
                    },
                  ),
                ),
                
                // Detailed Reports Section
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تقارير مفصلة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDetailedReportItem(
                        'رحلات هذا الأسبوع',
                        '12 رحلة',
                        Icons.directions_bus,
                        AppTheme.primaryColor,
                      ),
                      _buildDetailedReportItem(
                        'المدفوعات المعلقة',
                        '3 مدفوعات',
                        Icons.payment,
                        AppTheme.warningColor,
                      ),
                      _buildDetailedReportItem(
                        'معدل الحضور',
                        '95%',
                        Icons.check_circle,
                        AppTheme.successColor,
                      ),
                      _buildDetailedReportItem(
                        'التقييمات المرسلة',
                        '8 تقييمات',
                        Icons.star,
                        AppTheme.accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              report['color'].withOpacity(0.1),
              report['color'].withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: report['color'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                report['icon'],
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              report['title'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              report['type'] == 'attendance' 
                  ? '${report['count'].toStringAsFixed(1)}%'
                  : '${report['count']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: report['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReportItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
