import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ebazar/const/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../product_details_screen.dart';
import '../search_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> _carouselImages = [];
  var _dotPosition = 0;
List _products = [];
  var _firestoreInstance = FirebaseFirestore.instance;
  
  

  fetchCarouselImages() async {
    QuerySnapshot qn =
        await _firestoreInstance.collection("carousel-slider").get();
    setState(() {
      for (int i = 0; i < qn.docs.length; i++) {
        _carouselImages.add(
          qn.docs[i]["img-path"],
        );
        print(qn.docs[i]["img-path"]);
      }
    });
    print('click is');

    return qn.docs;
  }

  fetchProducts() async {
     print('product-name');
    QuerySnapshot q = await _firestoreInstance.collection("products").get();
    setState(() {
    
        // _products.add( qn.docs[i]["img-path"]);

      for (var i = 0; i < q.docs.length; i++) {
        _products.add({
          "product-name": q.docs[i]["product-name"],
          // "product-description": q.docs[0]["product-description"],
          "product-price": q.docs[i]["product-price"],
          "product-img": q.docs[i]["product-img"],
        });
        
      }

       
     
    });
   

    return q.docs;

  }

  @override
  void initState() {
    fetchProducts();
    fetchCarouselImages();
    // fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(_products);
      
    return Scaffold(
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  fillColor: Colors.blue,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(color: Colors.grey)),
                  hintText: "Search products here",
                  hintStyle: TextStyle(fontSize: 15.sp),
                ),
                onTap: () => Navigator.push(context,
                    CupertinoPageRoute(builder: (_) => SearchScreen())),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            AspectRatio(
              aspectRatio: 3.5,
              child: CarouselSlider(
                
                  items: _carouselImages
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(item),
                                      fit: BoxFit.fitWidth)),
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onPageChanged: (val, carouselPageChangedReason) {
                        setState(() {
                          _dotPosition = val;
                        });
                      }),),
            ),
            SizedBox(
              height: 10.h,
            ),
            DotsIndicator(
              dotsCount:
                  _carouselImages.length == 0 ? 1 : _carouselImages.length,
              position: _dotPosition.toDouble(),
              decorator: DotsDecorator(
                activeColor: AppColors.deep_orange,
                color: AppColors.deep_orange.withOpacity(0.5),
                spacing: EdgeInsets.all(2),
                activeSize: Size(8, 8),
                size: Size(6, 6),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            // OutlinedButton(onPressed: fetchProducts, child: Text("Click")),
            
            Expanded(
              child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length ,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1),
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ProductDetails(_products[index]))),
                      child: Card(
                        elevation: 3,
                        child: Column(
                          children: [
                             AspectRatio(
                                aspectRatio: 1.5,
                                child: Container(
                                    color: Colors.yellow,
                                    child: Image.network(
                                      _products[index]["product-img"],fit: BoxFit.cover,
                                    ))),
                                    Text("name: ${_products[index]["product-name"]}"),
                         
                                 Container(
                                   color: Colors.amberAccent,
                                   
                                   child: Text(
                                     
                                "Price: ${_products[index]["product-price"]} TK"),
                                 ),
                             
                          ]
                            
                          
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      )),
    );
  }
}
