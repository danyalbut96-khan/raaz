import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'data/models/category_model.dart';
import 'data/repositories/post_repository.dart';
import 'services/draft_database_service.dart';
import 'main.dart';


class CreatePostScreen extends StatefulWidget {
  final Map<String, dynamic>? draft; // passed when restoring a draft
  const CreatePostScreen({super.key, this.draft});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final _postRepo = PostRepository();
  final _uuid = const Uuid();

  int _charCount = 0;
  String? _selectedCategoryId;
  String _selectedCategoryName = '';
  String? _selectedMood;
  bool _isPublishing = false;
  bool _ghostMode = false;
  bool _allowComments = true;

  List<CategoryModel> _categories = [];
  String? _draftId;

  // PRD: max 5000 chars, no minimum
  static const int _maxChars = 5000;


  @override
  void initState() {
    super.initState();
    _loadCategories();
    _draftId = _uuid.v4();

    // Restore draft if passed
    if (widget.draft != null) {
      _textController.text = widget.draft!['body'] ?? '';
      _selectedCategoryId = widget.draft!['category_id'];
      _selectedMood = widget.draft!['mood'];
      _draftId = widget.draft!['id'];
    }

    _textController.addListener(() {
      setState(() => _charCount = _textController.text.length);
      // Auto-save draft every keystroke (debounced by Flutter's listener mechanism)
      _autoSaveDraft();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _postRepo.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          if (cats.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = cats.first.id;
            _selectedCategoryName = cats.first.name;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _autoSaveDraft() async {
    if (_textController.text.isEmpty) return;
    await DraftDatabaseService.saveDraft(
      id: _draftId!,
      body: _textController.text,
      categoryId: _selectedCategoryId,
      mood: _selectedMood,
    );
  }

  Future<void> _publish() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a category.'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _isPublishing = true);
    try {
      await _postRepo.createPost(
        body: _textController.text.trim(),
        categoryId: _selectedCategoryId!,
        mood: _selectedMood,
        ghostMode: _ghostMode,
        allowComments: _allowComments,
      );
      // Delete draft after publish
      if (_draftId != null) await DraftDatabaseService.deleteDraft(_draftId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Post published! ✅'), behavior: SnackBarBehavior.floating));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unable to publish. Draft saved.'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFF8FAFC);
    final Color onSurfaceVariant = const Color(0xFF434655);
    final Color outlineVariant = const Color(0xFFc3c6d7);
    final Color surfaceContainerLowest = Colors.white;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Share Secretly & Anonymously',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: _textController.text.trim().isNotEmpty && _selectedCategoryId != null && !_isPublishing
                  ? _publish
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd8e2ff),
                foregroundColor: const Color(0xFF001a41),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Post', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Section
              Container(
                constraints: const BoxConstraints(minHeight: 400),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, size: 16, color: onSurfaceVariant.withOpacity(0.6)),
                        const SizedBox(width: 8),
                        Text(
                          'Posting anonymously',
                          style: TextStyle(fontSize: 14, color: onSurfaceVariant.withOpacity(0.6), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      maxLines: 15,
                      maxLength: _maxChars,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(color: outlineVariant, fontSize: 16),
                        border: InputBorder.none,
                        counterText: "", // Hide default counter to use custom one below
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$_charCount / $_maxChars',
                          style: TextStyle(fontSize: 12, color: outlineVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Category Selection
              const Text(
                'Select a Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    bool isSelected = _selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                          _selectedCategoryName = cat.name;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFd8e2ff) : const Color(0xFFe9edff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tag, size: 16, color: isSelected ? primaryColor : onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(cat.name, style: TextStyle(fontSize: 14, color: isSelected ? primaryColor : onSurfaceVariant, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 48),

              // Security Visual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf1f3ff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe9edff),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user, color: Color(0xFF0058be), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RAAZ Protection',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0058be), fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your identity is cryptographically hashed. Even we don't know who you are.",
                            style: TextStyle(fontSize: 14, color: onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80), // Space for bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.85),
            border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.image, color: onSurfaceVariant),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Picture uploads are coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ));
                },
              ),
              IconButton(
                icon: Icon(Icons.mood, color: _selectedMood != null ? primaryColor : onSurfaceVariant),
                onPressed: () {
                  _showEmojiPicker();
                },
              ),
              if (_selectedMood != null)
                Text(_selectedMood!, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: _charCount / _maxChars,
                  backgroundColor: outlineVariant.withOpacity(0.3),
                  color: primaryColor,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    final List<String> emojis = ['😊', '😂', '🥺', '😡', '😴', '😎', '🤔', '😭', '❤️', '🔥', '✨', '🎉'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = emoji;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
