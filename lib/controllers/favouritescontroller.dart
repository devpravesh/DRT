import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:db_vendor/main.dart';
import 'package:db_vendor/modals/favorites.dart';
import 'package:db_vendor/modals/productsmodal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavouritesController extends GetxController {
  var firestore = FirebaseFirestore.instance;
  RxList<Products> favouriteProducts = <Products>[].obs;
  @override
  void onInit() {
    getFirstTime();
    getdata();
    super.onInit();
  }

  updateFavourites(dynamic id, BuildContext context) {
    var index =
        favouritesBox.values.toList().indexWhere((element) => element.id == id);
    if (index == -1) {
      Get.snackbar('Added to Favourites', '');
      favouritesBox.add(new FavouriteProduct(id: id));
    } else {
      Get.snackbar('Removed from Favourites', '');
      favouritesBox.deleteAt(index);
    }
  }

  getdata() {
    print('object');
    favouritesBox.listenable().addListener(() async {
      print('object');
      favouriteProducts.clear();
      List<dynamic> fav =
          favouritesBox.values.toList().map((e) => e.id).toList();
      for (var item in fav) {
        var snsapshhot = await firestore
            .collection('products')
            .where('id', isEqualTo: item)
            .get();
        for (var item in snsapshhot.docs) {
          if (!favouriteProducts
              .any((element) => element.id == item.data()['id']))
            favouriteProducts.add(new Products.fromJson(item.data()));
        }
      }
    });
  }

  getFirstTime() async {
    favouriteProducts.clear();
    List<dynamic> fav = favouritesBox.values.toList().map((e) => e.id).toList();
    for (var item in fav) {
      var snsapshhot = await firestore
          .collection('products')
          .where('id', isEqualTo: item)
          .get();
      for (var item in snsapshhot.docs) {
        if (!favouriteProducts
            .any((element) => element.id == item.data()['id']))
          favouriteProducts.add(new Products.fromJson(item.data()));
      }
    }
  }
}