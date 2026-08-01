import 'package:flutter/material.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  static const Color _primary = Color(0xFF004ac6);
  static const Color _surface = Color(0xFFf9f9ff);
  static const Color _onSurface = Color(0xFF141B2B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFc3c6d7);
  static const Color _secondary = Color(0xFF0058be);

  bool _autoManage = true;
  bool _wifiOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Data & Storage',
            style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            const SizedBox(height: 32),
            const Text('Downloaded Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
            const SizedBox(height: 12),
            _buildDetailedBreakdown(),
            const SizedBox(height: 32),
            const Text('Auto-Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurfaceVariant)),
            const SizedBox(height: 12),
            _buildAutoManagement(),
            const SizedBox(height: 32),
            _buildHelpBanner(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: _primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.storage, color: _primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Storage Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface)),
                  SizedBox(height: 2),
                  Text('2.4 GB of 5.0 GB used', style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar('Storage Usage', '48%', _primary, 48),
          const SizedBox(height: 16),
          _buildProgressBar('Cache Usage', '820 MB', _secondary, 35),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear Cache', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String value, Color color, int percent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _onSurface)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFFdce2f7), borderRadius: BorderRadius.circular(4)),
          child: Row(
            children: [
              Expanded(flex: percent, child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)))),
              Expanded(flex: 100 - percent, child: Container()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildBreakdownItem(Icons.movie, const Color(0xFF00569c), 'Videos & Media', '1.2 GB • 24 files'),
          const Divider(height: 1, color: _outlineVariant),
          _buildBreakdownItem(Icons.description, _secondary, 'Documents', '450 MB • 128 files'),
          const Divider(height: 1, color: _outlineVariant),
          _buildBreakdownItem(Icons.share, _primary, 'Anonymous Shares', '120 MB • Cached local'),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(IconData icon, Color iconColor, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, color: _onSurface)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: _onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right, color: _outlineVariant),
      onTap: () {},
    );
  }

  Widget _buildAutoManagement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-delete old cache', style: TextStyle(fontSize: 16, color: _onSurface)),
            subtitle: const Text('Delete files older than 30 days', style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
            value: _autoManage,
            activeColor: _primary,
            onChanged: (val) => setState(() => _autoManage = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Download over Wi-Fi only', style: TextStyle(fontSize: 16, color: _onSurface)),
            subtitle: const Text('Save mobile data usage', style: TextStyle(fontSize: 14, color: _onSurfaceVariant)),
            value: _wifiOnly,
            activeColor: _primary,
            onChanged: (val) => setState(() => _wifiOnly = val),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFe1e8fd),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: _primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Managing your data usage helps keep the app running smoothly. Cleared cache files will be re-downloaded when needed.',
                    style: TextStyle(fontSize: 14, color: _onSurfaceVariant, height: 1.5)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Learn more about storage', style: TextStyle(fontSize: 14, color: _primary, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
