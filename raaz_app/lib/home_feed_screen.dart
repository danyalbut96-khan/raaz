import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'skeleton_loading_screen.dart';
import 'post_details_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'data/models/post_model.dart';
import 'data/models/category_model.dart';
import 'data/repositories/post_repository.dart';
import 'services/auth_service.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final _postRepo = PostRepository();
  final _scrollController = ScrollController();

  List<PostModel> _posts = [];
  List<PostModel> _featured = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _isPaginating = false;
  bool _hasMore = true;
  int _page = 0;
  String? _error;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await AuthService.ensureSignedIn();
    await Future.wait([_loadCategories(), _loadFeed(reset: true), _loadFeatured()]);
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _postRepo.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _loadFeatured() async {
    try {
      final featured = await _postRepo.getFeaturedPosts();
      if (mounted) setState(() => _featured = featured);
    } catch (_) {}
  }

  Future<void> _loadFeed({bool reset = false}) async {
    if (_isPaginating) return;

    if (reset) {
      setState(() { _isLoading = true; _page = 0; _hasMore = true; _error = null; });
    } else {
      setState(() => _isPaginating = true);
    }

    try {
      final posts = await _postRepo.getFeed(
        page: _page,
        pageSize: _pageSize,
        categoryId: _selectedCategoryId,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _posts = posts;
          } else {
            _posts.addAll(posts);
          }
          _hasMore = posts.length == _pageSize;
          _isLoading = false;
          _isPaginating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load posts. Pull to refresh.';
          _isLoading = false;
          _isPaginating = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (_hasMore && !_isPaginating) {
        _page++;
        _loadFeed();
      }
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _loadFeed(reset: true);
  }

  Future<void> _toggleReaction(int index, String type) async {
    try {
      await _postRepo.toggleReaction(_posts[index].id, type);
      // Optimistic update
      final post = _posts[index];
      final alreadyReacted = post.myReactionType == type;
      setState(() {
        _posts[index] = post.copyWith(
          reactionCount: alreadyReacted ? post.reactionCount - 1 : post.reactionCount + 1,
          myReactionType: alreadyReacted ? null : type,
          clearReaction: alreadyReacted,
        );
      });
    } catch (_) {}
  }

  void _showReactionPicker(int index) {
    final post = _posts[index];
    final primaryColor = const Color(0xFF004ac6);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('React to this post', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerItem(index, Icons.favorite, 'Care', '❤️', 'care', post.myReactionType, primaryColor),
                  _buildPickerItem(index, Icons.psychology, 'Insightful', '🧠', 'insightful', post.myReactionType, primaryColor),
                  _buildPickerItem(index, Icons.volunteer_activism, 'Support', '🤝', 'support', post.myReactionType, primaryColor),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerItem(int index, IconData icon, String label, String emoji, String type, String? myReactionType, Color primaryColor) {
    final isActive = myReactionType == type;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _toggleReaction(index, type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? primaryColor : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: isActive ? primaryColor : const Color(0xFF434655))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);

    if (_isLoading) return const SkeletonLoadingScreen();

    return Scaffold(
      backgroundColor: surfaceColor,
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => _loadFeed(reset: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: surfaceColor.withOpacity(0.85),
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.security, color: primaryColor),
                  const SizedBox(width: 8),
                  Text('RAAZ',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: -0.5)),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: onSurfaceVariant),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: onSurfaceVariant),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            // ── Category chips ────────────────────────────────
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildCategoryChip('All', isSelected: _selectedCategoryId == null,
                        onTap: () => _onCategorySelected(null)),
                    ..._categories.map((c) => _buildCategoryChip(
                      c.name,
                      isSelected: _selectedCategoryId == c.id,
                      onTap: () => _onCategorySelected(c.id),
                    )),
                  ],
                ),
              ),
            ),

            // ── Featured horizontal carousel ──────────────────
            if (_featured.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hot Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('View all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _buildFeaturedCard(_featured[i], primaryColor),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // ── Error banner ─────────────────────────────────
            if (_error != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.wifi_off, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ]),
                ),
              ),

            // ── Latest posts label ────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Latest Shares', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF141B2B))),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Posts list ────────────────────────────────────
            _posts.isEmpty && !_isLoading
                ? SliverFillRemaining(child: _buildEmptyState(primaryColor))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i == _posts.length) {
                          return _isPaginating
                              ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : const SizedBox(height: 80);
                        }
                        return _buildPostCard(
                          _posts[i], i,
                          onSurfaceVariant: onSurfaceVariant,
                          outlineVariant: outlineVariant,
                          primaryColor: primaryColor,
                        );
                      },
                      childCount: _posts.length + 1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────

  Widget _buildCategoryChip(String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004ac6) : const Color(0xFFe1e8fd),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF434655),
                fontWeight: FontWeight.w500,
                fontSize: 14)),
      ),
    );
  }

  Widget _buildFeaturedCard(PostModel post, Color primaryColor) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFe9edff).withOpacity(0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(post.category?.name ?? 'Trending',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
            ]),
            const SizedBox(height: 8),
            Text(post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, height: 1.4)),
            const Spacer(),
            Text('${post.reactionCount + post.commentCount * 2} score',
                style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(PostModel post, int index,
      {required Color onSurfaceVariant, required Color outlineVariant, required Color primaryColor}) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                            color: Color(0xFFd8e2ff), shape: BoxShape.circle),
                        child: const Icon(Icons.security, size: 18, color: Color(0xFF004ac6)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.pseudonym,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF141B2B))),
                            Text(
                              '${timeago.format(post.createdAt)}${post.category != null ? ' • ${post.category!.name}' : ''}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF737686)),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.more_horiz, color: outlineVariant),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(post.body,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF141B2B))),
                  if (post.mood != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFf1f3ff),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(post.mood!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF434655))),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              child: Row(
                children: [
                  // Reaction button — tap to open picker
                  GestureDetector(
                    onTap: () => _showReactionPicker(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: post.myReactionType != null ? const Color(0xFFd8e2ff) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        Icon(
                          _feedReactionIcon(post.myReactionType),
                          size: 20,
                          color: post.myReactionType != null ? const Color(0xFF004ac6) : onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.reactionCount}',
                            style: TextStyle(fontSize: 13, color: onSurfaceVariant)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(children: [
                    Icon(Icons.chat_bubble_outline, size: 18, color: onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}',
                        style: TextStyle(fontSize: 13, color: onSurfaceVariant)),
                  ]),
                  const Spacer(),
                  Icon(Icons.ios_share, size: 18, color: outlineVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: primaryColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No posts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Be the first to share your RAAZ',
              style: TextStyle(fontSize: 14, color: Color(0xFF737686))),
        ],
      ),
    );
  }

  IconData _feedReactionIcon(String? type) {
    switch (type) {
      case 'care': return Icons.favorite;
      case 'insightful': return Icons.psychology;
      case 'support': return Icons.volunteer_activism;
      default: return Icons.favorite_border;
    }
  }
}
