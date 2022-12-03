import 'package:intl/intl.dart';

class DateTimeHelper {
  //convert string to corresponding date time string format
  static String formatStringDateTime(String dateTime) {
    //DateTime in String: 2022-12-03 13:09:31.266
    var date = DateTime.parse(dateTime).toLocal();
    DateFormat dateFormat;
    if (DateTime.now().difference(date).inHours < 24) {
      // DateFormat.jm() -> 13:09 PM
      dateFormat = DateFormat.jm();
    } else if (DateTime.now().difference(date).inDays < 7) {
      // DateFormat.E(); -> Sat
      dateFormat = DateFormat.E();
    } else if (DateTime.now().difference(date).inDays < 365) {
      //DateFormat.Md(); -> 12/3
      dateFormat = DateFormat.Md();
    } else {
      // DateFormat.yM(); -> 12/3/2022
      dateFormat = DateFormat.yMd();
    }
    return dateFormat.format(date);
  }
}
