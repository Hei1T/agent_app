import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../api/api_client.dart';
import 'auth_controller.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _email = TextEditingController(text: 'demo@benben.local');
  final _password = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authProvider.notifier).login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg(context)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 44),
                  SizedBox(height: AppSpacing.md(context)),
                  Text('笨笨', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(height: AppSpacing.xs(context)),
                  Text('正在栖湾生活的人', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54)),
                  SizedBox(height: AppSpacing.xxl(context)),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: '邮箱', hintText: 'demo@benben.local'),
                  ),
                  SizedBox(height: AppSpacing.sm(context)),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: '密码'),
                  ),
                  if (auth.error != null) ...[
                    SizedBox(height: AppSpacing.sm(context)),
                    Text(auth.error!, style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12)),
                  ],
                  SizedBox(height: AppSpacing.md(context)),
                  FilledButton(
                    onPressed: auth.loading ? null : _submit,
                    child: auth.loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('进入'),
                  ),
                  SizedBox(height: AppSpacing.sm(context)),
                  TextButton(
                    onPressed: () {
                      _email.text = 'demo@benben.local';
                      _password.text = 'demo1234';
                    },
                    child: const Text('使用演示账号'),
                  ),
                  TextButton(
                    onPressed: auth.loading ? null : () => ref.read(authProvider.notifier).register(_email.text, _password.text),
                    child: const Text('注册新账号'),
                  ),
                  SizedBox(height: AppSpacing.xxl(context)),
                  Text('API: ${ApiClient.baseUrl}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
