import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'soldticketmodel.dart';

class DBprovider{
  DBprovider._();

  static final DBprovider db =DBprovider._();
  static Database _database;

  Future<Database> get database async{
    if(_database != null){
      return _database;
    }else{
      _database=await initDB();
      return _database;
    }
  }

  initDB () async{
    return await openDatabase(
      join(await getDatabasesPath(), 'werefadb'),
      onCreate: (db, version) async{
        await db.execute('''
        CREATE TABLE sold_ticket (
          id integer primary key autoincrement,
          Ticket_id TEXT,
          Ticket_num integer)
        ''');

        await db.execute('''
        CREATE TABLE scanned_ticket (
          id integer primary key autoincrement,
          Ticket_id TEXT,
          Ticket_num integer)
        ''');

      },
        version: 1
    );
  }

  newsold(Soldticket soldticket) async{
    final db = await database;

    var res = await db.rawInsert(''' 
      INSERT INTO sold_ticket(
        Ticket_id,Ticket_num
      )VALUES (?,?)
      
    ''' , [soldticket.ticket_id, soldticket.ticket_num]);
    print(res);
    return res;
  }


  newscanned(Soldticket soldticket) async{
    print('scand add');
    final db = await database;
    var res = await db.rawInsert(''' 
      INSERT INTO scanned_ticket(
        Ticket_id,Ticket_num
      )VALUES (?,?)
    ''' , [soldticket.ticket_id, soldticket.ticket_num]);
    print(res);
    return res;

  }

  Future<dynamic> getsolds() async{

    final db = await database;
    var res = await db.query('sold_ticket');
    if(res.length == 0){
      return null;
    }else{
      List<Map<String, dynamic>> resmap=res;
      return resmap;
    }
  }

  Future<dynamic> getsoldbyid(String id) async{

    final db = await database;
    var res = await db.query("sold_ticket",where: "Ticket_id = ?", whereArgs: [id]);
    if(res.length == 0){
      return null;
    }else{
      List<Map<String, dynamic>> resmap=res;
      return  resmap ;
    }
  }

  Future<dynamic> getscannedbyid(String id) async{

    final db = await database;
    var res = await db.query("scanned_ticket",where: "Ticket_id = ?", whereArgs: [id]);
    print(res);
    if(res.length == 0){
      return null;
    }else{
      List<Map<String, dynamic>> resmap=res;
      return  resmap ;
    }
  }

  Future<void> deleteticket(String id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the Database.
    await db.delete(
      'sold_ticket',
      // Use a `where` clause to delete a specific dog.
      where: "Ticket_id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}

