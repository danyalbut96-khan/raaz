import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _textController = TextEditingController(
    text:
        "I've always felt like I'm moving at a different speed than everyone else in the office. Sometimes it feels like I'm seeing the code in 4D while they're stuck in a spreadsheet. Is this what they call the \"flow state\" or am I just overcaffeinated again? ☕️💻",
  );

  String _selectedCategory = 'Work Life';
  String _selectedMood = '🤔';

  bool _allowComments = true;
  bool _externalSharing = false;
  bool _ghostMode = false;

  bool _isUpdating = false;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.work, 'label': 'Work Life'},
    {'icon': Icons.favorite, 'label': 'Relationships'},
    {'icon': Icons.lightbulb, 'label': 'Deep Thoughts'},
    {'icon': Icons.mood, 'label': 'Life Hack'},
  ];

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '🤔', 'label': 'Pensive'},
    {'emoji': '🔥', 'label': 'Fired Up'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '🤯', 'label': 'Mind Blown'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    setState(() => _isUpdating = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
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
              children: [
                ..._categories.map((cat) {
                  final bool isSelected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFd8e2ff) : const Color(0xFFe9edff),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'] as IconData, size: 16, color: isSelected ? primaryColor : onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(cat['label'] as String, style: TextStyle(fontSize: 14, color: isSelected ? primaryColor : onSurfaceVariant, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: outlineVariant), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.add, size: 16, color: outlineVariant), const SizedBox(width: 4), Text('More', style: TextStyle(fontSize: 14, color: outlineVariant))],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mood Selector
            const Text('Current Mood', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFf1f3ff), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _moods.map((mood) {
                  final bool isSelected = _selectedMood == mood['emoji'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood['emoji']!),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                            border: isSelected ? Border.all(color: primaryColor, width: 2) : null,
                          ),
                          child: Center(child: Text(mood['emoji']!, style: TextStyle(fontSize: isSelected ? 26 : 22))),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['label']!,
                          style: TextStyle(fontSize: 11, color: isSelected ? primaryColor : onSurfaceVariant, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                        ),
                      ],
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
