import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [
    {
      'name': 'Anonymous Fox',
      'nameColor': Color(0xFF004ac6),
      'avatarIcon': Icons.pets,
      'avatarBg': Color(0xFFd8e2ff),
      'avatarColor': Color(0xFF004ac6),
      'time': '2h ago',
      'content': "This is so brave. I've been holding onto a secret for three years now and seeing posts like this makes me feel like I might actually be able to breathe one day.",
      'likes': 24,
      'liked': false,
      'isNested': false,
    },
    {
      'name': 'Anonymous Leaf',
      'nameColor': Color(0xFF006874),
      'avatarIcon': Icons.eco,
      'avatarBg': Color(0xFFcce5ff),
      'avatarColor': Color(0xFF006874),
      'time': '1h ago',
      'content': "I promise you, the weight lifting is worth any initial awkwardness. Good luck!",
      'likes': 8,
      'liked': false,
      'isNested': true,
    },
    {
      'name': 'Anonymous Owl',
      'nameColor': Color(0xFF0058be),
      'avatarIcon': Icons.dark_mode,
      'avatarBg': Color(0xFFd3e4ff),
      'avatarColor': Color(0xFF0058be),
      'time': '45m ago',
      'content': "The relief is the best part. Even if things change, you're no longer living a lie or hiding. That's a win in my book.",
      'likes': 12,
      'liked': false,
      'isNested': false,
    },
    {
      'name': 'Anonymous Wave',
      'nameColor': Color(0xFF141b2b),
      'avatarIcon': Icons.waves,
      'avatarBg': Color(0xFFe3e3ed),
      'avatarColor': Color(0xFF434655),
      'time': '10m ago',
      'content': "Does anyone else feel like telling the truth is harder when it's positive? Like admitting you're happy when you should be sad?",
      'likes': 5,
      'liked': false,
      'isNested': false,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike(int index) {
    setState(() {
      _comments[index]['liked'] = !(_comments[index]['liked'] as bool);
      _comments[index]['likes'] += (_comments[index]['liked'] as bool) ? 1 : -1;
    });
  }

  void _postComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          'name': 'You (Anonymous)',
          'nameColor': const Color(0xFF004ac6),
          'avatarIcon': Icons.person,
          'avatarBg': const Color(0xFFd8e2ff),
          'avatarColor': const Color(0xFF004ac6),
          'time': 'Just now',
          'content': _commentController.text.trim(),
          'likes': 0,
          'liked': false,
          'isNested': false,
        });
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFF8FAFC);
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
        title: Text('Comments', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.5)),
        actions: [
          Icon(Icons.security, color: primaryColor),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Post Summary Header
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f3ff),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: outlineVariant.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48, height: 48,
                          color: const Color(0xFFdce2f7),
                          child: const Icon(Icons.image, color: Colors.black26),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('I finally told him how I feel...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 4),
                            Text("The response wasn't what I expected, but the relief of finally saying it is overwhelming.", style: TextStyle(fontSize: 13, color: Color(0xFF434655)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Section title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECENT SHARES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFF737686))),
                    Text('124 Comments', style: TextStyle(fontSize: 11, color: outlineVariant)),
                  ],
                ),
                const SizedBox(height: 12),

                // Comments list
                ...List.generate(_comments.length, (i) {
                  final c = _comments[i];
                  final bool isNested = c['isNested'] as bool;
                  return Padding(
                    padding: EdgeInsets.only(left: isNested ? 24.0 : 0, bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isNested
                            ? Border(left: BorderSide(color: outlineVariant.withOpacity(0.4), width: 2))
                            : Border.all(color: outlineVariant.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: c['avatarBg'] as Color, shape: BoxShape.circle),
                                child: Icon(c['avatarIcon'] as IconData, size: 16, color: c['avatarColor'] as Color),
                              ),
                              const SizedBox(width: 8),
                              Text(c['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: c['nameColor'] as Color, fontSize: 14)),
                              const Spacer(),
                              Text(c['time'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(c['content'] as String, style: const TextStyle(fontSize: 16, height: 1.5)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _toggleLike(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (c['liked'] as bool) ? const Color(0xFFd8e2ff) : const Color(0xFFf1f3ff),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        (c['liked'] as bool) ? Icons.favorite : Icons.favorite_border,
                                        size: 16,
                                        color: (c['liked'] as bool) ? Colors.red : const Color(0xFF434655),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${c['likes']}', style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.reply, size: 16, color: Color(0xFF434655)),
                                    SizedBox(width: 4),
                                    Text('Reply', style: TextStyle(fontSize: 13, color: Color(0xFF434655))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Comment input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.92),
                border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf1f3ff),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: outlineVariant.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Add an anonymous thought...',
                          hintStyle: TextStyle(color: outlineVariant, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _postComment,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
