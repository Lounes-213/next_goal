import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../../domain/entities/stream_link.dart';

class HighlightsScraperService {
  final Dio dio;

  HighlightsScraperService({required this.dio});

  Options _opts() {
    return Options(
      responseType: ResponseType.plain,
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ar,en;q=0.9',
      },
    );
  }

  /// Search YouTube for Arabic beIN Sports match highlights
  Future<List<MatchHighlight>> getHighlightsForMatch({
    required String homeTeam,
    required String awayTeam,
    String? competitionName,
  }) async {
    final highlights = <MatchHighlight>[];

    // Arabic search queries for beIN Sports highlights
    final queries = [
      'ملخصات بي ان سبورت $homeTeam $awayTeam',
      'ملخص مباراة $homeTeam و $awayTeam bein sport',
      'اهداف مباراة $homeTeam $awayTeam بي ان',
      'ملخصات bein sport $homeTeam vs $awayTeam',
      'ملخص $homeTeam $awayTeam 2024',
    ];

    for (final query in queries) {
      if (highlights.length >= 5) break;
      try {
        final results = await _searchYouTube(query);
        for (final result in results) {
          if (highlights.length >= 5) break;
          if (!_containsTeamNames(result.title, homeTeam, awayTeam)) continue;
          if (highlights.any((h) => h.youtubeId == result.youtubeId)) continue;
          highlights.add(result);
        }
      } catch (e) {
        developer.log('YouTube search failed for "$query": $e');
      }
    }

    return highlights;
  }

  /// Search YouTube for recent Arabic highlights
  Future<List<MatchHighlight>> getRecentHighlights({int limit = 20}) async {
    final highlights = <MatchHighlight>[];
    final queries = [
      'ملخصات مباريات اليوم بي ان سبورت',
      'اهداف مباريات اليوم bein sport',
      'ملخصات دوري ابطال اوروبا',
      'ملخصات الدوري الانجليزي',
    ];

    for (final query in queries) {
      if (highlights.length >= limit) break;
      try {
        final results = await _searchYouTube(query);
        for (final result in results) {
          if (highlights.length >= limit) break;
          if (highlights.any((h) => h.youtubeId == result.youtubeId)) continue;
          highlights.add(result);
        }
      } catch (e) {
        developer.log('YouTube search failed: $e');
      }
    }
    return highlights;
  }

  /// Search YouTube and parse results
  Future<List<MatchHighlight>> _searchYouTube(String query) async {
    final highlights = <MatchHighlight>[];
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.youtube.com/results?search_query=$encodedQuery&sp=EgIQAQ%3D%3D';

    try {
      final response = await dio.get(url, options: _opts());
      if (response.statusCode != 200 || response.data is! String) {
        return [];
      }

      final html = response.data as String;

      // Extract video data from YouTube's initial data JSON
      final initialDataMatch = RegExp(
        r'var ytInitialData = ({.*?});</script>',
      ).firstMatch(html);

      if (initialDataMatch != null) {
        try {
          final jsonData = jsonDecode(initialDataMatch.group(1)!) as Map<String, dynamic>;
          final contents = _extractFromInitialData(jsonData);
          highlights.addAll(contents);
        } catch (e) {
          developer.log('Failed to parse YouTube JSON: $e');
        }
      }

      // Fallback: parse HTML directly
      if (highlights.isEmpty) {
        highlights.addAll(_parseYouTubeHtml(html));
      }
    } catch (e) {
      developer.log('YouTube search error: $e');
    }

    return highlights;
  }

  /// Extract videos from YouTube initial data JSON
  List<MatchHighlight> _extractFromInitialData(Map<String, dynamic> data) {
    final highlights = <MatchHighlight>[];
    try {
      final contents = data['contents']?['twoColumnSearchResultsRenderer']
          ?['primaryContents']?['sectionListRenderer']?['contents'];
      if (contents == null || contents is! List) return [];

      for (final section in contents) {
        final items = section['itemSectionRenderer']?['contents'];
        if (items == null || items is! List) continue;

        for (final item in items) {
          final videoRenderer = item['videoRenderer'];
          if (videoRenderer == null) continue;

          final videoId = videoRenderer['videoId'] as String?;
          if (videoId == null || videoId.isEmpty) continue;

          final titleRuns = videoRenderer['title']?['runs'];
          if (titleRuns == null || titleRuns is! List || titleRuns.isEmpty) continue;
          final title = titleRuns.map((r) => r['text'] as String? ?? '').join('');

          final thumbnails = videoRenderer['thumbnail']?['thumbnails'];
          String thumbnailUrl = '';
          if (thumbnails is List && thumbnails.isNotEmpty) {
            thumbnailUrl = thumbnails.last['url'] as String? ?? '';
            if (thumbnailUrl.startsWith('//')) {
              thumbnailUrl = 'https:$thumbnailUrl';
            }
          }

          highlights.add(MatchHighlight(
            id: 'yt_$videoId',
            title: title,
            thumbnailUrl: thumbnailUrl.isNotEmpty
                ? thumbnailUrl
                : 'https://i3.ytimg.com/vi/$videoId/hqdefault.jpg',
            videoUrl: 'https://www.youtube.com/watch?v=$videoId',
            source: _detectSourceFromTitle(title),
            matchTitle: title,
            leagueName: _extractLeagueFromTitle(title),
          ));
        }
      }
    } catch (e) {
      developer.log('Extract from initial data error: $e');
    }
    return highlights;
  }

  /// Fallback: parse YouTube HTML for video info
  List<MatchHighlight> _parseYouTubeHtml(String html) {
    final highlights = <MatchHighlight>[];
    try {
      final doc = html_parser.parse(html);
      final videoElements = doc.querySelectorAll('ytd-video-renderer');

      for (final element in videoElements) {
        final videoIdAttr = element.attributes['data-video-id'];
        if (videoIdAttr == null || videoIdAttr.isEmpty) continue;

        final titleElement = element.querySelector('#video-title');
        final title = titleElement?.text.trim() ?? '';
        if (title.isEmpty) continue;

        final thumbnailElement = element.querySelector('img');
        var thumbnail = thumbnailElement?.attributes['src'] ?? '';
        if (thumbnail.isEmpty) {
          thumbnail = 'https://i3.ytimg.com/vi/$videoIdAttr/hqdefault.jpg';
        }
        if (thumbnail.startsWith('//')) {
          thumbnail = 'https:$thumbnail';
        }

        highlights.add(MatchHighlight(
          id: 'yt_$videoIdAttr',
          title: title,
          thumbnailUrl: thumbnail,
          videoUrl: 'https://www.youtube.com/watch?v=$videoIdAttr',
          source: _detectSourceFromTitle(title),
          matchTitle: title,
          leagueName: _extractLeagueFromTitle(title),
        ));
      }
    } catch (e) {
      developer.log('YouTube HTML parse error: $e');
    }
    return highlights;
  }

  bool _containsTeamNames(String text, String home, String away) {
    final t = text.toLowerCase();
    final hWords = home.toLowerCase().split(' ').where((w) => w.length > 2).toList();
    final aWords = away.toLowerCase().split(' ').where((w) => w.length > 2).toList();
    if (hWords.isEmpty || aWords.isEmpty) return false;
    return hWords.any((w) => t.contains(w)) && aWords.any((w) => t.contains(w));
  }

  String _detectSourceFromTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('bein') || lower.contains('بي ان')) {
      return 'beIN SPORTS';
    }
    if (lower.contains('دوري ابطال')) {
      return 'beIN SPORTS';
    }
    if (lower.contains('الدوري')) {
      return 'beIN SPORTS';
    }
    return 'YouTube';
  }

  String? _extractLeagueFromTitle(String title) {
    final leagues = {
      'premier league': 'الدوري الإنجليزي',
      'الدوري الإنجليزي': 'الدوري الإنجليزي',
      'la liga': 'الدوري الإسباني',
      'الدوري الإسباني': 'الدوري الإسباني',
      'bundesliga': 'الدوري الألماني',
      'الدوري الألماني': 'الدوري الألماني',
      'serie a': 'الدوري الإيطالي',
      'الدوري الإيطالي': 'الدوري الإيطالي',
      'ligue 1': 'الدوري الفرنسي',
      'الدوري الفرنسي': 'الدوري الفرنسي',
      'champions league': 'دوري أبطال أوروبا',
      'دوري أبطال أوروبا': 'دوري أبطال أوروبا',
      'europa league': 'الدوري الأوروبي',
      'الدوري الأوروبي': 'الدوري الأوروبي',
      'world cup': 'كأس العالم',
      'كأس العالم': 'كأس العالم',
      'دوري أبطال آسيا': 'دوري أبطال آسيا',
      'الدوري السعودي': 'الدوري السعودي',
      'روشن برو': 'الدوري السعودي',
    };
    final lower = title.toLowerCase();
    for (final entry in leagues.entries) {
      if (lower.contains(entry.key.toLowerCase())) return entry.value;
    }
    return null;
  }
}
