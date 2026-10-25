import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../../domain/entities/stream_link.dart';

class StreamScraperService {
  final Dio dio;

  StreamScraperService({required this.dio});

  Options _opts({Map<String, dynamic>? extraHeaders}) {
    return Options(
      responseType: ResponseType.plain,
      sendTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ar,en;q=0.5',
        if (extraHeaders != null) ...extraHeaders,
      },
    );
  }

  Future<List<StreamSource>> getStreamsForMatch({
    required String homeTeam,
    required String awayTeam,
    int? matchId,
  }) async {
    final sources = <StreamSource>[];
    final results = await Future.wait([
      _scrapeYallaSport(homeTeam, awayTeam),
      _scrapeYallaGool(homeTeam, awayTeam),
      _scrapeIPTV(homeTeam, awayTeam),
    ]);
    for (final result in results) {
      if (result != null) sources.add(result);
    }
    return sources;
  }

  Future<StreamSource?> _scrapeYallaSport(String home, String away) async {
    try {
      final response = await dio.get(
        'https://www.yalla-sport.org/matches-today/',
        options: _opts(),
      );
      if (response.statusCode != 200 || response.data is! String) return null;
      final doc = html_parser.parse(response.data as String);
      final matchLinks = <String>[];
      for (final a in doc.querySelectorAll('a[href]')) {
        final href = a.attributes['href'] ?? '';
        if (href.contains('m.v-sami.online') ||
            href.contains('shoshohd') ||
            href.contains('koralive') ||
            href.contains('yalla-live') ||
            href.contains('bmax') ||
            href.contains('watch')) {
          matchLinks.add(href);
        }
      }
      final iframes = <String>[];
      for (final iframe in doc.querySelectorAll('iframe[src]')) {
        final src = iframe.attributes['src'] ?? '';
        if (src.isNotEmpty) iframes.add(src);
      }
      final links = <StreamLink>[];
      for (final url in [...matchLinks, ...iframes]) {
        if (_matchesQuery(url, home, away) || url.contains('bmax') || url.contains('koralive')) {
          links.add(StreamLink(
            title: '$home vs $away - Yalla Sport',
            url: url,
            quality: 'HD',
            isVerified: true,
          ));
        }
      }
      if (links.isNotEmpty) {
        return StreamSource(name: 'يلا شوت - رياضة', iconUrl: '', links: links);
      }
    } catch (e) {
      developer.log('Yalla Sport scrape failed: $e');
    }
    return null;
  }

  Future<StreamSource?> _scrapeYallaGool(String home, String away) async {
    try {
      final slug = _arabicSlug(home, away);
      final response = await dio.get(
        'https://yalla-gool.com/matches/$slug',
        options: _opts(),
      );
      if (response.statusCode != 200 || response.data is! String) return null;
      final doc = html_parser.parse(response.data as String);
      final links = <StreamLink>[];
      for (final iframe in doc.querySelectorAll('iframe[src]')) {
        final src = iframe.attributes['src'] ?? '';
        if (src.isNotEmpty) {
          links.add(StreamLink(
            title: '$home vs $away - Yalla Gool',
            url: src,
            quality: 'HD',
            isVerified: true,
          ));
        }
      }
      for (final a in doc.querySelectorAll('a[href]')) {
        final href = a.attributes['href'] ?? '';
        if (href.contains('m3u8') || href.contains('embed') || href.contains('player')) {
          links.add(StreamLink(
            title: a.text.trim().isNotEmpty ? a.text.trim() : '$home vs $away',
            url: href,
            quality: 'HD',
            isVerified: true,
          ));
        }
      }
      if (links.isNotEmpty) {
        return StreamSource(name: 'يلا غول', iconUrl: '', links: links);
      }
    } catch (e) {
      developer.log('Yalla Gool scrape failed: $e');
    }
    return null;
  }

  Future<StreamSource?> _scrapeIPTV(String home, String away) async {
    const playlists = [
      'https://iptv-org.github.io/iptv/categories/sports.m3u',
      'https://iptv-org.github.io/iptv/categories/sports_news.m3u',
    ];
    final allLinks = <StreamLink>[];
    for (final url in playlists) {
      try {
        final response = await dio.getUri(Uri.parse(url), options: _opts());
        if (response.statusCode == 200) {
          allLinks.addAll(_parseM3U(response.data.toString(), home, away));
        }
      } catch (e) {
        developer.log('IPTV failed ($url): $e');
      }
    }
    if (allLinks.isNotEmpty) {
      return StreamSource(name: 'قنوات رياضية', iconUrl: '', links: allLinks);
    }
    return null;
  }

  List<StreamLink> _parseM3U(String m3u, String home, String away) {
    final links = <StreamLink>[];
    final lines = m3u.split('\n');
    String currentTitle = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXTINF:')) {
        final m = RegExp(r',(.+)$').firstMatch(line);
        currentTitle = m?.group(1)?.trim() ?? '';
      } else if (line.startsWith('http') && currentTitle.isNotEmpty) {
        if (_matchesQuery(currentTitle, home, away)) {
          links.add(StreamLink(
            title: currentTitle,
            url: line,
            quality: 'Auto',
            isVerified: true,
          ));
        }
        currentTitle = '';
      }
    }
    return links;
  }

  bool _matchesQuery(String text, String home, String away) {
    final t = text.toLowerCase();
    final h = home.toLowerCase().split(' ').where((w) => w.length > 2).toList();
    final a = away.toLowerCase().split(' ').where((w) => w.length > 2).toList();
    return h.any((w) => t.contains(w)) && a.any((w) => t.contains(w));
  }

  String _arabicSlug(String home, String away) {
    final arabicNames = {
      'manchester city': 'مانشستر-سيتي', 'real madrid': 'ريال-مدريد',
      'barcelona': 'برشلونة', 'liverpool': 'ليفربول',
      'arsenal': 'آرسنال', 'chelsea': 'تشيلسي',
      'bayern': 'بايرن', 'psg': 'باريس-سان-جيرمان',
      'manchester united': 'مانشستر-يونايتد', 'tottenham': 'توتنهام',
      'juventus': 'يوفنتوس', 'inter': 'إنتر', 'milan': 'ميلان',
      'napoli': 'نابولي', 'atlético': 'أتلتيكو', 'atletico': 'أتلتيكو',
      'dortmund': 'بوروسيا', 'eintracht': 'آينتراخت',
      'marseille': 'مارسيليا', 'monaco': 'موناكو',
      'al hilal': 'الهلال', 'al ahly': 'الأهلي', 'al zamalek': 'الزمالك',
      'al ittihad': 'الاتحاد', 'al nasr': 'النصر', 'al shabab': 'الشباب',
    };
    final hSlug = arabicNames[home.toLowerCase()] ?? Uri.encodeComponent(home);
    final aSlug = arabicNames[away.toLowerCase()] ?? Uri.encodeComponent(away);
    return '$hSlug-ضد-$aSlug';
  }

  Future<List<StreamLink>> getAllSportChannels() async {
    const playlists = [
      'https://iptv-org.github.io/iptv/categories/sports.m3u',
      'https://iptv-org.github.io/iptv/categories/sports_news.m3u',
      'https://iptv-org.github.io/iptv/countries/ar.m3u',
      'https://iptv-org.github.io/iptv/countries/gb.m3u',
      'https://iptv-org.github.io/iptv/countries/us.m3u',
    ];
    final allChannels = <StreamLink>[];
    for (final url in playlists) {
      try {
        final response = await dio.getUri(Uri.parse(url), options: _opts());
        if (response.statusCode == 200) {
          allChannels.addAll(_parseAllChannels(response.data.toString()));
        }
      } catch (e) {
        developer.log('Channel playlist failed ($url): $e');
      }
    }
    return allChannels;
  }

  List<StreamLink> _parseAllChannels(String m3u) {
    final links = <StreamLink>[];
    final lines = m3u.split('\n');
    String currentTitle = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXTINF:')) {
        final titleM = RegExp(r',(.+)$').firstMatch(line);
        currentTitle = titleM?.group(1)?.trim() ?? '';
      } else if (line.startsWith('http') && currentTitle.isNotEmpty) {
        links.add(StreamLink(
          title: currentTitle,
          url: line,
          quality: 'Auto',
          isVerified: true,
        ));
        currentTitle = '';
      }
    }
    return links;
  }
}
