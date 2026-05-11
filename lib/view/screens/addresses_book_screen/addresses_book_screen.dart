import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_future_builder.dart';
import '../../../core/widgets/form_widgets/primary_button/simple_primary_button.dart';
import '../../../core/widgets/login_now_message.dart';
import '../../../core/widgets/message_widget.dart';
import '../../../model/addresses_model.dart';
import '../../../model/batteries_products_model.dart';
import '../../../model/car_model.dart';
import '../../../model/products_model.dart';
import '../../../model/tires_products_model.dart';
import '../main_screen/tabs/home_tab/batteries/batteries_checkout_screen.dart';
import '../main_screen/tabs/home_tab/car_parts/checkout_screen.dart';
import '../main_screen/tabs/home_tab/tires/tires_checkout_screen.dart';
import 'add_new_address_screen.dart';
import 'local_widgets/address_card.dart';

class AddressesBookScreen extends StatefulWidget {
  final List<Products> products;
  final List<Batteries> batteries;
  final List<Tires> tires;
  final int carID;
  final bool fromCart;
  final bool fromCartBatteries;
  final bool fromCartTires;
  final Car? car;

  const AddressesBookScreen(
      {super.key,
      required this.carID,
      required this.products,
      required this.batteries,
      required this.fromCart,
      required this.fromCartBatteries,
      required this.car,
      required this.tires,
      required this.fromCartTires});

  @override
  State<AddressesBookScreen> createState() => _AddressesBookScreenState();
}

class _AddressesBookScreenState extends State<AddressesBookScreen> {
  int? _selectedOption;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.addressBook.tr(),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AddNewAddressScreen(
                  products: widget.products,
                  batteries: widget.batteries,
                  carID: widget.carID,
                  car: widget.car,
                  fromCart: widget.fromCart,
                  fromCartBatteries: widget.fromCartBatteries,
                  fromCartTires: widget.fromCartTires,
                  tires: widget.tires,
                );
              }));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: ColorsPalette.primaryColor,
                    size: 20,
                  ),
                  UtilValues.gap2,
                  Text(
                    LocaleKeys.addNewAddress.tr(),
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsPalette.primaryColor,
                        fontFamily: ZainTextStyles.font),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Selector<UserProvider, bool>(
        selector: (context, provider) => provider.isLoggedIn,
        builder: (context, isLoggedIn, child) {
          if (!isLoggedIn) {
            return const Center(child: LoginNowMessage());
          }
          return Column(
            children: [
              UtilValues.gap12,
              Expanded(
                child: CustomFutureBuilder<AddressesModel>(
                  future: MiscellaneousApi.getAddresses(locale: context.locale),
                  successBuilder: (AddressesModel addresses) {
                    if (addresses.data?.addresses?.isEmpty ?? false) {
                      return Center(
                        child: MessageWidget(
                          icon: Icons.map_outlined,
                          message: LocaleKeys.noAddressesFound.tr(),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: UtilValues.padding16T12,
                      physics: UtilValues.scrollPhysics,
                      itemCount: addresses.data?.addresses?.length ?? 0,
                      separatorBuilder: (context, index) => UtilValues.gap12,
                      itemBuilder: (context, index) {
                        final address = addresses.data?.addresses?[index];
                        return CustomCard(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: ColorsPalette.extraDarkGrey),
                          color: ColorsPalette.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  title: AddressCard(
                                    name: address?.name ?? '',
                                    city: address?.city?.name ?? '',
                                    details: address?.details ?? '',
                                    selected: (_selectedOption != null)
                                        ? _selectedOption == address?.id
                                        : (address?.isDefault ?? false),
                                  ),
                                  value: address?.id,
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = address?.id!;
                                    });
                                  },
                                  fillColor:
                                      MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return ColorsPalette.primaryColor;
                                    }
                                    return ColorsPalette.veryDarkGrey3;
                                  }),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return AddNewAddressScreen(
                                      products: widget.products,
                                      batteries: widget.batteries,
                                      carID: widget.carID,
                                      car: widget.car,
                                      fromCart: widget.fromCart,
                                      fromCartBatteries: widget.fromCartBatteries,
                                      fromCartTires: widget.fromCartTires,
                                      tires: widget.tires,
                                      addressName: address?.name,
                                      addressDetails: address?.details,
                                      late: address?.lat,
                                      long: address?.lon,
                                    );
                                  }));
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: ColorsPalette.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                color: ColorsPalette.white,
                padding: UtilValues.padding16,
                child: SimplePrimaryButton(
                  backgroundColor: _selectedOption != null
                      ? ColorsPalette.primaryColor
                      : ColorsPalette.customGrey,
                  isLoading: _isLoading,
                  loadingWidgetColor: ColorsPalette.white,
                  label: LocaleKeys.setDefault.tr(),
                  onPressed: _setDefault,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _setDefault() async {
    try {
      if (_selectedOption != null) {
        setState(() => _isLoading = true);

        await MiscellaneousApi.setAddressDefault(
            locale: context.locale, addressID: _selectedOption!);
        await context
            .read<UserProvider>()
            .autoLogin(locale: context.locale, context: context);

        if (widget.fromCart) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return CheckoutScreen(
              products: widget.products,
              carID: widget.carID,
              car: widget.car,
            );
          }));
          return;
        } else if (widget.fromCartBatteries) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return BatteriesCheckoutScreen(
              batteries: widget.batteries,
              carID: widget.carID,
              car: widget.car,
            );
          }));
          return;
        } else if (widget.fromCartTires) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return TiresCheckoutScreen(
              tires: widget.tires,
              carID: widget.carID,
              car: widget.car,
            );
          }));
          return;
        }
        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.done.tr(),
        );
      }
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
