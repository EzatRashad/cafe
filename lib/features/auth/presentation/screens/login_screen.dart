import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';
import '../../../../shared/widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthValidationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.messageKey.tr()),
                backgroundColor: AppColors.error),
          );
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5D4037)
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.local_cafe_rounded,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 24),
                        Text('appName'.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('enterPassword'.tr(),
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'enterPassword'.tr(),
                          controller: _passCtrl,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'passwordRequired'.tr()
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.accent,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                            ),
                            Text('rememberMe'.tr()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'login'.tr(),
                          icon: Icons.login_rounded,
                          isLoading: state is AuthLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().login(
                                    _passCtrl.text,
                                    rememberMe: _rememberMe,
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
}
