import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/model/tires_brand_model.dart';
import 'package:ma7lola/model/tires_size_model.dart';
import 'package:ma7lola/view/screens/auth/YourCarDetails.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/products_provider.dart';
import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/local_orders/car_id.dart';
import '../../../../../../core/services/http/apis/car_api.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../../../../../core/widgets/custom_future_builder.dart';
import '../../../../../../core/widgets/horizontal_list_view.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/car_model.dart';
import '../../../../../../model/car_parts_model.dart';
import '../../../../../../model/local_car.dart' as s;
import '../../../../../../model/subcategory.dart' as es;
import '../../../../addresses_book_screen/local_widgets/address_card.dart';
import '../batteries/local_widets/voltage_card.dart';
import 'tires_cart_screen.dart';
import 'tires_resualts_screen.dart';

class TiresSearchScreen extends StatefulWidget {
  static String routeName = '/TiresSearchScreen';
  const TiresSearchScreen({Key? key}) : super(key: key);

  @override
  State<TiresSearchScreen> createState() => _TiresSearchScreenState();
}

class _TiresSearchScreenState extends State<TiresSearchScreen> {
  List<SubCategories>? carPartsCategory;
  es.CarPartsSubCategory? carPartsSubCategory2;
  ProductCategories? isChangeDropDownCars;
  SubCategories? isChangeDropDownSubCategories;
  bool _loading = false;
  bool _changeWidth = false;
  bool _changeHeight = false;
  bool _changeLength = false;
  bool _changeBrand = false;
  int? selected;
  int? selectedUserCar;
  Car? selectedCar;

