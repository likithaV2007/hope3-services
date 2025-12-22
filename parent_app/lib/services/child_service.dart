import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';

class ChildService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ChildModel>> getParentChildren(String parentId) async {
    final snapshot = await _firestore
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .get();
    
    return snapshot.docs
        .map((doc) => ChildModel.fromMap(doc.data()))
        .toList();
  }

  Future<ChildModel?> getChild(String childId) async {
    final doc = await _firestore.collection('children').doc(childId).get();
    return doc.exists ? ChildModel.fromMap(doc.data()!) : null;
  }

  Stream<List<ChildModel>> watchParentChildren(String parentId) {
    return _firestore
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChildModel.fromMap(doc.data()))
            .toList());
  }
}