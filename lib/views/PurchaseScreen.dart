import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_resizer/views/HomeScreen.dart';
import 'package:image_resizer/views/custom_widgets/custom_buttons.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


class PurchaseScreen extends StatefulWidget {
  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {

  final String testID = 'gems_test';
  bool available = true;


  List items_first = [
    'assets/intro_images/s1.png',
    'assets/intro_images/s2.png',
    'assets/intro_images/s3.png',
    'assets/intro_images/s4.png',
    'assets/intro_images/s5.png',
  ];

  List items_second = [
    'assets/intro_images/s6.png',
    'assets/intro_images/s7.png',
    'assets/intro_images/s8.png',
    'assets/intro_images/s9.png',
    'assets/intro_images/s10.png',
  ];

  bool flag = true;

  /// Products for sale
  List<ProductDetails> _products = [];


  /// The In App Purchase plugin
  InAppPurchase _iap = InAppPurchase.instance;


  /// Past purchases
  List<PurchaseDetails> _purchases = [];


  /// Consumable credits the user can buy
  int credits = 0;

  @override
  void initState() {
    _initialize();
    super.initState();
  }


  /// Initialize data
  void _initialize() async {

    // Check availability of In App Purchases
    available = await _iap.isAvailable();

    if (available) {

      await _getProducts();

      // Verify and deliver a purchase with your own business logic
      _verifyPurchase();

    }
  }



  /// Get all products available for sale
  Future<void> _getProducts() async {
    Set<String> ids = Set.from([testID, 'test_a']);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    setState(() {
      _products = response.productDetails;
    });
  }


  /// Returns purchase of specific product ID
  PurchaseDetails? _hasPurchased(String productID) {
    return _purchases.firstWhere( (purchase) => purchase.productID == productID);
  }

  /// Your own business logic to setup a consumable
  void _verifyPurchase() {
    PurchaseDetails? purchase = _hasPurchased(testID);

    // TODO serverside verification & record consumable in the database

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      flag = true;
    }
  }

  /// Purchase a product
  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    // _iap.buyNonConsumable(purchaseParam: purchaseParam);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/intro_bg.png'),
                fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                  items: items_first
                      .map((e) => Image(
                            image: AssetImage(e),
                            width: MediaQuery.of(context).size.width * 0.25,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                  options: CarouselOptions(
                    viewportFraction: 0.25,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 0),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    pauseAutoPlayOnTouch: false,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    scrollDirection: Axis.horizontal,
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                  items: items_second
                      .map((e) => Image(
                            image: AssetImage(e),
                            width: MediaQuery.of(context).size.width * 0.25,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                  options: CarouselOptions(
                    viewportFraction: 0.25,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 0),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    pauseAutoPlayOnTouch: false,
                    enlargeFactor: 0.3,
                    scrollDirection: Axis.horizontal,
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '\u2713 No Ads',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '\u2713 Square Crop',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '\u2713 Change Dimension',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '\u2713 Rotate, Flip Image',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            buttons(context, 'Purchase', () {
              if (flag) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
              }
              else{
                //show in app purchase
                _buyProduct(_products[0]);
              }
            }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
