import 'package:flutter/material.dart';
import 'package:next_goal/src/core/constants/app_constants.dart';
import 'package:next_goal/src/core/extensions/context_ext.dart';
import 'package:next_goal/src/core/widgets/app_loading.dart';
import 'package:next_goal/src/core/widgets/custom_image.dart';
import 'package:next_goal/src/features/soccer/data/datasources/top_scorers_datasource.dart';
import 'package:next_goal/src/features/soccer/domain/entities/top_scorer.dart';
import 'package:next_goal/src/container_injector.dart';

class TopScorersScreen extends StatefulWidget {
  final int competitionId;
  final String competitionName;
  const TopScorersScreen({super.key, required this.competitionId, required this.competitionName});

  @override
  State<TopScorersScreen> createState() => _TopScorersScreenState();
}

class _TopScorersScreenState extends State<TopScorersScreen> {
  List<TopScorer>? _scorers;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ds = sl<TopScorersDataSource>();
      final models = await ds.getTopScorers(widget.competitionId);
      if (mounted) setState(() { _scorers = models.map((m) => m.toDomain()).toList(); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.competitionName} - الهدافين')),
      body: _isLoading
          ? const AppLoadingIndicator()
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scorers!.length,
                  itemBuilder: (ctx, i) => _TopScorerCard(scorer: _scorers![i], rank: i + 1),
                ),
    );
  }
}

class _TopScorerCard extends StatelessWidget {
  final TopScorer scorer;
  final int rank;
  const _TopScorerCard({required this.scorer, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          CustomImage(
            width: 40,
            height: 40,
            imageUrl: scorer.imageId != null ? AppConstants.athleteImage(scorer.imageId!, size: '80') : '',
            placeholder: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: context.colorsExt.darkBlue),
              child: Center(
                child: Text(
                  scorer.name[0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scorer.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                if (scorer.teamName != null)
                  Text(scorer.teamName!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('${scorer.goals}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('هدف', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
