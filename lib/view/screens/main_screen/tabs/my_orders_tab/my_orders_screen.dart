import 'package:easy_localization/easy_localization.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ma7lola/controller/user_provider.dart';
import 'package:ma7lola/core/generated/locale_keys.g.dart';
import 'package:ma7lola/core/services/http/apis/miscellaneous_api.dart';
import 'package:ma7lola/core/utils/colors_palette.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/my_orders_tab/local_widet/no_orders_found.dart';
import 'package:ma7lola/view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/font.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../../model/my_orders_model.dart';
import 'local_widet/my_orders_card.dart';

class MyOrdersTab extends StatefulWidget {
  MyOrdersTab({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<MyOrdersTab> createState() => _MyOrdersTabState();
}

class _MyOrdersTabState extends State<MyOrdersTab>
    with TickerProviderStateMixin {
  final _numberOfPostsPerRequest = 10;

  final PagingController<int, Orders> _pagingControllerForAll =
      PagingController(firstPageKey: 1);

  int ordersLength = 0;
  Future<void> _fetchPage(int pageKey) async {
    try {
      final userProvider = context.read<UserProvider>();
      if (userProvider.isLoggedIn) {
        final items = (categorySelected == 0)
            ? await MiscellaneousApi.getMyOrdersBatteries(
                locale: context.locale,
                page: pageKey,
                perPage: _numberOfPostsPerRequest,
              )
            : (categorySelected == 1)
                ? await MiscellaneousApi.getMyOrdersTires(
                    locale: context.locale,
                    page: pageKey,
                    perPage: _numberOfPostsPerRequest,
                  )
                : (categorySelected == 2)
                    ? await MiscellaneousApi.getMyOrdersCarParts(
                        locale: context.locale,
                        page: pageKey,
                        perPage: _numberOfPostsPerRequest,
                      )
                    : (categorySelected == 3)
                        ? await MiscellaneousApi.getMyOrdersWinch(
                            locale: context.locale,
                            page: pageKey,
                            perPage: _numberOfPostsPerRequest,
                          )
                        : await MiscellaneousApi.getMyOrdersEmergency(
                            locale: context.locale,
                            page: pageKey,
                            perPage: _numberOfPostsPerRequest,
                          );
        setState(() {
          ordersLength = items.pagination?.total ?? 0;

          if (items.data?.orders?.isEmpty ?? true) {
            _pagingControllerForAll.appendLastPage([]);
          } else {
            final isLastPage =
                (items.data?.orders?.length ?? 0) < _numberOfPostsPerRequest;

            if (isLastPage) {
              _pagingControllerForAll.appendLastPage(items.data!.orders!);
            } else {
              final nextPageKey = pageKey + 1;
              _pagingControllerForAll.appendPage(
                  items.data!.orders!, nextPageKey);
            }
          }
          _isLoading = false;
        });
      } else {
        _pagingControllerForAll.appendLastPage([]);
      }
    } catch (e) {
      _pagingControllerForAll.error = e;
    }
  }

  final _scrollController = ScrollController();
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (!(_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse)) {
        return;
      }
      FocusScope.of(context).unfocus();
    });
    _pagingControllerForAll.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _tabController = TabController(vsync: this, length: categories.length)
      ..addListener(_handleTabSelection);
    _init();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    /*if (_tabController.index == 0 ||
        _tabController.index == 1 ||
        _tabController.index == 2 ||
        _tabController.index == 3) {*/
    setState(() {
      categorySelected = _tabController.index;

      _pagingControllerForAll.refresh();
    });
    /* } else {
      _pagingControllerForAll.itemList?.clear();
      _pagingControllerForAll.itemList = [];
    }*/

    // _fetchPage(1);

    // print(_tabController.index);
  }

  _init() {
    if (widget.index != 0) {
      setState(() {
        categorySelected = widget.index;
        _tabController.index = widget.index;
      });
    }
  }

  int categorySelected = 0;

  final categories = [
    LocaleKeys.batteries.tr(),
    LocaleKeys.tires.tr(),
    LocaleKeys.carParts.tr(),
    LocaleKeys.winch.tr(),
    LocaleKeys.emergency.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = categories
        .map((e) => Tab(
              child: Text(
                e,
                style: TextStyle(
                    color: ColorsPalette.customGrey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: ZainTextStyles.font),
              ),
            ))
        .toList();

    return Directionality(
      textDirection:
          Helpers.isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: DefaultTabController(
          length: categories.length,
          child: Scaffold(
            backgroundColor: ColorsPalette.lightGrey,
            appBar: TabBar(
              overlayColor: MaterialStateProperty.all(ColorsPalette.white),
              labelColor: ColorsPalette.customGrey,
              unselectedLabelColor: ColorsPalette.customGrey,
              labelStyle: const TextStyle(color: ColorsPalette.black),
              controller: _tabController,
              tabs: tabs,
            ),
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: tabs
                  .map((tab) =>
                      buildGridView(height: MediaQuery.of(context).size.height))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  SizedBox buildGridView({required double height}) {
    return SizedBox(
      height: height,
      child: RefreshIndicator(
        color: ColorsPalette.primaryColor,
        onRefresh: () => Future.sync(() => _pagingControllerForAll.refresh()),
        child: PagedGridView<int, Orders>(
          scrollController: _scrollController,
          showNewPageProgressIndicatorAsGridChild: false,
          showNewPageErrorIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: _pagingControllerForAll,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 5.w / 1.84.h,
          ),
          builderDelegate: PagedChildBuilderDelegate<Orders>(
              firstPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              newPageProgressIndicatorBuilder: (context) =>
                  const Center(child: LoadingWidget()),
              noItemsFoundIndicatorBuilder: (context) => _isLoading
                  ? const Center(child: LoadingWidget())
                  : const NoOrdersFound(),
              itemBuilder: (context, item, index) {
                final order = item;
                return Padding(
                  padding: EdgeInsets.all(5.0.sp),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return OrderDetails(
                          orderNum: order.id ?? 1,
                          orderType: categorySelected,
                        );
                      }));
                    },
                    child: MyOrderCard(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return OrderDetails(
                            orderNum: order.id ?? 1,
                            orderType: categorySelected,
                          );
                        }));
                      },
                      status: order.status ?? '',
                      date: order.deliveryTime ?? '',
                      total: order.total ?? 0,
                      orderNum: order.id ?? 1,
                      car: order.userCar,
                      products: order.products ?? [],
                      fromText: order.fromText,
                      toText: order.toText,
                      myLocText: order.myLocText ?? '',
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
