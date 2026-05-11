import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:ma7lola/core/widgets/custom_card.dart';
import 'package:ma7lola/view/screens/addresses_book_screen/add_new_address_screen.dart';
import 'package:ma7lola/view/screens/addresses_book_screen/addresses_book_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/products_provider.dart';
import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/services/http/apis/car_api.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/snackbars.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../../../../model/TaxAndHideServiceModel.dart';
import '../../../../../../model/car_model.dart';
import '../../../../../../model/tires_products_model.dart';
import '../../../../../../model/user.dart';
import '../../../../addresses_book_screen/local_widgets/address_card.dart';
import '../car_parts/local_widets/schdule_card.dart';
import '../car_parts/order_success_screen.dart';
import '../car_parts/payment_screen.dart';
import '../car_parts/select_date_and_time_screen.dart';

class TiresCheckoutScreen extends StatefulWidget {
  const TiresCheckoutScreen(
      {Key? key, required this.carID, required this.tires, required this.car})
      : super(key: key);

  final List<Tires> tires;
  final int carID;
  final Car? car;

  @override
  State<TiresCheckoutScreen> createState() => _TiresCheckoutScreenState();
}

class _TiresCheckoutScreenState extends State<TiresCheckoutScreen> {
  bool _isLoading = false;

  DateTime? _scheduledDateTime;
  int? _selectSchedule=1;
  int? _selectPayment;
  DefaultAddress? address;
  int? repairInstallationService=0;
  int? taxPercentage=0;
  var total;
  var prices;


