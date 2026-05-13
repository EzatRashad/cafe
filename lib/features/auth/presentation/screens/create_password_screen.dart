import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/auth_cubit.dart';
import '../../../../shared/widgets/common_widgets.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthValidationError) {
          _showError(context, state.messageKey.tr());
        } else if (state is AuthError) {
          _showError(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5D4037).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.local_cafe_rounded, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 24),
                        Text('appName'.tr(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text('createPassword'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'enterPassword'.tr(),
                          controller: _passCtrl,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'passwordRequired'.tr();
                            if (v.length < 4) return 'passwordTooShort'.tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'confirmPassword'.tr(),
                          controller: _confirmCtrl,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (v) {
                            if (v != _passCtrl.text) return 'passwordsNoMatch'.tr();
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        AppButton(
                          label: 'createPassword'.tr(),
                          icon: Icons.arrow_forward_rounded,
                          isLoading: state is AuthLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().createPassword(
                                     _passCtrl.text,
                                     _confirmCtrl.text,
                                   );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showError(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
