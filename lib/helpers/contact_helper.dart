import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "Contact";

final String idColumn = "id";
final String nameColumn = "name";
final String emailColumn = "email";
final String phoneColumn = "phone";
final String imageColumn = "image";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;
  
  Future<Database> get db async {
    if (_db != null)
      return _db;
    else
      return await initDb();
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (db, newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imageColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    
    List<Map> maps = await dbContact.query(
      contactTable, 
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
      where: "$idColumn = ?", 
      whereArgs: [id]);

    if (maps.length > 0)
      return Contact.fromMap(maps.first);
    else 
      return null;
  }

  Future<List> getContacts() async {
    Database dbContact = await db;
    
    List maps = await dbContact.rawQuery("SELECT * FROM $contactTable");

    List<Contact> listContacts = List();

    for (Map map in maps) {
      listContacts.add(Contact.fromMap(map));
    }

    return listContacts;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;

    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", 
      whereArgs: [contact.id]);
  }

  Future<int> getNumber() async {
    Database dbContact = await db;

    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }  

  Future close() async {
    Database dbContact = await db;

    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact({this.name, this.email, this.phone, this.image});

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };

    if (id != null)
      map[idColumn] = id;

    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, image: $image)";
  }
}