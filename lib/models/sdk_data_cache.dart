class SdkDataCache {
  SdkDataCache._internal();

  factory SdkDataCache() => _instance;

  static final SdkDataCache _instance = SdkDataCache._internal();

  String? appId;
  String? appKey;
  String? appSecret;
}
