import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_progress_service.dart';
import '../models/user_progress.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProgressService _progressService = UserProgressService();

  UserProgress? _userProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final progress = await _progressService.getUserProgress();
      setState(() {
        _userProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigate back to login screen or initial screen
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4285F4),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(user),
    );
  }

  Widget _buildProfileContent(User? user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            _buildProfileHeader(user),

            const SizedBox(height: 20),

            // Overall Progress Card
            _buildOverallProgressCard(),

            const SizedBox(height: 20),

            // Language Badges
            _buildLanguageBadgesSection(),

            const SizedBox(height: 20),

            // Recent Activity
            _buildRecentActivitySection(),

            const SizedBox(height: 20),

            // Profile Actions
            _buildProfileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Icon(Icons.person, size: 40, color: Colors.blue.shade700)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Language Learner',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressCircle(
                  'Level',
                  _userProgress?.overallLevel.toString() ?? '1',
                ),
                _buildProgressCircle(
                  'XP',
                  _userProgress?.totalExperience.toString() ?? '0',
                ),
                _buildProgressCircle(
                  'Languages',
                  (_userProgress?.languageProgress.length ?? 0).toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(String label, String value) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade100,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageBadgesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language Badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _userProgress?.languageProgress.isEmpty ?? true
                ? const Center(child: Text('No languages learned yet'))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _userProgress!.languageProgress.values
                        .map((langProgress) {
                      return _buildLanguageBadge(
                          langProgress.languageName, langProgress.level);
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageBadge(String language, int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            language,
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lvl $level',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    // Collect recent quiz activities
    final recentActivities = _userProgress?.languageProgress.values
        .expand((langProgress) => langProgress.quizHistory)
        .toList()
      ?..sort((a, b) => b.date.compareTo(a.date));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            recentActivities?.isEmpty ?? true
                ? const Center(child: Text('No recent activities'))
                : Column(
                    children: recentActivities!.take(3).map((activity) {
                      return ListTile(
                        leading: Icon(
                          Icons.quiz,
                          color: activity.percentage >= 70
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(
                          '${activity.language} Quiz',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Score: ${activity.score}/${activity.totalQuestions} | ${activity.percentage.toStringAsFixed(0)}%',
                        ),
                        trailing: Text(
                          _formatDate(activity.date),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Widget _buildProfileActions() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButton(
              icon: Icons.settings,
              label: 'Account Settings',
              onPressed: () {
                // TODO: Implement account settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account settings coming soon')),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onPressed: () {
                // TODO: Implement help section
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help section coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade100),
        ),
      ),
    );
  }
}
