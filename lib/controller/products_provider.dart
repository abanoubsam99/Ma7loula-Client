import 'package:flutter/material.dart';
import 'package:ma7lola/core/local_orders/database.dart';
import 'package:ma7lola/model/products_model.dart';
import 'package:ma7lola/model/tires_products_model.dart';

import '../model/batteries_products_model.dart';

class ProductsProvider extends ChangeNotifier {
  List<Products> products = [];
  List<Batteries> batteries = [];
  List<Tires> tires = [];

  addIncrementProduct(Products product) async {
    if (products.contains(product)) {
      products.add(product);
      await SQLHelper.updateOrder(
          product.id!, product.id!, product.qty! + 1, 2);
      product.qty = product.qty! + 1;
    } else {
      await SQLHelper.addOrder(product.id!, 1, 2);
      products.add(product);
      product.qty = 1;
    }
    notifyListeners();
  }

  decrementProduct(Products product) async {
    if (products.contains(product)) {
      products.remove(product);
      if (product.qty! >= 1) {
        await SQLHelper.updateOrder(
            product.id!, product.id!, product.qty! - 1, 2);
        product.qty = product.qty! - 1;
      } else {
        await SQLHelper.deleteOrder(product.id!);
        product.qty = 0;
      }
    }
    notifyListeners();
  }

  addIncrementBatteries(Batteries battery) async {
    if (batteries.contains(battery)) {
      batteries.add(battery);
      await SQLHelper.updateOrder(
          battery.id!, battery.id!, battery.qty! + 1, 0);
      battery.qty = battery.qty! + 1;
    } else {
      batteries.add(battery);
      await SQLHelper.addOrder(battery.id!, 1, 0);
      battery.qty = 1;
    }
    notifyListeners();
  }

  decrementBatteries(Batteries battery) async {
    if (batteries.contains(battery)) {
      batteries.remove(battery);
      if (battery.qty! >= 1) {
        await SQLHelper.updateOrder(
            battery.id!, battery.id!, battery.qty! - 1, 0);
        battery.qty = battery.qty! - 1;
      } else {
        await SQLHelper.deleteOrder(battery.id!);
        battery.qty = 0;
      }
    }
    notifyListeners();
  }

  addIncrementTires(Tires tire) async {
    if (tires.contains(tire)) {
      tires.add(tire);
      await SQLHelper.updateOrder(tire.id!, tire.id!, tire.qty! + 1, 1);
      tire.qty = tire.qty! + 1;
    } else {
      tires.add(tire);
      await SQLHelper.addOrder(tire.id!, 1, 1);
      tire.qty = 1;
    }
    notifyListeners();
  }

  decrementTires(Tires tire) async {
    if (tires.contains(tire)) {
      tires.remove(tire);
      if (tire.qty! >= 1) {
        await SQLHelper.updateOrder(tire.id!, tire.id!, tire.qty! - 1, 1);
        tire.qty = tire.qty! - 1;
      } else {
        await SQLHelper.deleteOrder(tire.id!);
        tire.qty = 0;
      }
    }
    notifyListeners();
  }

  clear() async {
    tires.clear();
    tires = [];
    batteries.clear();
    batteries = [];
    products.clear();
    products = [];
    await SQLHelper.cleanAllOrders();
    notifyListeners();
  }
}
