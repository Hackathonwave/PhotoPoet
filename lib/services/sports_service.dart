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
    return TeamStanding(
      rank: int.tryParse(json['intRank']?.toString() ?? '0') ?? 0,
      teamName: json['strTeam'] ?? 'Unknown',
      played: int.tryParse(json['intPlayed']?.toString() ?? '0') ?? 0,
      win: int.tryParse(json['intWin']?.toString() ?? '0') ?? 0,
      draw: int.tryParse(json['intDraw']?.toString() ?? '0') ?? 0,
      loss: int.tryParse(json['intLoss']?.toString() ?? '0') ?? 0,
      goalsFor: int.tryParse(json['intGoalsFor']?.toString() ?? '0') ?? 0,
      goalsAgainst: int.tryParse(json['intGoalsAgainst']?.toString() ?? '0') ?? 0,
      goalDifference: int.tryParse(json['intGoalDifference']?.toString() ?? '0') ?? 0,
      points: int.tryParse(json['intPoints']?.toString() ?? '0') ?? 0,
      badgeUrl: json['strBadge'] ?? '',
      form: json['strForm'] ?? '',
    );
  }
}

class SportsService {
  // Using TheSportsDB free tier for English Premier League (League ID: 4328)
  // Note: We use the 2023-2024 season for guaranteed data availability in the free tier
  static const String _baseUrl = 'https://www.thesportsdb.com/api/v1/json/3/lookuptable.php?l=4328&s=2023-2024';

  Future<List<TeamStanding>> getPremierLeagueStandings() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['table'] != null) {
          final List<dynamic> tableData = data['table'];
          return tableData.map((json) => TeamStanding.fromJson(json)).toList();
        } else {
          return []; // Return empty if there's no table data
        }
      } else {
        debugPrint('Failed to load standings: ${response.statusCode}');
        throw Exception('Failed to load standings');
      }
    } catch (e) {
      debugPrint('Error fetching Premier League standings: $e');
      throw Exception('Network error or API changes: $e');
    }
  }
}
