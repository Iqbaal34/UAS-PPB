import 'package:mysql1/mysql1.dart';

class MysqlUtils {
  static final settings = ConnectionSettings(
    host: '192.168.58.179',
    port: 3306,
    user: 'root',
    password: '',
    db: 'perpustakaaniqbal',
  );

  static Future<MySqlConnection> getConnection() async {
    return await MySqlConnection.connect(settings);
  }
}
