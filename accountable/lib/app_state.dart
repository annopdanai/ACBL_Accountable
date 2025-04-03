import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart'; // PROVIDER REQUIRES MATERIAL???? WHY????
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // for the firebase stuff
import 'firebase_options.dart'; // for the firebase stuff
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

FirebaseFirestore firebaseDB = FirebaseFirestore.instance;

// stolen from Mafuyu. Shut up.
// half the codebase is shared between Kanade and Mafuyu anyways.
// If there's an another version, it's gonna be called Ena or Mizuki or something.
class LocalDB {
  // if you touch this make sure to label the commit with BREAKING CHANGE
  static final LocalDB _instance = LocalDB._internal(); // this shi a singleton
  factory LocalDB() => _instance;
  LocalDB._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await init();
    return _db!;
  }

  Future<Database> init() async {
    // init database
    return await openDatabase(
      'transTable.db',
      version: 1,
      onCreate: (Database db, int version) async {
        //if the database doesn't exist, create it
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY,
            transName TEXT,
            transactionDate TEXT,
            transType TEXT,
            amount REAL
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await this.db;
    await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await this.db;
    return await db.query('transactions');
  }

  Future<void> deleteTransactions() async {
    final db = await this.db;
    await db.delete('transactions');
  }
}

// so that 29,110.00 can be converted to 29110.00. EVERYONE hates it when they see a comma in a number.
double commaToDouble(String input) {
  return double.parse(input.replaceAll(',', ''));
}

enum TransactionType {
  food,
  personal,
  utility,
  transportation,
  health,
  leisure,
  other
}

String transTypeToString(TransactionType type) {
  // FOR USE IN THE UI. WE'RE NOT THAT HIPSTER TO USE ALL LOWERCASE
  switch (type) {
    case TransactionType.food:
      return 'Food';
    case TransactionType.personal:
      return 'Personal';
    case TransactionType.utility:
      return 'Utility';
    case TransactionType.transportation:
      return 'Transportation';
    case TransactionType.health:
      return 'Health';
    case TransactionType.leisure:
      return 'Leisure';
    case TransactionType.other:
      return 'Other';
  }
}

TransactionType stringToTransType(String type) {
  // theoretically type can be null, in which it will return other
  switch (type) {
    case 'food':
      return TransactionType.food;
    case 'personal':
      return TransactionType.personal;
    case 'utility':
      return TransactionType.utility;
    case 'transportation':
      return TransactionType.transportation;
    case 'health':
      return TransactionType.health;
    case 'leisure':
      return TransactionType.leisure;
    case 'other':
      return TransactionType.other;
    default:
      return TransactionType.other;
  }
}

class TransList {
  // holds the current session's transactions. so that sqlite doesn't get called every time we need to access the transactions
  // we still have to call sqlite when we need to save the transactions, though
  // thats why this CANNOT send the transactions to the remote database. it's just a temporary storage.
  static final TransList _instance = TransList._internal();
  factory TransList() => _instance;
  TransList._internal();

  final List<Trans> transactions = [];

  @override
  String toString() {
    return 'TransList{transactions: $transactions}';
  }

  void addTransaction(Trans transaction) {
    transactions.add(transaction);
  }

  void removeTransaction(Trans transaction) {
    transactions.remove(transaction);
  }

  Map<TransactionType, double> generateInsights() {
    Map<TransactionType, double> insights = {
      TransactionType.food: 0,
      TransactionType.personal: 0,
      TransactionType.utility: 0,
      TransactionType.transportation: 0,
      TransactionType.health: 0,
      TransactionType.leisure: 0,
      TransactionType.other: 0,
    };

    for (Trans trans in transactions) {
      if (trans.transType != null) {
        insights[trans.transType] = insights[trans.transType]! + trans.amount;
      }
    }
    return insights;
  }

  void scorchedEarth() {
    // deletes all transactions. maybe to fetch them again?
    transactions.clear();
  }

  void getTransactionsFromDB() async {
    // get the transactions from the local database
    final db = LocalDB();
    List<Map<String, dynamic>> dbTransactions = await db.getTransactions();

    for (Map<String, dynamic> dbTrans in dbTransactions) {
      transactions.add(Trans.withType(
        transName: dbTrans['transName'],
        transactionDate: DateTime.parse(
            dbTrans['transactionDate']), // PLEASE SAVE IT AS ISO 8601
        amount: dbTrans['amount'],
        transType: stringToTransType(dbTrans['transType'].toLowerCase()),
      ));
    }
  }
}

class DailyTransList {
  // represents each day's transactions
  final List<Trans> transactions = [];

  // please use this method to instantiate a DailyTransList object
  static DailyTransList getThisDayList(DateTime date) {
    // nifty function to get the transactions of a specific day
    // if the list doesn't exist, create it
    // if it does, return it

    DailyTransList dailyTransList = DailyTransList();

    TransList transList = TransList(); // get the current session's transactions
    for (Trans trans in transList.transactions) {
      if (trans.transactionDate.year == date.year &&
          trans.transactionDate.month == date.month &&
          trans.transactionDate.day == date.day) {
        dailyTransList.addTransaction(trans);
      }
    }

    return dailyTransList;
  }

  @override
  String toString() {
    return 'DailyTransList{transactions: $transactions}';
  }

  DateTime getDate() {
    // get the date of the transactions. UI guys, u know what 2 do
    return transactions[0].transactionDate;
  }

  void addTransaction(Trans transaction) {
    transactions.add(transaction);
  }
}

class Trans {
  final String transName;
  final DateTime transactionDate;
  final double amount;
  TransactionType transType = TransactionType.other;

  Trans({
    required this.transName,
    required this.transactionDate,
    required this.amount,
  })  : assert(transName != null),
        assert(transactionDate != null),
        assert(amount != null);

  Trans.withType({
    required this.transName,
    required this.transactionDate,
    required this.amount,
    required this.transType,
  })  : assert(transName != null),
        assert(transactionDate != null),
        assert(amount != null),
        assert(transType != null);

  @override
  String toString() {
    // this is stupid. who would want to print a transaction object, let alone log it?
    return 'Transaction{transName: $transName, transactionDate: $transactionDate, amount: $amount}';
  }

  void generateCategory() async {
    await firebaseDB.collection("vendors").get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (transName.contains(doc["name"])) {
          Map<String, int> categories = doc["votes"];
          // sort it, get the string with the most int, and set it as the category
          // if there's a tie, set it as one of the categories. the user can change it later
          // which is pretty much what comes first in the sorted list

          final sortedCategories = categories.entries.toList() // java moment
            ..sort((a, b) => a.value.compareTo(b.value));
          transType = stringToTransType(sortedCategories.last.key);
        }
      }
    });
  }

  void voteCategory(String category) async {
    // if the user changes the category, make sure to save their vote too!
    await firebaseDB.collection("vendors").get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (transName.contains(doc["name"])) {
          Map<String, int> categories = doc["votes"];
          categories.update(category, (value) => value + 1,
              ifAbsent: () => 1); // if the category doesn't exist, create it
          doc.reference
              .update({'votes': categories}); // if broke, tell me. i'll fix it
        }
      }
    });
  }

  void saveToDB() async {
    // save the transaction to the local database
    final db = LocalDB();
    await db.insertTransaction({
      'transName': transName,
      'transactionDate': transactionDate.toIso8601String(), // HELL YEAH
      'amount':
          amount, // hopefully it saves as number. if breaks, make it so that it saves as REAL
      'transType': transTypeToString(transType),
    });
  }
}

