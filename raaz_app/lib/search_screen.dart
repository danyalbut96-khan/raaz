import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _recentSearches = [];

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  final List<Map<String, String>> _suggestedCategories = [
    {'name': 'Night Life', 'sub': 'Confessions Nocturnes'},
    {'name': 'Career', 'sub': 'Work & Ambition'},
    {'name': 'Deep Connections', 'sub': 'Relationships & Feelings'},
    {'name': 'Mental Health', 'sub': 'Mind & Wellness'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches = _recentSearches.sublist(0, 8);
    await prefs.setStringList('recent_searches', _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  Future<void> _removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    await prefs.setStringList('recent_searches', _recentSearches);
    setState(() {});
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    await _saveSearch(query.trim());
    _focusNode.unfocus();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsScreen(query: query.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.security, color: _primary, size: 22),
            const SizedBox(width: 8),
            const Text('RAAZ', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: _primary, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: _onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: _onSurfaceVariant, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onSubmitted: _performSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search secrets...',
                        hintStyle: TextStyle(color: _outlineVariant, fontSize: 15),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 15, color: _onSurface),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: _onSurfaceVariant),
                      onPressed: () => _searchController.clear(),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.mic_none, size: 20, color: _onSurfaceVariant),
                      onPressed: () {},
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildDiscovery()),
        ],
      ),
    );
  }

  Widget _buildDiscovery() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Searches',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _onSurface)),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: const Text('Clear all', style: TextStyle(color: _primary, fontSize: 13)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((q) => GestureDetector(
                  onTap: () {
                    _searchController.text = q;
                    _performSearch(q);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _outlineVariant.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(q, style: const TextStyle(fontSize: 13, color: _onSurface)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _removeSearch(q),
                          child: const Icon(Icons.close, size: 14, color: _onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Suggested categories
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Suggested Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _onSurface)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_suggestedCategories.length, (i) {
                final cat = _suggestedCategories[i];
                final isWide = i == _suggestedCategories.length - 1;
                return GestureDetector(
                  onTap: () {
                    _searchController.text = cat['name']!;
                    _performSearch(cat['name']!);
                  },
                  child: Container(
                    width: isWide
                        ? double.infinity
                        : (MediaQuery.of(context).size.width - 42) / 2,
                    height: isWide ? 90 : 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF001e6e).withOpacity(0.85 - i * 0.1),
                          const Color(0xFF00438a).withOpacity(0.7 - i * 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(cat['name']!,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text(cat['sub']!,
                              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 40),

          // Anonymous search badge
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security, size: 36, color: _primary),
                ),
                const SizedBox(height: 16),
                const Text('Search anonymously',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _onSurface)),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Your search history is encrypted and private.\nNo one can track what you are looking for.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _searchController.text = '';
                    _focusNode.requestFocus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Browse Global Secrets', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
