import 'package:eco_pop/grupo-pesquisa/grupo_dao.dart';
import 'package:eco_pop/instituicao/instituicao_dao.dart';
import 'package:eco_pop/pop/pop_dao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Connection {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db == null) {
      final path = join(await getDatabasesPath(), 'ecopop');
      //deleteDatabase(path);
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) => {_createTable(db)},
        onDowngrade: onDatabaseDowngradeDelete,
      );
    }

    return _db!;
  }

  /*return {
            _createTable(db);
            /*db.execute(GrupoPesquisaDao.tableSql),
            db.execute(InstituicaoDao.tableSql),
            db.execute(PopDao.tableSql),*/
          };*/

}

_createTable(Database db) {
  db.execute(GrupoPesquisaDao.tableSql);
  db.execute(InstituicaoDao.tableSql);
  db.execute(PopDao.tableSql);
  db.execute(PopDao.tableDadosSql);
}
