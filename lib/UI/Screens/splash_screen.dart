import 'dart:async';
import 'package:flutter/material.dart';
import 'package:send_snap/UI/Screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // smooth fade
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start fade after showing splash
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(Duration(seconds: 3), () {
      // Adjust duration as needed
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ), // Replace with your HomePage
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Home page behind splash
            Opacity(opacity: 1.0 - _fadeOutAnimation.value),

            // Splash content in front
            Opacity(
              opacity: _fadeOutAnimation.value,
              child: Scaffold(
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFF7F3DFF),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(right: 70),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFCAC12,
                                ).withValues(alpha: 0.6),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'sendSnap',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 42,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
