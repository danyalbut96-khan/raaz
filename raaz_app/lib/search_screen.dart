import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';
import 'post_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _postRepo = PostRepository();
  final FocusNode _focusNode = FocusNode();

  List<String> _recentSearches = [];
  List<PostModel> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

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
    setState(() { _isSearching = true; _hasSearched = true; });
    _focusNode.unfocus();
    try {
      final results = await _postRepo.searchPosts(query.trim());
      if (mounted) setState(() { _results = results; _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() { _results = []; _isSearching = false; });
    }
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
                      onPressed: () {
                        _searchController.clear();
                        setState(() { _hasSearched = false; _results = []; });
                      },
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
          Expanded(
            child: _hasSearched ? _buildResults() : _buildDiscovery(),
          ),
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

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: _outlineVariant),
            const SizedBox(height: 16),
            const Text('No secrets found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _onSurface)),
            const SizedBox(height: 8),
            Text('Try searching with different keywords',
                style: const TextStyle(color: _onSurfaceVariant)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('${_results.length} results found',
              style: const TextStyle(fontSize: 14, color: _onSurfaceVariant)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (_, i) => _buildResultCard(_results[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(PostModel post) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: _primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.security, size: 16, color: _primary),
                ),
                const SizedBox(width: 8),
                Text(post.pseudonym,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _onSurface)),
                if (post.category != null) ...[
                  const SizedBox(width: 6),
                  Text('• ${post.category!.name}',
                      style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.5, color: _onSurface)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 14, color: _onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${post.reactionCount}', style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline, size: 14, color: _onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${post.commentCount}', style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
