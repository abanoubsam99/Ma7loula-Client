import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/widgets/fixed_cached_network_image.dart';
import '../../../../../../controller/products_provider.dart';
import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../../model/products_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Products product;
  
  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // State variable for carousel position
  int _currentImageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Debug print all product images URLs
    _debugPrintImageUrls();
  }
  
  void _debugPrintImageUrls() {
    print('=============================================');
    print('DEBUG: PRODUCT DETAILS IMAGE URLS');
    print('=============================================');
    print('Product ID: ${widget.product.id}');
    print('Product Name: ${widget.product.name}');
    
    // Main thumbnail
    print('\nTHUMBNAIL:');
    if (widget.product.thumbnail != null) {
      print('Thumbnail URL: "${widget.product.thumbnail!.url}"');
    } else {
      print('No thumbnail available');
    }
    
    // Image gallery
    print('\nIMAGE GALLERY:');
    if (widget.product.images != null && widget.product.images!.isNotEmpty) {
      print('Number of images: ${widget.product.images!.length}');
      for (int i = 0; i < widget.product.images!.length; i++) {
        print('Image $i URL: "${widget.product.images![i].url}"');
      }
    } else {
      print('No gallery images available');
    }
    print('=============================================');
  }
  
  // Flag to control debug overlay visibility
  final bool _showDebugOverlay = true;
  
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
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Main Image Display - following vendor app styling
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.sp),
              child: _hasMultipleImages() 
                ? _buildMultipleImagesCarousel() 
                : _buildSingleImageDisplay(),
            ),
            UtilValues.gap16,
            
            // Brand and Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product.brand?.name ?? 'NGK',
                  style: TextStyle(
                    color: ColorsPalette.customGrey,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: ZainTextStyles.font),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorsPalette.customGrey.withOpacity(.3)),
                    color: ColorsPalette.customGrey.withOpacity(0.1),
                  ),
                  child: Text(
                    widget.product.category?.name ?? '',
                    style: TextStyle(
                      color: ColorsPalette.black,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: ZainTextStyles.font),
                  ),
                ),
              ],
            ),
            UtilValues.gap16,
            
            // Product Name
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.product.name ?? '',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsPalette.black,
                  fontFamily: ZainTextStyles.font),
                textAlign: TextAlign.left,
              ),
            ),
            UtilValues.gap8,
            
            // Price Section
            Row(
              children: [
                Text(
                  '${widget.product.price ?? 0} ${LocaleKeys.le.tr()}',
                  style: TextStyle(
                    color: ColorsPalette.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
                UtilValues.gap8,
                // Show discounted price if available
                if (widget.product.priceBeforeDiscount != null && widget.product.priceBeforeDiscount != widget.product.price)
                  Text(
                    '${widget.product.priceBeforeDiscount} ${LocaleKeys.le.tr()}',
                    style: TextStyle(
                      color: ColorsPalette.red,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.lineThrough,
                      fontFamily: ZainTextStyles.font,
                    ),
                  ),
              ],
            ),
            UtilValues.gap16,
            
            // Product Description
            if (widget.product.description != null && widget.product.description!.isNotEmpty)
              _buildDescriptionSection(),
            
            // Product Details Card
            _buildDetailsCard(),
            UtilValues.gap16,
            // Vendor information if available
            if (widget.product.vendor != null && widget.product.vendor?.name != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UtilValues.gap16,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${LocaleKeys.by.tr()}: ",
                        style: TextStyle(
                          color: ColorsPalette.customGrey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font),
                      ),
                      UtilValues.gap4,
                      Text(
                        widget.product.vendor?.name ?? "",
                        style: TextStyle(
                          color: ColorsPalette.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: ZainTextStyles.font),
                      ),
                    ],
                  ),
                ],
              ),
              
            // Bottom action row with price and add to cart button
            UtilValues.gap16,
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  // Price column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Show original price with strikethrough if there's a discount
                      if (widget.product.priceBeforeDiscount != null && 
                          widget.product.priceBeforeDiscount != widget.product.price) ...[
                        Text(
                          '${widget.product.priceBeforeDiscount} ${LocaleKeys.le.tr()}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: ColorsPalette.red,
                            color: ColorsPalette.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: ZainTextStyles.font),
                        ),
                      ],
                      
                      // Current price
                      Row(
                        children: [
                          Text(
                            widget.product.price.toString(),
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          UtilValues.gap4,
                          Text(
                            LocaleKeys.le.tr(),
                            style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Add to cart or quantity control
                  if (productProvider.products.contains(widget.product))
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
                                  .addIncrementProduct(widget.product)),
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
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() =>
                                productProvider.decrementProduct(widget.product)),
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
                        onPressed: () => setState(() =>
                            productProvider.addIncrementProduct(widget.product)),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bottom spacing
            const SizedBox(height: 80)
            ],
          ),
        ),
      ),
          
          // Debug overlay to show image information
          if (_showDebugOverlay)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEBUG: IMAGES',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.product.id}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Thumbnail: ${widget.product.thumbnail?.url != null ? "YES" : "NO"}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Gallery images: ${widget.product.images?.length ?? 0}',
                      style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                    if (widget.product.thumbnail != null)
                      Text(
                        'Thumbnail: ${widget.product.thumbnail?.url?.substring(0, min(20, (widget.product.thumbnail?.url?.length ?? 0)))}...',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    if (widget.product.images != null && widget.product.images!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.product.images!.take(3).map((img) => Text(
                          'URL: ${img.url?.substring(0, min(20, (img.url?.length ?? 0)))}...',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        )).toList(),
                      ),
                    if ((widget.product.images?.length ?? 0) > 3)
                      Text(
                        '+ ${(widget.product.images!.length - 3)} more',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for UI components
  
  // Build carousel items from product images
  List<Widget> _buildCarouselItems() {
    List<Widget> items = [];
    
    // If there are images, use them
    if (widget.product.images != null && widget.product.images!.isNotEmpty) {
      items = widget.product.images!.map((image) {
        final url = image.url ?? '';
        print('Loading carousel image URL: "$url"');
        return FixedCachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }).toList();
    } 
    // Otherwise use the thumbnail as a fallback
    else if (widget.product.thumbnail != null && widget.product.thumbnail!.url != null) {
      items = [
        FixedCachedNetworkImage(
          imageUrl: widget.product.thumbnail!.url!,
          fit: BoxFit.cover,
          width: double.infinity,
        )
      ];
    }
    // If no images available, show a placeholder
    else {
      items = [
        Container(
          color: Colors.grey[200],
          child: Center(child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey)),
        )
      ];
    }
    
    return items;
  }
  
  // Build indicator dots for carousel
  List<Widget> _buildIndicators() {
    int itemCount = 1; // Default to 1 for the placeholder or thumbnail
    
    if (widget.product.images != null && widget.product.images!.isNotEmpty) {
      itemCount = widget.product.images!.length;
    }
    
    return List.generate(itemCount, (index) {
      return Container(
        width: 8,
        height: 8,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentImageIndex == index 
              ? ColorsPalette.primaryColor 
              : Colors.white.withOpacity(0.5),
        ),
      );
    });
  }
  
  // Build product description section
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.title.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ColorsPalette.black,
            fontFamily: ZainTextStyles.font,
          ),
        ),
        UtilValues.gap8,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            widget.product.description ?? '',
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsPalette.black.withOpacity(0.8),
              fontFamily: ZainTextStyles.font,
            ),
          ),
        ),
        UtilValues.gap20,
      ],
    );
  }
  
  // Build product details card with specifications
  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColorsPalette.customGrey.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: ColorsPalette.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  LocaleKeys.product.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsPalette.black,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
              ],
            ),
          ),
          
          // Details content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(LocaleKeys.category.tr(), widget.product.category?.name ?? ''),
                _buildDetailRow(LocaleKeys.name.tr(), widget.product.brand?.name ?? ''),
                _buildDetailRow(LocaleKeys.price.tr(), '${widget.product.price ?? 0} ${LocaleKeys.le.tr()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to check if the product has multiple images
  bool _hasMultipleImages() {
    return widget.product.images != null && widget.product.images!.length > 1;
  }
  
  // Builds a multiple images carousel with vendor app styling
  Widget _buildMultipleImagesCarousel() {
    return SizedBox(
      height: 30.h, // Use 30% of screen height as in vendor app
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 0.9, // Each slide takes 90% of screen width
              enlargeCenterPage: true, // Make center image slightly larger
              height: 30.h,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: widget.product.images!.map((image) {
              final url = image.url ?? '';
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: FixedCachedNetworkImage(
                    imageUrl: url,
                    width: double.infinity,
                    fit: BoxFit.contain, // Use contain to avoid cropping
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Indicator dots position at bottom
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicators(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Builds a single image display with vendor app styling
  Widget _buildSingleImageDisplay() {
    String imageUrl = '';
    
    // First try to use the first image if available
    if (widget.product.images != null && widget.product.images!.isNotEmpty && 
        widget.product.images!.first.url != null) {
      imageUrl = widget.product.images!.first.url!;
    }
    // Otherwise fall back to thumbnail
    else if (widget.product.thumbnail != null && widget.product.thumbnail!.url != null) {
      imageUrl = widget.product.thumbnail!.url!;
    }
    
    // No image available
    if (imageUrl.isEmpty) {
      return SizedBox(
        height: 30.h, // Consistent height with carousel
        child: Center(child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey)),
      );
    }
    
    // Single image display with 4:3 aspect ratio
    return AspectRatio(
      aspectRatio: 4 / 3, // Match vendor app ratio
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FixedCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.contain, // Use contain to avoid cropping
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey)),
          ),
        ),
      ),
    );
  }
  
  // Helper to build a single detail row with label and value
  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: ColorsPalette.customGrey,
                fontFamily: ZainTextStyles.font,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorsPalette.black.withOpacity(0.8),
                fontFamily: ZainTextStyles.font,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Thumbnails carousel
  Widget _buildThumbnails(List<Thumbnail> sliders) {
    return CarouselSlider.builder(
      itemCount: sliders.length,
      options: CarouselOptions(
        viewportFraction: .2,
        enlargeCenterPage: false,
        height: 5.h,
        autoPlay: false,
        enableInfiniteScroll: sliders.length > 5,
      ),
      itemBuilder: (BuildContext context, int index, int realIndex) {
        final String imageUrl = (sliders.isNotEmpty && index < sliders.length) 
            ? (sliders[index].url ?? '')
            : '';
            
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
                    child: imageUrl.isEmpty
                      ? Container(
                          height: 5.h,
                          width: double.maxFinite,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 16),
                        )
                      : FixedCachedNetworkImage(
                          imageUrl: imageUrl,
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
