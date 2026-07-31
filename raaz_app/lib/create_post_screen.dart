import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  int _charCount = 0;
  String _selectedCategory = '';

  final List<String> _categories = [
    'Confessions',
    'Rants',
    'Questions',
    'Advice',
    'Random'
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _charCount = _textController.text.length;
      });
    });
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
          onPressed: () {
            _textController.clear();
            setState(() {
              _selectedCategory = '';
            });
          },
        ),
        title: const Text(
          'Share a Secret',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: _charCount > 0 && _selectedCategory.isNotEmpty ? () {} : null,
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
                      maxLength: 500,
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
                          '$_charCount / 500',
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
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    bool isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(category),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : onSurfaceVariant,
                          fontSize: 14,
                        ),
                        backgroundColor: isSelected ? primaryColor : surfaceContainerLowest,
                        side: BorderSide(
                          color: isSelected ? primaryColor : outlineVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
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
              IconButton(icon: Icon(Icons.image, color: onSurfaceVariant), onPressed: () {}),
              IconButton(icon: Icon(Icons.alternate_email, color: onSurfaceVariant), onPressed: () {}),
              IconButton(icon: Icon(Icons.mood, color: onSurfaceVariant), onPressed: () {}),
              const Spacer(),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: _charCount / 500,
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
}
