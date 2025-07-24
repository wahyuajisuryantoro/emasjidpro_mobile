class User {
  final int userId;
  final String username;
  final String name;
  final String category;
  final String replika;
  final String referral;
  final String subdomain;
  final String link;
  final String numberId;
  final String birth;
  final String sex;
  final String address;
  final String city;
  final String phone;
  final String email;
  final String bankName;
  final String bankBranch;
  final String bankAccountNumber;
  final String bankAccountName;
  final String lastLogin;
  final String lastIpaddress;
  final String picture;
  final String date;
  final String publish;

  User({
    required this.userId,
    required this.username,
    required this.name,
    required this.category,
    required this.replika,
    required this.referral,
    required this.subdomain,
    required this.link,
    required this.numberId,
    required this.birth,
    required this.sex,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.bankName,
    required this.bankBranch,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.lastLogin,
    required this.lastIpaddress,
    required this.picture,
    required this.date,
    required this.publish,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      name: json['name'],
      category: json['category'],
      replika: json['replika'],
      referral: json['referral'],
      subdomain: json['subdomain'],
      link: json['link'],
      numberId: json['number_id'],
      birth: json['birth'],
      sex: json['sex'],
      address: json['address'],
      city: json['city'],
      phone: json['phone'],
      email: json['email'],
      bankName: json['bank_name'],
      bankBranch: json['bank_branch'],
      bankAccountNumber: json['bank_account_number'],
      bankAccountName: json['bank_account_name'],
      lastLogin: json['last_login'],
      lastIpaddress: json['last_ipaddress'],
      picture: json['picture'],
      date: json['date'],
      publish: json['publish'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'name': name,
      'category': category,
      'replika': replika,
      'referral': referral,
      'subdomain': subdomain,
      'link': link,
      'number_id': numberId,
      'birth': birth,
      'sex': sex,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'bank_name': bankName,
      'bank_branch': bankBranch,
      'bank_account_number': bankAccountNumber,
      'bank_account_name': bankAccountName,
      'last_login': lastLogin,
      'last_ipaddress': lastIpaddress,
      'picture': picture,
      'date': date,
      'publish': publish,
    };
  }
}