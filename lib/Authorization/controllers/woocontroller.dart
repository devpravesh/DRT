import 'package:db_vendor/categoriesmodal.dart';
import 'package:db_vendor/productsmodal.dart';
import 'package:db_vendor/singlecategorymodal.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cache/flutter_cache.dart' as cache;

import '../../constants.dart';

class WooController extends GetxController {
  final categories = [].obs;
  final cat = [].obs;
  final topProducts = [].obs;
  final allProducts = <WooProducts>[].obs;
  int currentPage = 0;
  RxBool fetchingProducts = false.obs;
  int totalProductPageCount = 0;
  RxBool firstProduct = true.obs;
  RxBool lastProduct = false.obs;
  final allProductsCat = <WooProducts>[].obs;
  int currentPageCat = 1;
  RxBool fetchingProductsCat = false.obs;
  int totalProductPageCountCat = 1;
  RxBool firstProductCat = true.obs;
  RxBool lastProductCat = false.obs;

  @override
  onInit() async {
    super.onInit();
    await getTopProducts();
    await getCategories();
  }

  Future<void> getAllProducts(bool previous) async {
    if (currentPage <= totalProductPageCount) {
      allProducts.clear();
      if (previous) {
        currentPage--;
      } else {
        currentPage = currentPage + 1;
      }
      if (currentPage == 1) {
        firstProduct.value = true;
      } else {
        firstProduct.value = false;
      }

      if (currentPage == totalProductPageCount) {
        lastProduct.value = true;
      } else {
        lastProduct.value = false;
      }
      fetchingProducts.value = true;

      try {
        final String response = await cache.remember(
          'products$currentPage',
          () async {
            var response = await http.get(
              Uri.parse(
                  'https://discount-bazaar.com/wp-json/wc/v3/products?orderby=popularity&per_page=20&page=$currentPage&order=desc&consumer_key=ck_a8200f8c74b2f73c16a7e178b954c7977891000c&consumer_secret=cs_043642983a3d8799b786429a154264cb400d7fd2'),
            );
            final header = response.headers['x-wp-totalpages'];
            totalProductPageCount = int.parse(header);
            return response.body;
          },
          86400,
        );

        final responseJson = json.decode(response);
        print(responseJson.length);
        for (dynamic rsp in responseJson) {
          WooProducts wooProducts = WooProducts.fromJson(rsp);
          allProducts.add(wooProducts);
        }
      } catch (e) {
        if (!previous) {
          currentPage--;
        } else {
          currentPage++;
        }
        if (currentPage == 1) {
          firstProduct.value = true;
        } else {
          firstProduct.value = false;
        }

        if (currentPage == totalProductPageCount) {
          lastProduct.value = true;
        } else {
          lastProduct.value = false;
        }
        fetchingProducts.value = false;
        print(e.toString());
      }
      fetchingProducts.value = false;
    }
  }

  Future<void> getAllProductsCat(bool previous, int catId) async {
    if (currentPageCat <= totalProductPageCountCat) {
      print('right');
      allProductsCat.clear();
      if (previous) {
        if (currentPageCat >= 0) currentPageCat--;
      } else {
        if (currentPageCat <= totalProductPageCountCat)
          currentPageCat = currentPageCat + 1;
      }
      if (currentPageCat == 1) {
        firstProductCat.value = true;
      } else {
        firstProductCat.value = false;
      }

      if (currentPageCat == totalProductPageCountCat) {
        lastProductCat.value = true;
      } else {
        lastProductCat.value = false;
      }
      fetchingProductsCat.value = true;
      try {
        print(currentPageCat);
        final String response = await cache.remember(
          'productsCategory$catId$currentPageCat',
          () async {
            var response = await http.get(
              Uri.parse(
                'https://discount-bazaar.com/wp-json/wc/v3/products?orderby=popularity&per_page=20&page=$currentPageCat&category=$catId&order=desc&consumer_key=ck_a8200f8c74b2f73c16a7e178b954c7977891000c&consumer_secret=cs_043642983a3d8799b786429a154264cb400d7fd2',
              ),
            );
            //print(response.body);
            final header = response.headers['x-wp-totalpages'];
            totalProductPageCountCat = header == null ? 1 : int.parse(header);

            return response.body;
          },
          86400,
        );

        final responseJson = json.decode(response);

        for (dynamic rsp in responseJson) {
          WooProducts wooProducts = WooProducts.fromJson(rsp);
          allProductsCat.add(wooProducts);
        }
      } catch (e) {
        if (!previous) {
          currentPageCat--;
        } else {
          currentPageCat++;
        }
        if (currentPageCat == 1) {
          firstProductCat.value = true;
        } else {
          firstProductCat.value = false;
        }

        if (currentPageCat == totalProductPageCountCat) {
          lastProductCat.value = true;
        } else {
          lastProductCat.value = false;
        }
        fetchingProductsCat.value = false;
        print(e.toString());
      }
      fetchingProductsCat.value = false;
    }
  }

  getCategories({int pageCount}) async {
    if (pageCount == null) {
      pageCount = 10;
    }
    final response = await cache.remember(
      'categories',
      () async => await http
          .get(
            Uri.parse(Consts.url +
                Consts.prroductEp +
                '?consumer_key=${Consts.consumerKey}&consumer_secret=${Consts.consumerSecret}&per_page=$pageCount'),
          )
          .then((value) => value.body),
      86400,
    );

    final responseJson = json.decode(response);
    for (dynamic rsp in responseJson) {
      var cat = WooCategories.fromJson(rsp);
      if (!categories.any((element) {
        if (element.id != cat.id) {
          return false;
        }
        return true;
      })) {
        categories.add(cat);
        await getSubCategories(id: cat.id.toString());
      }
    }
  }

  getCategorDetails({String link}) async {
    final response = await http.get(
      Uri.parse(link +
          '?consumer_key=${Consts.consumerKey}&consumer_secret=${Consts.consumerSecret}'),
    );

    final responseJson = json.decode(response.body);
    SingleCategory category = SingleCategory.fromJson(responseJson);
    print(category.id);
  }

  getSubCategories({String id}) async {
    final response = await cache.remember(
      'subCategories$id',
      () async => await http
          .get(
            Uri.parse(
              'https://discount-bazaar.com/wp-json/wc/v3/products/categories/?parent=' +
                  id +
                  '&consumer_key=${Consts.consumerKey}&consumer_secret=${Consts.consumerSecret}',
            ),
          )
          .then((value) => value.body),
      86400,
    );
    final responseJson = json.decode(response);
    if (!cat.any(
      (element) => element['id'] == id,
    )) {
      cat.add({
        'id': id,
        'total': responseJson.length,
      });
    } else {
      cat.where((element) => element['id'] == id).first['total'] =
          responseJson.length;
    }
  }

  getTopProducts() async {
    final response = await cache.remember(
      'topProducts',
      () async => await http
          .get(
            Uri.parse(
                'https://discount-bazaar.com/wp-json/wc/v3/products?orderby=popularity&order=desc&consumer_key=ck_a8200f8c74b2f73c16a7e178b954c7977891000c&consumer_secret=cs_043642983a3d8799b786429a154264cb400d7fd2'),
          )
          .then((value) => value.body),
      86400,
    );
    final responseJson = json.decode(response);
    for (dynamic rsp in responseJson) {
      WooProducts wooProducts = WooProducts.fromJson(rsp);
      topProducts.add(wooProducts);
    }
  }
}