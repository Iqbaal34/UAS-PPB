import 'package:mysql1/mysql1.dart';

class MysqlUtils {
  static final settings = ConnectionSettings(
    host: 'localhost', 
    user: 'root',
    password: '',
    db: 'perpustakaaniqbal',
  );
  static late MySqlConnection conn;

  static void initConnection() async {
    conn = await MySqlConnection.connect(settings);
  }

  static Future<MySqlConnection> getConnection() async {
    return await MySqlConnection.connect(settings);
  }
}