import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/widgets/form_widgets/ternary_button.dart';
import 'package:ma7lola/core/widgets/loading_widget.dart';
import 'package:ma7lola/view/screens/auth/SignUpForm.dart';
import 'package:ma7lola/view/screens/main_screen/main_screen.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/home_tab/emergency/emergency_map_ploying.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/requestNotificationsPermission.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../model/batteries_products_model.dart';
import '../../../model/car_model.dart';
import '../../../model/products_model.dart';
import '../../../model/tires_products_model.dart';
import '../main_screen/tabs/home_tab/batteries/batteries_checkout_screen.dart';
import '../main_screen/tabs/home_tab/car_parts/checkout_screen.dart';
import '../main_screen/tabs/home_tab/tires/tires_checkout_screen.dart';
import '../main_screen/tabs/home_tab/winch/map_ploying.dart';

class LoginScreen extends StatefulWidget {
  final List<Products> products;
  final List<Batteries> batteries;
  final List<Tires> tires;
  final int carID;
  final bool fromWinch;
  final bool fromEmergency;
  final bool fromCart;
  final bool fromCartBatteries;
  final bool fromCartTires;
  final Car? car;
  LoginScreen({
    Key? key,
    this.fromWinch = false,
    this.fromEmergency = false,
    required this.fromCart,
    required this.carID,
    required this.products,
    required this.batteries,
    required this.fromCartBatteries,
    required this.tires,
    required this.fromCartTires,
    required this.car,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  var _phoneController = TextEditingController();

  var _passwordController = TextEditingController();

  bool showSniper = false;

  bool showPass = true;
  bool _loading = false;

  String? password;

  @override
  void initState() {
    requestNotificationsPermission();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                  ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
              image: AssetImage(AssetsManager.backgroundLogo),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UtilValues.gap16,
                    SizedBox(
                      width: 80.w,
                      height: 35.h,
                      child: Center(
                          child: Image.asset(
                        AssetsManager.appBlackLogo,
                      )),
                    ),
                    Text(
                      LocaleKeys.login.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 22.sp),
                    ),
                    UtilValues.gap32,
                    phoneFormField(),
                    UtilValues.gap8,
                    passwordFormField(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.forgetPassword.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        TernaryButton(
                            padding: EdgeInsets.zero,
                            label: LocaleKeys.reset.tr(),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, RegisterScreen.routeName,
                                  arguments: true);
                            }),
                      ],
                    ),
                    UtilValues.gap8,
                    _signInButton(),
                    UtilValues.gap12,
                    _signUpButton(),
                    UtilValues.gap24,
                    TernaryButton(
                        padding: EdgeInsets.zero,
                        label: LocaleKeys.guestUser.tr(),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen(
                                      index: 0,
                                    )),
                          );
                        }),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    try {
      final formState = _formKey.currentState;
      if (formState != null && formState.validate()) {
        setState(() => _loading = true);
        
        // Ensure phone and password are not empty before login
        if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: LocaleKeys.fieldRequired.tr(),
          );
          setState(() => _loading = false);
          return;
        }
        
        await context.read<UserProvider>().login(
            password: _passwordController.text,
            phone: _phoneController.text,
            locale: context.locale);
        // Don't set loading to true again - it's already true
        // This was likely a bug in the original code
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
        } else if (widget.fromWinch == true) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return MapPolylineScreen();
          }));
        } else if (widget.fromEmergency == true) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return EmergencyMapPolylineScreen();
          }));
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      index: 0,
                    )),
          );
        }
      }
    } catch (e) {
      showSnackbar(
        context: context,
        status: SnackbarStatus.error,
        message: e.toString(),
      );
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  _signInButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: signIn,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontSize: 14.sp,
            ),
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
                  LocaleKeys.loginBtn.tr(),
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

  _signUpButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, RegisterScreen.routeName);
        },
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorsPalette.black,
              fontFamily: ZainTextStyles.font,
              fontSize: 14.sp,
            ),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: ColorsPalette.black),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.lighttGrey),
        ),
        child: Center(
          child: Text(
            LocaleKeys.signUp.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorsPalette.black,
                fontFamily: ZainTextStyles.font,
                fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  Widget phoneFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.phone.tr(),
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
            borderSide:
                const BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: UtilValues.borderRadius10,
            borderSide:
                BorderSide(color: ColorsPalette.extraDarkGrey, width: 1),
          ),
          color: ColorsPalette.darkGrey,
          backgroundColor: ColorsPalette.white,
          controller: _phoneController,
          inputType: TextInputType.phone,
          name: LocaleKeys.name.tr(),
          key: const ValueKey('phone'),
          hint: '',
          validator: FormBuilderValidators.equalLength(11),
        ),
      ],
    );
  }

  Widget passwordFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.password.tr(),
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
            controller: _passwordController,
            inputType: TextInputType.name,
            obscured: showPass,
            name: LocaleKeys.password,
            key: const ValueKey('password'),
            hint: '',
            validator: FormBuilderValidators.required(),

            // prefixIcon: const Icon(Icons.lock_outline),
            // validator: FormBuilderValidators.minWordsCount(5),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  showPass = !showPass;
                });
              },
              icon: showPass
                  ? Icon(
                      Icons.remove_red_eye,
                      color: ColorsPalette.primaryColor,
                    )
                  : Icon(
                      Icons.remove_red_eye_outlined,
                      color: ColorsPalette.primaryColor,
                    ),
            )),
      ],
    );
  }
}
