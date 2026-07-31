import 'package:flutter/material.dart';
import 'data/models/post_model.dart';
import 'data/models/category_model.dart';
import 'data/repositories/post_repository.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _textController;
  final _postRepo = PostRepository();

  String? _selectedCategoryId;
  String? _selectedMood;

  bool _allowComments = true;
  bool _externalSharing = true;
  bool _ghostMode = false;

  bool _isUpdating = false;
  List<CategoryModel> _categories = [];

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '🤔', 'label': 'Pensive'},
    {'emoji': '🔥', 'label': 'Fired Up'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '🤯', 'label': 'Mind Blown'},
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.post.body);
    _selectedCategoryId = widget.post.categoryId;
    _selectedMood = widget.post.mood;
    _allowComments = widget.post.allowComments;
    _externalSharing = widget.post.allowSharing;
    _ghostMode = widget.post.isGhostMode;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _postRepo.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_selectedCategoryId == null) return;
    setState(() => _isUpdating = true);
    
    try {
      await _postRepo.updatePost(
        postId: widget.post.id,
        body: _textController.text.trim(),
        categoryId: _selectedCategoryId,
        mood: _selectedMood,
        ghostMode: _ghostMode,
        allowComments: _allowComments,
        allowSharing: _externalSharing,
      );
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!'), behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update post.'), behavior: SnackBarBehavior.floating),
        );
      }
    }
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
          icon: Icon(Icons.close, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Post', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isUpdating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update Post', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Editor Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Secret Thoughts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts anonymously...',
                      hintStyle: TextStyle(color: outlineVariant),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    onChanged: (v) => setState(() {}),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${_textController.text.length} / 500', style: TextStyle(fontSize: 11, color: outlineVariant)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Required', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSelected = _selectedCategoryId == c.id;
                  return ChoiceChip(
                    label: Text(c.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategoryId = c.id);
                    },
                    selectedColor: primaryColor.withOpacity(0.1),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? primaryColor : outlineVariant.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Mood Selector
            const Text('Current Mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(12)),
              child: Wrap(
                spacing: 8,
                children: _moods.map((m) {
                  final isSelected = _selectedMood == m['label'];
                  return ChoiceChip(
                    label: Text('${m['emoji']} ${m['label']}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMood = selected ? m['label'] : null;
                      });
                    },
                    selectedColor: const Color(0xFFd8e2ff),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? primaryColor : outlineVariant.withOpacity(0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Privacy Toggles
            const Text('Privacy Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildPrivacyToggle(
              icon: Icons.chat_bubble_outline,
              title: 'Allow Comments',
              subtitle: 'Let others respond to your secret',
              value: _allowComments,
              onChanged: (v) => setState(() => _allowComments = v),
              isFirst: true,
              isLast: false,
            ),
            _buildPrivacyToggle(
              icon: Icons.share,
              title: 'External Sharing',
              subtitle: 'Allow users to share this outside RAAZ',
              value: _externalSharing,
              onChanged: (v) => setState(() => _externalSharing = v),
              isFirst: false,
              isLast: false,
            ),
            _buildPrivacyToggle(
              icon: Icons.visibility_off,
              title: 'Ghost Mode',
              subtitle: "Your post won't appear in Trending lists",
              value: _ghostMode,
              onChanged: (v) => setState(() => _ghostMode = v),
              isFirst: false,
              isLast: true,
            ),

            const SizedBox(height: 32),

            // Delete Button
            Divider(color: outlineVariant.withOpacity(0.3)),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => _showDeleteDialog(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete Post Permanently', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 12 : 0),
          topRight: Radius.circular(isFirst ? 12 : 0),
          bottomLeft: Radius.circular(isLast ? 12 : 0),
          bottomRight: Radius.circular(isLast ? 12 : 0),
        ),
        border: Border(bottom: isLast ? BorderSide.none : BorderSide(color: const Color(0xFFe9edff), width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF434655)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF004ac6)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('This action cannot be undone. Your post will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
