import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';
import 'package:next_goal/src/features/soccer/data/datasources/player_datasource.dart';
import 'package:next_goal/src/container_injector.dart';

import '../../../../core/extensions/context_ext.dart';

class PlayerDetailScreen extends StatefulWidget {
  final int? playerId;
  final String playerName;
  final String? playerImageUrl;
  final int? shirtNumber;
  final String? teamName;
  final String? teamLogo;

  const PlayerDetailScreen({
    super.key,
    this.playerId,
    required this.playerName,
    this.playerImageUrl,
    this.shirtNumber,
    this.teamName,
    this.teamLogo,
  });

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  PlayerInfo? _playerInfo;
  PlayerStats? _playerStats;
  List<PlayerTransfer> _transfers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    if (widget.playerId == null) return;
    try {
      final ds = sl<PlayerDataSource>();
      final results = await Future.wait([
        ds.getPlayerInfo(widget.playerId!),
        ds.getPlayerStats(widget.playerId!),
        ds.getPlayerTransfers(widget.playerId!),
      ]);
      if (mounted) {
        setState(() {
          _playerInfo = results[0] as PlayerInfo;
          _playerStats = results[1] as PlayerStats;
          _transfers = results[2] as List<PlayerTransfer>;
        });
      }
    } catch (e) {
      // silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _playerInfo?.name ?? widget.playerName;
    final imageUrl = widget.playerImageUrl ?? (_playerInfo?.imageId != null ? AppConstants.athleteImage(_playerInfo!.imageId!, size: '200') : null);
    final number = _playerInfo?.number ?? widget.shirtNumber ?? 10;
    final team = _playerInfo?.teamName ?? widget.teamName ?? '';
    final position = _playerInfo?.position ?? '';
    final height = (_playerInfo != null && _playerInfo!.height != null) ? _playerInfo!.height!.toInt().toString() : '--';
    final weight = (_playerInfo != null && _playerInfo!.weight != null) ? _playerInfo!.weight!.toInt().toString() : '--';
    final age = (_playerInfo != null && _playerInfo!.dateOfBirth != null) ? DateTime.now().difference(_playerInfo!.dateOfBirth!).inDays ~/ 365 : 18;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A2744), Theme.of(context).scaffoldBackgroundColor],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface, size: 22),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurface, size: 22),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colorsExt.dividerSubtle, width: 3),
                            ),
                            child: imageUrl != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Color(0xFFD4A843))),
                                      errorWidget: (_, __, ___) => _buildPlaceholder(name),
                                    ),
                                  )
                                : _buildPlaceholder(name),
                          ),
                          Positioned(
                            bottom: -5,
                            left: -5,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: context.colorsExt.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.colorsExt.dividerSubtle, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '$number',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
                      if (team.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(team, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _PhysicalStat(label: 'الطول', value: '$height', unit: 'cm', color: Colors.grey[700]!),
                  const SizedBox(width: 6),
                  _PhysicalStat(label: 'الوزن', value: '$weight', unit: 'kg', color: Colors.red[800]!),
                  const SizedBox(width: 6),
                  _PhysicalStat(label: 'العمر', value: '$age', unit: 'سنة', color: Colors.grey[700]!),
                  const SizedBox(width: 6),
                  _PhysicalStat(label: 'المركز', value: position.isNotEmpty ? position : '--', unit: '', color: Colors.grey[700]!),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('إحصائيات', style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('الانتقالات', style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_transfers.isEmpty)
                    Center(child: Text('لا توجد انتقالات', style: TextStyle(color: Colors.grey[600])))
                  else
                    ..._transfers.take(5).map((t) => _TransferItem(
                      type: t.type ?? 'انتقال',
                      date: t.date != null ? '${t.date!.year}-${t.date!.month.toString().padLeft(2, '0')}' : '',
                      from: t.fromTeamName ?? '',
                      to: t.toTeamName ?? '',
                      isHighlighted: t == _transfers.first,
                    )),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
      ),
      child: Center(
        child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _playerStats;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(value: '${stats?.yellowCards ?? 0}', label: 'بطاقة صفراء', iconColor: Colors.yellow),
              _StatItem(value: '${stats?.appearances ?? 0}', label: 'المشاركات', iconColor: Colors.blue),
              _StatItem(value: '${stats?.goals ?? 0}', label: 'الأهداف', iconColor: Colors.green),
              _StatItem(value: '${stats?.shotsOnTarget ?? 0}', label: 'تسديدات', iconColor: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatItem(value: '${stats?.rating?.toStringAsFixed(1) ?? '0.0'}', label: 'التقييم', iconColor: Colors.amber),
              _StatItem(value: '${stats?.assists ?? 0}', label: 'تمريرات حاسمة', iconColor: Colors.cyan),
              _StatItem(value: '${stats?.redCards ?? 0}', label: 'بطاقة حمراء', iconColor: Colors.red),
              const SizedBox(width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhysicalStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _PhysicalStat({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
              Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({required this.value, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
              const SizedBox(width: 4),
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TransferItem extends StatelessWidget {
  final String type;
  final String date;
  final String from;
  final String to;
  final bool isHighlighted;

  const _TransferItem({required this.type, required this.date, required this.from, required this.to, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorsExt.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFD4A843) : Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(type, style: TextStyle(color: isHighlighted ? const Color(0xFFD4A843) : Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold)),
                if (date.isNotEmpty) Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(to, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                if (from.isNotEmpty) Text(from, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
