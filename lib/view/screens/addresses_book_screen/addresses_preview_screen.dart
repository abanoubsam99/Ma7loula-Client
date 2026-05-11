import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/dialogs/confirmation_dialog.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_future_builder.dart';
import '../../../core/widgets/login_now_message.dart';
import '../../../core/widgets/message_widget.dart';
import '../../../model/addresses_model.dart';
import 'add_new_address_screen.dart';
import 'local_widgets/address_card.dart';

class AddressesPreviewScreen extends StatefulWidget {
  static const String routeName = '/addressesPreview';

  const AddressesPreviewScreen({super.key});

  @override
  State<AddressesPreviewScreen> createState() => _AddressesPreviewScreenState();
}

class _AddressesPreviewScreenState extends State<AddressesPreviewScreen> {
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
                  products: [],
                  batteries: [],
                  carID: 1,
                  fromCart: false,
                  fromCartBatteries: false,
                  car: null,
                  tires: [],
                  fromCartTires: false,
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
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: ColorsPalette.extraDarkGrey),
                          color: ColorsPalette.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: AddressCard(
                                  name: address?.name ?? '',
                                  city: address?.city?.name ?? '',
                                  selected: address?.isDefault ?? false,
                                ),
                              ),
                              _buttons(
                                  addressId: address?.id ?? 0,
                                  addressName: address?.name ?? '')
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _buttons({required String addressName, required int addressId}) {
    return Row(
      children: [
        // Set as default address button
        IconButton(
            onPressed: () => _setDefaultAddress(addressName: addressName, addressId: addressId),
            icon: SvgPicture.asset(AssetsManager.edit)),
        // Delete address button
        IconButton(
          onPressed: () => _deleteAddress(addressName: addressName, addressId: addressId),
          icon: SvgPicture.asset(AssetsManager.delete),
        ),
      ],
    );
  }
  
  Future<void> _setDefaultAddress(
      {required String addressName, required int addressId}) async {
    try {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        message: LocaleKeys.setDefault.tr(args: [addressName]),
      );

      if (confirmed) {
        // Show loading indicator
        setState(() {});
        
        // Set address as default
        await MiscellaneousApi.setAddressDefault(
          addressID: addressId, 
          locale: context.locale
        );
        
        // Refresh UI
        setState(() {});
      }
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> _deleteAddress(
      {required String addressName, required int addressId}) async {
    try {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        message: LocaleKeys.deleteAddressConfirmation.tr(args: [addressName]),
      );

      if (confirmed) {
        await MiscellaneousApi.deleteAddress(
            addressId: addressId, locale: context.locale);

        setState(() {});
      }
    } catch (error) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: error.toString(),
      );
    }
  }
}
