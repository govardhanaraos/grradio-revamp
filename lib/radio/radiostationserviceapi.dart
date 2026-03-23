// radio_station_service.dart
import 'dart:convert';

import 'package:grradio/Env.dart';
import 'package:http/http.dart' as http; // Use the http package

import 'radiostation.dart';

// IMPORTANT: Use your deployed Render URL here.
String _baseUrl = Env.apiBaseUrl;
const String _apiEndpoint = '/stations';

class RadioStationServiceAPI {
  // 💡 MODIFIED: Accept only 'page' and 'limit' to support sequential fetching
  Future<List<RadioStation>> fetchRadioStations({
    int page = 1,
    int limit = 50, // Use a reasonable default limit per page
    String? language,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (language != null && language.isNotEmpty && language != 'All') {
      // Assuming your backend API supports filtering by language name
      queryParams['language'] = language;
    }

    // Construct the URI with query parameters for pagination
    final uri = Uri.parse('$_baseUrl$_apiEndpoint').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    print('Fetching stations from: $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Decode the JSON list received from FastAPI
        final List<dynamic> jsonList = json.decode(response.body);
        print('Loaded Stations page $page: ${jsonList.length} items');
        // Convert the list of JSON Maps to a List of RadioStation objects
        List<RadioStation> stations = jsonList
            .map((map) => RadioStation.fromMap(map as Map<String, dynamic>))
            .toList();

        // Persistence is handled in main.dart (cachedStations) so we never
        // write only page 1 into the wrong box or wipe the full offline cache mid-sync.

        return stations;
      } else {
        // Handle server-side errors (e.g., 404, 500)
        print('Server returned status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      // Handle network errors (e.g., no internet connection)
      print('Network error fetching radio stations: $e');
      return [];
    }
  }

  // The close method is no longer needed since we are not maintaining a DB connection.
  void close() {
    // No action needed for HTTP client
  }
}
