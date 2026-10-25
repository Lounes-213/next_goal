import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../container_injector.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../data/scrapers/highlights_scraper_service.dart';
import '../../domain/entities/stream_link.dart';

class HighlightsView extends StatefulWidget {
  final SoccerFixture fixture;

  const HighlightsView({super.key, required this.fixture});

  @override
  State<HighlightsView> createState() => _HighlightsViewState();
}

class _HighlightsViewState extends State<HighlightsView> {
  List<MatchHighlight> _highlights = [];
  bool _isLoading = true;
  String? _error;
  bool _showPlayer = false;
  WebViewController? _webController;

  bool get _isMatchFinished => widget.fixture.status.isEnded;

  @override
  void initState() {
    super.initState();
    if (_isMatchFinished) {
      _loadHighlights();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadHighlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final scraper = sl<HighlightsScraperService>();
      final highlights = await scraper.getHighlightsForMatch(
        homeTeam: widget.fixture.teams.home.displayName,
        awayTeam: widget.fixture.teams.away.displayName,
        competitionName: widget.fixture.fixtureLeague.name,
      );
      if (!mounted) return;
      setState(() {
        _highlights = highlights;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'فشل تحميل المشاهدات';
        _isLoading = false;
      });
    }
  }

  void _playHighlight(MatchHighlight highlight) {
    final url = highlight.videoUrl;
    if (url.isEmpty) return;

    // Convert YouTube watch URL to embed URL
    String embedUrl = url;
    final ytMatch = RegExp(r'youtube\.com/watch\?v=([^&]+)').firstMatch(url);
    if (ytMatch != null) {
      final videoId = ytMatch.group(1);
      embedUrl = 'https://www.youtube.com/embed/$videoId?autoplay=1&enablejsapi=1';
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {},
          onPageFinished: (url) {},
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));

    setState(() {
      _showPlayer = true;
      _webController = controller;
    });
  }

  void _closePlayer() {
    setState(() {
      _showPlayer = false;
      _webController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show video player if active
    if (_showPlayer && _webController != null) {
      return _buildVideoPlayer();
    }

    // Show message for unfinished matches
    if (!_isMatchFinished) {
      return _buildNotFinishedWidget();
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A843)),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_highlights.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildHighlightsList();
  }

  Widget _buildVideoPlayer() {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colorsExt.surfaceElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: _closePlayer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'مشاهدة المشهد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // WebView player with fixed height
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: WebViewWidget(controller: _webController!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFinishedWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              size: 48,
              color: context.colorsExt.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'المشاهدات ستكون متاحة بعد انتهاء المباراة',
              style: TextStyle(
                color: context.colorsExt.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A843).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.fixture.status.isLive
                    ? 'المباراة جارية حالياً'
                    : 'المباراة لم تبدأ بعد',
                style: const TextStyle(
                  color: Color(0xFFD4A843),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colorsExt.textMuted),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: context.colorsExt.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadHighlights,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A843),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_outlined, size: 48, color: context.colorsExt.textMuted),
            const SizedBox(height: 12),
            Text(
              'لا توجد مشاهدات متاحة لهذا اللقاء',
              style: TextStyle(color: context.colorsExt.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Color(0xFFE11D48),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ملخصات المباراة',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_highlights.length} فيديو',
                  style: const TextStyle(
                    color: Color(0xFFD4A843),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Main highlight (first one - larger)
        if (_highlights.isNotEmpty)
          _MainHighlightCard(
            highlight: _highlights.first,
            onTap: () => _playHighlight(_highlights.first),
          ),

        // Other highlights
        if (_highlights.length > 1) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'مشاهدات أخرى',
              style: TextStyle(
                color: context.colorsExt.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._highlights.skip(1).map(
                (h) => _HighlightCard(
                  highlight: h,
                  onTap: () => _playHighlight(h),
                ),
              ),
        ],
      ],
    );
  }
}

class _MainHighlightCard extends StatelessWidget {
  final MatchHighlight highlight;
  final VoidCallback onTap;

  const _MainHighlightCard({required this.highlight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.colorsExt.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colorsExt.dividerSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    highlight.thumbnailUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 180,
                      color: context.colorsExt.surfaceElevated,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: context.colorsExt.textMuted,
                        size: 48,
                      ),
                    ),
                  ),
                  // Play button
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  // Source badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        highlight.source ?? 'beIN SPORTS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (highlight.leagueName != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A843).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        highlight.leagueName!,
                        style: const TextStyle(
                          color: Color(0xFFD4A843),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final MatchHighlight highlight;
  final VoidCallback onTap;

  const _HighlightCard({required this.highlight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.colorsExt.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorsExt.dividerSubtle, width: 1),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      highlight.thumbnailUrl,
                      width: 120,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 72,
                        color: context.colorsExt.surfaceElevated,
                        child: Icon(
                          Icons.play_circle_fill,
                          color: context.colorsExt.textMuted,
                          size: 32,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    // Source badge
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          highlight.source ?? 'beIN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: const Color(0xFFD4A843),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            highlight.source ?? 'beIN SPORTS',
                            style: TextStyle(
                              color: context.colorsExt.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.chevron_left,
                  color: context.colorsExt.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
