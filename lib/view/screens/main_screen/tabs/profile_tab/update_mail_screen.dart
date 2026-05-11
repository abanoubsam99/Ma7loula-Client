import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ma7lola/core/utils/font.dart';
import 'package:ma7lola/core/widgets/loading_widget.dart';
import 'package:ma7lola/view/screens/main_screen/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controller/user_provider.dart';
import '../../../../../core/generated/locale_keys.g.dart';
import '../../../../../core/utils/colors_palette.dart';
import '../../../../../core/utils/snackbars.dart';
import '../../../../../core/utils/util_values.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/form_widgets/text_input_field.dart';

class UpdateMailScreen extends StatefulWidget {
  static const String routeName = '/updateMail';

  UpdateMailScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateMailScreen> createState() => _UpdateMailScreenState();
}

class _UpdateMailScreenState extends State<UpdateMailScreen> {
  final _formKey = GlobalKey<FormState>();
  var _phoneController = TextEditingController();

  var _userNameController = TextEditingController();
  var _userMailController = TextEditingController();
  bool showSniper = false;

  bool _loading = false;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final name = ModalRoute.of(context)!.settings.arguments as bool? ?? false;

    return Scaffold(
      appBar: AppBarApp(
        title: LocaleKeys.editProfile.tr(),
      ),
      bottomNavigationBar: _changePasswordButton(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: ColorsPalette.lighttGrey,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UtilValues.gap16,
                    if (name) nameFormField(),
                    if (!name) ...[
                      UtilValues.gap12,
                      mailFormField(),
                    ]
                    // UtilValues.gap12,
                    // phoneFormField(),
                    // UtilValues.gap12,
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
        setState(() => _loading = true);
        await context.read<UserProvider>().updateProfile(
            name: _userNameController.text,
            mail: _userMailController.text,
            phone: _phoneController.text,
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
                    index: 3,
                  )),
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

  _changePasswordButton() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.all(14.sp),
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
                  LocaleKeys.editProfile.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsPalette.white,
                      fontFamily: ZainTextStyles.font,
                      fontSize: 16.sp),
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
              fontSize: 14.sp),
        ),
        TextInputField(
          padding: EdgeInsets.all(11.sp),
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

  _loadData() {
    final userProvider = context.read<UserProvider>();

    _phoneController.text = userProvider.user?.data?.user?.phone ?? '';
    _userNameController.text = userProvider.user?.data?.user?.name ?? '';
    _userMailController.text = userProvider.user?.data?.user?.email ?? '';
  }
}
