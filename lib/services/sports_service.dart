import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TeamStanding {
  final int rank;
  final String teamName;
  final int played;
  final int win;
  final int draw;
  final int loss;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;
  final String badgeUrl;
  final String form;

  TeamStanding({
    required this.rank,
    required this.teamName,
    required this.played,
    required this.win,
    required this.draw,
    required this.loss,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
    required this.badgeUrl,
    required this.form,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? {};
    return TeamStanding(
      rank: json['position'] as int? ?? 0,
      teamName: team['name'] as String? ?? 'Unknown',
      played: json['playedGames'] as int? ?? 0,
      win: json['won'] as int? ?? 0,
      draw: json['draw'] as int? ?? 0,
      loss: json['lost'] as int? ?? 0,
      goalsFor: json['goalsFor'] as int? ?? 0,
      goalsAgainst: json['goalsAgainst'] as int? ?? 0,
      goalDifference: json['goalDifference'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      badgeUrl: (team['crest'] as String? ?? '').replaceAll('.svg', '.png'),
      form: json['form'] as String? ?? '',
    );
  }
}

class SportsService {
  static const String _baseUrl = 'https://api.football-data.org/v4/competitions/PL/standings';
  static const String _apiToken = '95bb9ee0b58945d891a1cecaf9dcf4ea';

  Future<List<TeamStanding>> getPremierLeagueStandings() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'X-Auth-Token': _apiToken},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['standings'] != null && (data['standings'] as List).isNotEmpty) {
          final List<dynamic> tableData = data['standings'][0]['table'];
          return tableData.map((json) => TeamStanding.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        debugPrint('Failed to load standings: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load standings');
      }
    } catch (e) {
      debugPrint('Error fetching Premier League standings: $e');
      throw Exception('Network error or API changes: $e');
    }
  }
}
