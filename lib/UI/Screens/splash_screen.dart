import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget homePage; // pass your home page here
  const SplashScreen({super.key, required this.homePage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 3200), () {
      _controller.forward();
    });

    // After fade-out completes, remove splash by rebuilding without it
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Instead of using go/goNamed, just replace splash with home
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => widget.homePage,
              transitionDuration: Duration.zero, // no extra animation
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.homePage, // home page already behind
        FadeTransition(
          opacity: _fadeOutAnimation,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: Color(0xAA7F3DFF)),
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
                              0xAAFCAC12,
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
  }
}
