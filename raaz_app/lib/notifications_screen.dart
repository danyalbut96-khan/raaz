import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/supabase_client.dart';
import 'post_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Activity', 'System', 'Trending'];

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) { setState(() => _isLoading = false); return; }

      final data = await supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      // Table may not exist yet — show empty state
      if (mounted) setState(() { _notifications = []; _isLoading = false; });
    }
  }

  Future<void> _markAllRead() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      await supabase.from('notifications').update({'is_read': true}).eq('user_id', userId);
      setState(() {
        for (var n in _notifications) { n['is_read'] = true; }
      });
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return _notifications;
    final map = {'Activity': 'activity', 'System': 'system', 'Trending': 'trending'};
    final type = map[_selectedFilter];
    return _notifications.where((n) => n['type'] == type).toList();
  }

  int get _unreadCount => _notifications.where((n) => n['is_read'] != true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.security, color: _primary, size: 22),
            const SizedBox(width: 8),
            const Text('RAAZ', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: _primary, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: _primary, fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: _onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: _loadNotifications,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Text('Notifications',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _onSurface)),
                  const SizedBox(width: 10),
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: _primary, borderRadius: BorderRadius.circular(12)),
                      child: Text('$_unreadCount New',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: isSelected ? _primary : _outlineVariant.withOpacity(0.4)),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : _onSurfaceVariant)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : _filtered.isEmpty
                          ? _buildFilterEmpty()
                          : ListView.separated(
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: _outlineVariant.withOpacity(0.15), indent: 72),
                              itemBuilder: (_, i) => _buildNotificationTile(_filtered[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> n) {
    final isUnread = n['is_read'] != true;
    final type = n['type'] ?? 'activity';
    final createdAt = n['created_at'] != null
        ? DateTime.parse(n['created_at'] as String)
        : DateTime.now();

    IconData icon;
    Color iconBg;
    switch (type) {
      case 'comment': icon = Icons.chat_bubble_outline; iconBg = _primary.withOpacity(0.12); break;
      case 'reaction': icon = Icons.favorite_border; iconBg = Colors.red.withOpacity(0.12); break;
      case 'trending': icon = Icons.trending_up; iconBg = Colors.orange.withOpacity(0.12); break;
      case 'system': icon = Icons.info_outline; iconBg = Colors.grey.withOpacity(0.12); break;
      default: icon = Icons.notifications_none; iconBg = _primary.withOpacity(0.12);
    }

    return InkWell(
      onTap: () {
        if (n['post_id'] != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => PostDetailsScreen(postId: n['post_id'] as String)));
        }
        if (isUnread) {
          setState(() => n['is_read'] = true);
          supabase.from('notifications').update({'is_read': true}).eq('id', n['id']).then((_) {});
        }
      },
      child: Container(
        color: isUnread ? _primary.withOpacity(0.03) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 20,
                  color: type == 'reaction' ? Colors.red : (type == 'trending' ? Colors.orange : _primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(n['title'] ?? '',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                color: _onSurface)),
                      ),
                      const SizedBox(width: 8),
                      Text(timeago.format(createdAt),
                          style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n['body'] ?? '',
                      style: const TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.4)),
                  if (isUnread) ...[
                    const SizedBox(height: 6),
                    const Text('UNREAD',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primary)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: _primary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_outlined, size: 40, color: _primary),
          ),
          const SizedBox(height: 20),
          const Text('No notifications yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface)),
          const SizedBox(height: 8),
          const Text('When someone reacts to or comments on\nyour posts, you\'ll see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFilterEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list_off, size: 48, color: _outlineVariant),
          const SizedBox(height: 12),
          Text('No $_selectedFilter notifications',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface)),
        ],
      ),
    );
  }
}
