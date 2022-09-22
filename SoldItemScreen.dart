import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marcjrfoundation/services/SharedPreferences/sharedprefs_helper.dart';
import 'package:marcjrfoundation/services/device_size.dart';
import 'package:websafe_svg/websafe_svg.dart';

import '../ProductItem/sellerProductItem.dart';

class SoldItemScreens extends StatefulWidget {
  static final String tag = '/soldItemScreen';
  @override
  _SoldItemScreensState createState() => _SoldItemScreensState();
}

class _SoldItemScreensState extends State<SoldItemScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Sold Products',
          style: TextStyle(
              fontSize: ResponsiveWidget.isSmallScreen(context) ? 17.0 : 25.0),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10.0,
          ),
          Container(
            color: Color(0xffF7F7F7),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("items")
                  .where('seller', isEqualTo: parentIdGlobal)
                  .where('isSold', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                if (docs.length == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: WebsafeSvg.asset(
                        'assets/images/sold-out.svg',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                    ),
                  );
                }
                return ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: docs.map((DocumentSnapshot doc) {
                    bool isSold = doc['isSold'];
                    bool isLiked = doc['isLiked'];
                    String itemId = doc['itemId'];
                    String seller = doc['seller'];
                    String sellerName = doc['sellerName'];
                    String title = doc['title'];
                    String desc = doc['desc'];
                    String price = doc['price'];
                    String condition = doc['condition'];
                    String category = doc['category'];
                    String location = doc['location'];
                    String itemImage = doc['imageDownloadUrl'];

                    return SellerProductItem(
                      itemId: itemId,
                      seller: seller,
                      sellerName: sellerName,
                      title: title,
                      desc: desc,
                      price: price,
                      itemImage: itemImage,
                      isLiked: isLiked,
                      isSold: isSold,
                      category: category,
                      condition: condition,
                      location: location,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
