import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<Database> initDb() async {
    return sql.openDatabase(
      'app.db', //database name
      version: 1, //version number
      onCreate: (Database database, int version) async {
        await createTable(database);
      },
    );
  }

  static Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE orders(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      productID INTEGER,
      productQty INTEGER,
      productType INTEGER
    )
    """);

    debugPrint("Table Created");
  }

  //add
  static Future<int> addOrder(
      int productID, int productQty, int productType) async {
    final db = await SQLHelper.initDb(); // open database
    final data = {
      'productID': productID,
      'productQty': productQty,
      'productType': productType,
    }; // create data in map
    final id = await db.insert('orders', data); // insert
    debugPrint("Data Added");
    return id;
  }

//read all orders
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await SQLHelper.initDb();
    return db.query('orders', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getOrder(int id) async {
    final db = await SQLHelper.initDb();
    return db.query('orders', where: "id = ?", whereArgs: [id]);
  }

  //update
  static Future<int> updateOrder(
      int id, int productID, int productQty, int productType) async {
    final db = await SQLHelper.initDb();
    final data = {
      'productID': productID,
      'productQty': productQty,
      'productType': productType,
    };

    final result =
        await db.update('orders', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteOrder(int id) async {
    final db = await SQLHelper.initDb();
    try {
      await db.delete("orders", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong: $err");
    }
  }

  static Future<void> cleanAllOrders() async {
    final db = await SQLHelper.initDb();
    try {
      await db.delete("orders");
      debugPrint("All orders cleaned");
    } catch (err) {
      print("Something went wrong while cleaning orders: $err");
    }
  }
}
