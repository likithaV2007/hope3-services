import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/child_model.dart';

class ChildSelector extends StatelessWidget {
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final Function(ChildModel) onChildSelected;

  const ChildSelector({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No children registered',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      height: 80,
      child: SizedBox(
        height: 80,
        child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = selectedChild?.id == child.id;
          
          return GestureDetector(
            onTap: () => onChildSelected(child),
            child: Container(
              margin: EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      backgroundImage: child.photoUrl != null 
                          ? NetworkImage(child.photoUrl!) 
                          : null,
                      child: child.photoUrl == null 
                          ? Text(
                              child.name.isNotEmpty ? child.name[0].toUpperCase() : 'C',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        child.name,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}