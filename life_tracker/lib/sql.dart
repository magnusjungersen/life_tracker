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
        date TEXT NOT NULL, 
        mood INTEGER,
        energy INTEGER,
        productivity INTEGER,
        stress INTEGER,
        happy INTEGER DEFAULT 0,
        grateful INTEGER DEFAULT 0,
        inspired INTEGER DEFAULT 0,
        confident INTEGER DEFAULT 0,
        proud INTEGER DEFAULT 0,
        relaxed INTEGER DEFAULT 0,
        content INTEGER DEFAULT 0,
        Curious INTEGER DEFAULT 0, 
        Optimistic INTEGER DEFAULT 0, 
        Loved INTEGER DEFAULT 0, 
        Calm INTEGER DEFAULT 0, 
        Hopeful INTEGER DEFAULT 0,
        Tired INTEGER DEFAULT 0, 
        Indifferent INTEGER DEFAULT 0, 
        Bored INTEGER DEFAULT 0, 
        Sad INTEGER DEFAULT 0, 
        Lonely INTEGER DEFAULT 0, 
        Anxious INTEGER DEFAULT 0, 
        Frustrated INTEGER DEFAULT 0, 
        Overwhelmed INTEGER DEFAULT 0, 
        Angry INTEGER DEFAULT 0, 
        Jealous INTEGER DEFAULT 0,  
        Guilty INTEGER DEFAULT 0, 
        Disappointed INTEGER DEFAULT 0, 
        Nervous INTEGER DEFAULT 0, 
        Grief INTEGER DEFAULT 0, 
        Insecure INTEGER DEFAULT 0, 
        Stressed INTEGER DEFAULT 0, 
        Restless INTEGER DEFAULT 0, 
        Nostalgic INTEGER DEFAULT 0, 
        Conflicted INTEGER DEFAULT 0, 
        Movies INTEGER DEFAULT 0, 
        Read INTEGER DEFAULT 0, 
        Intellectual_content INTEGER DEFAULT 0, 
	      Gaming INTEGER DEFAULT 0, 
	      Working_on_projects INTEGER DEFAULT 0, 
	      Family INTEGER DEFAULT 0, 
	      Friends INTEGER DEFAULT 0, 
	      Party INTEGER DEFAULT 0, 
	      Meeting_new_people INTEGER DEFAULT 0, 
	      Concert INTEGER DEFAULT 0, 
	      Festival INTEGER DEFAULT 0, 
	      Alone time INTEGER DEFAULT 0, 
	      Organization INTEGER DEFAULT 0, 
        Meditation INTEGER DEFAULT 0, 
	      Read_before_going_to_bed INTEGER DEFAULT 0, 
	      No_screen_before_going_to_bed INTEGER DEFAULT 0, 
	      Sunny INTEGER DEFAULT 0, 
	      Cloudy INTEGER DEFAULT 0, 
	      Rain INTEGER DEFAULT 0, 
	      Snow INTEGER DEFAULT 0, 
	      Heat INTEGER DEFAULT 0, 
	      Storm INTEGER DEFAULT 0, 
	      Wind INTEGER DEFAULT 0, 
	      Class INTEGER DEFAULT 0, 
	      Study INTEGER DEFAULT 0, 
	      Exam INTEGER DEFAULT 0, 
	      Work INTEGER, INTEGER DEFAULT 0, 
	      Conference INTEGER DEFAULT 0, 
	      Give_talk INTEGER DEFAULT 0, 
	      Research INTEGER DEFAULT 0, 
        Meetings INTEGER DEFAULT 0, 
	      Management INTEGER DEFAULT 0, 
	      Admin INTEGER DEFAULT 0, 
	      Deep_work INTEGER DEFAULT 0, 
	      Cleaning INTEGER DEFAULT 0, 
	      Cooking_food INTEGER DEFAULT 0, 
	      Other_practical_stuff INTEGER DEFAULT 0, 
	      Exercise INTEGER DEFAULT 0, 
	      Sport INTEGER DEFAULT 0, 
	      Walk INTEGER DEFAULT 0,  
	      Wellness  INTEGER DEFAULT 0, 
	      Swim INTEGER DEFAULT 0, 
	      Sick INTEGER DEFAULT 0, 
	      Sore INTEGER DEFAULT 0, 
	      Pain INTEGER DEFAULT 0, 
	      Drugs INTEGER DEFAULT 0,  
	      Masturbation INTEGER DEFAULT 0, 
	      Nap INTEGER DEFAULT 0,  
	      Sex INTEGER DEFAULT 0, 
	      Postive_event INTEGER DEFAULT 0, 
	      Negative_event INTEGER DEFAULT 0, 
	      Travel INTEGER DEFAULT 0, 
	      Dont_have_own_room INTEGER DEFAULT 0, 
	      Food INTEGER,
	      Sleep INTEGER,
	      Alcohol INTEGER,
	      Caffeine INTEGER,
      )
    ''');
  }

  Future<int> insertOrUpdateData(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      'life_tracking',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getDataByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'life_tracking',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
