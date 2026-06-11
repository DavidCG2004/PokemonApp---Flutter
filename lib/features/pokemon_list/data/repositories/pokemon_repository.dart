import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonRepository {
  static const _baseUrl = 'https://pokeapi.co/api/v2';
  static const int pageSize = 5;

  final http.Client _client;

  PokemonRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PokemonSummary>> fetchPokemonList({
    required int offset,
    int limit = pageSize,
  }) async {
    final uri = Uri.parse('$_baseUrl/pokemon?offset=$offset&limit=$limit');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon list (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map((e) => PokemonSummary.fromJson(e)).toList();
  }

  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$id');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon detail (${response.statusCode})');
    }

    return PokemonDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
