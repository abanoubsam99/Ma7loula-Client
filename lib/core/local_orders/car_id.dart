import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLCarsHelper {
  static Future<Database> initDb() async {
    return sql.openDatabase(
      'car.db', //database name
      version: 1, //version number
      onCreate: (Database database, int version) async {
        await createTable(database);
      },
    );
  }

  static Future<void> createTable(Database database) async {
    await database.execute("""
    CREATE TABLE cars(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      carID INTEGER
    )
  """);

    debugPrint("car table Created");
  }

  //add
  static Future<int> addCar(int carID) async {
    final db = await SQLCarsHelper.initDb(); //open database
    final data = {
      'carID': carID,
    }; //create data in map
    final id = await db.insert('cars', data); //insert
    debugPrint("Car Data Added");
    return id;
  }

//read all cars
  static Future<List<Map<String, dynamic>>> getCars() async {
    final db = await SQLCarsHelper.initDb();
    return db.query('cars', orderBy: "id");
  }

  //get car by id
  static Future<List<Map<String, dynamic>>> getcar(int id) async {
    final db = await SQLCarsHelper.initDb();
    return db.query('cars', where: "id = ?", whereArgs: [id]);
  }

  //update
  static Future<int> updateCar(int id, int carID) async {
    final db = await SQLCarsHelper.initDb();
    final data = {
      'carID': carID,
    };

    final result =
        await db.update('cars', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteCar(int id) async {
    final db = await SQLCarsHelper.initDb();
    try {
      await db.delete("cars", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when : $err");
    }
  }
}