class AppState extends ChangeNotifier {
  bool isAutomaticUpload = false;
  bool isDarkMode = false;
  LocalDB db = LocalDB(); // shove all of the database stuff here
  TransList transList = TransList();
  List<DailyTransList> dailyTransLists = [];
  List<ReceiptFile> receipts = [];

  void toggleAutomaticUpload() {
    isAutomaticUpload = !isAutomaticUpload;
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode; // do we have dark mode anyways
    notifyListeners();
  }

  void readReceipt(ReceiptFile receipt) async {
    // Process the receipt with OCR and add transaction if successful
    Map<String, dynamic> result = await receipt.OCRBS();
    
    // If OCR extracted valid data, create a transaction
    if (result['recipient'] != null && result['amount'] != null) {
      Trans transaction = Trans(
        transName: result['recipient'],
        transactionDate: DateTime.now(),
        amount: result['amount'],
      );
      
      // Add transaction to the list
      transList.addTransaction(transaction);
      
      // Save to local database
      await db.insertTransaction({
        'transName': transaction.transName,
        'transactionDate': transaction.transactionDate.toIso8601String(),
        'transType': 'other', // Default type, will be categorized later
        'amount': transaction.amount,
      });
      
      // Try to categorize the transaction
      transaction.generateCategory();
    }
    
    notifyListeners();
  }

