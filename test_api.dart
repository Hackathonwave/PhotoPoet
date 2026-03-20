import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String _baseUrl = 'https://corsproxy.io/?https://api.football-data.org/v4/competitions/PL/standings';
  const String _apiToken = '95bb9ee0b58945d891a1cecaf9dcf4ea';

  try {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'X-Auth-Token': _apiToken},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body.length} bytes');
  } catch (e) {
    print('Exception: $e');
  }
}
