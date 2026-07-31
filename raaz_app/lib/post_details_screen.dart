import 'package:flutter/material.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool _isLiked = false;
  int _likeCount = 42;
  bool _showShareSheet = false;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Post', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: onSurfaceVariant),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Post Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    border: Border.all(color: outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author row
                      Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.security, color: primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Anonymous Author', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Text('2 hours ago • Technology', style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      const Text(
                        'The unspoken anxiety of modern transparency.',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'In an era where every action is tracked and every thought is broadcasted, the value of true anonymity has shifted from a luxury to a necessity for mental preservation. We find ourselves curating versions of our lives that fit the algorithms rather than our actual experiences.',
                        style: TextStyle(fontSize: 16, color: onSurfaceVariant, height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      // Image placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 220,
                          color: const Color(0xFFdce2f7),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.image, size: 64, color: Colors.black12),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [primaryColor.withOpacity(0.2), const Color(0xFF0058be).withOpacity(0.3)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This platform, RAAZ, represents the friction against that trend. It\'s a space where the weight of identity is lifted, allowing for raw, unfiltered human connection without the fear of social repercussion.',
                        style: TextStyle(fontSize: 16, color: onSurfaceVariant, height: 1.6),
                      ),
                      Divider(color: outlineVariant.withOpacity(0.3), height: 32),
                      // Reactions row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildReactionChip(Icons.favorite, '$_likeCount Care', isActive: _isLiked, onTap: _toggleLike),
                            const SizedBox(width: 8),
                            _buildReactionChip(Icons.psychology, '18 Insightful', onTap: () {}),
                            const SizedBox(width: 8),
                            _buildReactionChip(Icons.volunteer_activism, '31 Support', onTap: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Comments section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Comments (12)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.sort, size: 16, color: primaryColor),
                      label: Text('Newest', style: TextStyle(color: primaryColor, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Comments
                _buildComment(
                  name: 'Anonymous User 1',
                  nameColor: primaryColor,
                  time: '45m ago',
                  content: 'This resonates deeply. I feel like I\'m constantly performing for an audience that doesn\'t actually exist. Being able to just share a thought here without my face attached is a relief.',
                  likes: '12',
                  indented: false,
                ),
                _buildComment(
                  name: 'Anonymous User 2',
                  nameColor: const Color(0xFF0058be),
                  time: '1h ago',
                  content: 'The "algorithm curation" part is so true. Everything is optimized for engagement now, not authenticity. Thanks for putting this into words.',
                  likes: '8',
                  indented: true,
                ),
                _buildComment(
                  name: 'Anonymous User 3',
                  nameColor: const Color(0xFF006874),
                  time: '1.5h ago',
                  content: 'I often wonder if total transparency actually leads to less understanding because people are too afraid to be misunderstood.',
                  likes: '5',
                  indented: false,
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // Share Sheet overlay
          if (_showShareSheet) ...[
            GestureDetector(
              onTap: () => setState(() => _showShareSheet = false),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildShareSheet(context, primaryColor),
            ),
          ],

          // Floating Share button
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => setState(() => _showShareSheet = true),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.share),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.9),
            border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f3ff),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: outlineVariant.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: outlineVariant, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.alternate_email, color: primaryColor, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionChip(IconData icon, String label, {bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? const Color(0xFF004ac6) : const Color(0xFF434655)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, color: isActive ? const Color(0xFF004ac6) : const Color(0xFF434655))),
          ],
        ),
      ),
    );
  }

  Widget _buildComment({required String name, required Color nameColor, required String time, required String content, required String likes, required bool indented}) {
    return Container(
      margin: EdgeInsets.only(left: indented ? 16 : 0, right: indented ? 0 : 16, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: indented ? Border(left: BorderSide(color: const Color(0xFF004ac6).withOpacity(0.3), width: 4)) : Border.all(color: const Color(0xFFe9edff).withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: nameColor, fontSize: 14)),
              Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF434655), height: 1.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(likes, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              const SizedBox(width: 16),
              Text('Reply', style: TextStyle(fontSize: 12, color: const Color(0xFF004ac6), fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareSheet(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Share this RAAZ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareOption(Icons.link, 'Link', () {}),
              _buildShareOption(Icons.chat_bubble, 'Messenger', () {}),
              _buildShareOption(Icons.send, 'WhatsApp', () {}),
              _buildShareOption(Icons.more_horiz, 'More', () {}),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _showShareSheet = false),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFf1f3ff),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close', style: TextStyle(fontSize: 16, color: Color(0xFF434655))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFFf1f3ff), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF004ac6)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF434655))),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.bookmark_border), title: const Text('Bookmark'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.report_outlined), title: const Text('Report'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.block), title: const Text('Block'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
