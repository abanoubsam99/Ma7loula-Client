import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/utils/assets_manager.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/core/utils/helpers.dart';
import 'package:ma7lola/core/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controller/user_provider.dart';
import '../../../../../../core/services/http/apis/miscellaneous_api.dart';
import '../../../../../../core/utils/util_values.dart';
import '../../../../../../core/widgets/loading_widget.dart';
import '../../../../../../model/car_parts_model.dart';
import '../services.dart';
import 'car_parts_search_screen.dart';
import 'cart_screen.dart';

class CategoriesScreen extends StatefulWidget {
  static String routeName = '/categories';
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // List<ProductCategories> productCategories = [
  //   ProductCategories(
  //     id: 1,
  //     image: URLImage(
  //       id: 1,
  //       url: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //     ),
  //     name: 'test1',
  //     subCategories: [
  //       SubCategories(
  //         name: 'productCategories1',
  //         id: 1,
  //         image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //       SubCategories(
  //         name: 'productCategories2',
  //         id: 2,
  //         image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //       SubCategories(
  //         name: 'productCategories3',
  //         id: 3,
  //         image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //       SubCategories(
  //         name: 'productCategories4',
  //         id: 4,
  //         image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //     ],
  //   ),
  //   ProductCategories(
  //     id: 2,
  //     image: URLImage(
  //       id: 2,
  //       url: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //     ),
  //     name: 'test2',
  //     subCategories: [
  //       SubCategories(
  //         name: 'productCategories5',
  //         id: 5,
  //         image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //       SubCategories(
  //         name: 'productCategories6',
  //         id: 6,
  //         image: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //     ],
  //   ),
  //   ProductCategories(
  //       id: 3,
  //       image: URLImage(
  //         id: 3,
  //         url: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //       name: 'test3'),
  //   ProductCategories(
  //       id: 4,
  //       image: URLImage(
  //         id: 4,
  //         url: 'https://i.ibb.co/Hz0q8H9/Rectangle-40-1.png',
  //       ),
  //       name: 'test4'),
  // ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection:
            Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
        child: FutureBuilder<CarPartsModel>(
            future: MiscellaneousApi.getCarParts(locale: context.locale),
            builder: (context, snapshot) {
              final userProvider = context.read<UserProvider>();

              if (snapshot.data == null) {
                return Container(
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: ColorsPalette.lightGrey,
                    borderRadius: UtilValues.borderRadius10,
                  ),
                  child: const Center(
                    child: LoadingWidget(),
                  ),
                );
              }

              final categories = snapshot.data!;

              if (categories.data == null) {
                return const SizedBox.shrink();
              }
              final category = categories.data?.productCategories;
              return Scaffold(
                backgroundColor: ColorsPalette.lightGrey,
                appBar: AppBarApp(
                  title: LocaleKeys.carParts.tr(),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CarPartsSearch(
                              search: true,
                              categories: category ?? [],
                              categoryID: 0,
                            );
                          }));
                        },
                        icon: SvgPicture.asset(AssetsManager.search)),
                    IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CartScreen(
                              carID: 0,
                              car: null,
                            );
                          }));
                        },
                        icon: SvgPicture.asset(AssetsManager.cart)),
                  ],
                ),
                body: Column(
                  children: [
                    UtilValues.gap8,
                    // if (categories.data != null && category != null)
                    ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => UtilValues.gap4,
                      itemCount: category?.length ?? 2,
                      itemBuilder: (context, index) {
                        final categ = category?[index];
                        return Services(
                          height: 13.h,
                          image: categ?.image?.url ?? '',
                          title: categ?.name ?? '',
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CarPartsSearch(
                                categories: category ?? [],
                                categoryID: categ?.id ?? 0,
                                search: false,
                              );
                            }));
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }));
  }
}
