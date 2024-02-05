import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image_resizer/views/HomeScreen.dart';
import 'package:image_resizer/views/custom_widgets/custom_buttons.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:platform/platform.dart';


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

  bool monthSelected = true;



  /// The In App Purchase plugin
  InAppPurchase _iap = InAppPurchase.instance;



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

      // Initialize in_app_purchase
      // _iap.enablePendingPurchases();
      // Add listeners
      _iap.purchaseStream.listen((data) {
        // Handle purchase updates
      });


    }
  }


  Future<void> _buyProduct(String productId) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: await _getProductDetails(productId),
      applicationUserName: null, // You can use an identifier for the user here
    );

    try {
      // Start the purchase process
      bool state = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      if(state){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      }

    } catch (e) {
      // Handle the purchase error
      debugPrint('Error purchasing: $e');
    }
  }

  Future<ProductDetails> _getProductDetails(String productId) async {
    final Set<String> ids = {productId};
    final ProductDetailsResponse response =
    await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Product not found: ${response.notFoundIDs.first}');
    }
    return response.productDetails.first;
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
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                  items: items_first
                      .map((e) => Image(
                            image: AssetImage(e),
                            width: MediaQuery.of(context).size.width * 0.2,
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
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                  items: items_second
                      .map((e) => Image(
                            image: AssetImage(e),
                            width: MediaQuery.of(context).size.width * 0.2,
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
              height: 15,
            ),

            const Row(mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '\u2713 No Ads',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '\u2713 Rotate, Flip Image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],),
            const Row(mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '\u2713 Change Dimension',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '\u2713 Square Crop',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],),

            Visibility(visible: LocalPlatform().isIOS,child: InkWell(
              onTap: () {
                _buyProduct('com.example.app.trial');
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Continue 3 days free trail',
                  style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white),
                ),
              ),
            ),),
            const SizedBox(
              height: 15,
            ),

            Visibility(visible: LocalPlatform().isIOS,child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      monthSelected = true;
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 85,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: monthSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor, width: 1)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Per month' , style: TextStyle(color: monthSelected ? Colors.white : primaryColor, fontSize: 15)),
                        const SizedBox(height: 10,),
                        Text('\$11.99', style: TextStyle(color: monthSelected ? Colors.white : primaryColor, fontSize: 20, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                InkWell(
                  onTap: () {
                    setState(() {
                      monthSelected = false;
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 85,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: monthSelected ? Colors.white  : primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor, width: 1)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Per year' , style: TextStyle(color: !monthSelected ? Colors.white : primaryColor, fontSize: 15)),
                        const SizedBox(height: 10,),
                        Text('\$59.99', style: TextStyle(color: !monthSelected ? Colors.white : primaryColor, fontSize: 20, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ],
            ),),

            const SizedBox(
              height: 15,
            ),
            buttons(context, LocalPlatform().isAndroid ? 'Next' : 'Purchase', () {
              if (LocalPlatform().isAndroid) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
              }
              else{
                if(monthSelected){
                  _buyProduct('com.example.app.monthly');
                }
                else{
                  _buyProduct('com.example.app.yearly');
                }
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
