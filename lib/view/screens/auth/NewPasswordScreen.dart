import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/widgets/loading_widget.dart';
import 'package:ma7lola/view/screens/auth/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/password_validator.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../loca_widgets/PasswordRequirementStep.dart';

class NewPasswordScreen extends StatefulWidget {
  static const String routeName = '/newPassword';
  final String phone;
  final int otp;
  NewPasswordScreen({Key? key, required this.phone, required this.otp})
      : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  var _passwordController = TextEditingController();

  var _confirmPasswordController = TextEditingController();

  bool showSniper = false;

  bool showPass = true;
  bool showConPass = true;
  bool _loading = false;

  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Center(
                      child: Text(
                        LocaleKeys.newPassword.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 22.sp),
                      ),
                    ),
                    UtilValues.gap48,
                    passwordFormField(),
                    UtilValues.gap16,
                    confirmPasswordFormField(),
                    UtilValues.gap12,
                    Text(
                      LocaleKeys.passwordTerms.tr(),
                      style: TextStyle(
                          color: ColorsPalette.passwordRequirementGrey,
                          fontWeight: FontWeight.w600,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 14.sp),
                    ),
                    PasswordRequirementStep(LocaleKeys.conOne.tr()),
                    PasswordRequirementStep(LocaleKeys.conTwo.tr()),
                    PasswordRequirementStep(LocaleKeys.conThree.tr()),
                    UtilValues.gap20,
                    _changePasswordButton(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void changePassword() async {
    try {
      final formState = _formKey.currentState ?? _formKey.currentState;
      if (formState!.validate()) {
        // Validate the password meets requirements
        String? passwordError = AppPasswordValidator.validate(context, _passwordController.text);
        if (passwordError != null) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: passwordError,
          );
          setState(() => _loading = false);
          return;
        }
        
        // Validate passwords match
        if (_passwordController.text != _confirmPasswordController.text) {
          showSnackbar(
            context: context,
            status: SnackbarStatus.error,
            message: LocaleKeys.passwordsDoNotMatch.tr(),
          );
          setState(() => _loading = false);
          return;
        }
        
        setState(() => _loading = true);
        await context.read<UserProvider>().resetPassword(
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            phone: widget.phone,
            otp: widget.otp,
            locale: context.locale);
            
        // Show success message
        showSnackbar(
          context: context,
          status: SnackbarStatus.success,
          message: LocaleKeys.passwordChangedSuccess.tr(),
        );

        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen(
              products: [],
              batteries: [],
              tires: [],
              carID: 0,
              fromCart: false,
              fromCartBatteries: false,
              fromCartTires: false,
              car: null,
            )),
            (route) => false);
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

  _changePasswordButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      height: 6.h,
      child: ElevatedButton(
        onPressed: changePassword,
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
                  LocaleKeys.changePassword.tr(),
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
          controller: _passwordController,
          inputType: TextInputType.visiblePassword,
          obscured: showPass,
          name: LocaleKeys.password.tr(),
          key: const ValueKey('password'),
          hint: '',
          validator: (value) => AppPasswordValidator.validate(context, value),
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
          ),
        ),
      ],
    );
  }

  Widget confirmPasswordFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.confirmPassword.tr(),
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
          controller: _confirmPasswordController,
          inputType: TextInputType.visiblePassword,
          obscured: showConPass,
          name: LocaleKeys.confirmPassword.tr(),
          key: const ValueKey('confirmPassword'),
          hint: '',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.fieldRequired.tr();
            }
            if (value != _passwordController.text) {
              return LocaleKeys.passwordsDoNotMatch.tr();
            }
            return null;
          },
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showConPass = !showConPass;
              });
            },
            icon: showConPass
                ? Icon(
                    Icons.remove_red_eye,
                    color: ColorsPalette.primaryColor,
                  )
                : Icon(
                    Icons.remove_red_eye_outlined,
                    color: ColorsPalette.primaryColor,
                  ),
          ),
        ),
      ],
    );
  }
}
