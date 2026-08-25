import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/utils/passenger_profile_requests.dart';
import '../providers/passenger_profile_controller.dart';
import '../theme/account_screen_tokens.dart';

Future<void> showProfileAvatarActions({
  required BuildContext context,
  required WidgetRef ref,
  required bool hasAvatar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AccountScreenTokens.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AccountScreenTokens.white,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: AccountScreenTokens.white),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await pickAndUploadProfileAvatar(context, ref);
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AccountScreenTokens.logoutRed,
                ),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(color: AccountScreenTokens.logoutRed),
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final ok = await ref
                      .read(passengerProfileControllerProvider.notifier)
                      .deleteAvatar();
                  if (!context.mounted) return;
                  final error = ref
                      .read(passengerProfileControllerProvider)
                      .errorMessage;
                  if (!ok && error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> pickAndUploadProfileAvatar(
  BuildContext context,
  WidgetRef ref,
) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery);
  if (file == null) return;

  final name = file.name.toLowerCase();
  final mime = file.mimeType?.toLowerCase() ?? '';
  final allowedExt =
      name.endsWith('.jpg') ||
      name.endsWith('.jpeg') ||
      name.endsWith('.png') ||
      name.endsWith('.webp');
  final allowedMime =
      mime == 'image/jpeg' || mime == 'image/png' || mime == 'image/webp';
  if (!allowedExt && !allowedMime) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please choose a JPEG, PNG, or WebP image.')),
    );
    return;
  }

  final bytes = await File(file.path).length();
  if (bytes > PassengerProfileRequests.maxAvatarBytes) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image must be 5 MB or smaller.')),
    );
    return;
  }

  final ok = await ref
      .read(passengerProfileControllerProvider.notifier)
      .uploadAvatar(
        filePath: file.path,
        filename: file.name,
        mimeType: file.mimeType,
      );
  if (!context.mounted) return;
  final error = ref.read(passengerProfileControllerProvider).errorMessage;
  if (!ok && error != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}
