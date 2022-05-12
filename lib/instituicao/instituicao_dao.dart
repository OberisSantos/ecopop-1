import 'dart:convert';

import 'package:eco_pop/database/connection.dart';
import 'package:eco_pop/instituicao/instituicao.dart';
import 'package:eco_pop/utils/network_status_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
//DatabaseReference ref = FirebaseDatabase.instance.refFromURL('https://ecop-25-d01d5-default-rtdb.firebaseio.com/');
DatabaseReference ref = FirebaseDatabase.instance.ref();
/*Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'ecopop');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(InstituicaoDao.tableSql);
    },
    version: 1,
    //limpar o banco de dados - primeiro precisa alterar a versão
    //onDowngrade: onDatabaseDowngradeDelete,
  );
}*/

class InstituicaoDao {
  Database? _db;

  static const String _tabela = 'instituicao';
  static const String _id = 'id';
  static const String _descricao = 'descricao';
  static const String _sigla = 'sigla';
  static const String _uuid = 'uuid';

  static const String tableSql = 'CREATE TABLE $_tabela('
      '$_id INTEGER PRIMARY KEY,'
      '$_descricao TEXT,'
      '$_sigla TEXT,'
      '$_uuid TEXT'
      ')';

  List<Instituicao> _instituicoes = [];
  //salvar instituicao
  Future<int> save(Instituicao instituicao) async {
    //final Database db = await getDatabase();
    _db = await Connection.getDatabase();

    Map<String, dynamic> instiMap = _toMap(instituicao);
    final insertedId = await _db!.insert(_tabela, instiMap);
    saveFB(instituicao, insertedId);

    return 0;
  }

  Map<String, dynamic> _toMap(Instituicao instituicao) {
    final Map<String, dynamic> instiMap = Map();
    instiMap[_uuid] = instituicao.uuid;
    instiMap[_descricao] = instituicao.descricao;
    instiMap[_sigla] = instituicao.sigla;

    return instiMap;
  }

  //gegar todas as instituições
  Future<List<Instituicao>> findAll() async {
    bool online = await hasNetwork();
    if (online) {
      //TODO: atualizar tabela local; *** se houver linha local a mais ?????
      deleteAll(); //Em tabelas específicas deletar somente o que pertence ao usuário
      _instituicoes = [];
      await findAllFB();
      _db = await Connection.getDatabase();
      for (Instituicao instituicao in _instituicoes) {
        Map<String, dynamic> instiMap = _toMap(instituicao);
        _db!.insert(_tabela, instiMap);
      }
    }
    //final Database db = await getDatabase();

    _db = await Connection.getDatabase();
    final List<Map<String, dynamic>> resultado = await _db!.query(_tabela);
    List<Instituicao> instituicoes = _toList(resultado);
    return instituicoes;
  }

  List<Instituicao> _toList(List<Map<String, dynamic>> resultado) {
    final List<Instituicao> instituicoes = [];
    for (Map<String, dynamic> row in resultado) {
      final Instituicao instituicao = Instituicao(
          id: row[_id],
          uuid: row[_uuid],
          descricao: row[_descricao],
          sigla: row[_sigla]);
      instituicoes.add(instituicao);
    }
    return instituicoes;
  }

  //delete
  void deleteAll() async {
    //final db = await getDatabase();
    _db = await Connection.getDatabase();
    await _db!.delete(_tabela);
  }

  //delete
  Future<int> delete(Instituicao instituicao) async {
    //final db = await getDatabase();
    _db = await Connection.getDatabase();
    int resultado = await _db!.delete(_tabela, //nome da tabela
        where: "$_id = ?",
        whereArgs: [instituicao.id]);
    deleteFB(instituicao);
    return resultado;
  }

  //atualizar
  Future<int> update(Instituicao instituicao) async {
    //final db = await getDatabase();
    _db = await Connection.getDatabase();
    final resultado = await _db!.update(_tabela, _toMap(instituicao),
        where: '$_id = ?', whereArgs: [instituicao.id]);
    updateFB(instituicao);
    return resultado;
  }

//##########FIREBASE
  Future<List<Instituicao>> findAllFB() async {
    final snapshot = (await ref.child('instituicao').get());
    final List<Instituicao> instituicoes = [];
    var i = 0;
    while (i < snapshot.children.length) {
      DataSnapshot data = snapshot.children.elementAt(i);
      final Instituicao instituicao = Instituicao(
          uuid: data.key,
          id: int.parse(data.child("id").value.toString()),
          descricao: data.child("descricao").value.toString(),
          sigla: data.child("sigla").value.toString());
      instituicoes.add(instituicao);
      i = i + 1;
    }
    _instituicoes = instituicoes;
    return instituicoes;
  }

  Future<int> deleteFB(Instituicao instituicao) async {
    final a = instituicao.uuid;
    ref.child('instituicao').child(a!).remove();
    return 0;
  }

  Future<int> updateFB(Instituicao instituicao) async {
    final postData = {
      'id': instituicao.id,
      'sigla': instituicao.sigla,
      'descricao': instituicao.descricao,
    };
    final Map<String, Map> updates = {};
    final uuid = instituicao.uuid;
    updates['/instituicao/$uuid'] = postData;
    ref.update(updates);
    return 0;
  }

  Future<int> saveFB(Instituicao instituicao, int id) async {
    final postData = {
      'id': id,
      'sigla': instituicao.sigla,
      'descricao': instituicao.descricao,
    };
    //salva no FB
    final Map<String, Map> updates = {};
    final newPostKey = ref.child('instituicao').push().key;
    updates['/instituicao/$newPostKey'] = postData;
    ref.update(updates);

    //atualiza uuid no Objeto
    Instituicao instituicaoFB = Instituicao(
        descricao: instituicao.descricao,
        uuid: newPostKey,
        id: 0,
        sigla: instituicao.sigla);
    //atualiza uuid no banco local
    _db = await Connection.getDatabase();
    await _db!.update(_tabela, _toMap(instituicaoFB),
        where: '$_id = ?', whereArgs: [id]);
    return 0;
  }
}
