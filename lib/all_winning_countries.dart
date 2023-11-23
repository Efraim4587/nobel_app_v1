import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nobel_v1/api_service.dart';

class AllWinningCountriesScreen extends StatelessWidget {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> winningCountriesFuture;
  late Map<String, String> countryCodes;

  AllWinningCountriesScreen({Key? key}) {
    winningCountriesFuture = loadWinningCountries();
  }

  Future<List<Map<String, dynamic>>> loadWinningCountries() async {
    final List<Map<String, String?>> laureateData = await apiService.fetchWinningCountries();

    List<Map<String, dynamic>> winningCountries = [];

    for (final laureate in laureateData) {
      final String countryName = laureate['countryName'] ?? '';
      final String category = laureate['category'] ?? '';
      final String year = laureate['year'] ?? '';
      final String countryCode = laureate['countryCode'] ?? '';

      if (countryName.isNotEmpty && category.isNotEmpty && year.isNotEmpty) {
        winningCountries.add({
          'countryName': countryName,
          'category': category,
          'year': year,
          'countryCode': countryCode,
        });
      }
    }

    return winningCountries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Winning Countries'),
      ),
      body: FutureBuilder(
        future: winningCountriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<Map<String, dynamic>> winningCountries =
            snapshot.data as List<Map<String, dynamic>>;

            return ListView.builder(
              itemCount: winningCountries.length,
              itemBuilder: (context, index) {
                if (index >= winningCountries.length) {
                  return const SizedBox();
                }
                final countryData = winningCountries[index];
                final String countryName = countryData['countryName'];
                final String category = countryData['category'];
                final String year = countryData['year'];
                final String countryCode = countryData['countryCode'];

                final flagImagePath = countryCode.isNotEmpty
                    ? 'assets/flags/${countryCode.toLowerCase()}.svg'
                    : 'assets/flags/il.svg';

                return ListTile(
                  leading: SvgPicture.asset(
                    flagImagePath,
                    width: 50,
                    height: 30,
                  ),
                  title: Text('$countryName - $year'),
                  subtitle: Text(category),
                );
              },
            );
          }
        },
      ),
    );
  }
}

