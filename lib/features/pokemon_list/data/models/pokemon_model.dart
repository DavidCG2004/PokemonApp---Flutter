class PokemonSummary {
  final int id;
  final String name;
  final String url;

  const PokemonSummary({
    required this.id,
    required this.name,
    required this.url,
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get formattedId => '#${id.toString().padLeft(3, '0')}';

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
    return PokemonSummary(id: id, name: json['name'] as String, url: url);
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;
  final String? imageUrl;
  final String? imageUrlShiny;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.types,
    required this.abilities,
    required this.stats,
    this.imageUrl,
    this.imageUrlShiny,
  });

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
  double get heightInMeters => height / 10;
  double get weightInKg => weight / 10;

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>;
    final other = sprites['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      baseExperience: (json['base_experience'] as int?) ?? 0,
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList(),
      stats:
          (json['stats'] as List).map((s) => PokemonStat.fromJson(s)).toList(),
      imageUrl: artwork?['front_default'] as String? ??
          sprites['front_default'] as String?,
      imageUrlShiny: artwork?['front_shiny'] as String? ??
          sprites['front_shiny'] as String?,
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;
  final int effort;

  const PokemonStat({
    required this.name,
    required this.baseStat,
    required this.effort,
  });

  String get displayName {
    const labels = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'Sp.ATK',
      'special-defense': 'Sp.DEF',
      'speed': 'SPD',
    };
    return labels[name] ?? name.toUpperCase();
  }

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'] as String,
      baseStat: json['base_stat'] as int,
      effort: json['effort'] as int,
    );
  }
}
