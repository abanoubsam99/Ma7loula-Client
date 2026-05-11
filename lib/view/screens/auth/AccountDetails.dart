import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/text_input_field.dart';
import '../loca_widgets/PasswordRequirementStep.dart';
import 'YourCarDetails.dart';

class AccountDetails extends StatefulWidget {
  static const String routeName = '/accountDetails';
  final String phone;
  final String otp;
  AccountDetails({Key? key, required this.phone, required this.otp})
      : super(key: key);

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  final _formKey = GlobalKey<FormState>();

  var _userNameController = TextEditingController();
  var _userMailController = TextEditingController();

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        LocaleKeys.accountDetails.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 22.sp),
                      ),
                    ),
                    UtilValues.gap32,
                    nameFormField(),
                    UtilValues.gap8,
                    mailFormField(),
                    UtilValues.gap8,
                    passwordFormField(),
                    UtilValues.gap8,
                    confirmPasswordFormField(),
                    UtilValues.gap16,
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
      if (_userMailController.text.isEmpty) {
        setState(() {
          _userMailController.text = _userNameController.text;
        });
      }

      if (formState!.validate() &&
          _passwordController.text.isNotEmpty &&
          _userNameController.text.isNotEmpty &&
          _userMailController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        setState(() => _loading = true);

        await context.read<UserProvider>().register(
              password: _passwordController.text,
              name: _userNameController.text,
              passwordConfirmation: _confirmPasswordController.text,
              mail: _userMailController.text,
              phone: widget.phone ?? '',
              otp: int.tryParse(widget.otp ?? '') ?? 0,
              locale: context.locale,
            );
        setState(() => _loading = true);
        Navigator.pushReplacementNamed(context, YourCarDetails.routeName);
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
            TextStyle(fontSize: 16.sp, fontFamily: ZainTextStyles.font),
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
                  LocaleKeys.createAccount.tr(),
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

  Widget nameFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.name.tr(),
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
          controller: _userNameController,
          inputType: TextInputType.name,
          name: LocaleKeys.name.tr(),
          key: const ValueKey('name'),
          hint: '',
          validator: FormBuilderValidators.required(),
        ),
      ],
    );
  }

  Widget mailFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.mail.tr(),
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
          controller: _userMailController,
          inputType: TextInputType.emailAddress,
          name: LocaleKeys.mail.tr(),
          key: const ValueKey('mail'),
          hint: '',
          validator: FormBuilderValidators.email(),
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
          inputType: TextInputType.name,
          obscured: showPass,
          name: LocaleKeys.password,
          key: const ValueKey('password'),
          hint: '',
          validator: FormBuilderValidators.minLength(8),
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
          inputType: TextInputType.name,
          obscured: showConPass,
          name: LocaleKeys.password,
          key: const ValueKey('confirmPassword'),
          hint: '',
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
          // validator: FormBuilderValidators.match(_passwordController.text),
        ),
      ],
    );
  }
}
