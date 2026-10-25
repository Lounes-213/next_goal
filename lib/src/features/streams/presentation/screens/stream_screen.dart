import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../container_injector.dart';
import '../../../../core/domain/entities/soccer_fixture.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../data/scrapers/stream_scraper_service.dart';
import '../../domain/entities/stream_link.dart';

class StreamScreen extends StatefulWidget {
  final SoccerFixture fixture;

  const StreamScreen({super.key, required this.fixture});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  List<StreamSource> _sources = [];
  bool _isLoading = true;
  String? _error;
  WebViewController? _webController;
  bool _isPlayerOpen = false;

  @override
  void initState() {
    super.initState();
    _loadStreams();
  }

  Future<void> _loadStreams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final scraper = sl<StreamScraperService>();
      final sources = await scraper.getStreamsForMatch(
        homeTeam: widget.fixture.teams.home.displayName,
        awayTeam: widget.fixture.teams.away.displayName,
        matchId: widget.fixture.id,
      );
      if (sources.isEmpty) {
        setState(() {
          _error = 'No streams available for this match';
          _isLoading = false;
        });
      } else {
        setState(() {
          _sources = sources;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load streams: $e';
        _isLoading = false;
      });
    }
  }

  void _openStream(StreamLink link) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(link.url));
    setState(() {
      _webController = controller;
      _isPlayerOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (_isPlayerOpen) {
              setState(() {
                _isPlayerOpen = false;
                _webController = null;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _isPlayerOpen
              ? context.l10n.liveScore
              : '${widget.fixture.teams.home.displayName} vs ${widget.fixture.teams.away.displayName}',
        ),
        centerTitle: true,
        actions: [
          if (_isPlayerOpen)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webController?.reload(),
            ),
        ],
      ),
      body: _isPlayerOpen && _webController != null
          ? WebViewWidget(controller: _webController!)
          : _buildSourceList(context),
    );
  }

  Widget _buildSourceList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadStreams,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Available Streams',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        for (final source in _sources) ...[
          if (source.links.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StreamSourceCard(
                source: source,
                onTap: (link) => _openStream(link),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _StreamSourceCard extends StatelessWidget {
  final StreamSource source;
  final void Function(StreamLink link) onTap;

  const _StreamSourceCard({required this.source, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    source.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${source.links.length} link${source.links.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...source.links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onTap(link),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colorsExt.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colorsExt.dividerSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        color: context.colors.primary,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                _QualityBadge(quality: link.quality),
                                if (link.isVerified) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.verified, size: 14, color: context.colorsExt.green),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final String quality;
  const _QualityBadge({required this.quality});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorsExt.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        quality,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.colorsExt.green,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
