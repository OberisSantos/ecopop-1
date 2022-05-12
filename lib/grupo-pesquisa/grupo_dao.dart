import 'package:eco_pop/database/connection.dart';
import 'package:eco_pop/grupo-pesquisa/grupo.dart';
import 'package:eco_pop/utils/network_status_service.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/*Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'ecopop');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(GrupoPesquisaDao.tableSql);
    },
    version: 1,
    //limpar o banco de dados - primeiro precisa alterar a versão
    //onDowngrade: onDatabaseDowngradeDelete,
  );
}*/

FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference ref = FirebaseDatabase.instance.ref();

class GrupoPesquisaDao {
  Database? _db;

  static const String _tabela = 'grupopesquisa';
  static const String _id = 'id';
  static const String _nomegrupo = 'nomegrupo';
  static const String _uuid = 'uuid';

  static const String tableSql = 'CREATE TABLE $_tabela('
      '$_id INTEGER PRIMARY KEY,'
      '$_nomegrupo TEXT,'
      '$_uuid TEXT'
      ')';

  List<GrupoPesquisa> _grupoPesquisa = [];
  //salvar grupo pesquisa
  Future<int> save(GrupoPesquisa grupo) async {
    //final Database db = await getDatabase();
    _db = await Connection.getDatabase();

    Map<String, dynamic> grupoMap = _toMap(grupo);
    final insertedId = await _db!.insert(_tabela, grupoMap);
    saveFB(grupo, insertedId);
    return 0;
  }

  Map<String, dynamic> _toMap(GrupoPesquisa grupo) {
    final Map<String, dynamic> grupoMap = Map();
    grupoMap[_uuid] = grupo.uuid;
    grupoMap[_nomegrupo] = grupo.nomegrupo;

    return grupoMap;
  }

  //gegar todos os grupos
  Future<List<GrupoPesquisa>> findAll() async {
    //TODO: atualizar tabela local; *** se houver linha local a mais ?????
    //deleteAll(); //Em tabelas específicas deletar somente o que pertence ao usuário

    _db = await Connection.getDatabase();
    final List<Map<String, dynamic>> resultado = await _db!.query(_tabela);
    List<GrupoPesquisa> grupos = _toList(resultado);
    return grupos;
  }

  List<GrupoPesquisa> _toList(List<Map<String, dynamic>> resultado) {
    final List<GrupoPesquisa> grupos = [];
    for (Map<String, dynamic> row in resultado) {
      final GrupoPesquisa grupo = GrupoPesquisa(
        row[_uuid],
        row[_id],
        row[_nomegrupo],
      );
      grupos.add(grupo);
    }
    return grupos;
  }

  //delete
  Future<int> delete(int id) async {
    //final db = await getDatabase();
    _db = await Connection.getDatabase();
    int resultado = await _db!.delete(_tabela, //nome da tabela
        where: "$_id = ?",
        whereArgs: [id]);

    return resultado;
  }

  //atualizar
  Future<int> update(GrupoPesquisa grupo) async {
    //final db = await getDatabase();
    _db = await Connection.getDatabase();
    final resultado = await _db!.update(_tabela, _toMap(grupo),
        where: '$_id = ?', whereArgs: [grupo.id]);
    return resultado;
  }

  //#############TABLE FIREBASE
  Future<int> saveFB(GrupoPesquisa grupo, int id) async {
    final postData = {
      'id': id,
      'nomegrupo': grupo.nomegrupo,
    };

    //salva no FB
    final Map<String, Map> updates = {};
    final newPostKey = ref.child('grupopesquisa').push().key;
    updates['/grupopesquisa/$newPostKey'] = postData;
    ref.update(updates);

    return 0;
  }
}
