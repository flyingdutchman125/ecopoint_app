import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'history_state.dart';

class PrimaryAddressCooldownException implements Exception {
  final String message;
  final int remainingSeconds;
  PrimaryAddressCooldownException(this.message, {required this.remainingSeconds});
  @override
  String toString() => message;
}

/// Central persistent state for User Addresses & Real GPS Detection
class AddressState {
  AddressState._internal();
  static final AddressState instance = AddressState._internal();

  static const String _storageKey = 'ecopoint_user_addresses_v2';
  static const String _selectedIndexKey = 'ecopoint_selected_address_index_v2';
  static const String _lastPrimaryChangeKey = 'ecopoint_last_primary_address_changed_v2';

  final ValueNotifier<List<Map<String, String>>> addresses = ValueNotifier<List<Map<String, String>>>([]);
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  DateTime? lastPrimaryAddressChangedAt;
  bool _initialized = false;

  Map<String, String>? get activeAddress {
    if (addresses.value.isEmpty) return null;
    final idx = selectedIndex.value;
    if (idx >= 0 && idx < addresses.value.length) {
      return addresses.value[idx];
    }
    return addresses.value.first;
  }

  /// Returns remaining cooldown duration if primary address was changed within 24 hours
  Duration? get primaryAddressCooldownRemaining {
    if (lastPrimaryAddressChangedAt == null) return null;
    final nextAllowed = lastPrimaryAddressChangedAt!.add(const Duration(hours: 24));
    final now = DateTime.now();
    if (now.isBefore(nextAllowed)) {
      return nextAllowed.difference(now);
    }
    return null;
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      final int savedIdx = prefs.getInt(_selectedIndexKey) ?? 0;
      final String? lastChangeStr = prefs.getString(_lastPrimaryChangeKey);

      if (lastChangeStr != null && lastChangeStr.isNotEmpty) {
        lastPrimaryAddressChangedAt = DateTime.tryParse(lastChangeStr);
      }

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final List<Map<String, String>> loaded = decoded.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            'label': map['label']?.toString() ?? 'Alamat Saya',
            'detail': map['detail']?.toString() ?? '',
            'lat': map['lat']?.toString() ?? '-7.1185',
            'lng': map['lng']?.toString() ?? '112.4166',
          };
        }).toList();

        if (loaded.isNotEmpty) {
          addresses.value = loaded;
          selectedIndex.value = (savedIdx >= 0 && savedIdx < loaded.length) ? savedIdx : 0;
          return;
        }
      }

      // Default initial addresses if none stored yet
      addresses.value = [
        {
          'label': 'Rumah Admin',
          'detail': 'Jln. Andansari Mojo GG duku No. 3, RT 001/ RW 003, Kelurahan Sukorejo (Rumah Cat Hijau)',
          'lat': '-7.1185',
          'lng': '112.4166',
        },
        {
          'label': 'Rumah Si mbah',
          'detail': 'Jl. Kali utik di walik dadi batagor enak nyam nyam no 3 Gerobak abu abu dan blue',
          'lat': '-7.1170',
          'lng': '112.4150',
        },
      ];
      selectedIndex.value = 0;
      await _saveToPrefs();
    } catch (e) {
      debugPrint('Error loading address state: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(addresses.value);
      await prefs.setString(_storageKey, jsonStr);
      await prefs.setInt(_selectedIndexKey, selectedIndex.value);
      if (lastPrimaryAddressChangedAt != null) {
        await prefs.setString(_lastPrimaryChangeKey, lastPrimaryAddressChangedAt!.toIso8601String());
      }
    } catch (e) {
      debugPrint('Error saving address state: $e');
    }
  }

  Future<void> addAddress({required String label, required String detail, String? lat, String? lng}) async {
    await init();
    final newList = List<Map<String, String>>.from(addresses.value);
    newList.add({
      'label': label,
      'detail': detail,
      'lat': lat ?? '-7.1185',
      'lng': lng ?? '112.4166',
    });
    addresses.value = newList;
    await _saveToPrefs();

    HistoryState.instance.addHistory(
      title: 'Tambah Alamat Baru',
      description: 'Menambahkan lokasi "$label": $detail',
      category: 'Alamat',
      valueChange: 'Alamat Tersimpan',
    );
  }

  Future<void> deleteAddress(int index) async {
    await init();
    if (index < 0 || index >= addresses.value.length) return;
    final newList = List<Map<String, String>>.from(addresses.value);
    newList.removeAt(index);
    addresses.value = newList;

    if (newList.isEmpty) {
      selectedIndex.value = -1;
    } else if (selectedIndex.value >= newList.length) {
      selectedIndex.value = newList.length - 1;
    }
    await _saveToPrefs();
  }

  /// Changes primary address with mandatory 24-hour cooldown rule
  Future<bool> selectAddress(int index) async {
    await init();
    if (index < 0 || index >= addresses.value.length) return false;
    
    // If already primary, no action needed
    if (selectedIndex.value == index) return true;

    // Enforce 24-hour cooldown
    final cooldown = primaryAddressCooldownRemaining;
    if (cooldown != null) {
      final hours = cooldown.inHours;
      final minutes = cooldown.inMinutes % 60;
      final timeStr = hours > 0 ? '$hours jam $minutes menit' : '$minutes menit';
      throw PrimaryAddressCooldownException(
        'Alamat Utama hanya dapat diubah kembali setelah 24 jam. Sisa waktu penunggu: $timeStr.',
        remainingSeconds: cooldown.inSeconds,
      );
    }

    selectedIndex.value = index;
    lastPrimaryAddressChangedAt = DateTime.now();
    await _saveToPrefs();

    final selected = addresses.value[index];
    HistoryState.instance.addHistory(
      title: 'Ubah Alamat Utama',
      description: 'Mengubah alamat utama menjadi "${selected['label']}": ${selected['detail']}',
      category: 'Alamat',
      valueChange: 'Alamat Utama Diperbarui',
    );

    return true;
  }

  /// Real GPS location detection + Reverse Geocoding with OSM Nominatim
  Future<Map<String, String>> detectCurrentLocation() async {
    isLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      double lat = -7.1185;
      double lng = 112.4166;
      bool positionObtained = false;

      if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
        try {
          Position pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 6)),
          );
          lat = pos.latitude;
          lng = pos.longitude;
          positionObtained = true;
        } catch (_) {
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) {
            lat = lastPos.latitude;
            lng = lastPos.longitude;
            positionObtained = true;
          }
        }
      }

      // Reverse Geocoding via OpenStreetMap Nominatim API
      String formattedAddress = '';
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng');
        final response = await http.get(url, headers: {'User-Agent': 'ecopoint_app/1.0'}).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('display_name')) {
            formattedAddress = data['display_name'].toString();
          }
        }
      } catch (e) {
        debugPrint('Reverse geocode error: $e');
      }

      if (formattedAddress.isEmpty) {
        if (positionObtained) {
          formattedAddress = 'Jl. Raya Babat - Lamongan No. 42, RT 02/RW 01, Sukorejo, Lamongan (Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)})';
        } else {
          formattedAddress = 'Jln. Andansari Mojo GG duku No. 3, RT 001/ RW 003, Kelurahan Sukorejo';
        }
      }

      return {
        'label': 'Lokasi Terdeteksi (GPS)',
        'detail': formattedAddress,
        'lat': lat.toString(),
        'lng': lng.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }
}
