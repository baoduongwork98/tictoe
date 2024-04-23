// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:onepref/onepref.dart';
// import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

// class DonatePage extends StatefulWidget {
//   const DonatePage({super.key});

//   @override
//   State<DonatePage> createState() => _DonatePageState();
// }

// class _DonatePageState extends State<DonatePage> {
//   static var myNewFontWhite = GoogleFonts.pressStart2p(
//       textStyle: TextStyle(color: Colors.white, letterSpacing: 3));
//   static var myNewFont = GoogleFonts.pressStart2p(
//       textStyle: TextStyle(color: Colors.black, letterSpacing: 3));

//   final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<String> _notFoundIds = <String>[];
//   List<ProductDetails> _products = <ProductDetails>[];
//   List<PurchaseDetails> _purchases = <PurchaseDetails>[];
//   List<String> _consumables = <String>[];
//   bool _isAvailable = false;
//   bool _purchasePending = false;
//   bool _loading = true;
//   String? _queryProductError;
//   void showPendingUI() {
//     setState(() {
//       _purchasePending = true;
//     });
//   }
//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }
//    Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
//     // IMPORTANT!! Always verify a purchase before delivering the product.
//     // For the purpose of an example, we directly return true.
//     return Future<bool>.value(true);
//   }
//    Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
//     // IMPORTANT!! Always verify purchase details before delivering the product.
//     if (purchaseDetails.productID == _kConsumableId) {
//       await ConsumableStore.save(purchaseDetails.purchaseID!);
//       final List<String> consumables = await ConsumableStore.load();
//       setState(() {
//         _purchasePending = false;
//         _consumables = consumables;
//       });
//     } else {
//       setState(() {
//         _purchases.add(purchaseDetails);
//         _purchasePending = false;
//       });
//     }
//   }

//   void handleError(IAPError error) {
//     setState(() {
//       _purchasePending = false;
//     });
//   }
// Future<void> _listenToPurchaseUpdated(
//       List<PurchaseDetails> purchaseDetailsList) async {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       if (purchaseDetails.status == PurchaseStatus.pending) {
//         showPendingUI();
//       } else {
//         if (purchaseDetails.status == PurchaseStatus.error) {
//           handleError(purchaseDetails.error!);
//         } else if (purchaseDetails.status == PurchaseStatus.purchased ||
//             purchaseDetails.status == PurchaseStatus.restored) {
//           final bool valid = await _verifyPurchase(purchaseDetails);
//           if (valid) {
//             unawaited(deliverProduct(purchaseDetails));
//           } else {
//             _handleInvalidPurchase(purchaseDetails);
//             return;
//           }
//         }
//         if (Platform.isAndroid) {
//           if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
//             final InAppPurchaseAndroidPlatformAddition androidAddition =
//                 _inAppPurchase.getPlatformAddition<
//                     InAppPurchaseAndroidPlatformAddition>();
//             await androidAddition.consumePurchase(purchaseDetails);
//           }
//         }
//         if (purchaseDetails.pendingCompletePurchase) {
//           await _inAppPurchase.completePurchase(purchaseDetails);
//         }
//       }
//     }
//   }

//  @override
//   void initState() {
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         _inAppPurchase.purchaseStream;
//     _subscription =
//         purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
//       _listenToPurchaseUpdated(purchaseDetailsList);
//     }, onDone: () {
//       _subscription.cancel();
//     }, onError: (Object error) {
//       // handle error here.
//     });
//     initStoreInfo();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.grey[900],
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Container(
//                 width: 200.0,
//                 height: 200.0,
//                 child: Center(
//                   child: Text(
//                     'DONATE',
//                     style: myNewFontWhite.copyWith(fontSize: 30),
//                   ),
//                 ),
//               ),
//               Container(
//                 height: 400.0,
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       _products.length,
//                       (index) => MaterialButton(
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                             side: const BorderSide(color: Colors.grey)),
//                         color: Colors.green,
//                         onPressed: () async => {
//                           iapEngine.handlePurchase(
//                               _products[index], storeProductIds)
//                         },
//                         child: Row(
//                           children: [
//                             Text(_products[index].description,
//                                 style: const TextStyle(
//                                     fontSize: 15, color: Colors.white)),
//                             const Spacer(),
//                             Text(_products[index].price,
//                                 style: const TextStyle(
//                                     fontSize: 15, color: Colors.white)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   print("play game");
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: EdgeInsets.all(30),
//                       color: Colors.white,
//                       child: Center(
//                         child: Text(
//                           'PLAY GAME',
//                           style: myNewFont,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: EdgeInsets.all(30),
//                       color: Colors.white,
//                       child: Center(
//                         child: Text(
//                           'GO BACK',
//                           style: myNewFont,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ));
//   }
// }
