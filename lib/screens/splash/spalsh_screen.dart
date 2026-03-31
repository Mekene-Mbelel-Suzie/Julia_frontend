import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../dashboard/dashboard_router.dart';
import '../login_screen.dart';


class SplashScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const SplashScreen({
    super.key,
    this.onLocaleChange,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bool isLoggedIn = await authService.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLocaleChange: widget.onLocaleChange,
          ),
        ),
      );
      return;
    }

    final AppUser? user = await authService.getStoredUser();

    if (!mounted) return;

    if (user == null) {
      await authService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLocaleChange: widget.onLocaleChange,
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardRouter(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vaccines_rounded,
              size: 72,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Julia',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}