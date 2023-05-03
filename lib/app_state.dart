import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr_tools/nostr_tools.dart';

class StorageItem {
  StorageItem(this.key, this.value);

  final String key;
  final String value;
}

class AppState with ChangeNotifier {
  final _keyGenerator = KeyApi();
  final _nip19 = Nip19();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
    // sharedPreferencesName: 'Test2',
    // preferencesKeyPrefix: 'Test'
  );
  IOSOptions _getIOSOptions() => const IOSOptions(
    accountName: "flutter_secure_storage_service",
  );

  List<StorageItem> items = [];
  TextEditingController nsecController = TextEditingController();

  void generateNewNsec() {
    var privateHex = _keyGenerator.generatePrivateKey();
    var publicHex =  _keyGenerator.getPublicKey(privateHex);
    var nsecKey = _nip19.nsecEncode(privateHex);
    var npubKey = _nip19.npubEncode(publicHex);

    notifyListeners();
  }
  void submitUserNsec() {
    var privateHex = _nip19.decode(nsecController.text);
    var publicHex = _keyGenerator.getPublicKey(privateHex['data']);

    notifyListeners();
  }

  Future<void> addSecret(String key, String? value) async {
    await _storage.write(
      key: key,
      value: value,
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    readSecrets();
  }

  Future<void> readSecrets() async {
    final all = await _storage.readAll(
      iOptions: _getIOSOptions(),
      aOptions: _getAndroidOptions(),
    );
    items = all.entries
      .map((entry) => StorageItem(entry.key, entry.value))
      .toList(growable: false);
  }
}