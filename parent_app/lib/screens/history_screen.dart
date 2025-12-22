import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/tracking_provider.dart';

class HistoryScreen extends StatefulWidget {
  final String parentId;

  const HistoryScreen({super.key, required this.parentId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadTripHistory(widget.parentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trip History',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
            
            // Trip history list
            Expanded(
              child: Consumer<TrackingProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildTripItem(
                        'Yesterday, Oct 26',
                        'Morning Trip',
                        '18:3 WON',
                        'Successful',
                        AppColors.success,
                        false,
                      ),
                      _buildTripItem(
                        '00:35 on day, Oct 28',
                        '20:1 in Trip',
                        '74:2 WON',
                        null,
                        null,
                        true,
                      ),
                      _buildTripItem(
                        '28:3 41 to 0:30',
                        '6:1 3m Trip',
                        '74:3 WON',
                        null,
                        null,
                        true,
                      ),
                      _buildTripItem(
                        'Obsterday, Oct 26',
                        '45:3 in Trip',
                        '74:2 WON',
                        null,
                        null,
                        true,
                      ),
                      _buildTripItem(
                        '08:4 88 to 0:30',
                        '16:3m Trip',
                        '74:5 WON',
                        'MISSED BUS',
                        AppColors.error,
                        true,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripItem(
    String date,
    String tripInfo,
    String timeInfo,
    String? status,
    Color? statusColor,
    bool showMap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: status == 'MISSED BUS' 
            ? Border.all(color: AppColors.error, width: 1)
            : Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  tripInfo,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  timeInfo,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          if (showMap) ...[
            Container(
              width: 60,
              height: 40,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: CustomPaint(
                painter: MapPainter(),
              ),
            ),
          ],
          
          if (status != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor ?? AppColors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw a simple route line
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.3,
      size.width * 0.8, size.height * 0.6,
    );
    
    canvas.drawPath(path, paint);
    
    // Draw start and end points
    final pointPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      3,
      pointPaint,
    );
    
    pointPaint.color = AppColors.error;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      3,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}