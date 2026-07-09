import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.radius = 32});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: radius, child: const Icon(Icons.person));
  }
}
