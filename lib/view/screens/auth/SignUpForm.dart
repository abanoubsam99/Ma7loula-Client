import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sizer/sizer.dart';

import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/user_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/password_validator.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/ternary_button.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../loca_widgets/PasswordRequirementStep.dart';
import 'LoginScreen.dart';
import 'OtpScreen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';

  RegisterScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  var _phoneController = TextEditingController();
  // Password fields removed as they are only used in the final registration screen

  bool showSniper = false;
  // Password visibility flags removed
  bool _loading = false;

  String? password;

  @override
  Widget build(BuildContext context) {
    final isChangePassword =
        ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            // Removed fixed height to allow proper scrolling
            decoration: BoxDecoration(
              color: ColorsPalette.lighttGrey,
              image: DecorationImage(
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    ColorsPalette.light.withOpacity(.9), BlendMode.lighten),
                image: AssetImage(AssetsManager.backgroundLogo),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                    UtilValues.gap24,
                    Text(
                      isChangePassword
                          ? LocaleKeys.resetPassword.tr()
                          : LocaleKeys.signUp.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 22.sp),
                    ),
                    UtilValues.gap48,
                    phoneFormField(),
                    // Password fields and requirements removed from the first screen
                    UtilValues.gap16,
                    _signUpButton(),
                    UtilValues.gap24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isChangePassword
                              ? LocaleKeys.rememberPassword.tr()
                              : LocaleKeys.haveAccount.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        TernaryButton(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            label: LocaleKeys.login.tr(),
                            underLine: true,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return LoginScreen(
                                  products: [],
                                  batteries: [],
                                  tires: [],
                                  carID: 0,
                                  fromCart: false,
                                  fromCartBatteries: false,
                                  fromCartTires: false,
                                  car: null,
                                );
                              }));
                            }),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void signUp() async {
    final isChangePassword =
        ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    try {
      final formState = _formKey.currentState ?? _formKey.currentState;
      if (formState!.validate()) {
        setState(() => _loading = true);
        if (isChangePassword) {
          final res = await UserApi.sentOtp(
              phone: _phoneController.text,
              locale: context.locale,
              purpose: 'reset-password');
          showSnackbar(
            context: context,
            status: SnackbarStatus.success,
            message: res.data?.otpForTesting.toString() ?? '',
          );
          setState(() => _loading = true);

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OtpScreen(
              phone: _phoneController.text,
              changePassword: true,
              changePhone: false,
              newPhone: '',
            );
          }));
        } else {
          // Password validation removed as passwords are now only entered in the final registration screen
          
          final res = await UserApi.sentOtp(
              phone: _phoneController.text,
              locale: context.locale,
              purpose: 'register');
          showSnackbar(
            context: context,
            status: SnackbarStatus.success,
            message: res.data?.otpForTesting.toString() ?? '',
          );

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OtpScreen(
              phone: _phoneController.text,
              changePassword: false,
              changePhone: false,
              newPhone: '',
              // No password passed to OTP screen anymore
            );
          }));
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

  _signUpButton() {
    final isChangePassword =
        ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      // width: 35.w,
      height: 6.h,
      child: ElevatedButton(
        onPressed: signUp,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontSize: 14.sp, fontFamily: ZainTextStyles.font),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: ColorsPalette.primaryColor),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorsPalette.primaryColor),
        ),
        child: Center(
          child: _loading
              ? LoadingWidget(
                  color: ColorsPalette.white,
                )
              : Text(
                  isChangePassword
                      ? LocaleKeys.confirmPhone.tr()
                      : LocaleKeys.createAccount.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
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
  
  // Password form fields removed as they're now only in the final registration screen
}
