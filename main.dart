import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const GCommandCenterApp());
}

class GCommandCenterApp extends StatelessWidget {
  const GCommandCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'G-Command Center',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58A6FF),
          brightness: Brightness.dark,
          surface: const Color(0xFF0B0F14),
        ),
        scaffoldBackgroundColor: const Color(0xFF05070A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF05070A),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF0E131A),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0E131A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      LibraryPage(),
      DiscoveryPage(),
      StatsPage(),
      WatchlistPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('G-Command Center'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _index = 0),
            icon: const Icon(Icons.local_movies_outlined),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_movies_outlined),
            selectedIcon: Icon(Icons.local_movies),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discovery',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}

enum ViewMode { grid, list }

class MediaItem {
  final int id;
  final String tipo;
  final String titulo;
  final String normalizedTitle;
  final double notaG;
  final int? ano;
  final String genero;
  final String saga;
  final int? sagaOrder;
  final String director;
  final String productora;
  final String sinopsis;
  final int presupuesto;
  final int ingresos;
  final String? posterUrl;
  final int? tmdbId;
  final bool visto;
  final bool isNew;
  final bool isUpdated;
  final int? manualRank;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MediaItem({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.normalizedTitle,
    required this.notaG,
    required this.ano,
    required this.genero,
    required this.saga,
    required this.sagaOrder,
    required this.director,
    required this.productora,
    required this.sinopsis,
    required this.presupuesto,
    required this.ingresos,
    required this.posterUrl,
    required this.tmdbId,
    required this.visto,
    required this.isNew,
    required this.isUpdated,
    required this.manualRank,
    required this.createdAt,
    required this.updatedAt,
  });

