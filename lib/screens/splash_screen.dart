import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_images.dart';
import '../constants/app_strings.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    print("Splash started");

    Future.delayed(const Duration(seconds: 5), () {
      print("Navigating to Login");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffFFFDFD),
                  Color(0xffFFF3F3),
                  Color(0xffFFE8E8),
                ],
              ),
            ),
          ),

          /// Decorative Icons
          Positioned(
            top: 90,
            left: 40,
            child: Icon(
              Icons.favorite_border,
              color: Colors.red.withOpacity(.15),
              size: 60,
            ),
          ),

          Positioned(
            top: 120,
            right: 50,
            child: Icon(
              Icons.add,
              color: Colors.red.withOpacity(.15),
              size: 70,
            ),
          ),

          Positioned(
            bottom: 250,
            right: 40,
            child: Icon(
              Icons.bloodtype_outlined,
              color: Colors.red.withOpacity(.15),
              size: 60,
            ),
          ),

          /// Bottom Wave
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x55FF6B6B),
                    Color(0xAAFF5252),
                    Color(0xFFD32F2F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(90),
                  topRight: Radius.circular(90),
                ),
              ),
            ),
          ),

          /// Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Logo
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(.12),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      AppImages.logo,
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                    .animate()
                    .fade(duration: 600.ms)
                    .scale(
                  begin: const Offset(.8, .8),
                  end: const Offset(1, 1),
                  duration: 900.ms,
                  curve: Curves.easeOutBack,
                ),

                const SizedBox(height: 35),

                /// App Name
                Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Color(0xffB71C1C),
                  ),
                )
                    .animate()
                    .fade(delay: 500.ms)
                    .slideY(begin: .2),

                const SizedBox(height: 15),

                /// Decorative Line
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 2,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 80,
                      height: 2,
                      color: Colors.red.shade300,
                    ),
                  ],
                ).animate().fade(delay: 700.ms),

                const SizedBox(height: 20),

                /// Slogan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    AppStrings.slogan,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ).animate().fade(delay: 900.ms),

                const SizedBox(height: 55),

                /// Loading Dots
                const _LoadingDots(),

                const SizedBox(height: 15),

                Text(
                  "Loading...",
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 18,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fade(delay: 1000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({super.key});

  Widget dot(int delay) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(
      duration: 500.ms,
      delay: Duration(milliseconds: delay),
    )
        .fadeOut(duration: 500.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(0),
        dot(250),
        dot(500),
      ],
    );
  }
}