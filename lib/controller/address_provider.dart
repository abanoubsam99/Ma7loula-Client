// import 'package:flutter/cupertino.dart';
//
// class AddressProvider with ChangeNotifier {
//   List<AddressModel> _addresses = [];
//   List<AddressModel> get addresses => [..._addresses];
//
//   Address? _selectedAddress;
//
//   set selectedAddress(Address address) {
//     _selectedAddress = address;
//     notifyListeners();
//   }
//
//   Address get selectedAddress => _selectedAddress ??= _addresses.first;
//
//   Future<void> getAddresses() async {
//     try {
//       _addresses = await AddressesApi.getAddresses();
//       notifyListeners();
//     } catch (_) {}
//   }
//
//   Future<void> addNewAddress(Map<String, dynamic> data) async {
//     try {
//       await AddressesApi.addNewAddress(data);
//       await getAddresses();
//     } catch (_) {}
//   }
// }
