import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../../core/widgets/fixed_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/model/batteries_products_model.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../controller/products_provider.dart';
import '../../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../../core/utils/assets_manager.dart';
import '../../../../../../../core/utils/colors_palette.dart';
import '../../../../../../../core/utils/font.dart';
import '../../../../../../../core/utils/util_values.dart';
import '../../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../../core/widgets/custom_network_image.dart';
import '../../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  Batteries product;
  ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailsScreenState();
  }
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBarApp(
        title: widget.product.name ?? '',
        actions: [
          UtilValues.gap8,
          SvgPicture.asset(AssetsManager.share),
          UtilValues.gap8,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomNetworkImage(
              imageUrl: widget.product.thumbnail?.url ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.fill,
              enableFullScreenViewer: true,
            ),
            UtilValues.gap8,
            _images(widget.product.images ?? []),
            UtilValues.gap16,
            // Brand Name (smaller gray font at the top)
            Text(
              widget.product.brand?.name ?? 'NGK',
              style: const TextStyle(
                color: ColorsPalette.customGrey,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                fontFamily: ZainTextStyles.font,
              ),
            ),
            
            UtilValues.gap8,
            
            // Product Name (large bold black text)
            Text(
              widget.product.name ?? '',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
              ),
            ),
            
            UtilValues.gap16,
            
            // Pricing Information
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Current price with LE currency indicator
                Text(
                  widget.product.price.toString(),
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
                UtilValues.gap4,
                Text(
                  LocaleKeys.le.tr(),
                  style: TextStyle(
                    color: ColorsPalette.customGrey,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
                
                // Original price (if discounted) with red strikethrough
                if (widget.product.priceBeforeDiscount > 0) ...[  
                  UtilValues.gap12,
                  Text(
                    '${widget.product.priceBeforeDiscount} ${LocaleKeys.le.tr()}',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      decorationColor: ColorsPalette.red,
                      color: ColorsPalette.red,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                    ),
                  ),
                ],
              ],
            ),
            
            UtilValues.gap16,
            
            // Product Description (medium-sized gray font)
            Text(
              widget.product.description ?? "-----",
              style: TextStyle(
                color: ColorsPalette.customGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
              ),
            ),
            
            UtilValues.gap24,
            
            // Detailed Product Specifications Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header with info icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorsPalette.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: ColorsPalette.primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text(
                          LocaleKeys.product.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorsPalette.black,
                            fontFamily: ZainTextStyles.font,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Product details in rows
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildDetailRow('Product ID', '${widget.product.id ?? "-"}'),
                        _buildDetailRow('Description', widget.product.description != null && widget.product.description!.isNotEmpty ? 
                          (widget.product.description!.length > 20 ? "${widget.product.description!.substring(0, 20)}..." : widget.product.description!) : "-"),
                        _buildDetailRow('Stock', 'Available'),
                        _buildDetailRow('Status', "Active"),
                        _buildDetailRow('Category', widget.product.category?.name ?? "-"),
                        _buildDetailRow('Vendor', widget.product.vendor?.name ?? "-"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            UtilValues.gap16,
            
            // Add to Cart section
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (productProvider.batteries.contains(widget.product))
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: ColorsPalette.grey),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: InkWell(
                            onTap: () => setState(() => productProvider
                                .addIncrementBatteries(widget.product)),
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: SvgPicture.asset(
                                AssetsManager.addToCart,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          widget.product.qty.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => productProvider
                              .decrementBatteries(widget.product)),
                          icon: SvgPicture.asset(
                            AssetsManager.minus,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: 200,
                    child: SimplePrimaryButton(
                      borderRadius: BorderRadius.circular(5),
                      label: LocaleKeys.addToCart.tr(),
                      icon: AssetsManager.addToCart,
                      iconColor: ColorsPalette.white,
                      onPressed: () => setState(() => productProvider
                          .addIncrementBatteries(widget.product)),
                    ),
                  ),
                SizedBox(
                  height: 100,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper to build a single detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label on the left (bold)
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ColorsPalette.customGrey,
                fontFamily: ZainTextStyles.font,
              ),
            ),
          ),
          
          // Value on the right
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsPalette.black.withOpacity(0.8),
                fontFamily: ZainTextStyles.font,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  _images(List<Thumbnail> sliders) {
    return CarouselSlider.builder(
      itemCount: sliders.length,
      options: CarouselOptions(
        viewportFraction: .2,
        enlargeCenterPage: false,
        height: 5.h,
        autoPlay: true,
        enableInfiniteScroll: true,
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        return InkWell(
          child: Container(
            margin: EdgeInsets.only(
              left: 4.sp,
              right: 4.sp,
            ),
            // padding: EdgeInsets.only(left: 5.sp, right: 5.sp,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkResponse(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FixedCachedNetworkImage(
                      imageUrl: (sliders.isNotEmpty ?? false)
                          ? (sliders[index].url ?? '')
                          : '',
                      fit: BoxFit.fill,
                      height: 5.h,
                      width: double.maxFinite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
