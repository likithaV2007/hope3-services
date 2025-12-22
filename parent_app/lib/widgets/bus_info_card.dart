import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../constants/app_colors.dart';
import '../services/eta_service.dart';

class BusInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(
      builder: (context, provider, child) {
        final bus = provider.currentBus;
        final eta = provider.eta;
        final pickupStop = provider.pickupStop;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.directions_bus,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    bus != null ? 'Bus ${bus.number}' : 'Bus Not Active',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bus?.isActive == true ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bus?.isActive == true ? 'ACTIVE' : 'OFFLINE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (bus != null) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.person,
                        label: 'Driver',
                        value: bus.driverName,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.speed,
                        label: 'Speed',
                        value: '${bus.speed.toInt()} km/h',
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.location_on,
                        label: 'Pickup Stop',
                        value: pickupStop?.name ?? 'Unknown',
                      ),
                    ),
                    if (eta != null)
                      Expanded(
                        child: _InfoItem(
                          icon: Icons.access_time,
                          label: 'ETA',
                          value: ETAService.formatETA(eta),
                          valueColor: eta.inMinutes <= 5 ? Colors.orange : AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ],
              
              if (bus == null || !bus.isActive) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.grey, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Bus is not currently active',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.grey, size: 16),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}