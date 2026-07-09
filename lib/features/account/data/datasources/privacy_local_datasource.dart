abstract interface class PrivacyLocalDatasource {
  Future<void> requestDataDownload();
}

class PrivacyLocalDatasourceImpl implements PrivacyLocalDatasource {
  @override
  Future<void> requestDataDownload() async {
    // TODO: Submit personal data archive request to privacy/backend API.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
