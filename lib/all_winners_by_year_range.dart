import 'package:flutter/material.dart';
import 'package:nobel_v1/api_service.dart'; // Import your ApiService

class AllWinnersByYearRangeScreen extends StatefulWidget {
  final int startYear;
  final int endYear;

  AllWinnersByYearRangeScreen({
    required this.startYear,
    required this.endYear,
  });

  @override
  _AllWinnersByYearRangeScreenState createState() =>
      _AllWinnersByYearRangeScreenState();
}

class _AllWinnersByYearRangeScreenState
    extends State<AllWinnersByYearRangeScreen> {
  final ApiService apiService = ApiService(); // Create an instance of ApiService

  List<Map<String, String>> winnersData = []; // Store the fetched data here

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final data = await apiService.fetchWinnersByYearRange(
        widget.startYear,
        widget.endYear,
      );
      setState(() {
        winnersData = data;
      });
    } catch (e) {
      // Handle errors
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Winners from ${widget.startYear} to ${widget.endYear}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
          child: ListView.builder(
            itemCount: winnersData.length,
            itemBuilder: (context, index) {
              final winner = winnersData[index];
              final currentYear = winner['year'] ?? '';

              // Check if the year is different from the previous item
              final isYearChange = index == 0 || currentYear != (winnersData[index - 1]['year'] ?? '');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isYearChange)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        currentYear,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ListTile(
                    title: Text(winner['surname'] ?? ''),
                    subtitle: Text(winner['firstname'] ?? ''),
                    trailing: Text(winner['category'] ?? ''),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
