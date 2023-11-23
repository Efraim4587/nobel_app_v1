import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nobel_v1/winners_by_country.dart';

import 'all_winners_by_year_range.dart';
import 'all_winning_countries.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nobel App',
      theme: ThemeData(
        primaryColor: const Color(0xFF3366FF),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        typography: Typography.material2018(),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFCCCCCC),
        ).copyWith(
          background: const Color(0xFFF5F5F5),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showCountrySelection = false;
  bool showYearSelection = false;
  String selectedCountry = 'Select a country';
  String? selectedStartYear;
  String selectedEndYear = 'Select an end year';

  final ApiService apiService = ApiService();

  void toggleCountrySelection() {
    setState(() {
      if (showCountrySelection) {
        // Hide the selection list if it's already shown
        showCountrySelection = false;
      } else {
        showCountrySelection = true;
        showYearSelection = false;
        selectedStartYear = null;
        selectedEndYear = 'Select an end year';
      }
    });
  }

  void toggleYearSelection() {
    setState(() {
      if (showYearSelection) {
        // Hide the selection list if it's already shown
        showYearSelection = false;
      } else {
        showYearSelection = true;
        showCountrySelection = false;
        selectedCountry = 'Select a country';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.7;
    double buttonHeight = 45.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nobel App'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50), // Added space
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                child: ClipRRect( // Added a ClipRRect for image border radius
                  borderRadius: BorderRadius.circular(18.0),
                  child: Image.asset(
                    'assets/nobel_prize_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to Nobel App!',
                style: TextStyle(fontSize: 22, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              Container(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    hideAllSelection();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AllWinningCountriesScreen(),
                      ),
                    );
                  },
                  child: const Text('Winning Countries', style: TextStyle(fontSize: 18),),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: buttonWidth,
                height: buttonHeight,
                child:ElevatedButton(
                  onPressed: () {
                    toggleCountrySelection(); // Toggle country selection
                  },
                  child: const Text('Winners by Country', style: TextStyle(fontSize: 18),),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: showCountrySelection ? null : 0,
                child: showCountrySelection
                    ? Column(
                  children: [
                    const SizedBox(height: 20),
                    FutureBuilder<List<Map<String, String?>>>(
                      future: apiService.fetchCountryCodes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No countries available.');
                        } else {
                          return DropdownButton<String>(
                            hint: const Text('Select a country', style: TextStyle(color: Colors.grey)), // Greyed out default text
                            value: selectedCountry,
                            onChanged: (newValue) {
                              if (newValue != null &&
                                  newValue != 'Select a country') {
                                setState(() {
                                  selectedCountry = newValue;
                                });
                                String country = selectedCountry;
                                // Navigate to Winners by Country screen with the selected country
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WinnersByCountryScreen(
                                          selectedCountry: country,
                                        ),
                                  ),
                                );
                                setState(() {
                                  selectedCountry = 'Select a country';
                                  showCountrySelection = false;
                                });
                              }
                            },
                            items: [
                              const DropdownMenuItem<String>(
                                value: 'Select a country', // Default text
                                child: Text('Select a country'),
                              ),
                              ...snapshot.data!.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country.values.first,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset('assets/flags/${country.values.last?.toLowerCase()}.svg', width: 24, height: 24),
                                      SizedBox(width: 8), // Add spacing between flag and text
                                      Text(country.values.first!),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                )
                    : null,
              ),
              const SizedBox(height: 15),
              Container(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    toggleYearSelection();
                  },
                  child: const Text('Winners by Year Range', style: TextStyle(fontSize: 18),),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: showYearSelection ? null : 0,
                child: showYearSelection
                    ? Column(
                  children: [
                    const SizedBox(height: 20),
                    // Dropdown for selecting commencement year
                    if (!showCountrySelection)
                      DropdownButton<String>(
                        hint: const Text('Select a start year', style: TextStyle(color: Colors.grey)), // Greyed out default text
                        value: selectedStartYear,
                        onChanged: (newValue) {
                          if (newValue != null &&
                              newValue != 'Select a start year') {
                            setState(() {
                              selectedStartYear = newValue;
                              selectedEndYear = 'Select an end year';
                            });
                          }
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'Select a start year', // Unique value
                            child: Text('Select a start year'),
                          ),
                          ...List.generate(
                            DateTime.now().year - 1900,
                                (index) =>
                                (DateTime.now().year - index).toString(),
                          ).map((year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (selectedStartYear != null)
                      Column(
                        children: [
                          DropdownButton<String>(
                            hint: const Text('Select an end year', style: TextStyle(color: Colors.grey)), // Greyed out default text
                            value: selectedEndYear,
                            onChanged: (newValue) {
                              if (newValue != null &&
                                  newValue != 'Select an end year') {
                                setState(() {
                                  selectedEndYear = newValue;
                                });
                                // Navigate to AllWinnersByYearRangeScreen
                                if (selectedStartYear != null &&
                                    selectedEndYear != 'Select an end year') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AllWinnersByYearRangeScreen(
                                            startYear: int.parse(selectedStartYear!),
                                            endYear: int.parse(selectedEndYear),
                                          ),
                                    ),
                                  );
                                }
                              }
                            },
                            items: [
                              const DropdownMenuItem<String>(
                                value: 'Select an end year',
                                child: Text('Select an end year'),
                              ),
                              ...List.generate(
                                DateTime.now().year -
                                    int.parse(selectedStartYear!) +
                                    1,
                                    (index) =>
                                    (int.parse(selectedStartYear!) +
                                        index)
                                        .toString(),
                              ).map((year) {
                                return DropdownMenuItem<String>(
                                  value: year.toString(),
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                            ],
                          ),
                          // Remove the separate button
                        ],
                      ),
                  ],
                )
                    : null,
              ),
            ],
          ),
        ),

      ),
    );
  }

  void hideAllSelection() {
    setState(() {
      showCountrySelection = false;
      showYearSelection = false;
    });
  }
}



