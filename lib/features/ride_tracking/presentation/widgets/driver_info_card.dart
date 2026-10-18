import 'package:flutter/material.dart';

import '../../../../core/network/profile_image_url.dart';
import '../../../ride_booking/presentation/theme/ride_booking_tokens.dart';

/// Driver and assigned-vehicle identification for an accepted ride.
class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({
    super.key,
    required this.driverName,
    required this.plateNumber,
    this.rating,
    this.profileImageUrl,
    this.makeModel,
    this.colorYear,
    this.onCall,
  });

  final String driverName;
  final String plateNumber;
  final String? rating;
  final String? profileImageUrl;
  final String? makeModel;
  final String? colorYear;

  /// Set only when the assigned driver payload includes a phone number.
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final name = driverName.trim().isEmpty ? 'Driver assigned' : driverName.trim();
    final plate = plateNumber.trim();
    final ratingText = rating?.trim() ?? '';
    final vehicleTitle = makeModel?.trim() ?? '';
    final vehicleMeta = colorYear?.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _DriverPhoto(name: name, imageUrl: profileImageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: RideBookingTokens.titleWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    if (ratingText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '★ $ratingText',
                        style: const TextStyle(
                          color: RideBookingTokens.titleWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (vehicleTitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        vehicleTitle,
                        style: const TextStyle(
                          color: RideBookingTokens.titleWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (vehicleMeta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vehicleMeta,
                        style: const TextStyle(
                          color: RideBookingTokens.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onCall != null)
                _CircleAction(icon: Icons.phone_outlined, onTap: onCall!),
            ],
          ),
          const SizedBox(height: 14),
          _PlateBadge(plate: plate),
        ],
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  const _PlateBadge({required this.plate});

  final String plate;

  @override
  Widget build(BuildContext context) {
    final hasPlate = plate.isNotEmpty && plate != '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasPlate ? Colors.white : RideBookingTokens.plusFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasPlate ? const Color(0xFF111827) : RideBookingTokens.border,
          width: hasPlate ? 2 : 1,
        ),
      ),
      child: Text(
        hasPlate ? plate : 'Plate unavailable',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: hasPlate ? const Color(0xFF111827) : RideBookingTokens.muted,
          fontWeight: FontWeight.w800,
          fontSize: hasPlate ? 22 : 14,
          letterSpacing: hasPlate ? 1.6 : 0,
        ),
      ),
    );
  }
}

class _DriverPhoto extends StatelessWidget {
  const _DriverPhoto({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = resolveProfileImageUrl(imageUrl);
    final initials = _initials(name);
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: url == null
            ? _fallback(initials)
            : Image.network(
                url,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _fallback(initials);
                },
                errorBuilder: (_, _, _) => _fallback(initials),
              ),
      ),
    );
  }

  Widget _fallback(String initials) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F6BFF), Color(0xFF4D7DFF)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty || name == 'Driver assigned') return 'D';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RideBookingTokens.plusFill,
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Icon(icon, color: RideBookingTokens.titleWhite, size: 20),
        ),
      ),
    );
  }
}
