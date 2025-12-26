import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> addToFavorites(Product product) async {
    if (_userId == null) return;
    try {
      await _firestore.collection('users').doc(_userId).collection('favorites').doc(product.id.toString()).set({
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    if (_userId == null) return;
    await _firestore.collection('users').doc(_userId).collection('favorites').doc(productId.toString()).delete();
  }

  Future<bool> isFavorite(int productId) async {
    if (_userId == null) return false;
    try {
      final doc = await _firestore.collection('users').doc(_userId).collection('favorites').doc(productId.toString()).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getFavorites() {
    if (_userId == null) return Stream.value([]);
    return _firestore.collection('users').doc(_userId).collection('favorites').snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}