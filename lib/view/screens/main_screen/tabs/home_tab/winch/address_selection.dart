import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/utils/util_values.dart';
import 'package:ma7lola/model/addresses_model.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/winch/searchPlaces.dart';
import 'package:sizer/sizer.dart';

class AddressSelectionWidget extends StatefulWidget {
  final bool isSource;
  final TextEditingController locationController;
  final List<Addresses>? savedAddresses;
  final int? selectedAddressId;
  final Function(int?, LatLng?) onAddressSelected;
  final Function() onMapSelection;

  const AddressSelectionWidget({
    Key? key,
    required this.isSource,
    required this.locationController,
    required this.savedAddresses,
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.onMapSelection,
  }) : super(key: key);

  @override
  State<AddressSelectionWidget> createState() => _AddressSelectionWidgetState();
}

class _AddressSelectionWidgetState extends State<AddressSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: ColorsPalette.primaryLightColor,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          width: double.infinity,
          child: Row(
            children: [
              SvgPicture.asset(
                widget.isSource ? AssetsManager.location : AssetsManager.flag,
                color: ColorsPalette.grey,
                width: 20,
                height: 20,
              ),
              SizedBox(width: 8),
              Text(
                widget.isSource 
                    ? LocaleKeys.searchYourCurrentLoc.tr() 
                    : LocaleKeys.searchYourDis.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  fontFamily: ZainTextStyles.font,
                ),
              ),
            ],
          ),
        ),
        
        // Address content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saved addresses section
              if (widget.savedAddresses != null && widget.savedAddresses!.isNotEmpty) 
                _buildSavedAddresses()
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: ColorsPalette.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorsPalette.lightGrey)
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off, 
                        color: ColorsPalette.primaryColor.withOpacity(0.7),
                        size: 36,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "No saved addresses found", 
                        style: TextStyle(
                          fontFamily: ZainTextStyles.font,
                          color: ColorsPalette.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 16),
              
              // Map selection button
              _buildMapSelectionButton(),
              
              // Selected address display
              if (widget.locationController.text.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorsPalette.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorsPalette.primaryColor),
                  ),
                  child: Text(
                    widget.locationController.text,
                    style: TextStyle(
                      fontFamily: ZainTextStyles.font,
                      color: ColorsPalette.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavedAddresses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Row(
            children: [
              Icon(Icons.bookmark, color: ColorsPalette.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                "Saved Addresses",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  fontFamily: ZainTextStyles.font,
                  color: ColorsPalette.primaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorsPalette.lightGrey, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.savedAddresses?.length ?? 0,
            itemBuilder: (context, index) {
              final address = widget.savedAddresses![index];
              final isSelected = widget.selectedAddressId == address.id;
              
              return GestureDetector(
                onTap: () {
                  // Update location in controller
                  widget.locationController.text = "${address.name}: ${address.details ?? ''}";
                  
                  // Create LatLng if coordinates are available
                  LatLng? coordinates;
                  if (address.lat != null && address.lon != null) {
                    try {
                      coordinates = LatLng(
                        double.parse(address.lat!),
                        double.parse(address.lon!)
                      );
                    } catch (e) {
                      print("Error parsing coordinates: $e");
                    }
                  }
                  
                  // Notify parent widget
                  widget.onAddressSelected(address.id, coordinates);
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorsPalette.primaryLightColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? ColorsPalette.primaryColor : ColorsPalette.extraDarkGrey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.name ?? "Address",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: ZainTextStyles.font,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          address.details ?? "",
                          style: TextStyle(
                            color: ColorsPalette.darkGrey,
                            fontSize: 12.sp,
                            fontFamily: ZainTextStyles.font,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (address.isDefault == true)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorsPalette.default1,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            LocaleKeys.defualt.tr(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: ZainTextStyles.font,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapSelectionButton() {
    return InkWell(
      onTap: widget.onMapSelection,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorsPalette.primaryColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, color: ColorsPalette.primaryColor, size: 24),
            SizedBox(width: 10),
            Text(
              "Select on Map",
              style: TextStyle(
                color: ColorsPalette.primaryColor,
                fontWeight: FontWeight.w600,
                fontFamily: ZainTextStyles.font,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
