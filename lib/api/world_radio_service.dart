import 'dart:convert';

import 'package:grradio/Env.dart';
import 'package:grradio/radio/radiostation.dart';
import 'package:http/http.dart' as http;

class WorldRadioService {
  RadioStation _mapToStation(Map<String, dynamic> map) {
    return RadioStation(
      id: map['stationuuid']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Station',
      streamUrl: map['url_resolved']?.toString(),
      logoUrl: map['favicon']?.toString(),
      language: map['language']?.toString(),
      genre: map['tags']?.toString(),
      state: map['country']?.toString(),
    );
  }

  Future<List<RadioStation>> fetchTopVoted({int limit = 20}) async {
    final uri = Uri.parse(
      '${Env.apiBaseUrl}/radio-browser/stations/top/voted?limit=$limit',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((e) => _mapToStation(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<RadioStation>> searchStations(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(
      '${Env.apiBaseUrl}/radio-browser/stations/search?name=$query&limit=$limit',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> results = data['results'] ?? [];
      return results
          .map((e) => _mapToStation(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<CountryCount>> fetchCountries() async {
    final uri = Uri.parse('${Env.apiBaseUrl}/radio-browser/meta/countries');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => CountryCount.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<RadioStation>> fetchStationsByCountry(
    String countrycode, {
    int page = 1,
    int limit = 30,
  }) async {
    final uri = Uri.parse(
      '${Env.apiBaseUrl}/radio-browser/stations/by-country/$countrycode?page=$page&limit=$limit',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> results = data['results'] ?? [];
      return results
          .map((e) => _mapToStation(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class CountryCount {
  final String country;
  final String? countrycode;
  final int stationCount;

  CountryCount({
    required this.country,
    this.countrycode,
    required this.stationCount,
  });

  factory CountryCount.fromJson(Map<String, dynamic> json) {
    return CountryCount(
      country: json['country'] as String,
      countrycode: json['countrycode'] as String?,
      stationCount: json['station_count'] as int,
    );
  }
}
