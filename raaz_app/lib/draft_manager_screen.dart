import 'package:flutter/material.dart';
import 'edit_post_screen.dart';

class DraftManagerScreen extends StatefulWidget {
  const DraftManagerScreen({super.key});

  @override
  State<DraftManagerScreen> createState() => _DraftManagerScreenState();
}

class _DraftManagerScreenState extends State<DraftManagerScreen> {
  final List<Map<String, dynamic>> _drafts = [
    {
      'category': 'Workplace',
      'categoryColor': Color(0xFF004ac6),
      'categoryBg': Color(0xFFd8e2ff),
      'time': '2h ago',
      'savedAt': '14:20',
      'content': "I've been noticing that the team culture is shifting lately. Everyone seems to be focused on individual metrics rather than...",
      'hasImage': false,
    },
    {
      'category': 'Life Hacks',
      'categoryColor': Color(0xFF00639c),
      'categoryBg': Color(0xFFcce5ff),
      'time': 'Yesterday',
      'savedAt': 'Mar 24',
      'content': "The secret to maintaining high energy throughout the day isn't caffeine, it's the timing of your deep work blocks and light exposure...",
      'hasImage': false,
    },
    {
      'category': 'Productivity',
      'categoryColor': Color(0xFF0058be),
      'categoryBg': Color(0xFFd3e4ff),
      'time': 'Mar 22',
      'savedAt': 'Mar 22',
      'content': "Morning routines are overrated if they don't include actual execution time. I've spent three weeks drafting this...",
      'hasImage': true,
    },
    {
      'category': 'Uncategorized',
      'categoryColor': Color(0xFF434655),
      'categoryBg': Color(0xFFe3e3ed),
      'time': '3 days ago',
      'savedAt': 'Mar 21',
      'content': "Random thought about why anonymity breeds both the worst and the best in human interaction. Is it the lack of consequence or...",
      'hasImage': false,
    },
  ];

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Drafts?'),
        content: const Text('All saved drafts will be deleted permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _drafts.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteDraft(int index) {
    setState(() => _drafts.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft deleted'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Drafts', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          Icon(Icons.security, color: primaryColor),
          const SizedBox(width: 16),
        ],
      ),
      body: _drafts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drafts_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No saved drafts', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_drafts.length} saved draft${_drafts.length > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF434655))),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: Icon(Icons.delete_sweep, size: 18, color: primaryColor),
                      label: Text('Clear All', style: TextStyle(color: primaryColor, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...List.generate(_drafts.length, (index) {
                  final draft = _drafts[index];
                  return Dismissible(
                    key: Key('draft_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    onDismissed: (_) => _deleteDraft(index),
                    child: _buildDraftCard(draft, primaryColor),
                  );
                }),

                // Footer message
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Your thoughts are safe and private.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> draft, Color primaryColor) {
    if (draft['hasImage'] == true) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 110,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFdce2f7),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
              child: const Center(child: Icon(Icons.image, size: 36, color: Colors.black26)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryBadge(draft),
                    const SizedBox(height: 8),
                    Text(draft['content'] as String, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(draft['time'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
                        Text('Edit', style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditPostScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryBadge(draft),
                Text(draft['time'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
              ],
            ),
            const SizedBox(height: 12),
            Text(draft['content'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFFe9edff)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 16, color: Color(0xFF737686)),
                    const SizedBox(width: 6),
                    Text('Last saved ${draft['savedAt']}', style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
                  ],
                ),
                Row(
                  children: [
                    Text('Continue', style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: primaryColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(Map<String, dynamic> draft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (draft['categoryBg'] as Color).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        draft['category'] as String,
        style: TextStyle(fontSize: 12, color: draft['categoryColor'] as Color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
