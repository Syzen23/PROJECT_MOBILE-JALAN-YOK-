import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';
import '../models/user_model.dart';
import '../models/trip_history_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService._init();

  // Collection references
  CollectionReference get _destinationsCol => _db.collection('destinations');
  CollectionReference get _usersCol => _db.collection('users');
  CollectionReference get _tripHistoryCol => _db.collection('trip_history');
  CollectionReference get _chatSessionsCol => _db.collection('chat_sessions');

  // ============================================================
  // INITIALIZATION - Seed dummy data if collections are empty
  // ============================================================
  Future<void> seedIfEmpty() async {
    final snapshot = await _destinationsCol.limit(1).get();
    if (snapshot.docs.isEmpty) {
      await _seedDestinations();
      await _seedUsers();
    }
  }

  Future<void> _seedDestinations() async {
    final dummyDestinations = [
      Destination(
        title: 'Pantai Marina',
        location: 'Kalianda, Lampung',
        image: 'assets/images/Pantai.png',
        rating: 4.8,
        visitors: '1K+ Pengunjung',
        tiket: 45000.0,
        waktu: 3,
      ),
      Destination(
        title: 'Gunung Bromo',
        location: 'Jawa Timur',
        image: 'assets/images/BromoCard.png',
        rating: 4.9,
        visitors: '5K+ Pengunjung',
        tiket: 35000.0,
        waktu: 12,
      ),
      Destination(
        title: 'Tari Kecak',
        location: 'Pura Luhur Uluwatu, Bali',
        image: 'assets/images/FestivalCard.png',
        rating: 4.8,
        visitors: '2K+ Pengunjung',
        tiket: 150000.0,
        waktu: 24,
      ),
      Destination(
        title: 'Nusa Penida',
        location: 'Bali',
        image: 'assets/images/NusaPenidaCard.png',
        rating: 4.9,
        visitors: '3K+ Pengunjung',
        tiket: 25000.0,
        waktu: 25,
      ),
      Destination(
        title: 'Toraja',
        location: 'Sulawesi Selatan',
        image: 'assets/images/TorajaCard.png',
        rating: 4.7,
        visitors: '1K+ Pengunjung',
        tiket: 50000.0,
        waktu: 48,
      ),
    ];

    for (var dest in dummyDestinations) {
      final map = dest.toMap();
      map.remove('id');
      await _destinationsCol.add(map);
    }
  }

  Future<void> _seedUsers() async {
    await _usersCol.add({
      'name': 'Admin User',
      'email': 'admin@jalanyok.com',
      'password': 'password123',
      'role': 'admin',
      'phone_number': '081234567890',
      'age': 25,
      'date_of_birth': '1999-01-01',
      'gender': 'Laki-laki',
      'address': 'Jl. Admin No. 1',
    });
    await _usersCol.add({
      'name': 'Regular User',
      'email': 'user@jalanyok.com',
      'password': 'password123',
      'role': 'user',
      'phone_number': '089876543210',
      'age': 20,
      'date_of_birth': '2004-05-05',
      'gender': 'Perempuan',
      'address': 'Jl. User No. 2',
    });
  }

  // ============================================================
  // DESTINATION OPERATIONS
  // ============================================================
  Future<Destination> create(Destination destination) async {
    final map = destination.toMap();
    map.remove('id');
    final docRef = await _destinationsCol.add(map);
    return Destination(
      id: docRef.id,
      title: destination.title,
      location: destination.location,
      image: destination.image,
      rating: destination.rating,
      visitors: destination.visitors,
      tiket: destination.tiket,
      waktu: destination.waktu,
    );
  }

  Future<List<Destination>> getAllDestinations() async {
    final snapshot = await _destinationsCol.get();
    return snapshot.docs.map((doc) {
      return Destination.fromMap(
        doc.data() as Map<String, dynamic>,
        documentId: doc.id,
      );
    }).toList();
  }

  Future<List<Destination>> searchDestinations(String query) async {
    // Firestore doesn't support LIKE queries, so we fetch all and filter locally
    final all = await getAllDestinations();
    final lowerQuery = query.toLowerCase();
    return all.where((d) =>
      d.title.toLowerCase().contains(lowerQuery) ||
      d.location.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Future<void> updateDestination(Destination destination) async {
    if (destination.id == null) return;
    final map = destination.toMap();
    map.remove('id');
    await _destinationsCol.doc(destination.id).update(map);
  }

  Future<void> deleteDestination(String id) async {
    await _destinationsCol.doc(id).delete();
  }

  // ============================================================
  // USER OPERATIONS
  // ============================================================
  Future<void> updateUser(User user) async {
    if (user.id == null) return;
    final map = user.toMap();
    map.remove('id');
    await _usersCol.doc(user.id).update(map);
  }

  Future<void> updatePassword(String userId, String newPassword) async {
    await _usersCol.doc(userId).update({'password': newPassword});
  }

  Future<User?> login(String email, String password) async {
    final snapshot = await _usersCol
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return User.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final snapshot = await _usersCol
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return User.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id);
    }
    return null;
  }

  Future<User?> register(User user) async {
    // Check if email already exists
    final existing = await getUserByEmail(user.email);
    if (existing != null) return null;

    final map = user.toMap();
    map.remove('id');
    final docRef = await _usersCol.add(map);
    return User(
      id: docRef.id,
      name: user.name,
      email: user.email,
      password: user.password,
      role: user.role,
      phoneNumber: user.phoneNumber,
      age: user.age,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      address: user.address,
    );
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _usersCol.get();
    return snapshot.docs.map((doc) {
      return User.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id);
    }).toList();
  }

  // ============================================================
  // TRIP HISTORY OPERATIONS
  // ============================================================
  Future<TripHistory> insertTripHistory(TripHistory history) async {
    final map = history.toMap();
    map.remove('id');
    final docRef = await _tripHistoryCol.add(map);
    return TripHistory(
      id: docRef.id,
      userId: history.userId,
      destinationId: history.destinationId,
      transport: history.transport,
      totalBudget: history.totalBudget,
      date: history.date,
    );
  }

  Future<List<Map<String, dynamic>>> getTripHistoryForUser(String userId) async {
    final snapshot = await _tripHistoryCol
        .where('user_id', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> results = [];
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Fetch destination info
      final destId = data['destination_id'].toString();
      final destDoc = await _destinationsCol.doc(destId).get();
      final destData = destDoc.data() as Map<String, dynamic>?;

      results.add({
        ...data,
        'id': doc.id,
        'title': destData?['title'] ?? 'Unknown',
        'image': destData?['image'] ?? '',
        'location': destData?['location'] ?? '',
      });
    }
    // Sort by date descending (newest first)
    results.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
    return results;
  }

  // ============================================================
  // CHAT SESSIONS OPERATIONS
  // ============================================================
  Future<String> createChatSession({
    required String userId,
    required String title,
    required List<Map<String, String>> initialMessages,
  }) async {
    final docRef = await _chatSessionsCol.add({
      'user_id': userId,
      'title': title,
      'messages': initialMessages,
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateChatSessionMessages(String sessionId, List<Map<String, String>> messages) async {
    await _chatSessionsCol.doc(sessionId).update({
      'messages': messages,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getChatSessionsForUser(String userId) async {
    try {
      final snapshot = await _chatSessionsCol
          .where('user_id', isEqualTo: userId)
          .get();

      var docs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      // Sort locally to avoid needing a composite index in Firestore
      docs.sort((a, b) {
        final aTime = a['updated_at'] as Timestamp?;
        final bTime = b['updated_at'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return docs;
    } catch (e) {
      print("Error loading chat sessions: $e");
      return [];
    }
  }

  Future<void> deleteChatSession(String sessionId) async {
    await _chatSessionsCol.doc(sessionId).delete();
  }
}
