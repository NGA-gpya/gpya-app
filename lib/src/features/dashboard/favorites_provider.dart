import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  static const _key = 'favorite_documents';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList(_key);
    if (favorites != null) {
      state = favorites.toSet();
    }
  }

  Future<void> toggleFavorite(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    final newFavorites = Set<String>.from(state);
    
    if (newFavorites.contains(docId)) {
      newFavorites.remove(docId);
    } else {
      newFavorites.add(docId);
    }
    
    state = newFavorites;
    await prefs.setStringList(_key, newFavorites.toList());
  }

  bool isFavorite(String docId) => state.contains(docId);
}
