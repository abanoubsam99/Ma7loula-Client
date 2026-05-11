import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/model/addresses_model.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/winch/searchPlaces.dart';
import 'package:sizer/sizer.dart';

class WinchAddressSection extends StatefulWidget {
  final bool isSource;
  final String title;
  final TextEditingController controller;
  final List<Addresses>? savedAddresses;
  final int? selectedAddressId;
  final Function(int?, LatLng?) onAddressSelected;
  final Function(LatLng?) onMapLocationSelected;

  const WinchAddressSection({
    Key? key,
    required this.isSource,
    required this.title,
    required this.controller,
    required this.savedAddresses,
    required this.selectedAddressId,
    required this.onAddressSelected,
    required this.onMapLocationSelected,
  }) : super(key: key);

  @override
  State<WinchAddressSection> createState() => _WinchAddressSectionState();
}

class _WinchAddressSectionState extends State<WinchAddressSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: widget.isSource 
            ? ColorsPalette.lightGrey.withOpacity(0.3) 
            : ColorsPalette.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                fontFamily: ZainTextStyles.font,
                color: ColorsPalette.darkGrey,
              ),
            ),
          ),
          
          // Saved addresses section
          if (widget.savedAddresses != null && widget.savedAddresses!.isNotEmpty)
            _buildSavedAddressesSection()
          else
            _buildNoAddressesSection(),
            
          SizedBox(height: 12),
          
          // Map selection button
          _buildMapSelectionButton(),
          
          // Show selected address if any
          if (widget.controller.text.isNotEmpty)
            _buildSelectedAddressDisplay(),
        ],
      ),
    );
  }

  Widget _buildSavedAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select from saved addresses:",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            fontFamily: ZainTextStyles.font,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.savedAddresses?.length ?? 0,
            itemBuilder: (context, index) {
              final address = widget.savedAddresses![index];
              final isSelected = widget.selectedAddressId == address.id;
              
              return GestureDetector(
                onTap: () {
                  // Update location in controller
                  widget.controller.text = "${address.name}: ${address.details ?? ''}";
                  
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
                  width: 160,
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
                            "Default",
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

  Widget _buildNoAddressesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
    );
  }

  Widget _buildMapSelectionButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select on Map:",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            fontFamily: ZainTextStyles.font,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            try {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceSearchScreen(
                    isSource: widget.isSource,
                    myLocController: widget.isSource 
                        ? widget.controller 
                        : TextEditingController(),
                    disController: !widget.isSource 
                        ? widget.controller 
                        : TextEditingController(),
                  ),
                ),
              );
              
              // If we have a result and it's a valid location, update the parent
              if (result != null && result is LatLng) {
                widget.onMapLocationSelected(result);
              }
            } catch (e) {
              print('Error selecting location on map: $e');
            }
          },
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
        ),
      ],
    );
  }

  Widget _buildSelectedAddressDisplay() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsPalette.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsPalette.primaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isSource ? "Your Location:" : "Destination:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              fontFamily: ZainTextStyles.font,
              color: ColorsPalette.darkGrey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            widget.controller.text,
            style: TextStyle(
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
