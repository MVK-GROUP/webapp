import 'services.dart';

class OrderItem {
  final String id;
  final double amount;
  final ACLCellType chosenCell;
  final String chosenTariff;

  OrderItem(this.id, this.amount, this.chosenCell, this.chosenTariff);
}
