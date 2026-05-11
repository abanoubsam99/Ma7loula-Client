import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_place/google_place.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../core/generated/locale_keys.g.dart';
import '../../../../../../core/services/http/api_endpoints.dart';
import '../../../../../../core/utils/assets_manager.dart';
import '../../../../../../core/utils/colors_palette.dart';
import '../../../../../../core/utils/font.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/form_widgets/text_input_field.dart';
import 'map_pick_location.dart';

class PlaceSearchScreen extends StatefulWidget {
  final bool isSource; // لتحديد ما إذا كان البحث للمصدر أو الوجهة
  final TextEditingController myLocController;
  final TextEditingController disController;

  PlaceSearchScreen(
      {Key? key,
      required this.isSource,
      required this.myLocController,
      required this.disController})
      : super(key: key);

  @override
  _PlaceSearchScreenState createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  List<AutocompletePrediction> myLocPredictions = [];
  List<AutocompletePrediction> disPredictions = [];
  late GooglePlace googlePlace;

  @override
  void initState() {
    super.initState();
    String apiKey = '$googleMapApiKey';
    googlePlace = GooglePlace(apiKey);
  }

  void _autoCompleteSearch(String value, bool isPickup) async {
    if (value.isNotEmpty) {
      var result = await googlePlace.autocomplete.get(
        value,
        language: 'ar',
        region: 'eg',
      );
      if (result != null && result.predictions != null) {
        setState(() {
          if (isPickup) {
            myLocPredictions = result.predictions!;
          } else {
            disPredictions = result.predictions!;
          }
        });
      }
    } else {
      setState(() {
        if (isPickup) {
          myLocPredictions = [];
        } else {
          disPredictions = [];
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.lightGrey,
      appBar: AppBarApp(
        title: LocaleKeys.chooseRoute.tr(),
      ),
      body: Column(
        children: [
          UtilValues.gap8,
          if(widget.isSource==true)
          myLocationFormField(),
          UtilValues.gap8,
          if(widget.isSource==false)
          disFormField(),
          UtilValues.gap8,
          GestureDetector(
            onTap: () async {
              try {
                // Wait for result from MapPickerScreen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPickerScreen(
                      isSource: widget.isSource,
                      myLocController: widget.myLocController,
                      disController: widget.disController,
                    ),
                  ),
                );

                // If we have a result and it's a valid location, update UI and return to previous screen
                if (result != null) {
                  setState(() {
                    // The text controllers are already updated in MapPickerScreen
                    // We just need to refresh the UI

                    // Clear the prediction list depending on whether this is the source or destination
                    if (widget.isSource) {
                      myLocPredictions = []; // Clear source location predictions
                    } else {
                      disPredictions = []; // Clear destination location predictions
                    }
                  });

                  // Return to the previous screen (probably map_screen) with the selected result
                  Navigator.pop(context, result);
                }
              } catch (e) {
                print('Error selecting location on map: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error selecting location: $e',
                      style: TextStyle(
                        color: ColorsPalette.white,
                        fontFamily: ZainTextStyles.font,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Row(
              children: [
                SvgPicture.asset(AssetsManager.searchPin),
                UtilValues.gap4,
                Text(
                  LocaleKeys.chooseOnMap.tr(),
                  style: TextStyle(
                      color: ColorsPalette.primaryColor,
                      fontWeight: FontWeight.w400,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 14.sp),
                ),
              ],
            ),
          ),
          Divider(
            color: ColorsPalette.grey,
            thickness: 1.5,
          ),
          Expanded(
            child: Column(
              children: [
                if (myLocPredictions.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: myLocPredictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: SvgPicture.asset(AssetsManager.lc),
                          title:
                              Text(myLocPredictions[index].description ?? ''),
                          onTap: () {
                            widget.myLocController.text =
                                myLocPredictions[index].description ?? '';
                            Navigator.pop(context, myLocPredictions[index]);
                          },
                        );
                      },
                    ),
                  ),
                if (disPredictions.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: disPredictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: SvgPicture.asset(AssetsManager.lc),
                          title: Text(disPredictions[index].description ?? ''),
                          onTap: () {
                            widget.disController.text =
                                disPredictions[index].description ?? '';
                            Navigator.pop(context, disPredictions[index]);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget myLocationFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextInputField(
        padding: EdgeInsets.all(11.sp),
        focusedBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide:
              const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide: BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        color: ColorsPalette.darkGrey,
        backgroundColor: ColorsPalette.white,
        controller: widget.myLocController,
        inputType: TextInputType.name,
        hint: LocaleKeys.searchYourCurrentLoc.tr(),
        name: '',
        onChanged: (value) {
          _autoCompleteSearch(value!, true);
        },
        prefixIcon: SvgPicture.asset(
          AssetsManager.location,
          color: ColorsPalette.grey,
          fit: BoxFit.scaleDown,
          width: 1,
          height: 1,
        ),
      ),
    );
  }

  Widget disFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextInputField(
        padding: EdgeInsets.all(11.sp),
        focusedBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide:
              const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UtilValues.borderRadius10,
          borderSide: BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
        ),
        color: ColorsPalette.darkGrey,
        backgroundColor: ColorsPalette.white,
        controller: widget.disController,
        inputType: TextInputType.name,
        hint: LocaleKeys.searchYourDis.tr(),
        name: '',
        onChanged: (String? value) {
          _autoCompleteSearch(value!, false);
        },
        prefixIcon: SvgPicture.asset(
          AssetsManager.flag,
          color: ColorsPalette.grey,
          fit: BoxFit.scaleDown,
          width: 1,
          height: 1,
        ),
      ),
    );
  }
}