  @override
  void initState() {
    _getDeliveryInstallAndTax();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: ColorsPalette.lightGrey,
          appBar: AppBarApp(
            title: LocaleKeys.orderDetails.tr(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: ColorsPalette.primaryLightColor,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    SvgPicture.asset(AssetsManager.carShape),
                    UtilValues.gap8,
                    Text(
                      widget.car != null
                          ? '${widget.car?.model?.brand?.name} ${widget.car?.model?.name} - ${widget.car?.year}'
                          : '',
                      style: TextStyle(
                          color: ColorsPalette.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              UtilValues.gap8,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.serviceType.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        UtilValues.gap4,
                        ScheduleCard(
                          // icon: AssetsManager.schedule,
                          name: LocaleKeys.deliveryJust.tr(),
                          value: 1,
                          selectedValue: _selectSchedule,
                          onChanged: _onScheduleOrder,
                        ),
                        if(repairInstallationService==1)
                          UtilValues.gap4,
                        if(repairInstallationService==1)
                        ScheduleCard(
                          name: LocaleKeys.deliveryInstall.tr(),
                          value: 2,
                          selectedValue: _selectSchedule,
                          onChanged: _onScheduleOrder,
                        ),
                        UtilValues.gap4,
                        // Text(
                        //   LocaleKeys.serviceTime.tr(),
                        //   style: TextStyle(
                        //       color: ColorsPalette.black,
                        //       fontWeight: FontWeight.w400,
                        //       fontFamily: ZainTextStyles.font,
                        //       fontSize: 14.sp),
                        // ),
                        // UtilValues.gap4,
                        // CustomCard(
                        //     padding: EdgeInsets.only(right: 15),
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: ColorsPalette.white,
                        //     child: Row(
                        //       children: [
                        //         Text(
                        //           LocaleKeys.deliverySchedule.tr(),
                        //           style: TextStyle(
                        //               color: ColorsPalette.black,
                        //               fontWeight: FontWeight.w400,
                        //               fontFamily: ZainTextStyles.font,
                        //               fontSize: 14.sp),
                        //         ),
                        //         Spacer(),
                        //         IconButton(
                        //           onPressed: () {
                        //             Navigator.push(context,
                        //                 MaterialPageRoute(builder: (context) {
                        //               return SelectDateAndTimeScreen(
                        //                 carID: widget.carID,
                        //                 car: widget.car,
                        //                 index: 1,
                        //                 cityID: address?.city?.id ?? 1,
                        //                 stateID: address?.state?.id ?? 1,
                        //                 products:
                        //                     prepareProductTimes(widget.tires),
                        //               );
                        //             }));
                        //           },
                        //           icon: Row(
                        //             children: [
                        //               Text(
                        //                 LocaleKeys.choseTime.tr(),
                        //                 style: TextStyle(
                        //                     color: ColorsPalette.black,
                        //                     fontWeight: FontWeight.w400,
                        //                     fontFamily: ZainTextStyles.font,
                        //                     fontSize: 14.sp),
                        //               ),
                        //               UtilValues.gap12,
                        //               SvgPicture.asset(
                        //                 AssetsManager.angleRight,
                        //                 color: ColorsPalette.customGrey,
                        //               )
                        //             ],
                        //           ),
                        //         ),
                        //       ],
                        //     )),
                        UtilValues.gap16,
                        Text(
                          LocaleKeys.addressSelected.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        UtilValues.gap4,
                        Builder(builder: (context) {
                          final userProvider = context.read<UserProvider>();
                          if (userProvider.user != null) {
                            address =
                                userProvider.user?.data?.user?.defaultAddress;
                            if (address != null) {
                              return InkWell(
                                onTap: () async {
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return AddressesBookScreen(
                                      products: [],
                                      carID: widget.carID,
                                      car: widget.car,
                                      batteries: [],
                                      fromCart: false,
                                      fromCartBatteries: false,
                                      tires: widget.tires,
                                      fromCartTires: true,
                                    );
                                  }));

                                  await context.read<UserProvider>().autoLogin(
                                      locale: context.locale, context: context);
                                },
                                child: CustomCard(
                                  color: ColorsPalette.white,
                                  border: Border.all(color: ColorsPalette.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  child: AddressCard(
                                    name: address?.name ?? '',
                                    city: address?.city?.name ?? '',
                                    details: address?.details ?? '',
                                    selected: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              );
                            }
                          }
                          return SizedBox.shrink();
                        }),
                        UtilValues.gap16,
                        Text(
                          LocaleKeys.paymentMethod.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        UtilValues.gap4,
                        ScheduleCard(
                          icon2: AssetsManager.masterCard,
                          icon: AssetsManager.visa,
                          name: LocaleKeys.credit.tr(),
                          value: 1,
                          selectedValue: _selectPayment,
                          onChanged: _onPaymentOrder,
                        ),
                        UtilValues.gap4,
                        ScheduleCard(
                          icon: AssetsManager.cash,
                          name: LocaleKeys.cash.tr(),
                          value: 2,
                          selectedValue: _selectPayment,
                          onChanged: _onPaymentOrder,
                        ),
                        UtilValues.gap16,
                        Text(
                          LocaleKeys.paymentData.tr(),
                          style: TextStyle(
                              color: ColorsPalette.customGrey,
                              fontWeight: FontWeight.w400,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        UtilValues.gap4,
                        CustomCard(
                            border: Border.all(color: ColorsPalette.grey),
                            color: ColorsPalette.white,
                            child: Builder(builder: (context) {
                              final productProvider =
                                  context.read<ProductsProvider>();
                              double productCost = 0.0;
                              double serviceCost = 0.0;
                              double total = 0.0;
                              
                              if (productProvider.tires.isNotEmpty) {
                                // Convert all prices to double before calculations
                                var pricesList = productProvider.tires
                                    .map((e) => e.price is int ? e.price.toDouble() : e.price)
                                    .toList();
                                
                                // Calculate proper total with service cost
                                productCost = pricesList.reduce((a, b) => (a as double) + (b as double));
                                serviceCost = productCost * 0.1; // Service cost is 10% of product cost
                                total = productCost + serviceCost; // Total is sum of product cost and service cost
                              }
                              return Column(
                                children: [
                                  _paymentDetails(
                                    '${LocaleKeys.productsCost.tr()} (${productProvider.tires.toSet().length})',
                                    productProvider.tires.isNotEmpty
                                        ? Helpers.formatPrice(productCost).toString()
                                        : '0.00',
                                  ),
                                  _paymentDetails(
                                    LocaleKeys.serviceCost.tr(),
                                    productProvider.tires.isNotEmpty
                                        ? Helpers.formatPrice(serviceCost).toString()
                                        : '0.00',
                                  ),
                                  Divider(
                                    color: ColorsPalette.grey,
                                  ),
                                  _paymentDetails(
                                    LocaleKeys.total.tr(),
                                    productProvider.tires.isNotEmpty
                                        ? Helpers.formatPrice(total).toString()
                                        : '0.00',
                                  ),
                                ],
                              );
                            })),
                      ],
                    ),
                  ),
                ),
              ),
              UtilValues.gap16,
              Container(
                color: ColorsPalette.white,
                padding: UtilValues.padding16,
                child: SimplePrimaryButton(
                  isLoading: _isLoading,
                  loadingWidgetColor: ColorsPalette.white,
                  label: LocaleKeys.completeOrder.tr(),
                  onPressed: placeOrder,
                ),
              ),
            ],
          )),
    );
  }
  void _getDeliveryInstallAndTax() async {
    TaxAndHideServiceModel data= await MiscellaneousApi.taxAndHideService(locale: context.locale);
    repairInstallationService = data.data?.repairInstalationService??0;
    taxPercentage = data.data?.taxPercentage??0;
    setState(() {

    });
  }
  _paymentDetails(String text, String num) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        Spacer(),
        Text(
          num.toString(),
          style: TextStyle(
              color: ColorsPalette.black,
              fontWeight: FontWeight.w600,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
        UtilValues.gap4,
        Text(
          LocaleKeys.le.tr(),
          style: TextStyle(
              color: ColorsPalette.customGrey,
              fontWeight: FontWeight.w400,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp),
        ),
      ],
    );
  }

  void _onScheduleOrder(int? schedule) async {
    // if (schedule == 2 && _scheduledDateTime == null) {
    setState(() => _selectSchedule = schedule);
    // if (schedule == 2) {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) {
    //     return SelectDateAndTimeScreen(
    //       carID: widget.carID,
    //       car: widget.car,
    //       index: 1,
    //       cityID: address?.city?.id ?? 1,
    //       stateID: address?.state?.id ?? 1,
    //       products: prepareProductTimes(widget.tires),
    //     );
    //   }));
    // }
    //   _scheduledDateTime = DateTime.now();
    //   return;
    // }

    // if (_scheduledDateTime != null) {
    //   setState(() => _scheduledDateTime = null);
    //   return;
    // }

    // final selectedDateTime = await Helpers.showDateTimePicker(context);

    // if (selectedDateTime != null /*&& schedule == 3*/) {
    //   setState(() => _selectSchedule = schedule);
    //   setState(() => _scheduledDateTime = selectedDateTime);
    // }
  }

  void _onPaymentOrder(int? payment) async {
    setState(() => _selectPayment = payment);
    if (payment == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaymentScreen();
      }));
    }
  }

  List<Map<String, dynamic>> prepareProductData(List<Tires> products) {
    List<Map<String, dynamic>> productData = [];

    for (var product in products.toSet()) {
      productData.add({
        "id": product.id,
        "qty": product.qty,
      });
    }

    return productData;
  }

  List<Map<String, dynamic>> prepareProductTimes(List<Tires> products) {
    List<Map<String, dynamic>> productData = [];

    for (var product in products.toSet()) {
      productData.add({
        "id": product.id,
      });
    }

    return productData;
  }

  void placeOrder() async {
    try {
      if (_selectPayment == null || _selectSchedule == null) {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.pleaseSelectAllOptions.tr(),
        );
        return;
      }
      if (address == null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AddNewAddressScreen(
            products: [],
            carID: widget.carID,
            car: widget.car,
            batteries: [],
            fromCart: false,
            fromCartBatteries: false,
            tires: widget.tires,
            fromCartTires: true,
          );
        }));
        return;
      }

      final cars = await CarApi.getCars(locale: context.locale);
      
      // Calculate the total with service cost before placing the order
      double productCost = 0.0;
      double serviceCost = 0.0;
      double total = 0.0;
      
      if (widget.tires.isNotEmpty) {
        // Convert all prices to double before calculations
        var pricesList = widget.tires
          .map((e) => e.price is int ? e.price.toDouble() : e.price)
          .toList();
        
        // Calculate proper total with service cost
        productCost = pricesList.reduce((a, b) => (a as double) + (b as double));
        serviceCost = productCost * 0.1; // Service cost is 10% of product cost
        total = productCost + serviceCost; // Total is sum of product cost and service cost
      }
      
      if (_selectPayment != null &&
          _selectSchedule != null &&
          address != null) {
        setState(() => _isLoading = true);
        final res = await MiscellaneousApi.createTiresOrder(
          locale: context.locale,
          addressID: address?.id ?? 1,
          carID: cars.first.id ?? 1,
          payment: _selectPayment == 2 ? "cash" : "visa",
          deliveryType: _selectSchedule == 1 ? "fast" : "scheduled",
          products: prepareProductData(widget.tires),
        );
        setState(() => _isLoading = false);
        final productProvider = context.read<ProductsProvider>();

        setState(() {
          productProvider.clear();
        });
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return OrderSuccessScreen(
              orderNumber: res.data?.order?.id,
              myOrdersIndex: 1,
              selectedDate: res.data?.order?.deliveryTime,
              total: total); // Use our correctly calculated total instead of res.data?.order?.total
        }), (e) => false);
      }
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _isLoading = false);
    }
  }
}
