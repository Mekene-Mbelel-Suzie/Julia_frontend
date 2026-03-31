import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'dashboard/dashboard_router.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final void Function(Locale locale)? onLocaleChange;

  const SignupScreen({
    super.key,
    this.onLocaleChange,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  List<dynamic> hospitals = [];
  int? selectedHospitalId;

  @override
  void initState() {
    super.initState();
    loadHospitals();
  }

  Future<void> loadHospitals() async {
    try {
      final data = await authService.getHospitals();
      if (!mounted) return;
      setState(() {
        hospitals = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load hospitals: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedHospitalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a hospital'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authService.parentSignup(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        hospitalId: selectedHospitalId!,
        address: addressController.text.trim(),
        emergencyContactName: emergencyNameController.text.trim(),
        emergencyContactPhone: emergencyPhoneController.text.trim(),
      );

      final AppUser? user = await authService.getStoredUser();

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created but session could not be loaded'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardRouter(user: user),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 820;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 760 : 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(24),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.child_care,
                          size: 42,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Create Parent Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Register to manage child vaccination reminders.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      if (isWide)
                        Row(
                          children: [
                            Expanded(child: _field(firstNameController, 'First name', Icons.person_outline)),
                            const SizedBox(width: 16),
                            Expanded(child: _field(lastNameController, 'Last name', Icons.badge_outlined)),
                          ],
                        )
                      else ...[
                        _field(firstNameController, 'First name', Icons.person_outline),
                        const SizedBox(height: 16),
                        _field(lastNameController, 'Last name', Icons.badge_outlined),
                      ],

                      const SizedBox(height: 16),

                      if (isWide)
                        Row(
                          children: [
                            Expanded(child: _emailField()),
                            const SizedBox(width: 16),
                            Expanded(child: _phoneField()),
                          ],
                        )
                      else ...[
                        _emailField(),
                        const SizedBox(height: 16),
                        _phoneField(),
                      ],

                      const SizedBox(height: 16),
                      _addressField(),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        value: selectedHospitalId,
                        items: hospitals.map((hospital) {
                          return DropdownMenuItem<int>(
                            value: hospital['id'] as int,
                            child: Text(hospital['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedHospitalId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Hospital',
                          prefixIcon: Icon(Icons.local_hospital_outlined),
                        ),
                        validator: (value) {
                          if (value == null) return 'Select a hospital';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      if (isWide)
                        Row(
                          children: [
                            Expanded(child: _optionalField(emergencyNameController, 'Emergency contact name', Icons.contact_phone_outlined)),
                            const SizedBox(width: 16),
                            Expanded(child: _optionalPhoneField()),
                          ],
                        )
                      else ...[
                        _optionalField(emergencyNameController, 'Emergency contact name', Icons.contact_phone_outlined),
                        const SizedBox(height: 16),
                        _optionalPhoneField(),
                      ],

                      const SizedBox(height: 16),

                      if (isWide)
                        Row(
                          children: [
                            Expanded(child: _passwordField()),
                            const SizedBox(width: 16),
                            Expanded(child: _confirmPasswordField()),
                          ],
                        )
                      else ...[
                        _passwordField(),
                        const SizedBox(height: 16),
                        _confirmPasswordField(),
                      ],

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : signup,
                        child: _isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Create Account'),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(
                                    onLocaleChange: widget.onLocaleChange,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter $label';
        }
        return null;
      },
    );
  }

  Widget _optionalField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email address',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter email';
        }
        if (!value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Phone number',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter phone number';
        }
        return null;
      },
    );
  }

  Widget _addressField() {
    return TextFormField(
      controller: addressController,
      decoration: const InputDecoration(
        labelText: 'Address',
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter address';
        }
        return null;
      },
    );
  }

  Widget _optionalPhoneField() {
    return TextFormField(
      controller: emergencyPhoneController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Emergency contact phone',
        prefixIcon: Icon(Icons.call_outlined),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm password',
        prefixIcon: const Icon(Icons.lock_reset_outlined),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirm your password';
        }
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}