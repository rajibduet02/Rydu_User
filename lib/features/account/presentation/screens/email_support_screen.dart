import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/email_support_provider.dart';
import '../theme/email_support_tokens.dart';
import '../widgets/email_attachment_box.dart';
import '../widgets/email_support_dropdown.dart';
import '../widgets/email_support_text_field.dart';

class EmailSupportScreen extends ConsumerStatefulWidget {
  const EmailSupportScreen({super.key});

  @override
  ConsumerState<EmailSupportScreen> createState() => _EmailSupportScreenState();
}

class _EmailSupportScreenState extends ConsumerState<EmailSupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _popOrHelpCenter(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.helpCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(emailSupportControllerProvider);
    final c = ref.read(emailSupportControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.048).clamp(17.0, 19.0);
    final headingSize = (w * 0.065).clamp(22.0, 26.0);
    final subSize = (w * 0.038).clamp(14.0, 15.0);
    final gap = (w * 0.045).clamp(16.0, 20.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    ref.listen(emailSupportControllerProvider, (prev, next) {
      final snack = next.snackMessage;
      if (snack != null && snack.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: EmailSupportTokens.card,
          ),
        );
        c.clearSnack();
        if (next.submitSucceeded) {
          Future<void>.delayed(const Duration(milliseconds: 400), () {
            if (!context.mounted) return;
            c.navigateAfterSuccess();
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: EmailSupportTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, hPad, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _popOrHelpCenter(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: EmailSupportTokens.accent,
                      size: (w * 0.05).clamp(20.0, 22.0),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Live Chat Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: EmailSupportTokens.white,
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.12).clamp(44.0, 48.0)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Support',
                      style: TextStyle(
                        color: EmailSupportTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: headingSize,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: (w * 0.025).clamp(8.0, 10.0)),
                    Text(
                      'Send us your issue and our team will reply by email.',
                      style: TextStyle(
                        color: EmailSupportTokens.muted,
                        fontSize: subSize,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: gap),
                    if (s.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          s.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all((w * 0.045).clamp(16.0, 18.0)),
                      decoration: BoxDecoration(
                        color: EmailSupportTokens.card,
                        borderRadius: BorderRadius.circular(
                          (w * 0.04).clamp(14.0, 16.0),
                        ),
                        border: Border.all(color: EmailSupportTokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          EmailSupportTextField(
                            label: 'SUBJECT',
                            hint: "What's the issue?",
                            controller: _subjectController,
                            onChanged: c.updateSubject,
                          ),
                          SizedBox(height: gap),
                          EmailSupportDropdown(
                            value: s.selectedCategory,
                            onChanged: c.updateCategory,
                          ),
                          SizedBox(height: gap),
                          EmailSupportTextField(
                            label: 'MESSAGE',
                            hint: 'Describe your problem in detail...',
                            controller: _messageController,
                            onChanged: c.updateMessage,
                            maxLines: 6,
                            minLines: 5,
                          ),
                          SizedBox(height: gap),
                          EmailAttachmentBox(
                            attachmentPath: s.attachmentPath,
                            onTap: c.pickAttachment,
                            onRemove: c.removeAttachment,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: EmailSupportTokens.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: EmailSupportTokens.muted,
                                fontSize: subSize,
                                height: 1.35,
                              ),
                              children: const [
                                TextSpan(text: 'Average response time: '),
                                TextSpan(
                                  text: '~2 hours',
                                  style: TextStyle(
                                    color: EmailSupportTokens.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPad,
                8,
                hPad,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: (w * 0.14).clamp(52.0, 56.0),
                child: FilledButton(
                  onPressed: s.isFormValid && !s.isSubmitting
                      ? () => c.submitRequest()
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: EmailSupportTokens.accent,
                    disabledBackgroundColor: EmailSupportTokens.accent
                        .withValues(alpha: 0.35),
                    foregroundColor: EmailSupportTokens.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        (w * 0.04).clamp(14.0, 16.0),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: s.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: EmailSupportTokens.white,
                          ),
                        )
                      : Text(
                          'Submit Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: (w * 0.042).clamp(15.0, 16.0),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
