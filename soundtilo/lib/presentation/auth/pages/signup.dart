import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundtilo/common/widgets/appbar/app_bar.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/auth/pages/signin.dart';
import 'package:soundtilo/presentation/main_shell.dart';

import '../../../common/widgets/button/basic_app_button.dart';
import '../../../common/widgets/textFormField/custom_field.dart';

class SignUpPage extends StatefulWidget {

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF323232),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        bottomNavigationBar: _signInPage(context),
          appBar: BasicAppBar(
            title: SvgPicture.asset(
                AppVectors.logo,
              height: 50,
              width: 50,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _registerTextField(),
                    const SizedBox(height: 10,),
                    _fullNameTextField(context),
                    const SizedBox(height: 10,),
                    _emailTextField(context),
                    const SizedBox(height: 10,),
                    _passwordTextField(context),
                    const SizedBox(height: 10,),
                    _confirmPasswordTextFeild(context),
                    const SizedBox(height: 10,),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return BasicAppButton(
                          onPressed: _onSignUp,
                          title: "Đăng ký",
                        );
                      },
                    ),
                    const SizedBox(height: 16,),
                    _dividerWithText("hoặc"),
                    const SizedBox(height: 16,),
                    _googleSignInButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  void _onSignUp() {
    if (formKey.currentState?.validate() ?? false) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mật khẩu xác nhận không khớp',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF323232),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(AuthSignUpRequested(
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      ));
    }
  }

  Widget _registerTextField() {
    return const Text(
      "Đăng ký",
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _fullNameTextField(BuildContext context) {
    return CustomField(
      labelText: "Tên đăng nhập",
      controller: nameController,
    );
  }

  Widget _emailTextField(BuildContext context) {
    return CustomField(
      labelText: "Email",
      controller: emailController,
    );
  }

  Widget _passwordTextField(BuildContext context) {
    return CustomField(
      labelText: "Mật khẩu",
      controller: passwordController,
      isObscureText: true,
    );
  }

  Widget _confirmPasswordTextFeild(BuildContext context) {
    return CustomField(
      labelText: "Xác nhận mật khẩu",
      controller: confirmPasswordController,
      isObscureText: true,
    );
  }

  Widget _signInPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(
        vertical: 5,
      ),
      child: Row (
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Bạn đã có tài khoản ?",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SignInPage(),
                  )
              );
            } ,
            child: const Text(
              "Đăng nhập",
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _googleSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(AuthGoogleSignInRequested());
        },
        icon: SvgPicture.asset(
          AppVectors.google,
          width: 24,
          height: 24,
        ),
        label: const Text(
          'Đăng ký với Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
