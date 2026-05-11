import 'dart:async';

import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:ma7lola/view/screens/auth/LoginScreen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controller/user_provider.dart';
import '../../../core/generated/locale_keys.g.dart';
import '../../../core/services/http/apis/user_api.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../core/utils/colors_palette.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/util_values.dart';
import '../../../core/widgets/form_widgets/ternary_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../main_screen/main_screen.dart';
import 'AccountDetails.dart';
import 'NewPasswordScreen.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/otp';

  final String phone;
  final String newPhone;
  final bool changePassword;
  final bool changePhone;
  OtpScreen(
      {Key? key,
      required this.phone,
      required this.newPhone,
      required this.changePassword,
      required this.changePhone})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const otpCodeDurationInSeconds = 120;

  StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>();

  final _formKey = GlobalKey<FormState>();

  var _userNameController = TextEditingController();

  var _passwordController = TextEditingController();

  var _confirmPasswordController = TextEditingController();

  bool showSniper = false;

  bool showPass = true;

  bool showConfirmPass = true;
  bool _loading = false;

  String? password;
  String? _verificationId;
  bool _isInit = false;
  String? _phoneNumber;
  String? _otpCode;
  bool _isLoading = false;
  int? _resendToken;
  int _passedSecondsSinceOtpSent = 0;
  // Timer? _timer;

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
                      LocaleKeys.confirmPhoneNumber.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: ZainTextStyles.font,
                          fontSize: 22.sp),
                    ),
                    UtilValues.gap48,
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        LocaleKeys.putConfirmationCode.tr(),
                        style: TextStyle(
                            color: ColorsPalette.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: ZainTextStyles.font,
                            fontSize: 14.sp),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        errorAnimationController: errorController,
                        // enabled: !_loading && _verificationId != null,
                        length: 6,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          fieldHeight: 50,
                          fieldWidth: 45,
                          borderWidth: 1,
                          borderRadius: UtilValues.borderRadius10,
                          selectedColor: ColorsPalette.primaryColor,
                          activeColor: ColorsPalette.white,
                          inactiveColor: ColorsPalette.white,
                          disabledColor: ColorsPalette.white,
                          inactiveFillColor: ColorsPalette.white,
                          activeFillColor: ColorsPalette.white,
                          selectedFillColor: ColorsPalette.white,
                        ),
                        beforeTextPaste: (text) => false,
                        textStyle: const TextStyle(
                          color: ColorsPalette.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(),
                        onChanged: (otp) => setState(() => _otpCode = otp),
                        // onCompleted: (otp) => _login(withOtpVerification: true),
                      ),
                    ),
                    UtilValues.gap16,
                    _submitButton(),
                    UtilValues.gap24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.changePassword
                              ? LocaleKeys.rememberPassword.tr()
                              : LocaleKeys.didntReciveCode.tr(),
                          style: TextStyle(
                              color: ColorsPalette.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: ZainTextStyles.font,
                              fontSize: 14.sp),
                        ),
                        TernaryButton(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            label: widget.changePassword
                                ? LocaleKeys.login.tr()
                                : LocaleKeys.sentAgain.tr(),
                            underLine: true,
                            onTap: () async {
                              if (widget.changePassword) {
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
                              } else {
                                try {
                                  final res = await UserApi.sentOtp(
                                      phone: widget.phone,
                                      locale: context.locale,
                                      purpose: 'register');

                                  showSnackbar(
                                    context: context,
                                    status: SnackbarStatus.success,
                                    message:
                                        res.data?.otpForTesting.toString() ??
                                            '',
                                  );
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return OtpScreen(
                                      phone: widget.phone,
                                      changePassword: false,
                                      changePhone: false,
                                      newPhone: '',
                                    );
                                  }));
                                } catch (e) {
                                  showSnackbar(
                                    context: context,
                                    status: SnackbarStatus.error,
                                    message: e.toString() ?? '',
                                  );
                                }
                              }
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

  void submit() async {
    try {
      if (_otpCode?.isNotEmpty ?? false) {
        setState(() => _loading = true);

        await context.read<UserProvider>().verifyOtp(
            phone: widget.phone ?? '',
            otp: _otpCode.toString(),
            locale: context.locale);
        setState(() => _loading = true);
        if (widget.changePassword) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return NewPasswordScreen(
              phone: widget.phone,
              otp: int.tryParse(_otpCode ?? '') ?? 0,
            );
          }));
        } else if (widget.changePhone) {
          await context.read<UserProvider>().updatePhone(
              phone: widget.newPhone ?? '',
              otp: int.tryParse(_otpCode ?? '') ?? 0,
              locale: context.locale);
          showSnackbar(
            context: context,
            status: SnackbarStatus.success,
            message: LocaleKeys.done.tr(),
          );
          setState(() => _loading = true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      index: 0,
                    )),
          );
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AccountDetails(phone: widget.phone, otp: _otpCode ?? '');
          }));
        }
      } else {
        showSnackbar(
          context: context,
          status: SnackbarStatus.error,
          message: LocaleKeys.putConfirmationCode.tr(),
        );
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

  _submitButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(1.sp),
      // width: 35.w,
      height: 6.h,
      child: ElevatedButton(
        onPressed: submit,
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
                  LocaleKeys.continu.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
