import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> with SingleTickerProviderStateMixin {
  String selectedMealType = 'Breakfast';
  DateTime selectedDate = DateTime.now();
  Map<String, Set<String>> selectedItemsByCategory = {
    'Proteins': <String>{},
    'Vegetables': <String>{},
    'Drinks': <String>{},
    'Desserts': <String>{},
  };

  List<Map<String, dynamic>> savedMeals = [];
  bool isExpanded = false;
  late TabController _tabController;
  final Map<String, TextEditingController> _searchControllers = {};
  final Map<String, TextEditingController> _customItemControllers = {};
  bool showCustomItemInput = false;
  String selectedCategory = 'Proteins';
  bool isFavorite = false;
  bool isRepeating = false;
  int repeatDays = 1;
  bool isDarkMode = false;
  String currentLanguage = 'en';
  int currentStreak = 0;
  List<String> earnedBadges = [];
  Map<String, List<String>> familyMembers = {
    'Mom': ['assets/avatars/mom.png'],
    'Dad': ['assets/avatars/dad.png'],
    'Ali': ['assets/avatars/ali.png'],
  };

  String? selectedFamilyMember;

  final Map<String, List<String>> commonMeals = {
    'Breakfast': [
      'Classic Breakfast: Eggs, Bread, Coffee',
      'Healthy Start: Oatmeal, Banana, Green Tea',
      'Protein Packed: Greek Yogurt, Berries, Protein Shake',
    ],
    'Lunch': [
      'Light Lunch: Grilled Chicken, Salad, Water',
      'Power Bowl: Quinoa, Vegetables, Tofu',
      'Mediterranean: Hummus, Pita, Vegetables',
    ],
    'Dinner': [
      'Family Dinner: Steak, Potatoes, Vegetables',
      'Asian Fusion: Rice, Stir-fry, Tea',
      'Italian Night: Pasta, Salad, Wine',
    ],
  };

  final Map<String, List<String>> foodCategories = {
    'Proteins': [
      'Chicken', 'Beef', 'Fish', 'Eggs', 'Tofu', 'Lentils', 'Beans',
      'Turkey', 'Pork', 'Lamb', 'Shrimp', 'Crab', 'Salmon', 'Tuna',
      'Chickpeas', 'Quinoa', 'Tempeh', 'Seitan', 'Duck', 'Venison',
      'Bison', 'Rabbit', 'Goat', 'Mussels', 'Oysters', 'Sardines',
      'Anchovies', 'Mackerel', 'Trout', 'Cod'
    ],
    'Vegetables': [
      'Lettuce', 'Tomato', 'Carrot', 'Broccoli', 'Spinach', 'Kale',
      'Cucumber', 'Bell Pepper', 'Onion', 'Garlic', 'Potato', 'Sweet Potato',
      'Cauliflower', 'Brussels Sprouts', 'Asparagus', 'Green Beans',
      'Peas', 'Corn', 'Mushrooms', 'Eggplant', 'Zucchini', 'Squash',
      'Radish', 'Beetroot', 'Celery', 'Artichoke', 'Okra', 'Bok Choy',
      'Cabbage', 'Arugula'
    ],
    'Drinks': [
      'Water', 'Juice', 'Tea', 'Coffee', 'Milk', 'Smoothie',
      'Lemonade', 'Iced Tea', 'Hot Chocolate', 'Coconut Water',
      'Almond Milk', 'Soy Milk', 'Oat Milk', 'Green Tea',
      'Herbal Tea', 'Sparkling Water', 'Sports Drink', 'Energy Drink',
      'Protein Shake', 'Fruit Punch', 'Apple Cider', 'Ginger Ale',
      'Soda', 'Wine', 'Beer', 'Cocktail', 'Mocktail', 'Milkshake',
      'Hot Cider', 'Espresso'
    ],
    'Desserts': [
      'Cake', 'Dates', 'Chocolate', 'Ice Cream', 'Cookies',
      'Pudding', 'Fruit Salad', 'Cheesecake', 'Pie', 'Brownies',
      'Muffins', 'Donuts', 'Cupcakes', 'Tiramisu', 'Cannoli',
      'Baklava', 'Gelato', 'Sorbet', 'Fruit Tart', 'Creme Brulee',
      'Panna Cotta', 'Mousse', 'Fudge', 'Caramel', 'Toffee',
      'Candy', 'Jelly', 'Custard', 'Trifle', 'Parfait'
    ],
  };

  // Nutrition data for food items
  final Map<String, Map<String, dynamic>> nutritionData = {
    // Proteins
    'Chicken': {'calories': 165, 'protein': 31, 'carbs': 0},
    'Beef': {'calories': 250, 'protein': 26, 'carbs': 0},
    'Fish': {'calories': 120, 'protein': 22, 'carbs': 0},
    'Eggs': {'calories': 155, 'protein': 12, 'carbs': 1.1},
    'Tofu': {'calories': 76, 'protein': 8, 'carbs': 1.9},
    'Lentils': {'calories': 116, 'protein': 9, 'carbs': 20},
    'Beans': {'calories': 127, 'protein': 8.7, 'carbs': 23},
    'Turkey': {'calories': 157, 'protein': 29, 'carbs': 0},
    'Pork': {'calories': 242, 'protein': 27, 'carbs': 0},
    'Lamb': {'calories': 294, 'protein': 25, 'carbs': 0},
    'Shrimp': {'calories': 99, 'protein': 24, 'carbs': 0.2},
    'Salmon': {'calories': 208, 'protein': 22, 'carbs': 0},
    'Tuna': {'calories': 132, 'protein': 28, 'carbs': 0},
    'Chickpeas': {'calories': 164, 'protein': 8.9, 'carbs': 27},
    'Quinoa': {'calories': 120, 'protein': 4.4, 'carbs': 21},
    'Tempeh': {'calories': 192, 'protein': 20, 'carbs': 7.6},
    'Seitan': {'calories': 370, 'protein': 75, 'carbs': 14},
    'Duck': {'calories': 337, 'protein': 19, 'carbs': 0},
    'Venison': {'calories': 158, 'protein': 30, 'carbs': 0},
    'Bison': {'calories': 143, 'protein': 28, 'carbs': 0},
    'Rabbit': {'calories': 173, 'protein': 33, 'carbs': 0},
    'Goat': {'calories': 143, 'protein': 27, 'carbs': 0},
    'Mussels': {'calories': 86, 'protein': 12, 'carbs': 3.3},
    'Oysters': {'calories': 69, 'protein': 9, 'carbs': 3.9},
    'Sardines': {'calories': 208, 'protein': 24, 'carbs': 0},
    'Anchovies': {'calories': 131, 'protein': 20, 'carbs': 0},
    'Mackerel': {'calories': 305, 'protein': 19, 'carbs': 0},
    'Trout': {'calories': 190, 'protein': 22, 'carbs': 0},
    'Cod': {'calories': 82, 'protein': 18, 'carbs': 0},

    // Vegetables
    'Lettuce': {'calories': 15, 'protein': 1.4, 'carbs': 2.9},
    'Tomato': {'calories': 22, 'protein': 1.1, 'carbs': 4.8},
    'Carrot': {'calories': 41, 'protein': 0.9, 'carbs': 9.6},
    'Broccoli': {'calories': 34, 'protein': 2.8, 'carbs': 6.6},
    'Spinach': {'calories': 23, 'protein': 2.9, 'carbs': 3.6},
    'Kale': {'calories': 49, 'protein': 4.3, 'carbs': 8.8},
    'Cucumber': {'calories': 15, 'protein': 0.7, 'carbs': 3.6},
    'Bell Pepper': {'calories': 31, 'protein': 1, 'carbs': 6},
    'Onion': {'calories': 40, 'protein': 1.1, 'carbs': 9.3},
    'Garlic': {'calories': 149, 'protein': 6.4, 'carbs': 33.1},
    'Potato': {'calories': 77, 'protein': 2, 'carbs': 17},
    'Sweet Potato': {'calories': 86, 'protein': 1.6, 'carbs': 20},
    'Cauliflower': {'calories': 25, 'protein': 1.9, 'carbs': 5},
    'Brussels Sprouts': {'calories': 43, 'protein': 3.4, 'carbs': 8.9},
    'Asparagus': {'calories': 20, 'protein': 2.2, 'carbs': 3.9},
    'Green Beans': {'calories': 31, 'protein': 1.8, 'carbs': 7},
    'Peas': {'calories': 81, 'protein': 5.4, 'carbs': 14.5},
    'Corn': {'calories': 86, 'protein': 3.2, 'carbs': 19},
    'Mushrooms': {'calories': 22, 'protein': 3.1, 'carbs': 3.3},
    'Eggplant': {'calories': 25, 'protein': 1, 'carbs': 6},
    'Zucchini': {'calories': 17, 'protein': 1.2, 'carbs': 3.1},
    'Squash': {'calories': 31, 'protein': 1.2, 'carbs': 6.5},
    'Radish': {'calories': 16, 'protein': 0.7, 'carbs': 3.4},
    'Beetroot': {'calories': 43, 'protein': 1.6, 'carbs': 9.6},
    'Celery': {'calories': 16, 'protein': 0.7, 'carbs': 3},
    'Artichoke': {'calories': 47, 'protein': 3.3, 'carbs': 10.5},
    'Okra': {'calories': 33, 'protein': 2, 'carbs': 7},
    'Bok Choy': {'calories': 13, 'protein': 1.5, 'carbs': 2.2},
    'Cabbage': {'calories': 25, 'protein': 1.3, 'carbs': 5.8},
    'Arugula': {'calories': 25, 'protein': 2.6, 'carbs': 3.7},

    // Drinks
    'Water': {'calories': 0, 'protein': 0, 'carbs': 0},
    'Juice': {'calories': 120, 'protein': 0.5, 'carbs': 30},
    'Tea': {'calories': 2, 'protein': 0.2, 'carbs': 0.5},
    'Coffee': {'calories': 2, 'protein': 0.3, 'carbs': 0},
    'Milk': {'calories': 103, 'protein': 8, 'carbs': 12},
    'Smoothie': {'calories': 150, 'protein': 2, 'carbs': 35},
    'Lemonade': {'calories': 120, 'protein': 0, 'carbs': 30},
    'Iced Tea': {'calories': 90, 'protein': 0, 'carbs': 22},
    'Hot Chocolate': {'calories': 192, 'protein': 8, 'carbs': 28},
    'Coconut Water': {'calories': 45, 'protein': 0.5, 'carbs': 11},
    'Almond Milk': {'calories': 30, 'protein': 1, 'carbs': 1},
    'Soy Milk': {'calories': 80, 'protein': 7, 'carbs': 4},
    'Oat Milk': {'calories': 120, 'protein': 3, 'carbs': 16},
    'Green Tea': {'calories': 2, 'protein': 0.2, 'carbs': 0.5},
    'Herbal Tea': {'calories': 2, 'protein': 0, 'carbs': 0.5},
    'Sparkling Water': {'calories': 0, 'protein': 0, 'carbs': 0},
    'Sports Drink': {'calories': 80, 'protein': 0, 'carbs': 21},
    'Energy Drink': {'calories': 110, 'protein': 0, 'carbs': 28},
    'Protein Shake': {'calories': 160, 'protein': 30, 'carbs': 3},
    'Fruit Punch': {'calories': 140, 'protein': 0, 'carbs': 35},
    'Apple Cider': {'calories': 120, 'protein': 0, 'carbs': 30},
    'Ginger Ale': {'calories': 124, 'protein': 0, 'carbs': 32},
    'Soda': {'calories': 150, 'protein': 0, 'carbs': 39},
    'Wine': {'calories': 125, 'protein': 0.1, 'carbs': 3.8},
    'Beer': {'calories': 153, 'protein': 1.6, 'carbs': 13},
    'Cocktail': {'calories': 180, 'protein': 0, 'carbs': 15},
    'Mocktail': {'calories': 120, 'protein': 0, 'carbs': 30},
    'Milkshake': {'calories': 300, 'protein': 8, 'carbs': 45},
    'Hot Cider': {'calories': 120, 'protein': 0, 'carbs': 30},
    'Espresso': {'calories': 1, 'protein': 0.1, 'carbs': 0},

    // Desserts
    'Cake': {'calories': 371, 'protein': 5, 'carbs': 53},
    'Dates': {'calories': 282, 'protein': 2.5, 'carbs': 75},
    'Chocolate': {'calories': 545, 'protein': 4.9, 'carbs': 61},
    'Ice Cream': {'calories': 273, 'protein': 4.6, 'carbs': 31},
    'Cookies': {'calories': 502, 'protein': 6, 'carbs': 65},
    'Pudding': {'calories': 142, 'protein': 2.6, 'carbs': 23},
    'Fruit Salad': {'calories': 60, 'protein': 0.8, 'carbs': 15},
    'Cheesecake': {'calories': 321, 'protein': 6, 'carbs': 25},
    'Pie': {'calories': 237, 'protein': 2.3, 'carbs': 34},
    'Brownies': {'calories': 466, 'protein': 6.1, 'carbs': 64},
    'Muffins': {'calories': 265, 'protein': 4.5, 'carbs': 44},
    'Donuts': {'calories': 452, 'protein': 4.9, 'carbs': 56},
    'Cupcakes': {'calories': 262, 'protein': 3.1, 'carbs': 39},
    'Tiramisu': {'calories': 300, 'protein': 4.5, 'carbs': 35},
    'Cannoli': {'calories': 300, 'protein': 5, 'carbs': 35},
    'Baklava': {'calories': 334, 'protein': 4.8, 'carbs': 45},
    'Gelato': {'calories': 200, 'protein': 3.5, 'carbs': 30},
    'Sorbet': {'calories': 120, 'protein': 0, 'carbs': 30},
    'Fruit Tart': {'calories': 250, 'protein': 3, 'carbs': 35},
    'Creme Brulee': {'calories': 300, 'protein': 4, 'carbs': 30},
    'Panna Cotta': {'calories': 280, 'protein': 3.5, 'carbs': 25},
    'Mousse': {'calories': 250, 'protein': 3, 'carbs': 30},
    'Fudge': {'calories': 411, 'protein': 1, 'carbs': 76},
    'Caramel': {'calories': 382, 'protein': 0.5, 'carbs': 77},
    'Toffee': {'calories': 400, 'protein': 0.5, 'carbs': 60},
    'Candy': {'calories': 300, 'protein': 0, 'carbs': 75},
    'Jelly': {'calories': 70, 'protein': 0, 'carbs': 17},
    'Custard': {'calories': 122, 'protein': 2.5, 'carbs': 17},
    'Trifle': {'calories': 200, 'protein': 3, 'carbs': 30},
    'Parfait': {'calories': 180, 'protein': 4, 'carbs': 25},
  };

  // Timeline view state
  DateTime selectedTimelineDate = DateTime.now();
  List<DateTime> timelineDates = [];
  int currentTimelineIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Timeline, Nutrition, Family, History
    _loadSavedMeals();
    _initializeControllers();
    _initializeTimeline();
    _loadUserProgress();
  }

  void _initializeControllers() {
    for (var category in foodCategories.keys) {
      _searchControllers[category] = TextEditingController();
      _customItemControllers[category] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchControllers.values.forEach((controller) => controller.dispose());
    _customItemControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadSavedMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedMealsJson = prefs.getString('saved_meals');
    if (savedMealsJson != null) {
      setState(() {
        savedMeals = List<Map<String, dynamic>>.from(
          json.decode(savedMealsJson).map((x) => Map<String, dynamic>.from(x))
        );
      });
    }
  }

  List<Map<String, dynamic>> getRecentMeals() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return savedMeals.where((meal) {
      final mealDate = DateTime.parse(meal['date']);
      return mealDate.isAfter(weekStart) && mealDate.isBefore(now.add(Duration(days: 7)));
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF0D4D4D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0D4D4D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _applyCommonMeal(String meal) {
    final items = meal.split(': ')[1].split(', ');
    setState(() {
      selectedItemsByCategory.forEach((category, items) => items.clear());
      for (var item in items) {
        for (var category in foodCategories.entries) {
          if (category.value.contains(item)) {
            selectedItemsByCategory[category.key]!.add(item);
            break;
          }
        }
      }
    });
  }

  Future<void> _saveMeal() async {
    final mealData = {
      'date': selectedDate.toIso8601String(),
      'mealType': selectedMealType,
      'items': selectedItemsByCategory.map((k, v) => MapEntry(k, v.toList())),
      'familyMember': selectedFamilyMember,
      'isFavorite': false,
    };
    setState(() {
      savedMeals.add(mealData);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_meals', json.encode(savedMeals));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal saved for ${DateFormat('MMMM d').format(selectedDate)} – $selectedMealType'),
        backgroundColor: Color(0xFF0D4D4D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    setState(() {
      selectedItemsByCategory.forEach((k, v) => v.clear());
      selectedMealType = 'Breakfast';
      selectedDate = DateTime.now();
      selectedFamilyMember = null;
    });
  }

  void _removeMeal(int index) async {
    setState(() {
      savedMeals.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_meals', json.encode(savedMeals));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal removed'),
        backgroundColor: Color(0xFF0D4D4D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _toggleFavorite(int index) async {
    setState(() {
      savedMeals[index]['isFavorite'] = !(savedMeals[index]['isFavorite'] ?? false);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_meals', json.encode(savedMeals));
  }

  void _addCustomItem(String category) {
    final controller = _customItemControllers[category];
    if (controller != null && controller.text.isNotEmpty) {
      setState(() {
        foodCategories[category]!.add(controller.text);
        selectedItemsByCategory[category]!.add(controller.text);
        controller.clear();
        showCustomItemInput = false;
      });
    }
  }

  Widget _buildFoodCategory(String category, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            category,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D4D4D),
            ),
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedItemsByCategory[category]!.contains(item);
              return ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF0D4D4D),
                  ),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleFoodSelection(category, item),
                  activeColor: Color(0xFF0D4D4D),
                ),
                onTap: () => _toggleFoodSelection(category, item),
                selected: isSelected,
                selectedTileColor: Color(0xFF0D4D4D).withOpacity(0.1),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedMealsList() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('Saved Meals', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Color(0xFF0D4D4D))),
        ),
        if (savedMeals.isEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('No saved meals yet', style: TextStyle(color: Colors.grey, fontFamily: 'Inter')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: savedMeals.length,
            itemBuilder: (context, index) {
              final meal = savedMeals[index];
              final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(meal['date']));
              final isToday = dateStr == todayStr;
              return Card(
                color: isToday ? Color(0xFFE0F7FA) : Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('${meal['mealType']} – ${DateFormat('MMM d').format(DateTime.parse(meal['date']))}',
                        style: TextStyle(fontFamily: 'Inter', color: Color(0xFF0D4D4D), fontWeight: FontWeight.w500)),
                      subtitle: meal['familyMember'] != null && meal['familyMember'] != ''
                        ? Text('For: ${meal['familyMember']}', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF0D4D4D)))
                        : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFF0D4D4D)),
                            onPressed: () {/* TODO: Implement edit */},
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() { savedMeals.removeAt(index); });
                              SharedPreferences.getInstance().then((prefs) => prefs.setString('saved_meals', json.encode(savedMeals)));
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (meal['items'] as Map<String, dynamic>).entries.map((entry) {
                          if ((entry.value as List).isEmpty) return SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.key}: ', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Color(0xFF0D4D4D))),
                                Expanded(
                                  child: Text((entry.value as List).join(', '), style: TextStyle(fontFamily: 'Inter', color: Color(0xFF0D4D4D))),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _toggleFoodSelection(String category, String item) {
    setState(() {
      if (selectedItemsByCategory[category]!.contains(item)) {
        selectedItemsByCategory[category]!.remove(item);
      } else {
        selectedItemsByCategory[category]!.add(item);
      }
    });
  }

  int _selectedItemCount() {
    int count = 0;
    for (final set in selectedItemsByCategory.values) {
      count += set.length;
    }
    return count;
  }

  int _selectedCategoryCount() {
    int count = 0;
    for (final set in selectedItemsByCategory.values) {
      if (set.isNotEmpty) count++;
    }
    return count;
  }

  void _initializeTimeline() {
    final today = DateTime.now();
    timelineDates = List.generate(7, (index) => today.add(Duration(days: index)));
  }

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentStreak = prefs.getInt('meal_planning_streak') ?? 0;
      earnedBadges = prefs.getStringList('earned_badges') ?? [];
    });
  }

  void _updateStreak() {
    final today = DateTime.now();
    final lastPlanned = DateTime.parse(savedMeals.last['date']);
    if (today.difference(lastPlanned).inDays == 1) {
      setState(() {
        currentStreak++;
        if (currentStreak >= 7) {
          earnedBadges.add('Healthy Streak');
        }
      });
      _saveUserProgress();
    }
  }

  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meal_planning_streak', currentStreak);
    await prefs.setStringList('earned_badges', earnedBadges);
  }

  Widget _buildTimelineView() {
    return Column(
      children: [
        // Date selector
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: timelineDates.length + 1,
            itemBuilder: (context, index) {
              if (index == timelineDates.length) {
                return _buildAddDateButton();
              }
              final date = timelineDates[index];
              final isSelected = date == selectedTimelineDate;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTimelineDate = date;
                    currentTimelineIndex = index;
                  });
                },
                child: Container(
                  width: 100,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF0D4D4D) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF0D4D4D).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF0D4D4D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF0D4D4D),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Meal timeline
        Expanded(
          child: ListView(
            children: [
              _buildMealTimeSlot('Breakfast', '🥞', 7),
              _buildMealTimeSlot('Lunch', '🍗', 12),
              _buildMealTimeSlot('Dinner', '🍝', 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddDateButton() {
    return Container(
      width: 60,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF0D4D4D).withOpacity(0.2),
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.add, color: Color(0xFF0D4D4D)),
        onPressed: () {
          setState(() {
            timelineDates.add(timelineDates.last.add(Duration(days: 1)));
          });
        },
      ),
    );
  }

  Widget _buildMealTimeSlot(String mealType, String emoji, int hour) {
    final mealsForDate = savedMeals.where((meal) {
      final mealDate = DateTime.parse(meal['date']);
      return mealDate.year == selectedTimelineDate.year &&
          mealDate.month == selectedTimelineDate.month &&
          mealDate.day == selectedTimelineDate.day &&
          meal['mealType'] == mealType;
    }).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '$emoji $mealType',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D4D4D),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${hour}:00',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF0D4D4D).withOpacity(0.7),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Color(0xFF0D4D4D)),
                  onPressed: () {
                    setState(() {
                      selectedMealType = mealType;
                      selectedDate = selectedTimelineDate;
                    });
                    _showMealPlanningDialog();
                  },
                ),
              ],
            ),
          ),
          if (mealsForDate.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: mealsForDate.map((meal) {
                  final items = (meal['items'] as Map<String, dynamic>)
                      .map((key, value) => MapEntry(key, List<String>.from(value)));
                  return _buildSavedMealsList();
                }).toList(),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No meals planned',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionView() {
    return Column(
      children: [
        // Daily nutrition summary
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Nutrition Summary',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D4D4D),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutritionMetric('Calories', '850', 'kcal'),
                  _buildNutritionMetric('Protein', '45', 'g'),
                  _buildNutritionMetric('Carbs', '120', 'g'),
                  _buildNutritionMetric('Fat', '30', 'g'),
                ],
              ),
            ],
          ),
        ),
        // Food items with nutrition info
        Expanded(
          child: ListView.builder(
            itemCount: foodCategories.length,
            itemBuilder: (context, index) {
              final category = foodCategories.keys.elementAt(index);
              return ExpansionTile(
                title: Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF0D4D4D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: foodCategories[category]!.map((item) {
                  final nutrition = nutritionData[item] ?? {
                    'calories': 0,
                    'protein': 0,
                    'carbs': 0,
                    'fat': 0
                  };
                  return ListTile(
                    leading: Text(
                      _getFoodEmoji(item),
                      style: TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      item,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF0D4D4D),
                      ),
                    ),
                    subtitle: Text(
                      '${nutrition['calories']} kcal | P: ${nutrition['protein']}g | C: ${nutrition['carbs']}g | F: ${nutrition['fat']}g',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF0D4D4D).withOpacity(0.7),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionMetric(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D4D4D),
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF0D4D4D).withOpacity(0.7),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF0D4D4D).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyView() {
    return Column(
      children: [
        // Family members overview
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: familyMembers.length,
            itemBuilder: (context, index) {
              final member = familyMembers.keys.elementAt(index);
              return Container(
                width: 80,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF0D4D4D).withOpacity(0.1),
                      child: Text(
                        member[0],
                        style: TextStyle(
                          color: Color(0xFF0D4D4D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      member,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF0D4D4D),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Weekly meal plan per family member
        Expanded(
          child: ListView.builder(
            itemCount: familyMembers.length,
            itemBuilder: (context, index) {
              final member = familyMembers.keys.elementAt(index);
              return _buildFamilyMemberMealPlan(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyMemberMealPlan(String member) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '$member\'s Meals',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D4D4D),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              return _buildFamilyMemberDayPlan(member, date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMemberDayPlan(String member, DateTime date) {
    final mealsForDate = savedMeals.where((meal) {
      final mealDate = DateTime.parse(meal['date']);
      return mealDate.year == date.year &&
          mealDate.month == date.month &&
          mealDate.day == date.day &&
          meal['familyMember'] == member;
    }).toList();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF0D4D4D).withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(date),
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF0D4D4D),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          if (mealsForDate.isEmpty)
            Text(
              'No meals planned',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey,
              ),
            )
          else
            Column(
              children: mealsForDate.map((meal) {
                return ListTile(
                  leading: Text(_getMealEmoji(meal['mealType'])),
                  title: Text(
                    meal['mealType'],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF0D4D4D),
                    ),
                  ),
                  subtitle: Text(
                    (meal['items'] as Map<String, dynamic>)
                        .values
                        .expand((x) => x as List)
                        .join(', '),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF0D4D4D).withOpacity(0.7),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _getFoodEmoji(String food) {
    final emojiMap = {
      'Chicken': '🍗',
      'Salmon': '🐟',
      'Eggs': '🥚',
      'Bread': '🍞',
      'Rice': '🍚',
      'Pasta': '🍝',
      'Salad': '🥗',
      'Fruit': '🍎',
      'Vegetables': '🥬',
      'Water': '💧',
      'Coffee': '☕',
      'Tea': '🫖',
      // Add more mappings...
    };
    return emojiMap[food] ?? '🍽️';
  }

  String _getMealEmoji(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return '🥞';
      case 'Lunch':
        return '🍗';
      case 'Dinner':
        return '🍝';
      default:
        return '🍽️';
    }
  }

  void _showMealPlanningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Plan ${selectedMealType} for ${DateFormat('MMM d').format(selectedDate)}',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF0D4D4D),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Family member selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'For Family Member',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: familyMembers.keys.map((member) {
                  return DropdownMenuItem(
                    value: member,
                    child: Text(member),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFamilyMember = value;
                  });
                },
              ),
              SizedBox(height: 16),
              // Food selection
              ...foodCategories.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.key,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF0D4D4D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: category.value.map((item) {
                        final isSelected = selectedItemsByCategory[category.key]!.contains(item);
                        final nutrition = nutritionData[item];
                        return FilterChip(
                          label: Text(
                            nutrition != null
                                ? '$item (${nutrition['calories']} kcal)'
                                : item,
                          ),
                          selected: isSelected,
                          onSelected: (selected) => _toggleFoodSelection(category.key, item),
                          backgroundColor: Colors.white,
                          selectedColor: Color(0xFF0D4D4D).withOpacity(0.2),
                          checkmarkColor: Color(0xFF0D4D4D),
                          labelStyle: TextStyle(
                            color: isSelected ? Color(0xFF0D4D4D) : Colors.black87,
                            fontFamily: 'Inter',
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }).toList(),
              // Nutrition summary
              _buildNutritionSummary(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF0D4D4D),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveMeal();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D4D4D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateNutritionTotals() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;

    selectedItemsByCategory.forEach((category, items) {
      items.forEach((item) {
        final nutrition = nutritionData[item];
        if (nutrition != null) {
          totalCalories += nutrition['calories'] as double;
          totalProtein += nutrition['protein'] as double;
          totalCarbs += nutrition['carbs'] as double;
        }
      });
    });

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
    };
  }

  Widget _buildNutritionSummary() {
    final totals = _calculateNutritionTotals();
    final selectedCount = _selectedItemCount();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0D4D4D).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF0D4D4D).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D4D4D),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Selected $selectedCount items',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF0D4D4D).withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionMetric('🔥 Calories', '${totals['calories']!.round()}', 'kcal'),
              _buildNutritionMetric('🍗 Protein', '${totals['protein']!.round()}', 'g'),
              _buildNutritionMetric('🍞 Carbs', '${totals['carbs']!.round()}', 'g'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF0D4D4D),
        title: Text(
          '🍽️ Meal Planner',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 22.0,
                letterSpacing: 0.0,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: () {
              setState(() {
                currentLanguage = currentLanguage == 'en' ? 'ar' : 'en';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () {
              // TODO: Implement print functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Streak and badges
          if (currentStreak > 0 || earnedBadges.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF0D4D4D).withOpacity(0.1),
              child: Row(
                children: [
                  if (currentStreak > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF0D4D4D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '$currentStreak Day Streak',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(width: 8),
                  if (earnedBadges.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: earnedBadges.map((badge) {
                            return Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF0D4D4D),
                                ),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  color: Color(0xFF0D4D4D),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineView(),
                _buildNutritionView(),
                _buildFamilyView(),
                _buildHistoryView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        labelColor: Color(0xFF0D4D4D),
        unselectedLabelColor: Color(0xFF0D4D4D).withOpacity(0.5),
        indicatorColor: Color(0xFF0D4D4D),
        tabs: [
          Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
          Tab(icon: Icon(Icons.monitor_heart), text: 'Nutrition'),
          Tab(icon: Icon(Icons.family_restroom), text: 'Family'),
          Tab(icon: Icon(Icons.history), text: 'History'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMealPlanningDialog,
        backgroundColor: Color(0xFF0D4D4D),
        icon: Icon(Icons.add),
        label: Text(
          'Add Meal',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView() {
    return Column(
      children: [
        // Favorites section
        Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Favorite Meals',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D4D4D),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: savedMeals.where((meal) => meal['isFavorite'] == true).length,
                itemBuilder: (context, index) {
                  final favoriteMeals = savedMeals.where((meal) => meal['isFavorite'] == true).toList();
                  return _buildSavedMealsList();
                },
              ),
            ],
          ),
        ),
        // Past meals section
        Expanded(
          child: ListView.builder(
            itemCount: savedMeals.length,
            itemBuilder: (context, index) {
              final meal = savedMeals[index];
              return _buildSavedMealsList();
            },
          ),
        ),
      ],
    );
  }
} 