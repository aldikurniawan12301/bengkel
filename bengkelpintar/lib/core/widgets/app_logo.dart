import 'package:flutter/widgets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: 'Logo Bengkel Pintar',
  );
}
