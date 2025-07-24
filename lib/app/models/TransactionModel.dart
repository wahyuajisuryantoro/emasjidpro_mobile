class TransactionModel {
  final String id;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final DateTime date;
  final String description;

  TransactionModel({
    required this.id,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.date,
    required this.description,
  });
}