  void getInsights() {
    transList.generateInsights();
    notifyListeners();
  }

  DailyTransList getDailyTransList(DateTime date) {
    return DailyTransList.getThisDayList(
        date); // there it is, the object. have fun mapping it to the UI
  }

  // if you do UI and wanna use this, use the methods, then call notifyListeners(). -the backend guy
  // welcome back, observer pattern. we missed you.
}

class ReceiptFile {
  final String name;
  final String path;
  String? recipient;
  double? amount;

  ReceiptFile({required this.name, required this.path})
      : assert(name != null),
        assert(path != null);

  @override
  String toString() {
    return 'ReceiptFile{name: $name, path: $path}';
  }

  Future<Map<String, dynamic>> OCRBS() async {
    try {
      // Extract text from the image using Tesseract OCR with Thai language support
      String extractedText = await FlutterTesseractOcr.extractText(
        path,
        language: 'tha+eng', // Thai + English language pack
        args: {
          "preserve_interword_spaces": "1",
        },
      );
      
      // Parse the extracted text to find recipient and amount
      Map<String, dynamic> extractedData = _parseThaiEslip(extractedText);
      
      // Save the extracted data
      recipient = extractedData['recipient'];
      amount = extractedData['amount'];
      
      return extractedData;
    } catch (e) {
      print('OCR Error: $e');
      return {'error': e.toString()};
    }
  }
  
  Map<String, dynamic> _parseThaiEslip(String text) {
    // Initialize result map
    Map<String, dynamic> result = {
      'recipient': null,
      'amount': null,
    };
    
    // Split text into lines for processing
    List<String> lines = text.split('\n');
    
    // Process each line
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      // Check for recipient indicators in Thai banking slips
      if (line.contains('ไปยัง') || line.contains('โอนเงินให้') || 
          line.contains('ผู้รับเงิน') || line.contains('ชื่อบัญชีปลายทาง') ||
          line.contains('ไปถึง') || line.contains('โอนไปยัง')) {
        // Recipient is typically on the next line or in the same line after the indicator
        if (i + 1 < lines.length && lines[i + 1].isNotEmpty) {
          result['recipient'] = lines[i + 1].trim();
        } else if (line.contains(':')) {
          result['recipient'] = line.split(':').last.trim();
        }
      }
      
      // Specific patterns for Krungthai Bank
      if (line.contains('นาย') || line.contains('นางสาว') || line.contains('นาง')) {
        if (result['recipient'] == null) {
          result['recipient'] = line.trim();
        }
      }
      
      // Specific patterns for SCB Bank format
      if (line.contains('จาก') && i + 2 < lines.length && lines[i + 2].contains('ไปยัง')) {
        if (i + 3 < lines.length) {
          result['recipient'] = lines[i + 3].trim();
        }
      }
      
      // Look for MS or MR prefix which often indicates recipient name
      if ((line.startsWith('MS') || line.startsWith('MR') || 
           line.contains('MS ') || line.contains('MR ')) && 
           result['recipient'] == null) {
        result['recipient'] = line.trim();
      }
      
      // Check for amount indicators
      if (line.contains('จำนวนเงิน') || line.contains('จำนวน') || 
          line.contains('ยอดเงิน') || line.contains('amount') ||
          line.contains('บาท') || line.contains('THB')) {
        // Extract amount pattern (Thai baht format)
        RegExp amountRegex = RegExp(r'([0-9,]+\.[0-9]{2})');
        Match? match = amountRegex.firstMatch(line);
        
        if (match != null) {
          String amountStr = match.group(1)!.replaceAll(',', '');
          result['amount'] = double.tryParse(amountStr);
        } else if (i + 1 < lines.length) {
          // Try next line if amount is on a separate line
          String nextLine = lines[i + 1].trim();
          Match? nextMatch = RegExp(r'([0-9,]+\.[0-9]{2})').firstMatch(nextLine);
          if (nextMatch != null) {
            String amountStr = nextMatch.group(1)!.replaceAll(',', '');
            result['amount'] = double.tryParse(amountStr);
          }
        }
      }
      
      // Direct amount pattern search (if not found above)
      if (result['amount'] == null) {
        Match? amountMatch = RegExp(r'([0-9,]+\.[0-9]{2})').firstMatch(line);
        if (amountMatch != null) {
          String amountStr = amountMatch.group(1)!.replaceAll(',', '');
          result['amount'] = double.tryParse(amountStr);
        }
      }
    }
    
    return result;
  }
}
