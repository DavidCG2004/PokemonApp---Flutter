import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/pokemon_model.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/pokemon_card.dart';
import '../../../pokemon_detail/presentation/pages/pokemon_detail_page.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final _repository = PokemonRepository();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  final List<PokemonSummary> _allPokemon = [];
  List<PokemonSummary> _filtered = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _query) return;
    setState(() {
      _query = query;
      _filtered = _applyFilter(_allPokemon);
    });
  }

  List<PokemonSummary> _applyFilter(List<PokemonSummary> source) {
    if (_query.isEmpty) return List.of(source);
    return source
        .where((p) =>
            p.name.toLowerCase().contains(_query) ||
            p.formattedId.contains(_query))
        .toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filtered = List.of(_allPokemon);
    });
  }

  // ── Infinite scroll ───────────────────────────────────────────────────────

  void _onScroll() {
    if (_query.isNotEmpty) return; // no paginar mientras se busca
    if (_scrollController.position.extentAfter < 300) {
      _loadMore();
    }
  }

  void _checkIfNeedsMoreData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_query.isNotEmpty) return;
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent == 0 &&
          _hasMore &&
          !_isLoading) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _repository.fetchPokemonList(offset: _offset);
      setState(() {
        _allPokemon.addAll(results);
        _filtered = _applyFilter(_allPokemon);
        _offset += results.length;
        _hasMore = results.length == PokemonRepository.pageSize;
        _isLoading = false;
      });
      _checkIfNeedsMoreData();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _allPokemon.clear();
      _filtered = [];
      _offset = 0;
      _hasMore = true;
      _error = null;
      _query = '';
      _searchController.clear();
    });
    await _loadMore();
  }

  void _navigateToDetail(PokemonSummary summary) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(pokemonId: summary.id),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Poké',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'dex',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: _SearchBar(
            controller: _searchController,
            onClear: _clearSearch,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_allPokemon.isEmpty && _isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_allPokemon.isEmpty && _error != null) {
      return _ErrorView(message: _error!, onRetry: _loadMore);
    }

    if (_filtered.isEmpty && _query.isNotEmpty) {
      return _EmptySearch(query: _query);
    }

    // En búsqueda activa no mostrar spinner de paginación al final
    final showLoader = _query.isEmpty && (_isLoading || _hasMore);

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _filtered.length + (showLoader ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= _filtered.length) {
          return _isLoading
              ? const _LoadingTile()
              : const SizedBox.shrink();
        }
        return PokemonCard(
          pokemon: _filtered[index],
          onTap: () => _navigateToDetail(_filtered[index]),
        );
      },
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: 'Nombre o número...',
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 20),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (_, __) => controller.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: onClear,
                  ),
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.catching_pokemon,
              color: AppColors.textSecondary, size: 48),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "$query"',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba con otro nombre o número',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}