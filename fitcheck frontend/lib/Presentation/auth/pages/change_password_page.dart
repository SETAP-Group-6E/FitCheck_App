import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const Color _accent = Color.fromRGBO(217, 156, 19, 1);
  static const Color _surface = Color(0xFF1C1C1C);
  static const Color _surfaceBorder = Color(0xFF2E2E2E);
  static const Color _iconButtonBg = Color.fromRGBO(42, 42, 42, 1);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topBarHeight = 120;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  height: topBarHeight,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  color: Colors.black,
                  child: Row(
                    children: [
                      _circleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Change password',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40, width: 40),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update your password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Use a strong password you do not reuse elsewhere.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCard(
                        child: Column(
                          children: [
                            _buildTextField(
                              label: 'Current password',
                              hint: 'Enter current password',
                              controller: _currentPasswordController,
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'New password',
                              hint: 'Enter new password',
                              controller: _newPasswordController,
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              label: 'Confirm new password',
                              hint: 'Re-enter new password',
                              controller: _confirmPasswordController,
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password change requested.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Save password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _iconButtonBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _surfaceBorder,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Georgia',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
