import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/supabase_client.dart';

class ReportedPostsStatusScreen extends StatefulWidget {
  const ReportedPostsStatusScreen({super.key});

  @override
  State<ReportedPostsStatusScreen> createState() => _ReportedPostsStatusScreenState();
}

class _ReportedPostsStatusScreenState extends State<ReportedPostsStatusScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);

  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() { _reports = []; _isLoading = false; });
        return;
      }

      final data = await supabase
          .from('reported_posts')
          .select('*, posts ( body, pseudonym )')
          .eq('reporter_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _reports = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _reports = []; _isLoading = false; });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'under_review':
        return Colors.orange;
      case 'dismissed':
        return _onSurfaceVariant;
      default:
        return _primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'under_review':
        return 'Under Review';
      case 'resolved':
        return 'Resolved';
      case 'dismissed':
        return 'Dismissed';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reported Posts',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _onSurfaceVariant),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _reports.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: _primary,
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (_, i) => _buildReportCard(_reports[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_off_outlined, size: 64, color: _outlineVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          const Text('No reports yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _onSurface)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When you report a post, you can track its moderation status here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] as String? ?? 'pending';
    final reason = report['reason'] as String? ?? 'other';
    final createdAt = DateTime.tryParse(report['created_at'] as String? ?? '') ?? DateTime.now();
    final post = report['posts'] as Map<String, dynamic>?;
    final postBody = post?['body'] as String? ?? 'Post unavailable';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_statusLabel(status),
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
              ),
              const Spacer(),
              Text(timeago.format(createdAt),
                  style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Reason: ${_formatReason(reason)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _onSurface)),
          const SizedBox(height: 8),
          Text(postBody,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: _onSurfaceVariant, height: 1.4)),
          if (report['admin_notes'] != null) ...[
            const SizedBox(height: 8),
            Text('Note: ${report['admin_notes']}',
                style: TextStyle(fontSize: 12, color: _primary.withValues(alpha: 0.8), fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  String _formatReason(String reason) {
    return reason.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}
