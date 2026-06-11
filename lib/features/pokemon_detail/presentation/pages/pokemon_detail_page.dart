import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pokemon_list/data/models/pokemon_model.dart';
import '../../../pokemon_list/data/repositories/pokemon_repository.dart';
import '../widgets/detail_section.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_chip.dart';

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({super.key, required this.pokemonId});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  final _repository = PokemonRepository();
  late Future<PokemonDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _repository.fetchPokemonDetail(widget.pokemonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PokemonDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _ErrorBody(
              message: snapshot.error.toString(),
              onBack: () => Navigator.of(context).pop(),
              onRetry: () => setState(() {
                _detailFuture =
                    _repository.fetchPokemonDetail(widget.pokemonId);
              }),
            );
          }

          final p = snapshot.data!;
          final primaryType = p.types.isNotEmpty ? p.types.first : 'normal';
          final headerColor = AppColors.typeColor(primaryType);

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, p, headerColor),
              SliverToBoxAdapter(
                child: _buildBody(context, p, headerColor),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, PokemonDetail p, Color headerColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradient header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    headerColor.withOpacity(0.3),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Pokemon image
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Hero(
                  tag: 'pokemon_${p.id}',
                  child: Image.network(
                    p.imageUrl ?? '',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.catching_pokemon,
                      color: AppColors.textSecondary,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
            // ID badge top-right
            Positioned(
              top: 56,
              right: 20,
              child: Text(
                p.formattedId,
                style: TextStyle(
                  color: headerColor.withOpacity(0.5),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PokemonDetail p, Color headerColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + types
          Text(
            _capitalize(p.name),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: p.types
                .map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TypeChip(type: t),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),

          // ── 1. Physical info ──────────────────────────────────────────────
          DetailSection(
            title: 'Profile',
            child: _infoGrid([
              _InfoItem(
                  label: 'Height', value: '${p.heightInMeters.toStringAsFixed(1)} m'),
              _InfoItem(
                  label: 'Weight', value: '${p.weightInKg.toStringAsFixed(1)} kg'),
              _InfoItem(
                  label: 'Base EXP', value: p.baseExperience.toString()),
              _InfoItem(label: 'ID', value: p.formattedId),
            ]),
          ),
          const SizedBox(height: 24),

          // ── 2. Types ──────────────────────────────────────────────────────
          DetailSection(
            title: 'Types',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.types.map((t) => TypeChip(type: t)).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── 3. Abilities ──────────────────────────────────────────────────
          DetailSection(
            title: 'Abilities',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: p.abilities
                  .map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _capitalize(a),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── 4. Base Stats ─────────────────────────────────────────────────
          DetailSection(
            title: 'Base Stats',
            child: Column(
              children: p.stats
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StatBar(stat: s),
                      ))
                  .toList(),
            ),
          ),

          // ── 5. Effort values ──────────────────────────────────────────────
          if (p.stats.any((s) => s.effort > 0)) ...[
            const SizedBox(height: 24),
            DetailSection(
              title: 'Effort Values (EV)',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.stats
                    .where((s) => s.effort > 0)
                    .map((s) => _EvChip(stat: s))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoGrid(List<_InfoItem> items) {
    // Dividir en filas de 2 columnas sin GridView (evita el childAspectRatio)
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _InfoTile(item: left)),
            const SizedBox(width: 12),
            Expanded(
              child: right != null
                  ? _InfoTile(item: right)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < items.length) rows.add(const SizedBox(height: 12));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
}

class _InfoTile extends StatelessWidget {
  final _InfoItem item;
  const _InfoTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvChip extends StatelessWidget {
  final PokemonStat stat;
  const _EvChip({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        '${stat.displayName} +${stat.effort}',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _ErrorBody({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
          ),
          const Spacer(),
          const Icon(Icons.error_outline, color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary),
            child: const Text('Retry'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
