import 'package:flutter/material.dart';
import 'skeleton_loading_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate network fetch
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
    final Color surfaceContainerLowest = Colors.white;
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);

    if (_isLoading) {
      return const SkeletonLoadingScreen();
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.security, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'RAAZ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildCategoryChip('All', isSelected: true),
                  _buildCategoryChip('Confessions'),
                  _buildCategoryChip('Questions'),
                  _buildCategoryChip('Rants'),
                  _buildCategoryChip('Life'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Trending Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hot Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('View all', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTrendingCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.red,
                    category: 'Trending in Rants',
                    content: '"I just realized that I\'ve been working the wrong career for 10 years and I\'m too scared to quit..."',
                    stats: '2.4k engagements',
                  ),
                  const SizedBox(width: 16),
                  _buildTrendingCard(
                    icon: Icons.trending_up,
                    iconColor: primaryColor,
                    category: 'Trending in Questions',
                    content: '"What is the one secret you\'ll take to your grave? No judgments here."',
                    stats: '1.8k comments',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Latest Posts Feed
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Latest Shares', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            
            // Post 1
            _buildPostCard(
              avatarIcon: Icons.person,
              author: 'Anonymous Owl',
              timeAndCategory: '12m ago • Confessions',
              content: "I found a stray kitten in the rain today and couldn't leave it there. My apartment doesn't allow pets, so I'm currently hiding a tiny fluff ball in my bathroom. He's sleeping in a shoebox and I've never felt more alive.",
              likes: '342',
              comments: '24',
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
              outlineVariant: outlineVariant,
            ),
            
            // Post 2 (With Image Placeholder)
            _buildPostCard(
              avatarIcon: Icons.mood,
              avatarColor: const Color(0xFF00569c),
              author: 'Midnight Rambler',
              timeAndCategory: '45m ago • Life',
              content: "The view from the rooftop tonight is everything I needed. Sometimes you just have to look at the city lights and realize how small your problems really are.",
              hasImage: true,
              likes: '892',
              comments: '56',
              surfaceContainerLowest: surfaceContainerLowest,
              onSurfaceVariant: onSurfaceVariant,
              outlineVariant: outlineVariant,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF004ac6) : const Color(0xFFe1e8fd),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF434655),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTrendingCard({
    required IconData icon,
    required Color iconColor,
    required String category,
    required String content,
    required String stats,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFc3c6d7).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 4),
              Text(category, style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(stats, style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required IconData avatarIcon,
    Color avatarColor = const Color(0xFFd8e2ff),
    required String author,
    required String timeAndCategory,
    required String content,
    bool hasImage = false,
    required String likes,
    required String comments,
    required Color surfaceContainerLowest,
    required Color onSurfaceVariant,
    required Color outlineVariant,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(avatarIcon, size: 16, color: Colors.black54),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(author, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text(timeAndCategory, style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
                          ],
                        ),
                      ],
                    ),
                    Icon(Icons.more_horiz, color: outlineVariant),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          if (hasImage)
            Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFdce2f7),
              child: const Center(
                child: Icon(Icons.image, size: 48, color: Colors.black26),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 20, color: onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(likes, style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20, color: onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(comments, style: TextStyle(fontSize: 14, color: onSurfaceVariant)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.ios_share, size: 20, color: onSurfaceVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
