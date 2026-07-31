import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';
import 'core/supabase_client.dart';
import 'post_details_screen.dart';
import 'create_post_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with SingleTickerProviderStateMixin {
  final _postRepo = PostRepository();
  late final TabController _tabController;

  List<PostModel> _trendingPosts = [];
  List<Map<String, dynamic>> _categoryStats = []; // Real category data
  bool _isLoading = true;
  bool _isCatsLoading = true;
  String? _error;

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  // Colors per category index
  static const List<Color> _catColors = [
    Color(0xFF004ac6), Color(0xFF6750a4), Color(0xFF006874),
    Color(0xFF9c4221), Color(0xFF1a6b3c), Color(0xFF7a2f8a),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrending();
    _loadCategoryStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final posts = await _postRepo.getFeed(trending: true, pageSize: 30);
      if (mounted) setState(() { _trendingPosts = posts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load trending posts.'; _isLoading = false; });
    }
  }

  Future<void> _loadCategoryStats() async {
    setState(() => _isCatsLoading = true);
    try {
      // Get all categories with post counts
      final res = await supabase
          .from('categories')
          .select('id, name, icon')
          .order('sort_order');
      final cats = (res as List).cast<Map<String, dynamic>>();

      // For each category get post count
      final List<Map<String, dynamic>> stats = [];
      for (final cat in cats) {
        final countRes = await supabase
            .from('posts')
            .select('id', const FetchOptions(count: CountOption.exact))
            .eq('category_id', cat['id'])
            .eq('is_deleted', false);
        final count = countRes.count ?? 0;
        stats.add({
          'id': cat['id'],
          'name': cat['name'],
          'count': count,
        });
      }
      // Sort by count desc
      stats.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      if (mounted) setState(() { _categoryStats = stats; _isCatsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isCatsLoading = false);
    }
  }

  Future<void> _toggleReaction(int index, String type) async {
    try {
      await _postRepo.toggleReaction(_trendingPosts[index].id, type);
      final post = _trendingPosts[index];
      final alreadyReacted = post.myReactionType == type;
      setState(() {
        _trendingPosts[index] = post.copyWith(
          reactionCount: alreadyReacted ? post.reactionCount - 1 : post.reactionCount + 1,
          myReactionType: alreadyReacted ? null : type,
          clearReaction: alreadyReacted,
        );
      });
    } catch (_) {}
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
            icon: const Icon(Icons.notifications_none_outlined, color: _onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: _onSurfaceVariant,
          indicatorColor: _primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildCategoriesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostsTab() {
    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadTrending,
      child: CustomScrollView(
        slivers: [
          // Trending Topics Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Text('Trending Topics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: _categoryStats.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categoryStats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final cat = _categoryStats[i];
                        final color = _catColors[i % _catColors.length];
                        return _buildTopicCard(
                          tag: '#${(cat['name'] as String).replaceAll(' ', '')}',
                          count: cat['count'] as int,
                          color: color,
                        );
                      },
                    ),
            ),
          ),

          // Top Shares header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Top Shares',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface)),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004ac6).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.trending_up, size: 14, color: _primary),
                            SizedBox(width: 4),
                            Text('Global Heat', style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Posts or loading state
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 48, color: _outlineVariant),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: _onSurfaceVariant)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadTrending, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else if (_trendingPosts.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No trending posts right now.',
                  style: TextStyle(color: _onSurfaceVariant))),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i == _trendingPosts.length) return const SizedBox(height: 80);
                  return _buildTrendingPostCard(_trendingPosts[i], i);
                },
                childCount: _trendingPosts.length + 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_isCatsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_categoryStats.isEmpty) {
      return const Center(child: Text('No categories found.', style: TextStyle(color: _onSurfaceVariant)));
    }

    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadCategoryStats,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: _categoryStats.length,
        itemBuilder: (_, i) {
          final cat = _categoryStats[i];
          final color = _catColors[i % _catColors.length];
          final count = cat['count'] as int;
          String countStr;
          if (count >= 1000) {
            countStr = '${(count / 1000).toStringAsFixed(1)}k';
          } else {
            countStr = '$count';
          }
          return GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tag, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(cat['name'] as String,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _onSurface)),
                  const SizedBox(height: 2),
                  Text('$countStr shares',
                      style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat['icon'] as IconData, color: color, size: 22),
                  ),
                  const Spacer(),
                  Text(cat['name'] as String,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _onSurface)),
                  const SizedBox(height: 2),
                  Text('${cat['posts']} shares',
                      style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicCard({required String tag, required int count, required Color color}) {
    String countStr = count >= 1000
        ? '${(count / 1000).toStringAsFixed(1)}k'
        : '$count';
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tag,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('$countStr shares',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingPostCard(PostModel post, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category + time
              Row(
                children: [
                  if (post.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('#${post.category!.name.replaceAll(' ', '')}',
                          style: const TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time, size: 12, color: _onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(timeago.format(post.createdAt),
                      style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
                  const Spacer(),
                  const Icon(Icons.more_horiz, color: _outlineVariant),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, height: 1.55, color: _onSurface)),
              const SizedBox(height: 14),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleReaction(index, 'care'),
                    child: Row(children: [
                      Icon(
                        post.myReactionType != null ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.myReactionType != null ? Colors.red : _onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.reactionCount}',
                          style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                    ]),
                  ),
                  const SizedBox(width: 20),
                  Row(children: [
                    const Icon(Icons.chat_bubble_outline, size: 16, color: _onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}',
                        style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                  ]),
                  const Spacer(),
                  const Icon(Icons.ios_share, size: 16, color: _outlineVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