  @override
  void initState() {
    // TODO: implement initState
    final userProvider = context.read<UserProvider>();

    if (!userProvider.isLoggedIn) _addLocalData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorsPalette.lightGrey,
        appBar: AppBarApp(
          title: LocaleKeys.tires.tr(),
          actions: [
            IconButton(
                onPressed: () {
                  _getCar();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TiresCartScreen(
                      carID: selected ?? 1,
                      car: selectedCar,
                    );
                  }));
                },
                icon: SvgPicture.asset(AssetsManager.cart)),
          ],
        ),
        bottomNavigationBar: _startSearchButton(),
        body: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: ColorsPalette.primaryLightColor,
              height: 10,
            ),
            Container(
              color: ColorsPalette.primaryLightColor,
              child: Row(
                children: [
                  UtilValues.gap8,
                  SvgPicture.asset(AssetsManager.carShape),
                  UtilValues.gap8,
                  Text(
                    LocaleKeys.chooseFromCars.tr(),
                    style: TextStyle(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: ZainTextStyles.font,
                        fontSize: 14.sp),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => YourCarDetails(
                                  type: 1,
                                )),
                      );
                      // Navigator.pushNamed(context, YourCarDetails.routeName);
                    },
                    icon: Row(
                      children: [
                        SvgPicture.asset(AssetsManager.addCircle),
                        UtilValues.gap8,
                        Text(
                          LocaleKeys.addCar.tr(),
                          style: TextStyle(
                              color: ColorsPalette.primaryColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  UtilValues.gap8,
                ],
              ),
            ),
            Container(
              height: 100,
              color: ColorsPalette.primaryLightColor,
              child: Builder(builder: (context) {
                final userProvider = context.read<UserProvider>();
                if (userProvider.isLoggedIn) {
                  return CustomFutureBuilder<List<UserCars>>(
                      future: CarApi.getCars(locale: context.locale),
                      successBuilder: (List<UserCars> cars) {
                        if (cars.isEmpty) {
                          return Center(
                              child: Column(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 50,
                                color: ColorsPalette.primaryColor,
                              ),
                              UtilValues.gap16,
                              Text(
                                LocaleKeys.noCarsFound.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: ColorsPalette.black,
                                    fontSize: 12,
                                    fontFamily: ZainTextStyles.font),
                              ),
                            ],
                          ));
                        }

                        return SizedBox(
                          height: 100,
                          child: HorizontalListView(
                              padding: EdgeInsets.all(5),
                              itemCount: cars.length,
                              itemBuilder: (index) {
                                final car = cars[index];
                                if(selected==null){
                                  Timer(Duration(seconds: 1), () {
                                    setState(() {
                                      selected = cars[0].car?.id;
                                      selectedUserCar = cars[0].id;
                                      selectedCar = cars[0].car;
                                    });
                                  });

                                }
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selected = car.car?.id;
                                      selectedUserCar = car.id;
                                      selectedCar = car.car;
                                    });
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3.5,
                                    child: CustomCard(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: ((selected == null)
                                                  ? (car.isDefault ?? false)
                                                  : (selected == car.car?.id))
                                              ? ColorsPalette.primaryColor
                                              : ColorsPalette.extraDarkGrey),
                                      color: ColorsPalette.white,
                                      child: AddressCard(
                                        name:
                                            '${car.car?.model?.brand?.name}, ${car.car?.model?.name}' ??
                                                '',
                                        city: car.car?.year ?? '',
                                        selected: false,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        );
                      });
                }
                return Builder(builder: (context) {
                  final cars = allCarsPreview.isNotEmpty
                      ? allCarsPreview.toSet().toList()
                      : [];

                  if (cars.isEmpty) {
                    return Center(
                        child: Column(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 50,
                          color: ColorsPalette.primaryColor,
                        ),
                        UtilValues.gap16,
                        Text(
                          LocaleKeys.noCarsFound.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 12,
                              fontFamily: ZainTextStyles.font),
                        ),
                      ],
                    ));
                  }
                  return SizedBox(
                    height: 100,
                    child: HorizontalListView(
                        padding: EdgeInsets.all(5),
                        itemCount: allCarsPreview.toSet().toList().length,
                        itemBuilder: (index) {
                          final car = allCarsPreview.toSet().toList()[index];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selected = car?.id;
                                selectedUserCar = car?.id;
                                // selectedCar = car;
                              });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 3.5,
                              child: CustomCard(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: (selected == car?.id)
                                        ? ColorsPalette.primaryColor
                                        : ColorsPalette.extraDarkGrey),
                                color: ColorsPalette.white,
                                child: AddressCard(
                                  name:
                                      '${car?.model?.brand?.name}, ${car?.model?.name}' ??
                                          '',
                                  city: car?.year ?? '',
                                  selected: false,
                                ),
                              ),
                            ),
                          );
                        }),
                  );
                });
              }),
            ),
            Container(
              color: ColorsPalette.primaryLightColor,
              height: 10,
            ),
            UtilValues.gap12,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDropDownBrands(),
                  UtilValues.gap12,
                  if (tiresTypes != null) _typesWidget(),
                  if (tiresSizes != null && tiresSizes!.widthTireSizes!.isNotEmpty) ...[
                    Text(
                      LocaleKeys.sizeDetails.tr(),
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp),
                    ),
                    UtilValues.gap2,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: buildDropDownWidth(),
                        ),
                        UtilValues.gap12,
                        Expanded(
                          child: _buildDropDownHeight(),
                        ),
                        UtilValues.gap12,
                        Expanded(
                          child: _buildDropDownLength(),
                        ),
                      ],
                    )
                  ] else if (tiresSizes != null && tiresSizes!.widthTireSizes!.isEmpty) ...[
                    _buildErrorMessage("No tire sizes available for this type")
                  ]
                ],
              ),
            )
          ],
        )),
      );
  }

  String? _tupe;
  int? _isChangeDropDownBrands;
  String? _isChangeDropDownSizesHeight;
  String? _isChangeDropDownSizesLength;
  String? _isChangeDropDownSizesWidth;
  List<String>? tiresTypes;
  // List<TireSizes>? tiresSizes;
  TireSizes? tiresSizes;
  _buildErrorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: ColorsPalette.red,
              fontSize: 14.sp,
              fontFamily: ZainTextStyles.font,
              fontWeight: FontWeight.w500,
            ),
          ),
          UtilValues.gap8,
          // Add icon to make message more visible
          Icon(
            Icons.info_outline,
            color: ColorsPalette.red,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  _typesWidget() {
    if (tiresTypes == null || tiresTypes!.isEmpty) {
      return _buildErrorMessage("No tire types available for this brand");
    }
    
    return SizedBox(
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            // 'Choose Tire Type', // Direct text instead of using localization key
            LocaleKeys.chooseTireType.tr(),
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
          UtilValues.gap2,
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, index) {
                  return UtilValues.gap4;
                },
                shrinkWrap: true,
                itemCount: tiresTypes != null ? (tiresTypes?.length ?? 0) : 0,
                itemBuilder: (context, index) {
                  final name = tiresTypes?[index];
                  if (tiresTypes != null) {
                    return _types(name, name);
                  }
                  return SizedBox.shrink();
                }),
          ),
        ],
      ),
    );
  }

  _types(String? name, String? value) {
    return CardVoltages(
      name: name ?? '',
      value: value,
      selectedValue: _tupe,
      onChanged: _onType,
    );
  }

  void _onType(String? type) async {
    setState(() {
      tiresSizes = null;
      _isChangeDropDownSizesHeight = null;
      _isChangeDropDownSizesWidth = null;
      _isChangeDropDownSizesLength = null;
      _tupe = type;
    });
    final all = await MiscellaneousApi.getTiresSizes(
        locale: context.locale,
        type: type ?? '',
        carID: selected ?? 1,
        brandID: _isChangeDropDownBrands ?? 1);
    tiresSizes = all.data?.tireSizes;
    print("tiresSizestiresSizestiresSizestiresSizes ${tiresSizes?.length??0}");
    setState(() {});
  }

  Widget buildDropDownBrands() {
    print('=== DEBUG: Building tire brands dropdown ===');
    print('Selected Car ID: ${selected ?? "none"}');
    
    return FutureBuilder<TiresBrandsModel>(
      future: MiscellaneousApi.getTiresBrands(
          locale: context.locale, carID: selected ?? 1),
      builder: (context, brand) {
        // Debug the API response
        print('=== DEBUG: Tire brands API response ===');
        print('Has data: ${brand.hasData}');
        print('Has error: ${brand.hasError}');
        if (brand.hasError) print('Error: ${brand.error}');
        if (brand.hasData) {
          print('Response data: ${brand.data}');
          print('Tire brands count: ${brand.data?.data?.tireBrands?.length ?? 0}');
          if (brand.data?.data?.tireBrands != null) {
            print('Brands: ${brand.data?.data?.tireBrands?.map((b) => "${b.id}:${b.name}").join(", ")}');
          }
        }
        print('=== End API debug ===');
        // Don't show error message for API errors, just check car selection
        if (selected == null) {
          return _buildErrorMessage("${LocaleKeys.selectCarfirst.tr()}");
        }
        
        if (brand.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (brand.data != null &&
            (brand.data?.data?.tireBrands?.isNotEmpty ?? false)) {
          print('=== DEBUG: Tire brands found, building UI ===');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.tireBrand.tr(),
                style: TextStyle(
                    color: ColorsPalette.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: ZainTextStyles.font,
                    fontSize: 14.sp),
              ),
              UtilValues.gap2,
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: ColorsPalette.primaryColor),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  icon: SvgPicture.asset(
                    'assets/images/expanded.svg',
                    fit: BoxFit.scaleDown,
                    width: 1.w,
                    height: .8.h,
                    color: _changeBrand
                        ? ColorsPalette.primaryColor
                        : ColorsPalette.darkGrey,
                  ),
                  alignment: Alignment.center,
                  hint: Text(
                    LocaleKeys.choseBrand.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorsPalette.black,
                      fontFamily: ZainTextStyles.font,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: ZainTextStyles.font,
                    color: ColorsPalette.black,
                  ),
                  value: _isChangeDropDownBrands,
                  onChanged: (int? newValue) async {
                    _isChangeDropDownBrands = newValue!;
                    _changeBrand = true;
                    tiresTypes = null;
                    tiresSizes = null;
                    _tupe = null;
                    setState(() {});

                    final allTypes = await MiscellaneousApi.getTiresTypes(
                        locale: context.locale,
                        carID: selected ?? 1,
                        brandID: newValue);
                    tiresTypes = allTypes.data?.tireTypes;
                    setState(() {});
                  },
                  items: brand.data?.data?.tireBrands
                          ?.map((TireBrands tireBrands) {
                        return DropdownMenuItem<int>(
                          value: tireBrands.id,
                          child: Text(
                            tireBrands.name ?? 'Unknown',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 14.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ],
          );
        }
        // No brands found, show message
        return _buildErrorMessage("No tire brands available for this car");
      },
    );
  }

  Widget buildDropDownWidth() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorsPalette.primaryColor),
          ),
        ),
        dropdownColor: Colors.white,
        icon: SvgPicture.asset(
          'assets/images/expanded.svg',
          fit: BoxFit.scaleDown,
          width: 1.w,
          height: .8.h,
          color: _changeWidth
              ? ColorsPalette.primaryColor
              : ColorsPalette.darkGrey,
        ),
        alignment: Alignment.center,
        hint: Text(
          "ex R15",
          // LocaleKeys.width.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: _changeWidth ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontFamily: ZainTextStyles.font,
          color: ColorsPalette.black,
        ),
        value: _isChangeDropDownSizesWidth,
        onChanged: (String? newValue) async {
          _isChangeDropDownSizesWidth = newValue!;
          _changeWidth = true;
          setState(() {});
        },
        items: tiresSizes != null
            ? tiresSizes?.widthTireSizes?.map((int widthTireSizes) {
                  return DropdownMenuItem<String>(
                    value: '${widthTireSizes}',
                    child:  Text(
                      '${widthTireSizes}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 14.sp,
                        fontFamily: ZainTextStyles.font,
                      ),
                    ),
                  );
                }).toList() ??
                []
            : [],
      ),
    );
  }

  Widget _buildDropDownHeight() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorsPalette.primaryColor),
          ),
        ),
        dropdownColor: Colors.white,
        icon: SvgPicture.asset(
          'assets/images/expanded.svg',
          fit: BoxFit.scaleDown,
          width: 1.w,
          height: .8.h,
          color: _changeHeight
              ? ColorsPalette.primaryColor
              : ColorsPalette.darkGrey,
        ),
        alignment: Alignment.center,
        hint: Text(
          "ex 185",
          // LocaleKeys.height.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: _changeHeight ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontFamily: ZainTextStyles.font,
          color: ColorsPalette.black,
        ),
        value: _isChangeDropDownSizesHeight,
        onChanged: (String? newValue) async {
          _isChangeDropDownSizesHeight = newValue!;
          _changeHeight = true;
          setState(() {});
        },
        items: tiresSizes != null
            ? tiresSizes?.heightTireSizes?.map((int heightTireSizes) {
          return DropdownMenuItem<String>(
            value: '${heightTireSizes}',
                    child: Text("${heightTireSizes}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 14.sp,
                        fontFamily: ZainTextStyles.font,
                      ),
                    ),
                  );
                }).toList() ??
                []
            : [],
      ),
    );
  }
  Widget _buildDropDownLength() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorsPalette.primaryColor),
          ),
        ),
        dropdownColor: Colors.white,
        icon: SvgPicture.asset(
          'assets/images/expanded.svg',
          fit: BoxFit.scaleDown,
          width: 1.w,
          height: .8.h,
          color: _changeLength
              ? ColorsPalette.primaryColor
              : ColorsPalette.darkGrey,
        ),
        alignment: Alignment.center,
        hint: Text(
          "ex 65",
          // LocaleKeys.length.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: _changeLength ? ColorsPalette.black : ColorsPalette.darkGrey,
            fontFamily: ZainTextStyles.font,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontFamily: ZainTextStyles.font,
          color: ColorsPalette.black,
        ),
        value: _isChangeDropDownSizesLength,
        onChanged: (String? newValue) async {
          _isChangeDropDownSizesLength = newValue!;
          _changeLength = true;
          setState(() {});
        },
        items: tiresSizes != null
            ? tiresSizes?.length?.map((String length) {
          return DropdownMenuItem<String>(
            value: '${length}',
                    child: Text(
                      '$length',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorsPalette.black,
                        fontSize: 14.sp,
                        fontFamily: ZainTextStyles.font,
                      ),
                    ),
                  );
                }).toList() ??
                []
            : [],
      ),
    );
  }

  _startSearchButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: _loading?null:startSearch,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: ColorsPalette.primaryColor),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
        ),
        child: Center(
          child: _loading
              ? const LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  LocaleKeys.startSearch.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.white,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
        ),
      ),
    );
  }

  void startSearch() async {
    try {
      setState(() => _loading = true); // Start loading

      final productProvider = context.read<ProductsProvider>();
      productProvider.clear();

      _getCar();

      // final values = _isChangeDropDownSizesWidth?.split('_');
      // final w = values?.elementAt(0);
      // final h = values?.elementAt(1);
      // final l = values?.elementAt(2);

      await Future.delayed(Duration(seconds: 1)); // Optional delay

      if ((selected != null) &&
          _isChangeDropDownBrands != null &&
          _tupe != null &&
          _isChangeDropDownSizesWidth != null) {

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return TiresResultsScreen(
            brandID: _isChangeDropDownBrands!,
            car: selectedCar,
            carId: selected ?? 1,
            userCarId: selectedUserCar ?? 1,
            // width: w ?? '',
            // height: h ?? '',
            // length: l ?? '',        
            width: "${_isChangeDropDownSizesWidth ?? ''}",
            height: "${_isChangeDropDownSizesHeight ?? ''}",
            length: "${_isChangeDropDownSizesLength ?? ''}",
            type: _tupe ?? '',
          );
        })).then((_) {
          // Restore loading state after returning from next screen
          setState(() => _loading = false);
        });

      } else {
        final missingFields = <String>[];
        if (selected == null) missingFields.add('Car');
        if (_isChangeDropDownBrands == null) missingFields.add('Brand');
        if (_tupe == null) missingFields.add('Tire Type');
        if (_isChangeDropDownSizesWidth == null) missingFields.add('Tire Size');

        print('Missing Fields: ${missingFields.join(', ')}');
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );

        setState(() => _loading = false); // Reset loading if validation fails
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');

      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );

      setState(() => _loading = false); // Reset loading on error
    }
  }
  _getCar() async {
    final userProvider = context.read<UserProvider>();

    if (userProvider.isLoggedIn) {
      final List<UserCars> cars = await CarApi.getCars(locale: context.locale);
      setState(() {
        selected ??= cars
            .firstWhereOrNull((element) => element.isDefault ?? false)
            ?.car
            ?.id;
        selectedCar ??=
            cars.firstWhereOrNull((element) => element.isDefault ?? false)?.car;
        selectedUserCar ??=
            cars.firstWhereOrNull((element) => element.isDefault ?? false)?.id;
      });
    } else {
      selected ??= allCarsPreview.last?.id;
      // selectedCar ??= allCarsPreview.last!;
      // selectedUserCar ??= allCarsPreview.last?.id;
    }
    setState(() {});
  }

  // List<CarS> allCars = [];
  List<s.Car?> allCarsPreview = [];

  _addLocalData() {
    SQLCarsHelper.getCars().then((value) async {
      for (int i = 0; i < value.length; i++) {
        s.LocalCarModel car = await CarApi.getCarById(
            locale: context.locale, carId: value[i]['carID']);
        allCarsPreview.add(car.data?.car);
        setState(() {
          // allCars.add(CarS.fromDbMap(value[i]));
        });
      }
    });
  }
}
