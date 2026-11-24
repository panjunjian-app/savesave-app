import '../../core/money.dart';
import '../../core/uuid.dart';
import '../../data/database.dart' hide Bill;
import '../models/bill.dart';
import 'balance_service.dart';

class BillValidationFailure implements Exception {
  const BillValidationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Application service for bill CRUD with balance-cache invalidation.
class BillService {
  BillService(this._db, this._balanceService);

  final AppDatabase _db;
  final BalanceService _balanceService;

  Future<Bill> quickAddBill({
    required String ledgerId,
    required String categoryId,
    required String type,
    required int amountCents,
    required String billDate,
    String? note,
    String source = 'manual',
  }) async {
    _validate(type, amountCents, billDate);
    final now = DateTime.now().toUtc();
    final bill = Bill(
      id: Uuid.v4(),
      ledgerId: ledgerId,
      categoryId: categoryId,
      type: type,
      amountCents: amountCents,
      billDate: billDate,
      note: note,
      source: source,
      createdAt: now,
      updatedAt: now,
    );
    await _db.billDao.save(bill);
    _balanceService.invalidate(<String>{ledgerId});
    return bill;
  }

  Future<void> updateBill({
    required Bill bill,
    required String ledgerId,
    required String categoryId,
    required String type,
    required int amountCents,
    required String billDate,
    String? note,
  }) async {
    _validate(type, amountCents, billDate);
    await _db.billDao.save(
      bill.copyWith(
        ledgerId: ledgerId,
        categoryId: categoryId,
        type: type,
        amountCents: amountCents,
        billDate: billDate,
        note: note,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    _balanceService.invalidate(<String>{bill.ledgerId, ledgerId});
  }

  Future<void> deleteBill(String billId) async {
    final bill = await _db.billDao.findById(billId);
    if (bill == null) {
      return;
    }
    await _db.billDao.remove(billId);
    _balanceService.invalidate(<String>{bill.ledgerId});
  }

  static void _validate(String type, int amountCents, String billDate) {
    if (type != 'expense' && type != 'income') {
      throw const BillValidationFailure('收支类型无效');
    }
    if (amountCents <= 0) {
      throw const BillValidationFailure('金额必须大于 0');
    }
    Money.enforceLimit(amountCents);
    if (DateTime.tryParse(billDate) == null) {
      throw const BillValidationFailure('账单日期无效');
    }
  }
}
