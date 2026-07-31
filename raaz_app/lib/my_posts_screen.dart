import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data/models/post_model.dart';
import 'data/repositories/post_repository.dart';
import 'post_details_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _postRepo = PostRepository();
  
  List<PostModel> _publishedPosts = [];
  bool _isLoading = true;

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postRepo.getMyPosts();
      if (mounted) setState(() { _publishedPosts = posts; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPostOptions(PostModel post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: _onSurface),
              title: const Text('Edit Post'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit screen if implemented
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Post'),
                    content: const Text('Are you sure you want to delete this post? This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await _postRepo.deletePost(post.id);
                    setState(() => _publishedPosts.removeWhere((p) => p.id == post.id));
                  } catch (_) {}
                }
              },
            ),
          ],
        ),
      ),
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
            icon: const Icon(Icons.notifications_none_outlined, color: _onSurfaceVariant),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF004ac6), shape: BoxShape.circle),
            child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('My Posts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _onSurface)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Manage your anonymous shares and drafts', style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: _primary,
            unselectedLabelColor: _onSurfaceVariant,
            indicatorColor: _primary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: [
              const Tab(text: 'Published'),
              const Tab(text: 'Drafts'),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Scheduled', style: TextStyle(color: _outlineVariant)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFe9edf8), borderRadius: BorderRadius.circular(10)),
                      child: const Text('COMING SOON', style: TextStyle(fontSize: 8, color: _onSurfaceVariant, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPublishedTab(),
                _buildDraftsTab(),
                const Center(child: Text('Scheduled Posts Coming Soon', style: TextStyle(color: _onSurfaceVariant))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_publishedPosts.isEmpty) {
      return const Center(
        child: Text('No published posts yet', style: TextStyle(color: _onSurfaceVariant)),
      );
    }
    return RefreshIndicator(
      color: _primary,
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _publishedPosts.length,
        itemBuilder: (context, i) {
          final post = _publishedPosts[i];
          return _buildMyPostCard(post);
        },
      ),
    );
  }

  Widget _buildDraftsTab() {
    return const Center(
      child: Text('No drafts yet', style: TextStyle(color: _onSurfaceVariant)),
    );
  }

  Widget _buildMyPostCard(PostModel post) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 4, 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Published ${timeago.format(post.createdAt)}', style: const TextStyle(fontSize: 13, color: _onSurfaceVariant, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: _onSurfaceVariant, size: 20),
                    onPressed: () => _showPostOptions(post),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post.body, style: const TextStyle(fontSize: 15, height: 1.5, color: _onSurface)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.favorite_border, size: 16, color: _onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${post.reactionCount}', style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 16, color: _onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: const TextStyle(fontSize: 13, color: _onSurfaceVariant)),
                  const Spacer(),
                  if (post.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Text('#${post.category!.name.replaceAll(' ', '')}', style: const TextStyle(fontSize: 11, color: _primary, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
