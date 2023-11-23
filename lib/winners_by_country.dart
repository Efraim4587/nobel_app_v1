import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nobel_v1/api_service.dart';

class WinnersByCountryScreen extends StatelessWidget {
  String countryCode = '';
  final String selectedCountry;
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> winnersByCountryFuture;
  late Map<String, String> countryCodes;

  WinnersByCountryScreen({Key? key, required this.selectedCountry}) : super(key: key){
    winnersByCountryFuture = loadWinnersByCountry(this.selectedCountry);
  }

  Future<List<Map<String, dynamic>>> loadWinnersByCountry(String selectedCountry) async {
    final List<Map<String, String?>> laureateData = await apiService.fetchWinningCountries();

    List<Map<String, dynamic>> winningCountries = [];
    for (final laureate in laureateData) {
      if (laureate['countryName'] == selectedCountry) {
        countryCode = laureate['countryCode'] ?? '';
        final String firstname = laureate['firstname']?.replaceAll("\"", "") ?? '';
        final String surname = laureate['surname']?.replaceAll("\"", "") ?? '';
        final String year = laureate['year']?.replaceAll("\"", "") ?? '';
        final String born = laureate['born']?.replaceAll("\"", "") ?? '';
        final String died = laureate['died']?.replaceAll("\"", "") ?? '';
        final String category = laureate['category']?.replaceAll("\"", "") ?? '';
        final String motivation = laureate['motivation']?.replaceAll("\"", "") ?? '';

        winningCountries.add({
          'countryCode': countryCode,
          'firstname': firstname,
          'surname': surname,
          'year': year,
          'born': born,
          'died': died,
          'category': category,
          'motivation': motivation,
        });
      }
    }
    return winningCountries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Winners By ${selectedCountry}'),
      ),
      body: FutureBuilder(
        future: winnersByCountryFuture,
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    'assets/flags/${countryCode.toLowerCase()}.svg',
                    width: 100,
                    height: 60,
                  ),
                ),
                Expanded(
                  child: winningCountries.isEmpty
                      ? Center(
                    child: Text(
                      'No winners found in ${selectedCountry}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                      : ListView.builder(
                    itemCount: winningCountries.length,
                    itemBuilder: (context, index) {
                      if (index >= winningCountries.length) {
                        return const SizedBox();
                      }
                      final countryData = winningCountries[index];
                      final String firstname = countryData['firstname'];
                      final String surname = countryData['surname'];
                      final String year = countryData['year'];
                      final String born = countryData['born'];
                      final String died = countryData['died'];
                      final String category = countryData['category'];
                      final String motivation = countryData['motivation'];

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Colors.lightBlue,
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$firstname $surname',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style, // Default text style
                                  children: <TextSpan>[
                                    TextSpan(text: 'Year: ', style: TextStyle(fontWeight: FontWeight.bold)), // Bold part
                                    TextSpan(text: '$year'), // Regular part, replace '$year' with your year variable
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style, // Default text style
                                  children: <TextSpan>[
                                    TextSpan(text: 'Born: ', style: TextStyle(fontWeight: FontWeight.bold)), // Bold part
                                    TextSpan(text: '$born'), // Regular part, replace '$year' with your year variable
                                  ],
                                ),
                              ),
                              if (died != '0000-00-00') SizedBox(height: 5),
                              if (died != '0000-00-00')
                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style, // Default text style
                                    children: <TextSpan>[
                                      TextSpan(text: 'Died: ', style: TextStyle(fontWeight: FontWeight.bold)), // Bold part
                                      TextSpan(text: '$died'), // Regular part, replace '$year' with your year variable
                                    ],
                                  ),
                                ),
                              SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style, // Default text style
                                  children: <TextSpan>[
                                    TextSpan(text: 'Category: ', style: TextStyle(fontWeight: FontWeight.bold)), // Bold part
                                    TextSpan(text: '$category'), // Regular part, replace '$year' with your year variable
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style, // Default text style
                                  children: <TextSpan>[
                                    TextSpan(text: 'Motivation: ', style: TextStyle(fontWeight: FontWeight.bold)), // Bold part
                                    TextSpan(text: '$motivation', style: TextStyle(fontStyle: FontStyle.italic)), // Regular part, replace '$year' with your year variable
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
