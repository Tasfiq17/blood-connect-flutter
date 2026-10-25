import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _changePassword() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Reset Password"),
        content: Text(
          "A password reset link will be sent to:\n\n$email",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text("Reset link sent to $email"),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.danger,
                    content: Text("Error: ${e.toString()}"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Send Link"),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.privacy_tip, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: privacyPolicyContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("I Understand"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shared privacy policy widget — used in Settings and Registration
  static Widget privacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _policySection(
          "1. Information We Collect",
          "We collect your name, email address, phone number, blood group, district, and address when you register. This information is stored securely in Firebase Cloud Firestore.",
        ),
        _policySection(
          "2. How We Use Your Information",
          "Your personal data is used solely to connect blood donors with patients in need. Your blood group and location are visible to other app users to enable blood donation matching.",
        ),
        _policySection(
          "3. Data Sharing",
          "We do not sell, trade, or share your personal data with any third party. Your contact information is only visible to other registered users of Blood Connect.",
        ),
        _policySection(
          "4. Donor Eligibility",
          "By registering as a donor, you confirm that you are medically fit to donate blood and that you have not donated blood within the last 3 months (90 days). Blood Connect is not responsible for any health complications.",
        ),
        _policySection(
          "5. Data Security",
          "Your data is protected using Google Firebase's industry-standard security. Passwords are encrypted and never stored in plain text.",
        ),
        _policySection(
          "6. Your Rights",
          "You can update or delete your account at any time through the Profile screen. Deleting your account permanently removes all your data from our systems.",
        ),
        _policySection(
          "7. Contact",
          "If you have any questions about this Privacy Policy, please contact us through the app's support channel.",
        ),
      ],
    );
  }

  static Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bloodtype, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Text("Blood Connect"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text(
              "Blood Connect is a platform that connects blood donors with people in need. Together we save lives.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 12),
            Text("© 2026 Blood Connect. All rights reserved.",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffE53935), Color(0xffC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Settings ⚙️",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Manage your account and preferences.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ── Settings List ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [

                  // Account Section
                  _sectionLabel("Account"),
                  _settingsTile(
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue,
                    title: "Email Address",
                    subtitle: user?.email ?? 'Not logged in',
                    onTap: null,
                  ),
                  _settingsTile(
                    icon: Icons.lock_outline,
                    iconColor: Colors.orange,
                    title: "Change Password",
                    subtitle: "Send a reset link to your email",
                    onTap: _changePassword,
                  ),

                  const SizedBox(height: 20),

                  // Preferences Section
                  _sectionLabel("Preferences"),
                  _settingsSwitchTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.primary,
                    title: "In-App Notifications",
                    subtitle: "Receive blood request alerts",
                    value: _notificationsEnabled,
                    onChanged: (v) =>
                        setState(() => _notificationsEnabled = v),
                  ),

                  const SizedBox(height: 20),

                  // Information Section
                  _sectionLabel("Information"),
                  _settingsTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.teal,
                    title: "About Blood Connect",
                    subtitle: "Version info and description",
                    onTap: _showAbout,
                  ),
                  _settingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.indigo,
                    title: "Privacy Policy",
                    subtitle: "How we handle your data",
                    onTap: () => _showPrivacyPolicy(context),
                  ),

                  const SizedBox(height: 20),

                  // Danger Zone
                  _sectionLabel("Account Actions"),
                  _settingsTile(
                    icon: Icons.logout,
                    iconColor: AppColors.danger,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    onTap: _confirmLogout,
                    isDestructive: true,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDestructive ? AppColors.danger : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _settingsSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
