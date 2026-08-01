import 'package:flutter/material.dart';
import 'data/models/post_model.dart';
import 'post_details_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.results,
    this.isLoading = false,
  });

  final String query;
  final List<PostModel> results;
  final bool isLoading;

  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface)),
            Text('"$query"', style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : results.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('${results.length} results found',
                            style: const TextStyle(fontSize: 14, color: _onSurfaceVariant)),
                      );
                    }
                    return _buildResultCard(context, results[index - 1]);
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Color(0xFFc3c6d7)),
          const SizedBox(height: 16),
          const Text('No secrets found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _onSurface)),
          const SizedBox(height: 8),
          Text('No results for "$query"',
              style: const TextStyle(color: _onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: post.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security, size: 16, color: _primary),
                ),
                const SizedBox(width: 8),
                Text(post.pseudonym,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: _onSurface)),
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
                Text('${post.reactionCount}',
                    style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline, size: 14, color: _onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${post.commentCount}',
                    style: const TextStyle(fontSize: 12, color: _onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