  MediaItem copyWith({
    int? id,
    String? tipo,
    String? titulo,
    String? normalizedTitle,
    double? notaG,
    int? ano,
    String? genero,
    String? saga,
    int? sagaOrder,
    String? director,
    String? productora,
    String? sinopsis,
    int? presupuesto,
    int? ingresos,
    String? posterUrl,
    int? tmdbId,
    bool? visto,
    bool? isNew,
    bool? isUpdated,
    int? manualRank,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      normalizedTitle: normalizedTitle ?? this.normalizedTitle,
      notaG: notaG ?? this.notaG,
      ano: ano ?? this.ano,
      genero: genero ?? this.genero,
      saga: saga ?? this.saga,
      sagaOrder: sagaOrder ?? this.sagaOrder,
      director: director ?? this.director,
      productora: productora ?? this.productora,
      sinopsis: sinopsis ?? this.sinopsis,
      presupuesto: presupuesto ?? this.presupuesto,
      ingresos: ingresos ?? this.ingresos,
      posterUrl: posterUrl ?? this.posterUrl,
      tmdbId: tmdbId ?? this.tmdbId,
      visto: visto ?? this.visto,
      isNew: isNew ?? this.isNew,
      isUpdated: isUpdated ?? this.isUpdated,
      manualRank: manualRank ?? this.manualRank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MediaItem.fromMap(Map<String, dynamic> m) {
    return MediaItem(
      id: _asInt(m['id']) ?? 0,
      tipo: (m['tipo'] ?? '') as String,
      titulo: (m['titulo'] ?? '') as String,
      normalizedTitle: (m['normalized_title'] ?? _normalizeTitle((m['titulo'] ?? '').toString()))
          .toString(),
      notaG: _asDouble(m['nota_g']) ?? 0.0,
      ano: _asInt(m['ano']),
      genero: (m['genero'] ?? 'N/A') as String,
      saga: (m['saga'] ?? 'Individual') as String,
      sagaOrder: _asInt(m['saga_order']),
      director: (m['director'] ?? 'N/A') as String,
      productora: (m['productora'] ?? 'N/A') as String,
      sinopsis: (m['sinopsis'] ?? '') as String,
      presupuesto: _asInt(m['presupuesto']) ?? 0,
      ingresos: _asInt(m['ingresos']) ?? 0,
      posterUrl: m['poster_url'] as String?,
      tmdbId: _asInt(m['tmdb_id']),
      visto: (m['visto'] ?? true) as bool,
      isNew: (m['is_new'] ?? false) as bool,
      isUpdated: (m['is_updated'] ?? false) as bool,
      manualRank: _asInt(m['manual_rank']),
      createdAt: _asDateTime(m['created_at']),
      updatedAt: _asDateTime(m['updated_at']),
    );
  }
}

class UpsertResult {
  final MediaItem item;
  final bool wasNew;
  final bool wasUpdated;
  final String message;

  const UpsertResult({
    required this.item,
    required this.wasNew,
    required this.wasUpdated,
    required this.message,
  });
}

class SagaGroup {
  final String key;
  final String title;
  final bool isSaga;
  final List<MediaItem> items;
  final int manualOrder;

  const SagaGroup({
    required this.key,
    required this.title,
    required this.isSaga,
    required this.items,
    required this.manualOrder,
  });

  SagaGroup copyWith({
    String? key,
    String? title,
    bool? isSaga,
    List<MediaItem>? items,
    int? manualOrder,
  }) {
    return SagaGroup(
      key: key ?? this.key,
      title: title ?? this.title,
      isSaga: isSaga ?? this.isSaga,
      items: items ?? this.items,
      manualOrder: manualOrder ?? this.manualOrder,
    );
  }
}

class GApi {
  static final _supabase = Supabase.instance.client;
  static const _tmdbKey = String.fromEnvironment('TMDB_API_KEY');

  static Future<List<MediaItem>> fetchAllMovies() async {
    const pageSize = 200;
    int from = 0;
    final all = <MediaItem>[];

    while (true) {
      final data = await _supabase
          .from('elementos_g')
          .select()
          .range(from, from + pageSize - 1);

      final page = (data as List)
          .map((e) => MediaItem.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      all.addAll(page);

      if (page.length < pageSize) break;
      from += pageSize;
    }

    return all;
  }

  static Future<String?> getAppState(String key) async {
    try {
      final data = await _supabase
          .from('app_state')
          .select('value')
          .eq('key', key)
          .limit(1);

      if (data is List && data.isNotEmpty) {
        final row = Map<String, dynamic>.from(data.first as Map);
        return row['value']?.toString();
      }
    } catch (_) {}
    return null;
  }

  static Future<void> setAppState(String key, String value) async {
    try {
      await _supabase.from('app_state').upsert({
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<void> insertHistory({
    required int itemId,
    required String action,
    double? oldRating,
    double? newRating,
    String? note,
  }) async {
    try {
      await _supabase.from('elementos_g_history').insert({
        'item_id': itemId,
        'action': action,
        'old_rating': oldRating,
        'new_rating': newRating,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<void> updateManualRank({
    required int id,
    required int manualRank,
  }) async {
    try {
      await _supabase.from('elementos_g').update({
        'manual_rank': manualRank,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> fetchTmdbData(
    String query,
    String tipo,
  ) async {
    if (_tmdbKey.isEmpty) return null;
    if (tipo == 'Libro') return null;

    try {
      final path = tipo == 'Pelicula' ? 'movie' : 'tv';

      final searchUrl = Uri.parse(
        'https://api.themoviedb.org/3/search/$path?api_key=$_tmdbKey&query=${Uri.encodeComponent(query)}&language=es-ES',
      );

      final searchRes = await http.get(searchUrl);
      if (searchRes.statusCode != 200) return null;

      final searchJson = jsonDecode(searchRes.body) as Map<String, dynamic>;
      final results = (searchJson['results'] as List?) ?? [];
      if (results.isEmpty) return null;

      final item = Map<String, dynamic>.from(results.first as Map);
      final id = item['id'];

      final detailUrl = Uri.parse(
        'https://api.themoviedb.org/3/$path/$id?api_key=$_tmdbKey&append_to_response=credits,videos&language=es-ES',
      );

      final detailRes = await http.get(detailUrl);
      if (detailRes.statusCode != 200) return null;

      final det = jsonDecode(detailRes.body) as Map<String, dynamic>;

      final fecha = det[tipo == 'Pelicula' ? 'release_date' : 'first_air_date']
          as String?;
      final ano = (fecha != null && fecha.length >= 4)
          ? int.tryParse(fecha.substring(0, 4))
          : null;

      final crew = ((det['credits'] as Map<String, dynamic>?)?['crew'] as List?) ?? [];
      final director = crew
          .map((e) => Map<String, dynamic>.from(e as Map))
          .firstWhere(
            (m) => m['job'] == 'Director',
            orElse: () => {'name': 'N/A'},
          )['name']
          .toString();

      final posterPath = det['poster_path'] as String?;
      int? sagaOrder;
      final belongsToCollection = det['belongs_to_collection'] as Map?;
      final sagaName = (belongsToCollection?['name'] ?? 'Individual').toString();

      if (belongsToCollection != null && belongsToCollection['id'] != null) {
        try {
          final collectionId = belongsToCollection['id'];
          final collectionUrl = Uri.parse(
            'https://api.themoviedb.org/3/collection/$collectionId?api_key=$_tmdbKey&language=es-ES',
          );
          final collectionRes = await http.get(collectionUrl);
          if (collectionRes.statusCode == 200) {
            final collectionJson =
                jsonDecode(collectionRes.body) as Map<String, dynamic>;
            final parts = (collectionJson['parts'] as List?) ?? [];
            final normalizedQueryTitle =
                _normalizeTitle((det[tipo == 'Pelicula' ? 'title' : 'name'] ?? '').toString());

            for (int i = 0; i < parts.length; i++) {
              final p = Map<String, dynamic>.from(parts[i] as Map);
              final partTitle = _normalizeTitle(
                (p['title'] ?? p['name'] ?? '').toString(),
              );
              if (partTitle == normalizedQueryTitle) {
                sagaOrder = i + 1;
                break;
              }
            }
          }
        } catch (_) {}
      }

      return {
        'tmdb_id': id,
        'titulo': (det[tipo == 'Pelicula' ? 'title' : 'name'] ?? query).toString(),
        'normalized_title': _normalizeTitle((det[tipo == 'Pelicula' ? 'title' : 'name'] ?? query).toString()),
        'ano': ano,
        'genero': ((det['genres'] as List?)?.isNotEmpty ?? false)
            ? (det['genres'][0] as Map)['name']
            : 'N/A',
        'director': director,
        'productora': ((det['production_companies'] as List?)?.isNotEmpty ?? false)
            ? ((det['production_companies'][0] as Map)['name'] ?? 'Independiente')
            : 'Independiente',
        'sinopsis': det['overview'] ?? '',
        'presupuesto': det['budget'] ?? 0,
        'ingresos': det['revenue'] ?? 0,
        'poster_url':
            posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null,
        'saga': sagaName,
        'saga_order': sagaOrder,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<UpsertResult> addOrUpdateMovie({
    required List<MediaItem> currentItems,
    required String title,
    required String tipo,
    required double notaG,
  }) async {
    final cleanTitle = title.trim();
    final normalized = _normalizeTitle(cleanTitle);

    MediaItem? existing;
    for (final item in currentItems) {
      if (_normalizeTitle(item.normalizedTitle) == normalized ||
          _normalizeTitle(item.titulo) == normalized) {
        existing = item;
        break;
      }
    }

    final meta = await fetchTmdbData(cleanTitle, tipo);

    if (existing != null) {
      if ((existing.notaG - notaG).abs() < 0.0001) {
        return UpsertResult(
          item: existing,
          wasNew: false,
          wasUpdated: false,
          message: 'Ya existía: sin cambios',
        );
      }

      try {
        await _supabase.from('elementos_g').update({
          'nota_g': notaG,
          'is_updated': true,
          'is_new': false,
          'updated_at': DateTime.now().toIso8601String(),
          'normalized_title': normalized,
        }).eq('id', existing.id);
      } catch (_) {}

      await insertHistory(
        itemId: existing.id,
        action: 'updated',
        oldRating: existing.notaG,
        newRating: notaG,
        note: cleanTitle,
      );

      return UpsertResult(
        item: existing.copyWith(
          notaG: notaG,
          isUpdated: true,
          isNew: false,
          updatedAt: DateTime.now(),
        ),
        wasNew: false,
        wasUpdated: true,
        message: 'Película actualizada',
      );
    }

    final insertMap = <String, dynamic>{
      'tipo': tipo,
      'titulo': meta?['titulo'] ?? cleanTitle,
      'normalized_title': meta?['normalized_title'] ?? normalized,
      'nota_g': notaG,
      'ano': meta?['ano'],
      'genero': meta?['genero'] ?? (tipo == 'Libro' ? 'Libro' : 'N/A'),
      'saga': meta?['saga'] ?? 'Individual',
      'saga_order': meta?['saga_order'],
      'director': meta?['director'] ?? 'N/A',
      'productora': meta?['productora'] ?? 'N/A',
      'sinopsis': meta?['sinopsis'] ?? '',
      'presupuesto': meta?['presupuesto'] ?? 0,
      'ingresos': meta?['ingresos'] ?? 0,
      'poster_url': meta?['poster_url'],
      'tmdb_id': meta?['tmdb_id'],
      'visto': true,
      'is_new': true,
      'is_updated': false,
      'manual_rank': _nextManualRank(currentItems),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _supabase
        .from('elementos_g')
        .insert(insertMap)
        .select()
        .single();

    final item = MediaItem.fromMap(Map<String, dynamic>.from(inserted));

    await insertHistory(
      itemId: item.id,
      action: 'added',
      oldRating: null,
      newRating: notaG,
      note: cleanTitle,
    );

    return UpsertResult(
      item: item,
      wasNew: true,
      wasUpdated: false,
      message: 'Nueva película agregada',
    );
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  ViewMode _viewMode = ViewMode.grid;
  String _sortBy = 'Nota';
  String _tipoFilter = 'Todos';
  int _gridColumns = 4;
  double _posterSize = 120;
  bool _onlyHigh = false;
  bool _isLoading = false;

  final List<MediaItem> _allItems = [];
  final Map<int, GlobalKey> _itemKeys = {};
  final List<SagaGroup> _groups = [];
  final Map<int, int> _rankMap = {};

  Timer? _searchDebounce;
  String _savedSearch = '';
  int? _highlightedId;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _savedSearch = await GApi.getAppState('recent_search') ?? '';
    if (_savedSearch.isNotEmpty) {
      _searchController.text = _savedSearch;
    }

    await _reloadAll();
    if (_savedSearch.isNotEmpty) {
      _performSearch(scroll: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _reloadAll() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final items = await GApi.fetchAllMovies();
      _allItems
        ..clear()
        ..addAll(items);

      _ensureKeys();
      _rebuildViewModels();
    } catch (e) {
      _showSnack('Error cargando: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _ensureKeys() {
    for (final item in _allItems) {
      _itemKeys.putIfAbsent(item.id, () => GlobalKey());
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {}
  }

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() => _status = message);
    _showSnack(message);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _groupKey(MediaItem item) {
    final saga = item.saga.trim();
    if (saga.isNotEmpty && saga.toLowerCase() != 'individual') {
      return _normalizeTitle(saga);
    }
    return _normalizeTitle(item.titulo);
  }

  String _groupTitle(MediaItem item) {
    final saga = item.saga.trim();
    if (saga.isNotEmpty && saga.toLowerCase() != 'individual') {
      return saga;
    }
    return item.titulo;
  }

  int _groupManualOrder(SagaGroup group) {
    return group.manualOrder;
  }

  int _compareManualRank(MediaItem a, MediaItem b) {
    final ra = a.manualRank ?? 9999999;
    final rb = b.manualRank ?? 9999999;
    return ra.compareTo(rb);
  }

  int _compareBasic(MediaItem a, MediaItem b) {
    if (_sortBy == 'Nota') {
      return b.notaG.compareTo(a.notaG);
    } else if (_sortBy == 'Año') {
      return (b.ano ?? 0).compareTo(a.ano ?? 0);
    } else if (_sortBy == 'Título') {
      return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
    } else if (_sortBy == 'Manual') {
      return _compareManualRank(a, b);
    }
    return b.notaG.compareTo(a.notaG);
  }

  int _internalSagaOrder(MediaItem a, MediaItem b) {
    final oa = _sequenceHint(a) ?? a.sagaOrder ?? a.ano ?? 999999;
    final ob = _sequenceHint(b) ?? b.sagaOrder ?? b.ano ?? 999999;
    if (oa != ob) return oa.compareTo(ob);
    return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
  }

  int? _sequenceHint(MediaItem item) {
    final title = _normalizeTitle(item.titulo);
    final numerals = {
      'i': 1,
      'ii': 2,
      'iii': 3,
      'iv': 4,
      'v': 5,
      'vi': 6,
      'vii': 7,
      'viii': 8,
      'ix': 9,
      'x': 10,
    };

    final digits = RegExp(r'(?:\b|[^\w])(\d{1,2})(?:\b|[^\w])')
        .firstMatch(title);
    if (digits != null) {
      return int.tryParse(digits.group(1)!);
    }

    final roman = RegExp(r'\b(i|ii|iii|iv|v|vi|vii|viii|ix|x)\b').firstMatch(title);
    if (roman != null) {
      return numerals[roman.group(1)!];
    }

    return null;
  }

  List<MediaItem> _applyFiltersAndSort(List<MediaItem> input) {
    final filtered = input.where((e) {
      final matchesType = _tipoFilter == 'Todos' || e.tipo == _tipoFilter;
      final matchesHigh = !_onlyHigh || e.notaG >= 7.0;
      return matchesType && matchesHigh;
    }).toList();

    filtered.sort(_compareBasic);
    return filtered;
  }

  List<SagaGroup> _buildGroups(List<MediaItem> sortedItems) {
    final map = LinkedHashMap<String, List<MediaItem>>();
    final titleByKey = <String, String>{};
    final sagaFlagByKey = <String, bool>{};

    for (final item in sortedItems) {
      final key = _groupKey(item);
      map.putIfAbsent(key, () => <MediaItem>[]);
      map[key]!.add(item);
      titleByKey[key] = _groupTitle(item);
      sagaFlagByKey[key] =
          item.saga.trim().isNotEmpty && item.saga.toLowerCase() != 'individual';
    }

    final groups = <SagaGroup>[];

    for (final entry in map.entries) {
      final items = [...entry.value];
      if (items.length > 1 || sagaFlagByKey[entry.key] == true) {
        items.sort(_internalSagaOrder);
      }

      final manualOrder = items
              .map((e) => e.manualRank ?? 9999999)
              .reduce(math.min);

      groups.add(
        SagaGroup(
          key: entry.key,
          title: titleByKey[entry.key] ?? entry.key,
          isSaga: sagaFlagByKey[entry.key] ?? false,
          items: items,
          manualOrder: manualOrder,
        ),
      );
    }

    if (_sortBy == 'Manual') {
      groups.sort((a, b) => a.manualOrder.compareTo(b.manualOrder));
    }

    return groups;
  }

  void _rebuildViewModels() {
    final visibleItems = _applyFiltersAndSort(_allItems);
    final rebuiltGroups = _buildGroups(visibleItems);

    _groups
      ..clear()
      ..addAll(rebuiltGroups);

    _rankMap.clear();
    var rank = 1;
    for (final group in _groups) {
      for (final item in group.items) {
        _rankMap[item.id] = rank++;
      }
    }

    for (final item in _allItems) {
      _itemKeys.putIfAbsent(item.id, () => GlobalKey());
    }

    if (_searchController.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(scroll: true);
      });
    }

    setState(() {});
  }

  Future<void> _refreshAll() async {
    await _reloadAll();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _savedSearch = value;
    GApi.setAppState('recent_search', value);
    setState(() {});

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _performSearch(scroll: true);
    });
  }

  double _searchScore(MediaItem item, String query) {
    final q = _normalizeTitle(query);
    if (q.isEmpty) return 0;

    final title = _normalizeTitle(item.titulo);
    final saga = _normalizeTitle(item.saga);

    if (title == q) return 1000;
    if (title.contains(q)) return 900;
    if (saga.isNotEmpty && saga.contains(q)) return 850;

    final qTokens = q.split(' ').where((e) => e.isNotEmpty).toList();
    final tTokens = <String>{...title.split(' '), ...saga.split(' ')};

    var matches = 0;
    for (final token in qTokens) {
      if (tTokens.any((t) => t.contains(token) || token.contains(t))) {
        matches++;
      }
    }

    if (matches > 0) return 100 + (matches * 20);
    return 0;
  }

  MediaItem? _findBestMatch(String query) {
    final visible = _applyFiltersAndSort(_allItems);
    if (visible.isEmpty) return null;

    final ranked = visible
        .map((item) => MapEntry(item, _searchScore(item, query)))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ranked.isNotEmpty ? ranked.first.key : null;
  }

  Future<void> _performSearch({required bool scroll}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() => _highlightedId = null);
      }
      return;
    }

    final match = _findBestMatch(query);
    if (match == null) {
      if (mounted) {
        setState(() => _highlightedId = null);
      }
      return;
    }

    if (mounted) {
      setState(() => _highlightedId = match.id);
    }

    if (scroll) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _scrollToItem(match.id);
    }
  }

  void _scrollToItem(int id) {
    final key = _itemKeys[id];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.12,
    );
  }

  Future<void> _openAddDialog() async {
    final titleController = TextEditingController();
    final ratingController = TextEditingController(text: '7.0');
    String tipo = 'Pelicula';

    final result = await showDialog<UpsertResult?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0E131A),
              title: const Text('Agregar / actualizar'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Lo que el viento se llevó',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tipo,
                      items: const [
                        DropdownMenuItem(value: 'Pelicula', child: Text('Película')),
                        DropdownMenuItem(value: 'Serie', child: Text('Serie')),
                        DropdownMenuItem(value: 'Libro', child: Text('Libro')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setLocal(() => tipo = v);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ratingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Puntaje',
                        hintText: '7.0',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Si ya existe por título normalizado, solo se actualiza el puntaje.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final score = double.tryParse(ratingController.text.trim());

                    if (title.isEmpty || score == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Título o puntaje inválido')),
                      );
                      return;
                    }

                    Navigator.pop(
                      context,
                      await GApi.addOrUpdateMovie(
                        currentItems: _allItems,
                        title: title,
                        tipo: tipo,
                        notaG: score,
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    ratingController.dispose();

    if (result == null) return;

    await _reloadAll();

    if (result.item.id != 0) {
      _highlightedId = result.item.id;
      _scrollToItem(result.item.id);
    }

    _setStatus(result.message);
  }

  Future<void> _persistManualOrder(List<SagaGroup> groups) async {
    var groupRank = 1;
    for (final group in groups) {
      for (final item in group.items) {
        await GApi.updateManualRank(id: item.id, manualRank: groupRank);
      }
      groupRank++;
    }

    await GApi.insertHistory(
      itemId: 0,
      action: 'reorder',
      note: 'Nuevo orden manual de sagas aplicado',
    );
  }

  void _reorderGroups(int oldIndex, int newIndex) {
    if (_sortBy != 'Manual') return;

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final moved = _groups.removeAt(oldIndex);
      _groups.insert(newIndex, moved);

      _rankMap.clear();
      var rank = 1;
      for (final group in _groups) {
        for (final item in group.items) {
          _rankMap[item.id] = rank++;
        }
      }
    });

    _persistManualOrder(_groups);
  }

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E131A), Color(0xFF071018)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biblioteca Central',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Búsqueda global, ranking, sagas agrupadas y edición manual.',
                  style: TextStyle(color: Colors.white.withOpacity(0.74)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Image.asset(
                'assets/app_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.white10,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined, size: 34),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onSubmitted: (_) => _performSearch(scroll: true),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
          hintText: 'Buscar película...',
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              SegmentedButton<ViewMode>(
                segments: const [
                  ButtonSegment(
                    value: ViewMode.grid,
                    label: Text('Grid'),
                    icon: Icon(Icons.grid_view_rounded),
                  ),
                  ButtonSegment(
                    value: ViewMode.list,
                    label: Text('Lista'),
                    icon: Icon(Icons.view_list_rounded),
                  ),
                ],
                selected: {_viewMode},
                onSelectionChanged: (s) => setState(() => _viewMode = s.first),
              ),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'Nota', child: Text('Orden: Nota')),
                  DropdownMenuItem(value: 'Año', child: Text('Orden: Año')),
                  DropdownMenuItem(value: 'Título', child: Text('Orden: Título')),
                  DropdownMenuItem(value: 'Manual', child: Text('Orden: Manual')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _sortBy = v);
                    _rebuildViewModels();
                  }
                },
              ),
              DropdownButton<String>(
                value: _tipoFilter,
                items: const [
                  DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                  DropdownMenuItem(value: 'Pelicula', child: Text('Película')),
                  DropdownMenuItem(value: 'Serie', child: Text('Serie')),
                  DropdownMenuItem(value: 'Libro', child: Text('Libro')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _tipoFilter = v);
                    _rebuildViewModels();
                  }
                },
              ),
              FilterChip(
                label: const Text('Solo +7.0'),
                selected: _onlyHigh,
                onSelected: (v) {
                  setState(() => _onlyHigh = v);
                  _rebuildViewModels();
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Agregar'),
                onPressed: _openAddDialog,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Columnas Grid: $_gridColumns'),
                    Slider(
                      value: _gridColumns.toDouble(),
                      min: 2,
                      max: 8,
                      divisions: 6,
                      onChanged: (v) {
                        setState(() => _gridColumns = v.round());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tamaño poster: ${_posterSize.toInt()}'),
                    Slider(
                      value: _posterSize,
                      min: 80,
                      max: 220,
                      divisions: 14,
                      onChanged: (v) {
                        setState(() => _posterSize = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _status,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCatalog() {
    final sortedVisible = _applyFiltersAndSort(_allItems);
    final groups = _buildGroups(sortedVisible);

    if (_sortBy == 'Manual') {
      return RefreshIndicator(
        onRefresh: _refreshAll,
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: groups.length,
          buildDefaultDragHandles: false,
          onReorder: _reorderGroups,
          itemBuilder: (context, index) {
            final group = groups[index];
            return _buildGroupBlock(
              group: group,
              index: index,
              reorderable: true,
              key: ValueKey('group-${group.key}'),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Resultados: ${sortedVisible.length}  |  Grupos: ${groups.length}',
                style: TextStyle(color: Colors.white.withOpacity(0.65)),
              ),
            );
          }

          final group = groups[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGroupBlock(
              group: group,
              index: index - 1,
              reorderable: false,
              key: ValueKey('group-${group.key}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupBlock({
    required SagaGroup group,
    required int index,
    required bool reorderable,
    required Key key,
  }) {
    return Card(
      key: key,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (group.isSaga)
                            const Chip(label: Text('Pertenece a saga')),
                          Chip(label: Text('${group.items.length} ítem(s)')),
                        ],
                      ),
                    ],
                  ),
                ),
                if (reorderable)
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.drag_handle_rounded),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _viewMode == ViewMode.grid
                  ? _buildGroupGrid(group)
                  : _buildGroupList(group),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupGrid(SagaGroup group) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _gridColumns.clamp(2, 8);
        final cardWidth = (constraints.maxWidth - (cols - 1) * 12) / cols;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: group.items.map((item) {
            final rank = _rankMap[item.id] ?? 0;
            return SizedBox(
              width: cardWidth,
              child: _AnimatedPosterCard(
                key: _itemKeys[item.id],
                item: item,
                rank: rank,
                isHighlighted: _highlightedId == item.id,
                onTap: () => _openDetail(item),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGroupList(SagaGroup group) {
    return Column(
      children: group.items.map((item) {
        final rank = _rankMap[item.id] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnimatedListRow(
            key: _itemKeys[item.id],
            item: item,
            rank: rank,
            posterSize: _posterSize,
            isHighlighted: _highlightedId == item.id,
            onTap: () => _openDetail(item),
          ),
        );
      }).toList(),
    );
  }

  void _openDetail(MediaItem item) {
    setState(() => _highlightedId = item.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F14),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _DetailSheet(
        item: item,
        rank: _rankMap[item.id] ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca Central'),
        actions: [
          IconButton(
            onPressed: _openAddDialog,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          IconButton(
            onPressed: _reloadAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBanner(),
            _buildSearchBar(),
            _buildControlPanel(),
            Expanded(
              child: _isLoading && _allItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCatalog(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPosterCard extends StatelessWidget {
  final MediaItem item;
  final int rank;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _AnimatedPosterCard({
    super.key,
    required this.item,
    required this.rank,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlighted ? const Color(0xFF58A6FF) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: item.posterUrl != null
                          ? Image.network(
                              item.posterUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  color: Colors.white10,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 42,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.white10,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 42,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _RankPill(rank: rank),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (item.isNew) const _StatusPill(text: 'Nueva'),
                          if (item.isUpdated) const _StatusPill(text: 'Actualizada'),
                          if (item.saga.trim().isNotEmpty &&
                              item.saga.toLowerCase() != 'individual')
                            const _StatusPill(text: 'Saga'),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.notaG.toStringAsFixed(1)} • ${item.ano ?? '—'}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedListRow extends StatelessWidget {
  final MediaItem item;
  final int rank;
  final double posterSize;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _AnimatedListRow({
    super.key,
    required this.item,
    required this.rank,
    required this.posterSize,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHighlighted ? const Color(0xFF58A6FF) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: posterSize * 0.72,
                          height: posterSize,
                          child: item.posterUrl != null
                              ? Image.network(
                                  item.posterUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: Colors.white10,
                                      child: const Icon(Icons.image_not_supported_outlined),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.white10,
                                  child: const Icon(Icons.image_not_supported_outlined),
                                ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _RankPill(rank: rank),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.ano ?? '—'} • ${item.genero} • ${item.director}',
                          style: TextStyle(color: Colors.white.withOpacity(0.75)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.sinopsis,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('⭐ ${item.notaG.toStringAsFixed(1)}')),
                            Chip(label: Text(item.tipo)),
                            if (item.isNew) const Chip(label: Text('Nueva')),
                            if (item.isUpdated) const Chip(label: Text('Actualizada')),
                            if (item.saga.trim().isNotEmpty &&
                                item.saga.toLowerCase() != 'individual')
                              const Chip(label: Text('Saga')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankPill extends StatelessWidget {
  final int rank;

  const _RankPill({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        '#$rank',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;

  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final MediaItem item;
  final int rank;

  const _DetailSheet({
    required this.item,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final roi = item.presupuesto > 0
        ? ((item.ingresos - item.presupuesto) / item.presupuesto) * 100
        : null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 130,
                    height: 195,
                    child: item.posterUrl != null
                        ? Image.network(
                            item.posterUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white10,
                            ),
                          )
                        : Container(color: Colors.white10),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '#$rank • ${item.ano ?? '—'} • ${item.genero}',
                        style: TextStyle(color: Colors.white.withOpacity(0.75)),
                      ),
                      const SizedBox(height: 6),
                      Text('Director: ${item.director}'),
                      const SizedBox(height: 6),
                      Text('Estudio: ${item.productora}'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text('⭐ ${item.notaG.toStringAsFixed(1)}')),
                          Chip(label: Text(item.saga)),
                          Chip(label: Text(item.tipo)),
                          if (item.isNew) const Chip(label: Text('Nueva')),
                          if (item.isUpdated) const Chip(label: Text('Actualizada')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              item.sinopsis,
              style: TextStyle(
                height: 1.45,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricBox(
                    title: 'Presupuesto',
                    value: 'S/ ${item.presupuesto}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBox(
                    title: 'Ingresos',
                    value: 'S/ ${item.ingresos}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricBox(
                    title: 'ROI',
                    value: roi == null ? 'N/A' : '${roi.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;

  const _MetricBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Discovery listo para búsquedas por director, estudio y franquicia.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aquí puedes conectar charts reales con fl_chart o Syncfusion.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Watchlist inteligente: ranking por saga, nota y pendiente de ver.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

int _nextManualRank(List<MediaItem> currentItems) {
  var maxRank = 0;
  for (final item in currentItems) {
    final r = item.manualRank ?? 0;
    if (r > maxRank) maxRank = r;
  }
  return maxRank + 1;
}

String _normalizeTitle(String input) {
  final s = input
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[áàäâãå]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'ñ'), 'n')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return s;
}