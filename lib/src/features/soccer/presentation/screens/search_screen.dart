import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:next_goal/src/config/app_route.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';
import 'package:next_goal/src/features/soccer/data/datasources/search_datasource.dart';
import 'package:next_goal/src/container_injector.dart';

import '../../../../core/extensions/context_ext.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<SearchResultItem> _results = [];
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().length >= 2) {
        setState(() { _query = value.trim(); _isSearching = true; });
        _performSearch(value.trim());
      } else {
        setState(() { _query = ''; _results = []; _isSearching = false; });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final ds = sl<SearchDataSource>();
      final results = await ds.search(query);
      if (mounted) setState(() { _results = results; _isSearching = false; });
    } catch (e) {
      if (mounted) setState(() { _isSearching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _query.isEmpty ? _buildSuggestions() : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: context.colorsExt.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'بحث',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: context.colorsExt.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final mostSearchedTeams = [
      _SuggestionData(name: 'ريال مدريد', logoUrl: AppConstants.clubImage('12', size: '80')),
      _SuggestionData(name: 'برشلونة', logoUrl: AppConstants.clubImage('13', size: '80')),
      _SuggestionData(name: 'باريس سان جيرمان', logoUrl: AppConstants.clubImage('14', size: '80')),
      _SuggestionData(name: 'أرسنال', logoUrl: AppConstants.clubImage('8', size: '80')),
    ];

    final mostSearchedCompetitions = [
      _SuggestionData(name: 'كأس العالم', logoUrl: AppConstants.competitionImage(5930, size: '80')),
      _SuggestionData(name: 'دوري أبطال أوروبا', logoUrl: AppConstants.competitionImage(572, size: '80')),
      _SuggestionData(name: 'الدوري الإنجليزي', logoUrl: AppConstants.competitionImage(7, size: '80')),
      _SuggestionData(name: 'الدوري الإسباني', logoUrl: AppConstants.competitionImage(11, size: '80')),
    ];

    final mostSearchedPlayers = [
      _SuggestionData(name: 'ميسي', imageUrl: AppConstants.athleteImage(1, size: '120')),
      _SuggestionData(name: 'رونالدو', imageUrl: AppConstants.athleteImage(2, size: '120')),
      _SuggestionData(name: 'مبابي', imageUrl: AppConstants.athleteImage(3, size: '120')),
      _SuggestionData(name: 'صلاح', imageUrl: AppConstants.athleteImage(4, size: '120')),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSection(title: 'الأندية الأكثر بحثاً', items: mostSearchedTeams),
          const SizedBox(height: 24),
          _buildSection(title: 'البطولات الأكثر بحثاً', items: mostSearchedCompetitions),
          const SizedBox(height: 24),
          _buildSection(title: 'اللاعبون الأكثر بحثاً', items: mostSearchedPlayers),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('آخر طلبات البحث', style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_SuggestionData> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (ctx, i) => _buildSuggestionCard(items[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(_SuggestionData item) {
    final imageUrl = item.logoUrl ?? item.imageUrl;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colorsExt.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: context.colorsExt.dividerSubtle, width: 2),
          ),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                      child: Text(item.name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(item.name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              : Center(
                  child: Text(item.name[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            item.name,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isSearching) return const Center(child: CircularProgressIndicator(color: Color(0xFFD4A843)));

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('لا توجد نتائج لـ "$_query"', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (ctx, i) => _SearchResultCard(
        result: _results[i],
        onTap: () {
          final r = _results[i];
          if (r.type == 'player') {
            context.push(Routes.playerDetail, extra: {
              'playerId': r.id,
              'playerName': r.name,
              'playerImageUrl': r.imageId != null ? AppConstants.athleteImage(r.imageId!, size: '200') : null,
              'teamName': r.teamName ?? r.subtitle,
              'shirtNumber': null,
            });
          } else if (r.type == 'team') {
            context.push(Routes.teamDetail, extra: {
              'teamId': r.id,
              'teamName': r.name,
              'teamLogo': r.imageId != null ? AppConstants.clubImage(r.id.toString(), size: '200') : null,
            });
          } else if (r.type == 'competition') {
            context.push(Routes.standings, extra: r.id);
          }
        },
      ),
    );
  }
}

class _SuggestionData {
  final String name;
  final String? logoUrl;
  final String? imageUrl;
  _SuggestionData({required this.name, this.logoUrl, this.imageUrl});
}

class _SearchResultCard extends StatelessWidget {
  final SearchResultItem result;
  final VoidCallback? onTap;
  const _SearchResultCard({required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String? imageUrl;

    switch (result.type) {
      case 'player':
        icon = Icons.person;
        color = const Color(0xFFD4A843);
        if (result.imageId != null) imageUrl = AppConstants.athleteImage(result.imageId!, size: '80');
      case 'team':
        icon = Icons.shield;
        color = const Color(0xFF3B82F6);
        if (result.imageId != null) imageUrl = AppConstants.clubImage(result.id.toString(), size: '80');
      case 'competition':
        icon = Icons.emoji_events;
        color = const Color(0xFFF59E0B);
        imageUrl = AppConstants.competitionImage(result.id, size: '80');
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: imageUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Icon(icon, color: color, size: 20),
                    errorWidget: (_, __, ___) => Icon(icon, color: color, size: 20),
                  ),
                )
              : Icon(icon, color: color, size: 20),
        ),
        title: Text(result.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
        subtitle: result.subtitle != null ? Text(result.subtitle!, style: TextStyle(color: Colors.grey[500], fontSize: 12)) : null,
        trailing: Icon(Icons.chevron_left, color: Colors.grey[500], size: 20),
        onTap: onTap,
      ),
    );
  }
}
