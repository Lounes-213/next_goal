class StreamLink {
  final String title;
  final String url;
  final String quality;
  final bool isVerified;

  const StreamLink({
    required this.title,
    required this.url,
    this.quality = 'HD',
    this.isVerified = false,
  });
}

class StreamSource {
  final String name;
  final String iconUrl;
  final List<StreamLink> links;

  const StreamSource({
    required this.name,
    this.iconUrl = '',
    this.links = const [],
  });
}

class MatchHighlight {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String? source;
  final String? matchTitle;
  final String? leagueName;

  const MatchHighlight({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.source,
    this.matchTitle,
    this.leagueName,
  });

  String? get youtubeId {
    // Match youtube.com/watch?v=ID
    final watchMatch = RegExp(r'youtube\.com/watch\?v=([^&]+)').firstMatch(videoUrl);
    if (watchMatch != null) return watchMatch.group(1);
    // Match youtube.com/embed/ID
    final embedMatch = RegExp(r'youtube\.com/embed/([^?]+)').firstMatch(videoUrl);
    if (embedMatch != null) return embedMatch.group(1);
    // Match youtu.be/ID
    final shortMatch = RegExp(r'youtu\.be/([^?]+)').firstMatch(videoUrl);
    if (shortMatch != null) return shortMatch.group(1);
    // Match from thumbnail URL
    final imgMatch = RegExp(r'ytimg\.com/vi/([^/]+)').firstMatch(thumbnailUrl);
    if (imgMatch != null) return imgMatch.group(1);
    return null;
  }

  String? get youtubeEmbedUrl {
    final id = youtubeId;
    if (id != null) return 'https://www.youtube.com/embed/$id';
    if (videoUrl.contains('youtube.com')) return videoUrl;
    return null;
  }
}
