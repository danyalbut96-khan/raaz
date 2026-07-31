import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'services/draft_database_service.dart';
import 'create_post_screen.dart';

class DraftManagerScreen extends StatefulWidget {
  const DraftManagerScreen({super.key});

  @override
  State<DraftManagerScreen> createState() => _DraftManagerScreenState();
}

class _DraftManagerScreenState extends State<DraftManagerScreen> {
  List<Map<String, dynamic>> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final drafts = await DraftDatabaseService.getAllDrafts();
    if (mounted) setState(() { _drafts = drafts; _isLoading = false; });
  }

  Future<void> _deleteDraft(int index) async {
    final id = _drafts[index]['id'] as String;
    await DraftDatabaseService.deleteDraft(id);
    setState(() => _drafts.removeAt(index));
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Drafts'),
        content: const Text('This will permanently delete all saved drafts. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear All', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DraftDatabaseService.clearAllDrafts();
      setState(() => _drafts.clear());
    }
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
        title: Text('Drafts', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          if (_drafts.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined, size: 64, color: primaryColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('No drafts saved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Your drafts will appear here', style: TextStyle(color: Color(0xFF737686))),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        children: [
                          Text('${_drafts.length} draft${_drafts.length > 1 ? 's' : ''} saved',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF737686))),
                          const Spacer(),
                          Text('Max 10 per device', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _drafts.length,
                        itemBuilder: (_, i) {
                          final d = _drafts[i];
                          final updatedAt = DateTime.tryParse(d['updated_at'] as String? ?? '') ?? DateTime.now();
                          return Dismissible(
                            key: Key(d['id'] as String),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteDraft(i),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                  color: Colors.red, borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => CreatePostScreen(draft: d)));
                                _loadDrafts();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFd8e2ff),
                                              borderRadius: BorderRadius.circular(10)),
                                          child: Text(d['category_id'] != null ? 'Saved' : 'Draft',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF004ac6), fontWeight: FontWeight.w500)),
                                        ),
                                        const Spacer(),
                                        Text(timeago.format(updatedAt),
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF737686))),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      (d['body'] as String?) ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, height: 1.5),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: const [
                                        Icon(Icons.edit_outlined, size: 14, color: Color(0xFF737686)),
                                        SizedBox(width: 4),
                                        Text('Tap to edit', style: TextStyle(fontSize: 12, color: Color(0xFF737686))),
                                        Spacer(),
                                        Text('Swipe left to delete', style: TextStyle(fontSize: 11, color: Color(0xFFc3c6d7))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
