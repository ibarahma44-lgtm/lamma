import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class MealPlannerWidget extends StatefulWidget {
  const MealPlannerWidget({Key? key}) : super(key: key);

  @override
  State<MealPlannerWidget> createState() => _MealPlannerWidgetState();
}

class _MealPlannerWidgetState extends State<MealPlannerWidget> {
  // Sample food items for each meal
  final Map<String, List<String>> mealItems = {
    'Breakfast': ['Bread', 'Eggs', 'Milk', 'Cereal', 'Fruits', 'Coffee', 'Tea', 'Juice'],
    'Lunch': ['Rice', 'Chicken', 'Salad', 'Pasta', 'Sandwich', 'Soup', 'Vegetables'],
    'Dinner': ['Meat', 'Fish', 'Potatoes', 'Pasta', 'Salad', 'Bread', 'Dessert'],
  };

  // Track selected items for each meal
  final Map<String, Set<String>> selectedItems = {
    'Breakfast': {},
    'Lunch': {},
    'Dinner': {},
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF0D4D4D).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(0xFF0D4D4D),
                    size: 24.0,
                  ),
                ),
                SizedBox(width: 12.0),
                Text(
                  '🍽️ Meal Planner',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Inter',
                        color: Color(0xFF0D4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ...mealItems.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Inter',
                          color: Color(0xFF0D4D4D),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    height: 100.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final item = entry.value[index];
                        final isSelected = selectedItems[entry.key]!.contains(item);
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              item,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Color(0xFF0D4D4D),
                                fontFamily: 'Inter',
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedItems[entry.key]!.add(item);
                                } else {
                                  selectedItems[entry.key]!.remove(item);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Color(0xFF0D4D4D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                color: Color(0xFF0D4D4D),
                                width: 1.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 