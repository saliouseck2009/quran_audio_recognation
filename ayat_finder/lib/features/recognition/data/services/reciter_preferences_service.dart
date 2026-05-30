import 'package:ayat_finder/core/constants/reciters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReciterPreferencesService {
  ReciterPreferencesService(this._preferences);

  static const String _selectedReciterKey = 'selected_reciter_id';

  final SharedPreferences _preferences;

  String getSelectedReciterId() {
    final id = _preferences.getString(_selectedReciterKey);
    if (id == null || id.isEmpty) {
      return kDefaultReciterId;
    }

    final isKnownReciter = kReciterOptions.any((option) => option.id == id);
    return isKnownReciter ? id : kDefaultReciterId;
  }

  Future<void> setSelectedReciterId(String reciterId) async {
    await _preferences.setString(_selectedReciterKey, reciterId);
  }
}
