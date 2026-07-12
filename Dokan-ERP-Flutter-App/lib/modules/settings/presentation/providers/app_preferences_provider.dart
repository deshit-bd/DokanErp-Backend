import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesState {
  final bool barcodeRequired;
  final bool offlineCache;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const AppPreferencesState({
    this.barcodeRequired = true,
    this.offlineCache = true,
    this.soundEnabled = true,
    this.vibrationEnabled = false,
  });

  AppPreferencesState copyWith({
    bool? barcodeRequired,
    bool? offlineCache,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return AppPreferencesState(
      barcodeRequired: barcodeRequired ?? this.barcodeRequired,
      offlineCache: offlineCache ?? this.offlineCache,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class AppPreferencesNotifier extends StateNotifier<AppPreferencesState> {
  AppPreferencesNotifier() : super(const AppPreferencesState()) {
    _load();
  }

  static const _barcodeRequiredKey = 'dokan_barcode_required';
  static const _offlineCacheKey = 'dokan_offline_cache';
  static const _soundKey = 'dokan_sound';
  static const _vibrationKey = 'dokan_vibration';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppPreferencesState(
      barcodeRequired: prefs.getBool(_barcodeRequiredKey) ?? true,
      offlineCache: prefs.getBool(_offlineCacheKey) ?? true,
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? false,
    );
  }

  Future<void> setBarcodeRequired(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_barcodeRequiredKey, value);
    state = state.copyWith(barcodeRequired: value);
  }

  Future<void> setOfflineCache(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineCacheKey, value);
    state = state.copyWith(offlineCache: value);
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
    state = state.copyWith(soundEnabled: value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
    state = state.copyWith(vibrationEnabled: value);
  }

  void triggerFeedback() {
    if (state.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (state.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferencesState>((ref) {
  return AppPreferencesNotifier();
});
