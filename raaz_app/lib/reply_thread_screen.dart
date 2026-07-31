import 'package:flutter/material.dart';

class ReplyThreadScreen extends StatefulWidget {
  const ReplyThreadScreen({super.key});

  @override
  State<ReplyThreadScreen> createState() => _ReplyThreadScreenState();
}

class _ReplyThreadScreenState extends State<ReplyThreadScreen> {
  final TextEditingController _replyController = TextEditingController();
  final List<Map<String, dynamic>> _replies = [
    {
      'name': 'Silent_Cipher',
      'time': '1h ago',
      'content': 'I can confirm the latency drop. The handshake protocol feels much more streamlined now.',
      'avatarIcon': Icons.face,
      'avatarColor': Color(0xFF004ac6),
      'avatarBg': Color(0xFFd8e2ff),
      'indentLevel': 1,
      'collapsed': false,
      'subReplies': [
        {
          'name': 'DataGhost',
          'time': '45m ago',
          'content': 'Did you test this on the regional nodes or just the primary backbone? I\'m curious if the optimization propagates correctly.',
          'avatarIcon': Icons.bolt,
          'avatarColor': Color(0xFF006874),
          'avatarBg': Color(0xFFcce5ff),
          'subReplies': [
            {
              'name': 'Silent_Cipher',
              'time': '30m ago',
              'content': 'Tested on both. The regional nodes actually show even better gains, likely due to the new compression algorithm.',
              'avatarIcon': Icons.face,
              'avatarColor': Color(0xFF004ac6),
              'avatarBg': Color(0xFFd8e2ff),
              'subReplies': [],
            }
          ],
        }
      ],
    },
    {
      'name': 'NodeExpert',
      'time': '50m ago',
      'content': 'Still experiencing some dropped packets in the EU-West corridor. Might be unrelated to the patch though.',
      'avatarIcon': Icons.shield,
      'avatarColor': Color(0xFFba1a1a),
      'avatarBg': Color(0xFFffdad6),
      'indentLevel': 1,
      'collapsed': false,
      'subReplies': [],
    },
  ];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF004ac6);
    final Color surfaceColor = const Color(0xFFf9f9ff);
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
        title: Text('Reply Thread', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [
          IconButton(icon: Icon(Icons.more_vert, color: const Color(0xFF434655)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Root Post
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFFd8e2ff), shape: BoxShape.circle),
                        child: const Icon(Icons.security, color: Color(0xFF004ac6)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Anonymous Sentry', style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 14)),
                                const Text('2h ago', style: TextStyle(fontSize: 12, color: Color(0xFF737686))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The recent security patch seems to have resolved the metadata leakage issue. Has anyone else noticed the improved response times on the encrypted relay? I\'m seeing almost 40% reduction in latency.',
                              style: TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.thumb_up_outlined, size: 18, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Text('124', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                                const SizedBox(width: 16),
                                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Text('8 replies', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                                const SizedBox(width: 16),
                                Icon(Icons.share, size: 18, color: Colors.grey.shade400),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Reply list
                ..._replies.map((r) => _buildReplyCard(r, 0, context)),

                const SizedBox(height: 80),
              ],
            ),
          ),
          // Reply input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.95),
                border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.2))),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
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
                              controller: _replyController,
                              decoration: InputDecoration(
                                hintText: 'Add a reply...',
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
                  GestureDetector(
                    onTap: () {
                      if (_replyController.text.isNotEmpty) {
                        _replyController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reply posted anonymously!'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    },
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

  Widget _buildReplyCard(Map<String, dynamic> reply, int depth, BuildContext context) {
    final bool isNested = depth > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 24.0, bottom: 12),
          child: Row(
            children: [
              if (isNested)
                Container(
                  width: 2,
                  height: 100,
                  color: const Color(0xFFc3c6d7),
                  margin: const EdgeInsets.only(right: 12),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isNested ? const Color(0xFFf8fafc) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: const Color(0xFF004ac6).withOpacity(0.2), width: 4)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: (reply['avatarBg'] as Color),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(reply['avatarIcon'] as IconData, color: reply['avatarColor'] as Color, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(reply['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const Spacer(),
                          Text(reply['time'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF737686))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(reply['content'] as String, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF434655))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(onPressed: () {}, child: Text('Reply', style: TextStyle(fontSize: 12, color: const Color(0xFF004ac6), fontWeight: FontWeight.w500))),
                          if ((reply['subReplies'] as List).isNotEmpty)
                            TextButton(onPressed: () {}, child: const Text('Collapse', style: TextStyle(fontSize: 12, color: Color(0xFF737686)))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ...(reply['subReplies'] as List).map((sub) => _buildReplyCard(Map<String, dynamic>.from(sub as Map), depth + 1, context)),
      ],
    );
  }
}
