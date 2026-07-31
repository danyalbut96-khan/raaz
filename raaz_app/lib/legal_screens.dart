import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f9ff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Terms of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionHeader('Last Updated: January 1, 2025'),
          SizedBox(height: 16),
          _LegalSection(
            title: '1. Acceptance of Terms',
            body:
                'By accessing or using RAAZ ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.',
          ),
          _LegalSection(
            title: '2. Anonymous Use',
            body:
                'RAAZ is designed for anonymous sharing. You may not use the App to post content that harasses, threatens, or harms others. Anonymity does not exempt you from legal responsibility for your content.',
          ),
          _LegalSection(
            title: '3. Prohibited Content',
            body:
                'You agree not to post content that:\n• Is defamatory, obscene, or abusive\n• Violates any applicable law\n• Contains personal information of others without consent\n• Promotes violence or illegal activity\n• Constitutes spam or commercial solicitation',
          ),
          _LegalSection(
            title: '4. Content Ownership',
            body:
                'You retain ownership of the content you post. By posting, you grant RAAZ a non-exclusive, royalty-free license to display and distribute your content within the App.',
          ),
          _LegalSection(
            title: '5. Account Termination',
            body:
                'We reserve the right to suspend or terminate access to RAAZ for users who violate these Terms. Violations may also be reported to relevant authorities.',
          ),
          _LegalSection(
            title: '6. Disclaimers',
            body:
                'RAAZ is provided "as is" without warranties of any kind. We are not responsible for user-generated content or for any loss resulting from use of the App.',
          ),
          _LegalSection(
            title: '7. Governing Law',
            body:
                'These Terms are governed by the laws of Pakistan. Any disputes shall be resolved in the courts of Lahore, Punjab.',
          ),
          _LegalSection(
            title: '8. Changes to Terms',
            body:
                'We may update these Terms at any time. Continued use of the App after changes constitutes acceptance of the new Terms.',
          ),
          _LegalSection(
            title: '9. Contact',
            body:
                'For legal inquiries, contact us at: legal@raazapp.com',
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f9ff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionHeader('Last Updated: January 1, 2025'),
          SizedBox(height: 16),
          _LegalSection(
            title: '1. Information We Collect',
            body:
                'RAAZ collects minimal data to operate:\n• Anonymous session identifiers\n• Pseudonyms generated locally\n• Post content and interactions\n• Device type and OS version (for crash reporting)\n\nWe do NOT collect your name, email, or real identity.',
          ),
          _LegalSection(
            title: '2. How We Use Your Data',
            body:
                'Data collected is used solely to:\n• Display your posts and interactions\n• Improve app performance\n• Detect and prevent abuse\n\nWe never sell your data to third parties.',
          ),
          _LegalSection(
            title: '3. Anonymity Guarantee',
            body:
                'Your real identity is never stored. Pseudonyms are generated and rotated to ensure no post can be traced back to you. Even our team cannot identify who posted what.',
          ),
          _LegalSection(
            title: '4. Data Retention',
            body:
                'Posts and comments are retained until deleted by the user. Anonymous session data is purged after 90 days of inactivity.',
          ),
          _LegalSection(
            title: '5. Third-Party Services',
            body:
                'RAAZ uses Supabase for secure data storage. Supabase is GDPR-compliant. No other third-party analytics or tracking tools are used.',
          ),
          _LegalSection(
            title: '6. Your Rights',
            body:
                'You may:\n• Delete your posts at any time\n• Request account deletion\n• Request a copy of your data\n\nContact us at: privacy@raazapp.com',
          ),
          _LegalSection(
            title: '7. Cookies',
            body:
                'The app does not use tracking cookies. Session tokens are stored securely on your device only.',
          ),
          _LegalSection(
            title: '8. Changes',
            body:
                'We may update this policy. You will be notified in-app of significant changes.',
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Color(0xFF737686), fontStyle: FontStyle.italic),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;
  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF141B2B))),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF434655))),
        ],
      ),
    );
  }
}
