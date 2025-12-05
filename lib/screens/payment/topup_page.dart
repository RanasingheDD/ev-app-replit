import 'package:evhub_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopupScreen extends StatefulWidget {
  final String name;
  final String id;

  const TopupScreen({super.key,
  required this.name,
  required this.id,
  });

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  int? selectedPoints;

  final List<int> pointOptions = [500, 1000, 1500, 2000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Up Points"),
        leading: IconButton(onPressed: context.pop,
        icon: Icon(Icons.arrow_back, color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ⭐ User Account Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Account ID: ${widget.id}",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ Points Selection
            const Text(
              "Select Points",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 12,
              children: pointOptions.map((points) {
                final isSelected = selectedPoints == points;
                return ChoiceChip(
                  backgroundColor: AppTheme.surfaceColor,
                  label: Text("$points Points"),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedPoints = points;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // ⭐ Declaration
            const Text(
              "By tapping 'Add Points', you agree to our terms and "
              "confirm that this top-up is non-refundable.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // ⭐ Add Points Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedPoints == null
                    ? null
                    : () {
                        // handle top-up
                        print("Adding $selectedPoints points");
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Add Points",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
