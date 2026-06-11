# Pokédex App

Una aplicación móvil/web desarrollada en Flutter que consume la [PokéAPI](https://pokeapi.co/) para explorar el universo Pokémon. Diseño minimalista oscuro con paleta de colores coherente, infinite scrolling y vista de detalle completa.

---

## Capturas de pantalla

> Reemplaza las rutas con tus imágenes reales.

| Lista principal | Búsqueda activa | Detalle |
|:-:|:-:|:-:|
|<img width="251" height="522" alt="image" src="https://github.com/user-attachments/assets/19a68c74-8ac2-4759-b836-9258d89e93df" />
|<img width="372" height="571" alt="image" src="https://github.com/user-attachments/assets/0167aafb-1f08-4507-a62f-f2177011d093" />
|<img width="315" height="560" alt="image" src="https://github.com/user-attachments/assets/a495b44f-8249-4602-a0aa-3a385d1fcaf4" />
|

---

## Características

- **Infinite scroll** — carga 5 Pokémon por lote al llegar al final de la lista
- **Barra de búsqueda** — filtra por nombre o número (`#001`) en tiempo real sobre los datos ya cargados
- **Vista de detalle** — muestra más de 10 atributos por Pokémon
- **Pull to refresh** — recarga la lista deslizando hacia abajo
- **Diseño dark minimalista** — paleta coherente en toda la app con colores semánticos por tipo
- **Manejo de errores** — pantallas de error con opción de reintentar

---

## Atributos mostrados en el detalle

| # | Atributo |
|---|---|
| 1 | ID formateado (`#006`) |
| 2 | Nombre |
| 3 | Altura (metros) |
| 4 | Peso (kg) |
| 5 | Experiencia base |
| 6 | Tipos (con color semántico) |
| 7 | Habilidades |
| 8 | HP |
| 9 | Ataque |
| 10 | Defensa |
| 11 | Ataque especial |
| 12 | Defensa especial |
| 13 | Velocidad |
| 14 | Effort Values (EV) |

---

## Tecnologías

- [Flutter](https://flutter.dev/) `>=3.10.0`
- [Dart](https://dart.dev/) `>=3.0.0`
- [`http`](https://pub.dev/packages/http) `^1.2.0` — llamadas a la API REST
- [PokéAPI](https://pokeapi.co/) — fuente de datos pública y gratuita

---

## Arquitectura

El proyecto sigue una estructura **Feature-first** con separación de capas por feature.

```
lib/
├── main.dart
├── core/
│   └── theme/
│       └── app_theme.dart          # Paleta, colores de tipos, ThemeData
└── features/
    ├── pokemon_list/
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── pokemon_model.dart        # PokemonSummary, PokemonDetail, PokemonStat
    │   │   └── repositories/
    │   │       └── pokemon_repository.dart   # Llamadas a PokéAPI, pageSize = 5
    │   └── presentation/
    │       ├── pages/
    │       │   └── pokemon_list_page.dart    # Infinite scroll + búsqueda
    │       └── widgets/
    │           └── pokemon_card.dart         # Card de la lista
    └── pokemon_detail/
        └── presentation/
            ├── pages/
            │   └── pokemon_detail_page.dart  # Vista de detalle completa
            └── widgets/
                ├── detail_section.dart       # Sección con título
                ├── stat_bar.dart             # Barra animada de estadísticas
                └── type_chip.dart            # Chip de tipo con color semántico
```

---

## Paleta de colores

| Token | Hex | Uso |
|---|---|---|
| `background` | `#0F0F0F` | Fondo principal |
| `surface` | `#1A1A1A` | Cards y contenedores |
| `surfaceVariant` | `#242424` | Tiles de info, barra de búsqueda |
| `primary` | `#CC0000` | Acento principal (rojo Pokémon) |
| `accent` | `#FFD700` | Acento secundario (amarillo Pikachu) |
| `textPrimary` | `#FAFAFA` | Texto principal |
| `textSecondary` | `#9E9E9E` | Texto secundario y placeholders |

Los tipos Pokémon tienen su propio color semántico (fuego → naranja, agua → azul, eléctrico → amarillo, etc.) definidos en `AppColors.typeColors`.

---

## Instalación y ejecución

### Requisitos previos

- Flutter SDK `>=3.10.0` — [guía de instalación](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.0.0` (incluido con Flutter)
- Conexión a internet (consume PokéAPI)

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/pokedex-app.git
cd pokedex-app

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en el dispositivo/emulador conectado
flutter run

# 4. Ejecutar en Chrome (web)
flutter run -d chrome
```

### Build de producción

```bash
# APK Android
flutter build apk --release

# Web
flutter build web --release
```

---

## Decisiones de diseño

**¿Por qué filtrado local y no búsqueda por API?**
La PokéAPI no ofrece un endpoint de búsqueda por prefijo. Filtrar sobre la lista ya cargada en memoria es instantáneo para el usuario y evita latencia de red en cada tecla. A medida que el usuario hace scroll y se cargan más Pokémon, el filtro se amplía automáticamente.

**¿Por qué infinite scroll de 5 en 5?**
Reduce la carga inicial y simula un feed progresivo. El `ScrollController` detecta cuando quedan menos de 300px de contenido y dispara la siguiente página. Si los 5 items no llenan la pantalla (escritorio/web), `_checkIfNeedsMoreData()` carga el siguiente lote automáticamente vía `postFrameCallback`.

**¿Por qué Feature-first y no Layer-first?**
Con feature-first cada funcionalidad (`pokemon_list`, `pokemon_detail`) es un módulo autocontenido. Escalar añadiendo un feature nuevo (favoritos, equipos, etc.) no requiere tocar carpetas globales.

---

## Posibles mejoras

- [ ] Caché local con `shared_preferences` o `hive` para uso offline
- [ ] Filtro por tipo desde la lista principal
- [ ] Animación Hero entre la card de la lista y la imagen del detalle
- [ ] Soporte para cadenas de evolución en el detalle
- [ ] Tests unitarios para `PokemonRepository` y `PokemonDetail.fromJson`
- [ ] Migración a un gestor de estado (Riverpod / Bloc) cuando crezca la app

---

## Licencia

Este proyecto es de uso educativo y está disponible bajo la licencia [MIT](LICENSE).

> Los datos y sprites son provistos por [PokéAPI](https://pokeapi.co/) y son propiedad de Nintendo / Game Freak.
