import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/destination_model.dart';
import '../models/user_model.dart';
import '../models/trip_history_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('jalanyok.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // If upgrading to version 3, drop and recreate
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS destinations');
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS trip_history');
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE destinations (
  id $idType,
  title $textType,
  location $textType,
  image $textType,
  rating $doubleType,
  visitors $textType,
  tiket $doubleType,
  waktu $intType
  )
''');

    await db.execute('''
CREATE TABLE users (
  id $idType,
  name $textType,
  email $textType,
  password $textType,
  role $textType
  )
''');

    await db.execute('''
CREATE TABLE trip_history (
  id $idType,
  user_id $intType,
  destination_id $intType,
  transport $textType,
  total_budget $doubleType,
  date $textType
  )
''');

    // Insert dummy users
    await db.insert('users', {
      'name': 'Admin User',
      'email': 'admin@jalanyok.com',
      'password': 'password123',
      'role': 'admin',
    });

    await db.insert('users', {
      'name': 'Regular User',
      'email': 'user@jalanyok.com',
      'password': 'password123',
      'role': 'user',
    });

    // Insert dummy data
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

    for (var destination in dummyDestinations) {
      await db.insert('destinations', destination.toMap());
    }
  }

  Future<Destination> create(Destination destination) async {
    final db = await instance.database;
    final id = await db.insert('destinations', destination.toMap());
    return Destination(
      id: id,
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
    final db = await instance.database;
    final result = await db.query('destinations');
    return result.map((json) => Destination.fromMap(json)).toList();
  }

  Future<List<Destination>> searchDestinations(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'destinations',
      where: 'LOWER(title) LIKE ? OR LOWER(location) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%', '%${query.toLowerCase()}%'],
    );
    return result.map((json) => Destination.fromMap(json)).toList();
  }

  Future<int> updateDestination(Destination destination) async {
    final db = await instance.database;
    return await db.update(
      'destinations',
      destination.toMap(),
      where: 'id = ?',
      whereArgs: [destination.id],
    );
  }

  Future<int> deleteDestination(int id) async {
    final db = await instance.database;
    return await db.delete('destinations', where: 'id = ?', whereArgs: [id]);
  }

  // --- User Operations ---
  Future<User?> login(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> register(User user) async {
    final db = await instance.database;
    // Check if email exists
    final exists = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );
    if (exists.isNotEmpty) return null;

    final id = await db.insert('users', user.toMap());
    return User(
      id: id,
      name: user.name,
      email: user.email,
      password: user.password,
      role: user.role,
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((json) => User.fromMap(json)).toList();
  }

  // --- Trip History Operations ---
  Future<TripHistory> insertTripHistory(TripHistory history) async {
    final db = await instance.database;
    final id = await db.insert('trip_history', history.toMap());
    return TripHistory(
      id: id,
      userId: history.userId,
      destinationId: history.destinationId,
      transport: history.transport,
      totalBudget: history.totalBudget,
      date: history.date,
    );
  }

  Future<List<Map<String, dynamic>>> getTripHistoryForUser(int userId) async {
    final db = await instance.database;
    // Join with destinations to get title and image
    final result = await db.rawQuery(
      '''
      SELECT h.*, d.title, d.image, d.location 
      FROM trip_history h
      JOIN destinations d ON h.destination_id = d.id
      WHERE h.user_id = ?
      ORDER BY h.id DESC
    ''',
      [userId],
    );
    return result;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
