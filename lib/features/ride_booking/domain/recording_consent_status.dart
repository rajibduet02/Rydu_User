import 'entities/ride_planning_entities.dart';

/// Passenger-facing recording consent lifecycle (single source of truth).
enum RecordingConsentStatus {
  unknown,
  required,
  submitting,
  granted,
  denied,
  failed,
  notRequired,
}

/// Resolves authoritative consent from booking / socket / API fields.
RecordingConsentStatus resolveRecordingConsentStatus({
  required bool isAssignedRidePhase,
  RecordingConsentInfo? info,
  RecordingConsentStatus? preserveTransient,
}) {
  if (preserveTransient == RecordingConsentStatus.submitting) {
    return RecordingConsentStatus.submitting;
  }

  final raw = (info?.consentStatus ?? '').trim().toLowerCase();
  final consentedAt = info?.recordingConsentedAt?.trim();
  final consented = info?.consented;
  final required = info?.required;

  if (raw == 'granted' ||
      raw == 'approved' ||
      raw == 'allowed') {
    return RecordingConsentStatus.granted;
  }
  if (raw == 'not_required') {
    return RecordingConsentStatus.notRequired;
  }
  if (raw == 'denied' || raw == 'revoked' || raw == 'rejected') {
    return RecordingConsentStatus.denied;
  }

  if (consented == false) {
    return RecordingConsentStatus.denied;
  }
  if (consented == true ||
      (consentedAt != null && consentedAt.isNotEmpty)) {
    return RecordingConsentStatus.granted;
  }

  if (!isAssignedRidePhase) {
    return RecordingConsentStatus.unknown;
  }

  if (raw == 'pending' ||
      raw == 'required' ||
      raw == 'awaiting' ||
      raw == 'denied_pending') {
    return RecordingConsentStatus.required;
  }

  if (required == false) {
    return RecordingConsentStatus.notRequired;
  }
  if (required == true) {
    return RecordingConsentStatus.required;
  }

  // Assigned ride with no decision yet: consent is expected for video flow.
  if (preserveTransient == RecordingConsentStatus.failed) {
    return RecordingConsentStatus.failed;
  }

  return RecordingConsentStatus.required;
}
