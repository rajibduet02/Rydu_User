import 'package:flutter/material.dart';

import '../theme/settings_screen_tokens.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key, required this.appVersion});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final padTop = (w * 0.06).clamp(22.0, 28.0);
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final small = (w * 0.032).clamp(12.0, 13.0);
    final brainSize = (w * 0.11).clamp(40.0, 44.0);

    return Padding(
      padding: EdgeInsets.only(top: padTop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: SettingsScreenTokens.border,
          ),
          SizedBox(height: (w * 0.05).clamp(20.0, 24.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'RYD U',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SettingsScreenTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                    Text(
                      'Version $appVersion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SettingsScreenTokens.muted,
                        fontSize: small,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: (w * 0.045).clamp(16.0, 18.0)),
                    Text(
                      '© 2026 RYD U Technologies',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SettingsScreenTokens.muted,
                        fontSize: small,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: (w * 0.02).clamp(8.0, 10.0)),
              Container(
                width: brainSize,
                height: brainSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SettingsScreenTokens.iconWell,
                  border: Border.all(color: SettingsScreenTokens.border),
                ),
                alignment: Alignment.center,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF2F6BFF),
                      Color(0xFF9B59FF),
                      Color(0xFFFF6BB3),
                    ],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: brainSize * 0.52,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: (w * 0.06).clamp(20.0, 28.0)),
        ],
      ),
    );
  }
}
