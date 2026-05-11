import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
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
import '../../../../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../../../../core/widgets/horizontal_list_view.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/car_model.dart';
import '../../../../../../model/car_parts_model.dart';
import '../../../../../../model/local_car.dart' as s;
import '../../../../../../model/subcategory.dart' as es;
import '../../../../addresses_book_screen/local_widgets/address_card.dart';
import 'car_parts_resualts_screen.dart';
import 'cart_screen.dart';

class CarPartsSearch extends StatefulWidget {
  static String routeName = '/carPartsSearch';
  const CarPartsSearch(
      {Key? key,
      required this.categories,
      required this.categoryID,
      required this.search})
      : super(key: key);

  final List<ProductCategories> categories;
  final int categoryID;
  final bool search;
  @override
  State<CarPartsSearch> createState() => _CarPartsSearchState();
}

class _CarPartsSearchState extends State<CarPartsSearch> {
  List<SubCategories>? carPartsCategory;
  es.CarPartsSubCategory? carPartsSubCategory2;
  ProductCategories? isChangeDropDownCars;
  SubCategories? isChangeDropDownSubCategories;
  bool changeModel = false;
  bool _loading = false;
  int? selected;
  int? selectedUserCar;
  Car? selectedCar;
  var _userNameController = TextEditingController();

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
          title: LocaleKeys.carParts.tr(),
          actions: [
            IconButton(
                onPressed: () {
                  _getCar();

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CartScreen(
                      carID: selected ?? 1,
                      car: selectedCar,
                    );
                  }));
                },
                icon: SvgPicture.asset(AssetsManager.cart)),
          ],
        ),
        bottomNavigationBar: _startSearchButton(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.search) ...[
              UtilValues.gap12,
              searchFormField(),
              UtilValues.gap12,
            ],
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
                                  type: 0,
                                )),
                      );
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
                  final cars = allCarsPreview.toSet().toList();
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
                  buildDropDownAllCarParts(),
                  buildDropDownProductCategory(),
                  buildDropDownProductSubCategory()
                ],
              ),
            )
          ],
        ));
  }

  Widget searchFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.search.tr(),
            style: TextStyle(
                color: ColorsPalette.black,
                fontWeight: FontWeight.w400,
                fontFamily: ZainTextStyles.font,
                fontSize: 16.sp),
          ),
          TextInputField(
            padding: EdgeInsets.all(16.sp),
            focusedBorder: OutlineInputBorder(
              borderRadius: UtilValues.borderRadius10,
              borderSide: const BorderSide(
                  color: ColorsPalette.extraDarkGrey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: UtilValues.borderRadius10,
              borderSide:
                  BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
            ),
            color: ColorsPalette.darkGrey,
            backgroundColor: ColorsPalette.white,
            controller: _userNameController,
            inputType: TextInputType.name,
            name: LocaleKeys.name.tr(),
            key: const ValueKey('name'),
            hint: '',
            validator: FormBuilderValidators.required(),
          ),
        ],
      ),
    );
  }

  int? _isChangeDropDownAllCarParts;
  int? _isChangeDropDownCategories;
  int? _isChangeDropDownSubCategories;

  Widget buildDropDownAllCarParts() {
    _isChangeDropDownAllCarParts =
        widget.categories.any((element) => element.id == widget.categoryID)
            ? widget.categoryID
            : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.category.tr(),
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
                borderSide: const BorderSide(color: ColorsPalette.primaryColor),
              ),
            ),
            dropdownColor: Colors.white,
            icon: SvgPicture.asset(
              'assets/images/expanded.svg',
              fit: BoxFit.scaleDown,
              width: 1.w,
              height: .8.h,
              color: changeModel
                  ? ColorsPalette.primaryColor
                  : ColorsPalette.darkGrey,
            ),
            alignment: Alignment.center,
            hint: Text(
              /*widget.categories.first.name ?? '',*/
              widget.categoryID != 0
                  ? widget.categories
                          .firstWhereOrNull(
                              (element) => element.id == widget.categoryID)
                          ?.name ??
                      LocaleKeys.choose.tr()
                  : LocaleKeys.choose.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color:
                    changeModel ? ColorsPalette.black : ColorsPalette.darkGrey,
                fontFamily: ZainTextStyles.font,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.black,
            ),
            value: _isChangeDropDownAllCarParts,
            onChanged: (int? newValue) async {
              _isChangeDropDownAllCarParts = newValue!;
              _isChangeDropDownCategories = null;
              // carPartsCategory = await MiscellaneousApi.getCarPartsSubCategory(
              //     locale: context.locale, categoryID: newValue);
              carPartsCategory = widget.categories
                      .firstWhereOrNull((element) => element.id == newValue)
                      ?.subCategories ??
                  [];
              setState(() {});
            },
            items: widget.categories.map((ProductCategories productCategories) {
              return DropdownMenuItem<int>(
                value: productCategories.id,
                child: Text(
                  productCategories.name ?? 'Unknown',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorsPalette.black,
                    fontSize: 14.sp,
                    fontFamily: ZainTextStyles.font,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildDropDownProductCategory() {
    return Builder(builder: (context) {
      if (carPartsCategory == null &&
          widget.categoryID != 0 &&
          widget.categories.isNotEmpty) {
        carPartsCategory = widget.categories
                .firstWhereOrNull((element) => element.id == widget.categoryID)
                ?.subCategories ??
            [];
      }
      if ((carPartsCategory != null &&
          (carPartsCategory?.isNotEmpty ?? false))) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UtilValues.gap12,
            Text(
              LocaleKeys.subCategory.tr(),
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
                  color: changeModel
                      ? ColorsPalette.primaryColor
                      : ColorsPalette.darkGrey,
                ),
                alignment: Alignment.center,
                hint: Text(
                  LocaleKeys.choose.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: changeModel
                        ? ColorsPalette.black
                        : ColorsPalette.darkGrey,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: ZainTextStyles.font,
                  color: ColorsPalette.black,
                ),
                value: _isChangeDropDownCategories,
                onChanged: (int? newValue) async {
                  _isChangeDropDownCategories = newValue!;
                  _isChangeDropDownSubCategories = null;
                  carPartsSubCategory2 =
                      await MiscellaneousApi.getCarPartsSubCategory(
                          locale: context.locale, categoryID: newValue);
                  setState(() {});
                },
                items: carPartsCategory != null
                    ? carPartsCategory?.map((SubCategories subCategories) {
                        return DropdownMenuItem<int>(
                          value: subCategories.id,
                          child: Text(
                            subCategories.name ?? 'Unknown',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 14.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                        );
                      }).toList()
                    : [],
              ),
            ),
          ],
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget buildDropDownProductSubCategory() {
    return Builder(builder: (context) {
      if (carPartsCategory != null &&
          (carPartsCategory?.isNotEmpty ?? false) &&
          carPartsSubCategory2 != null &&
          (carPartsSubCategory2
                  ?.data?.productCategories?.first.subCategories?.isNotEmpty ??
              false)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UtilValues.gap12,
            Text(
              LocaleKeys.product.tr(),
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
                  color: changeModel
                      ? ColorsPalette.primaryColor
                      : ColorsPalette.darkGrey,
                ),
                alignment: Alignment.center,
                hint: Text(
                  /*carPartsSubCategory2 != null
                      ? carPartsSubCategory2?.data?.productCategories?.first
                              .subCategories?.first.name ??
                          ''
                      : widget.categories.first.name ?? '',*/
                  LocaleKeys.choose.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: changeModel
                        ? ColorsPalette.black
                        : ColorsPalette.darkGrey,
                    fontFamily: ZainTextStyles.font,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: ZainTextStyles.font,
                  color: ColorsPalette.black,
                ),
                value: _isChangeDropDownSubCategories,
                onChanged: (int? newValue) {
                  setState(() {
                    _isChangeDropDownSubCategories = newValue!;
                  });
                },
                items: carPartsSubCategory2 != null
                    ? carPartsSubCategory2
                        ?.data?.productCategories?.first.subCategories
                        ?.map((es.SubCategories subCategories) {
                        return DropdownMenuItem<int>(
                          value: subCategories.id, // Ensure this is unique
                          child: Text(
                            subCategories.name ?? 'Unknown',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorsPalette.black,
                              fontSize: 14.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                        );
                      }).toList()
                    : [],
              ),
            ),
          ],
        );
      }
      return SizedBox.shrink();
    });
  }

  _startSearchButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: startSearch,
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
    // If already loading, prevent multiple clicks
    if (_loading) return;
    
    // Set loading state to true immediately to prevent multiple clicks
    setState(() => _loading = true);
    
    try {
      final productProvider = context.read<ProductsProvider>();
      productProvider.clear();

      await _getCar();
      
      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      if (widget.search && _userNameController.text.isEmpty) {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
        setState(() => _loading = false);
        return;
      }
      
      if ((selected != null) && _isChangeDropDownAllCarParts != null) {
        // Keep loading indicator active while navigating
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CarPartsResultsScreen(
            categoryID: _isChangeDropDownAllCarParts ?? 5,
            carId: selected ?? 1,
            car: selectedCar,
            userCarId: selectedUserCar ?? 1,
            name: _userNameController.text,
          );
        })).then((_) {
          // Only set loading to false after returning from the next screen
          if (mounted) setState(() => _loading = false);
        });
        return;
      } else {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: e.toString(),
        );
        setState(() => _loading = false);
      }
    }
  }

  _getCar() async {
    final userProvider = context.read<UserProvider>();

    _isChangeDropDownAllCarParts ??= widget.categoryID;

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

class CarS {
  int id = -1;
  CarS();

  CarS.fromDbMap(Map<String, dynamic> map) {
    id = map['carID'];
  }
}
