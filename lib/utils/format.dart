import 'package:intl/intl.dart';

class Fmt {
  static final _fcfa = NumberFormat('#,##0', 'fr_FR');
  static String fcfa(num v) => '${_fcfa.format(v)} FCFA';
}