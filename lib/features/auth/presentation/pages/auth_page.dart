import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_event.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.infoMessage != current.infoMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.errorMessage != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<AuthBloc>().add(const AuthFeedbackCleared());
          return;
        }

        if (state.infoMessage != null) {
          messenger.showSnackBar(SnackBar(content: Text(state.infoMessage!)));
          context.read<AuthBloc>().add(const AuthFeedbackCleared());
        }
      },
      builder: (context, state) {
        final isLoading = state.otpInProgress || state.loginInProgress;

        return Scaffold(
          appBar: AppBar(title: const Text('TestBor Login')),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Авторизация по телефону',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Введите телефон и одноразовый код'),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Телефон',
                          hintText: '998901234567',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          labelText: 'Код',
                          hintText: '123456',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: state.otpInProgress ? null : _requestOtp,
                        child: state.otpInProgress
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Запросить код'),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: state.loginInProgress ? null : _submitLogin,
                        child: state.loginInProgress
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Войти / Зарегистрироваться'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _requestOtp() {
    final normalizedPhone = _normalizePhone(_phoneController.text);
    if (!_isPhoneValid(normalizedPhone)) {
      _showError('Телефон должен быть в формате 998XXXXXXXXX');
      return;
    }

    context.read<AuthBloc>().add(OtpRequested(normalizedPhone));
  }

  void _submitLogin() {
    final normalizedPhone = _normalizePhone(_phoneController.text);
    final code = _codeController.text.trim();

    if (!_isPhoneValid(normalizedPhone)) {
      _showError('Телефон должен быть в формате 998XXXXXXXXX');
      return;
    }

    if (code.isEmpty) {
      _showError('Введите код подтверждения');
      return;
    }

    context.read<AuthBloc>().add(
      LoginSubmitted(phone: normalizedPhone, pinCode: code),
    );
  }

  String _normalizePhone(String rawPhone) {
    return rawPhone.replaceAll(RegExp(r'\D'), '');
  }

  bool _isPhoneValid(String phone) {
    return RegExp(r'^998\d{9}$').hasMatch(phone);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
