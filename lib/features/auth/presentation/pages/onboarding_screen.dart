import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background color for the bottom half
          Container(
            color: const Color(0xFFEAF4FF).withOpacity(0.5), // Very light blue gradient effect from bottom
          ),
          
          Column(
            children: [
              // Curved Image Header
              ClipPath(
                clipper: BottomCurveClipper(),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.55,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bromo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Headline
              Text(
                'Liburan Seru Tanpa\nOver Budget',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007AFF),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Masuk dan mulai rencanakan\nperjalananmu sekarang!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Primary Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/auth-options');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Mulai sekarang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Top Overlays (Language and Theme)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ID Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red, // Simplified flag
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 16,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ID',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Theme Toggle
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.light_mode_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    // Control point is at the bottom center
    path.quadraticBezierTo(
      size.width / 2, 
      size.height, 
      size.width, 
      size.height - 60
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
