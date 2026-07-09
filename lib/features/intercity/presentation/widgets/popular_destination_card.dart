import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../theme/intercity_tokens.dart';

class PopularDestinationCard extends StatelessWidget {
  const PopularDestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final Destination destination;
  final VoidCallback onTap;

  static const double _imageHeight = 128;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IntercityTokens.radiusLg),
        side: const BorderSide(color: IntercityTokens.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IntercityTokens.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _imageHeight,
              child: _DestinationImage(path: destination.imagePath),
            ),
            Container(
              color: IntercityTokens.cardFill,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(
                        color: IntercityTokens.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: destination.cityName),
                        const TextSpan(
                          text: ' →',
                          style: TextStyle(
                            color: IntercityTokens.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination.startingPrice,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: IntercityTokens.muted,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationImage extends StatelessWidget {
  const _DestinationImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace network URLs with bundled destination art when assets are ready.
    if (path.isEmpty || !path.startsWith('http')) {
      return const _ImagePlaceholder();
    }
    return Image.network(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImagePlaceholder(showSpinner: true);
      },
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: IntercityTokens.iconWell,
      alignment: Alignment.center,
      child: showSpinner
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: IntercityTokens.accent,
              ),
            )
          : Icon(
              Icons.image_outlined,
              size: 40,
              color: IntercityTokens.muted.withValues(alpha: 0.6),
            ),
    );
  }
}
