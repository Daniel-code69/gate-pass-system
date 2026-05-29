import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import '../models/visitor.dart';
import '../main.dart' show firebaseAvailable;

class VisitorService {
  static final VisitorService instance = VisitorService._();
  DatabaseReference? _ref;
  static const _cacheBoxName = 'visitors_cache';

  VisitorService._();

  DatabaseReference get _db {
    _ref ??= FirebaseDatabase.instance.ref().child('visitors');
    return _ref!;
  }

  static List<Visitor> _parse(Map data) {
    final list = <Visitor>[];
    for (final entry in data.entries) {
      final m = Map<String, dynamic>.from(entry.value as Map);
      list.add(Visitor.fromMap(m));
    }
    list.sort((a, b) => b.entryTime.compareTo(a.entryTime));
    return list;
  }

  Future<void> addVisitor(Visitor v) async {
    final cache = await Hive.openBox<Map>(_cacheBoxName);
    await cache.put(v.passId, v.toMap());
    if (firebaseAvailable) {
      _db.child(v.passId).set(v.toMap()).catchError((_) {});
    }
  }

  Future<List<Visitor>> getAll() async {
    final byPassId = <String, Visitor>{};

    try {
      final cache = await Hive.openBox<Map>(_cacheBoxName);
      for (final key in cache.keys) {
        final val = cache.get(key);
        if (val != null) {
          byPassId[key] =
              Visitor.fromMap(Map<String, dynamic>.from(val));
        }
      }
    } catch (_) {}

    if (firebaseAvailable) {
      try {
        final snap = await _db.get();
        if (snap.exists) {
          for (final entry in (snap.value as Map).entries) {
            byPassId[entry.key] =
                Visitor.fromMap(Map<String, dynamic>.from(entry.value));
          }
        }
      } catch (_) {}
    }

    final list = byPassId.values.toList();
    list.sort((a, b) => b.entryTime.compareTo(a.entryTime));
    return list;
  }

  Future<Visitor?> getByPassId(String passId) async {
    try {
      final cache = await Hive.openBox<Map>(_cacheBoxName);
      final cached = cache.get(passId);
      if (cached != null) {
        return Visitor.fromMap(Map<String, dynamic>.from(cached));
      }
    } catch (_) {}

    if (firebaseAvailable) {
      try {
        final snap = await _db.child(passId).get();
        if (snap.exists) {
          final v = Visitor.fromMap(
              Map<String, dynamic>.from(snap.value as Map));
          return v;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<List<Visitor>> getActive() async {
    final all = await getAll();
    return all.where((v) => v.status == 'ACTIVE').toList();
  }

  Stream<List<Visitor>> getActiveStream() {
    if (!firebaseAvailable) return const Stream.empty();
    return _db.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final all =
          _parse(Map<String, dynamic>.from(data as Map));
      return all.where((v) => v.status == 'ACTIVE').toList();
    });
  }

  Future<Map<String, int>> getStats() async {
    final all = await getAll();
    int total = 0, pending = 0, active = 0, exited = 0;
    for (final v in all) {
      total++;
      switch (v.status) {
        case 'PENDING': pending++;
        case 'ACTIVE': active++;
        case 'EXITED': exited++;
      }
    }
    return {
      'total': total, 'pending': pending,
      'active': active, 'exited': exited,
    };
  }

  Future<List<Visitor>> search(String query, {String filter = 'ALL'}) async {
    final q = query.toLowerCase().trim();
    final all = await getAll();
    return all.where((v) {
      final matchSearch = q.isEmpty ||
          v.fullName.toLowerCase().contains(q) ||
          v.phone.contains(q) ||
          v.passId.toLowerCase().contains(q);
      final matchFilter = filter == 'ALL' || v.status == filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  Future<void> confirmEntry(String passId) async {
    try {
      final cache = await Hive.openBox<Map>(_cacheBoxName);
      final cached = cache.get(passId);
      if (cached != null) {
        cached['status'] = 'ACTIVE';
        cached['entryTime'] = DateTime.now().millisecondsSinceEpoch;
        await cache.put(passId, cached);
        if (firebaseAvailable) {
          await _db.child(passId)
              .set(Map<String, dynamic>.from(cached));
        }
        return;
      }
    } catch (_) {}
    if (firebaseAvailable) {
      await _db.child(passId).update({
        'status': 'ACTIVE',
        'entryTime': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> markExit(String passId) async {
    try {
      final cache = await Hive.openBox<Map>(_cacheBoxName);
      final cached = cache.get(passId);
      if (cached != null) {
        cached['status'] = 'EXITED';
        cached['exitTime'] = DateTime.now().millisecondsSinceEpoch;
        await cache.put(passId, cached);
        if (firebaseAvailable) {
          await _db.child(passId)
              .set(Map<String, dynamic>.from(cached));
        }
        return;
      }
    } catch (_) {}
    if (firebaseAvailable) {
      await _db.child(passId).update({
        'status': 'EXITED',
        'exitTime': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
