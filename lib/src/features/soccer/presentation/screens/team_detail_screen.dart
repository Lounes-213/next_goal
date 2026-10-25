import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';

import '../../../../core/extensions/context_ext.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final int? fifaRanking;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    this.fifaRanking,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    'المباريات',
    'الأخبار',
    'الترتيب',
    'اللاعبون',
    'معلومات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _TeamHeader(
            teamName: widget.teamName,
            teamLogo: widget.teamLogo,
            teamId: widget.teamId,
            fifaRanking: widget.fifaRanking,
          ),
          _TabBarSection(
            controller: _tabController,
            tabs: _tabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MatchesTab(),
                _NewsTab(),
                _RankingTab(),
                _PlayersTab(),
                _InfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final String teamName;
  final String? teamLogo;
  final int teamId;
  final int? fifaRanking;

  const _TeamHeader({
    required this.teamName,
    required this.teamLogo,
    required this.teamId,
    this.fifaRanking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2744), Theme.of(context).scaffoldBackgroundColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTeamLogo(context),
            const SizedBox(height: 16),
            Text(
              teamName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (fifaRanking != null) ...[
              const SizedBox(height: 8),
              _buildFifaBadge(fifaRanking!),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(BuildContext context) {
    final logoSize = 120.0;
    final hasLogo = teamLogo != null && teamLogo!.isNotEmpty;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colorsExt.dividerSubtle, width: 3),
        color: context.colorsExt.surfaceElevated,
      ),
      child: hasLogo
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: AppConstants.clubImage(
                  teamId.toString(),
                  size: '120',
                ),
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        teamName.isNotEmpty ? teamName[0] : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFifaBadge(int ranking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A843).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A843),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFD4A843), size: 16),
          const SizedBox(width: 4),
          Text(
            'FIFA #$ranking',
            style: const TextStyle(
              color: Color(0xFFD4A843),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarSection extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _TabBarSection({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: context.colorsExt.surfaceElevated, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        labelColor: const Color(0xFFD4A843),
        unselectedLabelColor: Colors.grey[500],
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: const Color(0xFFD4A843),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerHeight: 0,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

class _MatchesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildMatchesGroup(
            competitionName: 'الدوري الإنجليزي الممتاز',
            competitionLogo: 7,
            matches: [
              _MatchData(
                homeTeam: 'مانشستر سيتي',
                awayTeam: 'أرسنال',
                homeScore: 2,
                awayScore: 1,
                date: '2026-06-20',
                time: '18:00',
                isFinished: true,
              ),
              _MatchData(
                homeTeam: 'مانشستر سيتي',
                awayTeam: 'ليفربول',
                homeScore: null,
                awayScore: null,
                date: '2026-07-01',
                time: '20:00',
                isFinished: false,
              ),
              _MatchData(
                homeTeam: 'تشيلسي',
                awayTeam: 'مانشستر سيتي',
                homeScore: null,
                awayScore: null,
                date: '2026-07-08',
                time: '19:30',
                isFinished: false,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: _buildMatchesGroup(
            competitionName: 'دوري أبطال أوروبا',
            competitionLogo: 572,
            matches: [
              _MatchData(
                homeTeam: 'مانشستر سيتي',
                awayTeam: 'ريال مدريد',
                homeScore: 3,
                awayScore: 2,
                date: '2026-06-15',
                time: '21:00',
                isFinished: true,
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildMatchesGroup({
    required String competitionName,
    required int competitionLogo,
    required List<_MatchData> matches,
  }) {
    final finished = matches.where((m) => m.isFinished).toList();
    final upcoming = matches.where((m) => !m.isFinished).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Image.network(
                AppConstants.competitionImage(competitionLogo, size: '20'),
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.emoji_events,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  competitionName,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (upcoming.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'المباريات القادمة',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        if (upcoming.isNotEmpty)
          ...upcoming.map((match) => _MatchCard(match: match)),
        if (upcoming.isNotEmpty && finished.isNotEmpty)
          const SizedBox(height: 8),
        if (finished.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'المباريات المنتهية',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        if (finished.isNotEmpty)
          ...finished.map((match) => _MatchCard(match: match)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _MatchData {
  final String homeTeam;
  final String awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String date;
  final String time;
  final bool isFinished;

  const _MatchData({
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.date,
    required this.time,
    required this.isFinished,
  });
}

class _MatchCard extends StatelessWidget {
  final _MatchData match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.homeTeam,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (match.isFinished && match.homeScore != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${match.homeScore} - ${match.awayScore}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            Column(
              children: [
                Text(
                  match.time,
                  style: const TextStyle(
                    color: Color(0xFFD4A843),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  match.date,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
          Expanded(
            child: Text(
              match.awayTeam,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newsItems = [
      {
        'title': 'المدرب يعلن عن القائمة النهائية لدوري أبطال أوروبا',
        'date': '2026-06-24',
        'source': 'الجزيرة الرياضية',
      },
      {
        'title': 'نجم الفريق يوقع عقدًا جديدًا لمدة 5 سنوات',
        'date': '2026-06-22',
        'source': 'سكاي سبورتس',
      },
      {
        'title': 'إصابة اللاعب الأساسي خلال التدريبات',
        'date': '2026-06-20',
        'source': 'بي بي سي سبورت',
      },
      {
        'title': 'الفريق يحقق الفوز في المباراة الودية',
        'date': '2026-06-18',
        'source': 'الرياضية',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final news = newsItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorsExt.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                news['title']!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    news['source']!,
                    style: TextStyle(
                      color: const Color(0xFFD4A843),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    news['date']!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RankingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'الترتيب',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم عرض الترتيب هنا',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final players = List.generate(
      22,
      (i) => _PlayerData(
        id: i + 1,
        name: _mockPlayerNames[i % _mockPlayerNames.length],
        position: _mockPositions[i % _mockPositions.length],
        shirtNumber: i + 1,
      ),
    );

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return _PlayerCard(player: player);
      },
    );
  }

  static const _mockPlayerNames = [
    'إيرك تين هاج',
    'كيليان مبابي',
    'فينيسيوس جونيور',
    'جود بيلينغهام',
    'رودري',
    'ماركينيوس',
    'تيبو كورتوا',
    'كريم بنزيما',
    'محمد صلاح',
    'نيمار جونيور',
    'إرلينغ هالاند',
    'لوكا مودريتش',
  ];

  static const _mockPositions = [
    'حارس مرمى',
    'مدافع',
    'لاعب وسط',
    'مهاجم',
  ];
}

class _PlayerData {
  final int id;
  final String name;
  final String position;
  final int shirtNumber;

  const _PlayerData({
    required this.id,
    required this.name,
    required this.position,
    required this.shirtNumber,
  });
}

class _PlayerCard extends StatelessWidget {
  final _PlayerData player;

  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.colorsExt.dividerSubtle, width: 2),
                color: context.colorsExt.surfaceElevated,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: AppConstants.athleteImage(
                    player.id,
                    size: '80',
                  ),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => Center(
                    child: Text(
                      player.name[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorsExt.dividerSubtle,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${player.shirtNumber}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          player.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoSection(context, 'معلومات النادي', [
          _InfoRow(label: 'المدينة', value: 'مانشستر'),
          _InfoRow(label: 'الدولة', value: 'إنجلترا'),
          _InfoRow(label: 'التأسيس', value: '1880'),
          _InfoRow(label: 'الملعب', value: 'ملعب الاتحاد'),
          _InfoRow(label: 'السعة', value: '53,400'),
        ]),
        const SizedBox(height: 16),
        _buildInfoSection(context, 'البطولات', [
          _InfoRow(label: 'الدوري المحلي', value: '10 مرات'),
          _InfoRow(label: 'كأس الاتحاد', value: '7 مرات'),
          _InfoRow(label: 'دوري الأبطال', value: '1 مرة'),
        ]),
        const SizedBox(height: 16),
        _buildInfoSection(context, 'معلومات الاتصال', [
          _InfoRow(label: 'الموقع', value: 'www.mancity.com'),
          _InfoRow(label: 'البريد الإلكتروني', value: 'info@mancity.com'),
        ]),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<_InfoRow> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
