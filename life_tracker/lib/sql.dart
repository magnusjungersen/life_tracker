import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';  // Used to construct file paths

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the database path
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'life_tracker.db');

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create table of all data
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE life_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE, 
        mood INTEGER DEFAULT 50,
        energy INTEGER DEFAULT 50,
        productivity INTEGER DEFAULT 50,
        stress INTEGER DEFAULT 50,
        happy INTEGER DEFAULT 0,
        grateful INTEGER DEFAULT 0,
        inspired INTEGER DEFAULT 0,
        confident INTEGER DEFAULT 0,
        proud INTEGER DEFAULT 0,
        relaxed INTEGER DEFAULT 0,
        content INTEGER DEFAULT 0,
        curious INTEGER DEFAULT 0, 
        optimistic INTEGER DEFAULT 0, 
        loved INTEGER DEFAULT 0, 
        calm INTEGER DEFAULT 0, 
        hopeful INTEGER DEFAULT 0,
        tired INTEGER DEFAULT 0, 
        indifferent INTEGER DEFAULT 0, 
        bored INTEGER DEFAULT 0, 
        sad INTEGER DEFAULT 0, 
        lonely INTEGER DEFAULT 0, 
        anxious INTEGER DEFAULT 0, 
        frustrated INTEGER DEFAULT 0, 
        overwhelmed INTEGER DEFAULT 0, 
        angry INTEGER DEFAULT 0, 
        jealous INTEGER DEFAULT 0,  
        guilty INTEGER DEFAULT 0, 
        disappointed INTEGER DEFAULT 0, 
        nervous INTEGER DEFAULT 0, 
        grief INTEGER DEFAULT 0, 
        insecure INTEGER DEFAULT 0, 
        stressed INTEGER DEFAULT 0, 
        restless INTEGER DEFAULT 0, 
        nostalgic INTEGER DEFAULT 0, 
        conflicted INTEGER DEFAULT 0, 
        movies INTEGER DEFAULT 0, 
        read INTEGER DEFAULT 0, 
        intellectual_content INTEGER DEFAULT 0, 
	      gaming INTEGER DEFAULT 0, 
	      working_on_projects INTEGER DEFAULT 0, 
	      family INTEGER DEFAULT 0, 
	      friends INTEGER DEFAULT 0, 
	      party INTEGER DEFAULT 0, 
	      meeting_new_people INTEGER DEFAULT 0, 
	      concert INTEGER DEFAULT 0, 
	      festival INTEGER DEFAULT 0, 
	      alone_time INTEGER DEFAULT 0, 
	      organization INTEGER DEFAULT 0, 
        meditation INTEGER DEFAULT 0, 
	      read_before_going_to_bed INTEGER DEFAULT 0, 
	      no_screen_before_going_to_bed INTEGER DEFAULT 0, 
	      sunny INTEGER DEFAULT 0, 
	      cloudy INTEGER DEFAULT 0, 
	      rain INTEGER DEFAULT 0, 
	      snow INTEGER DEFAULT 0, 
	      heat INTEGER DEFAULT 0, 
	      storm INTEGER DEFAULT 0, 
	      wind INTEGER DEFAULT 0, 
	      class INTEGER DEFAULT 0, 
	      study INTEGER DEFAULT 0, 
	      exam INTEGER DEFAULT 0, 
	      work INTEGER DEFAULT 1, 
	      conference INTEGER DEFAULT 0, 
	      give_talk INTEGER DEFAULT 0, 
	      research INTEGER DEFAULT 0, 
        meetings INTEGER DEFAULT 0, 
	      management INTEGER DEFAULT 0, 
	      admin INTEGER DEFAULT 0, 
	      deep_work INTEGER DEFAULT 0, 
	      cleaning INTEGER DEFAULT 0, 
	      cooking_food INTEGER DEFAULT 0, 
	      other_practical_stuff INTEGER DEFAULT 0, 
	      exercise INTEGER DEFAULT 0, 
	      sport INTEGER DEFAULT 0, 
	      walk INTEGER DEFAULT 0,  
	      wellness INTEGER DEFAULT 0, 
	      swim INTEGER DEFAULT 0, 
	      sick INTEGER DEFAULT 0, 
	      sore INTEGER DEFAULT 0, 
	      pain INTEGER DEFAULT 0, 
	      drugs INTEGER DEFAULT 0,  
	      masturbation INTEGER DEFAULT 0, 
	      nap INTEGER DEFAULT 0,  
	      sex INTEGER DEFAULT 0, 
	      positive_event INTEGER DEFAULT 0, 
	      negative_event INTEGER DEFAULT 0, 
	      travel INTEGER DEFAULT 0, 
	      dont_have_own_room INTEGER DEFAULT 0, 
	      food INTEGER DEFAULT 2,
	      sleep INTEGER DEFAULT 2,
	      alcohol INTEGER DEFAULT 1,
	      caffeine INTEGER DEFAULT 1
      )
    ''');
  }

  Future<int> insertOrUpdateData(Map<String, dynamic> row) async {
    final db = await database;

    try {
      // print('Data to insert: $row'); // Print the data map for debugging
      return await db.insert(
        'life_tracking',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // print('Error inserting data: $e'); // Print any errors for debugging
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }

  Future<Map<String, dynamic>?> getDataByDate(String date) async {
    final db = await database;
    // Standardize the date to midnight UTC
    final standardDate = DateTime.parse(date).toUtc().toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'life_tracking',
      where: 'date = ?',
      whereArgs: [standardDate],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query('life_tracking', orderBy: 'date ASC');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
