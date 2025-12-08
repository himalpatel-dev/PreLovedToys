class Address {
  final int id;
  final String receiverName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String addressType; // 'Home', 'Work', 'Other'
  final bool isDefault;

  Address({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.addressType,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      receiverName: json['receiver_name'] ?? 'Unknown',
      phoneNumber: json['phone_number'] ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      addressType: json['address_type'] ?? 'Other',
      isDefault: json['is_default'] ?? false,
    );
  }

  // Helper to format full address string
  String get fullAddress {
    String addr = addressLine1;
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      addr += ", $addressLine2";
    }
    addr += ", $city, $state - $pincode";
    addr += "\n$country";
    return addr;
  }
}
