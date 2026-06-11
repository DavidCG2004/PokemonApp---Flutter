import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/pokemon_list/presentation/pages/pokemon_list_page.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PokemonListPage(),
    );
  }
}
