import 'dart:ffi';

import 'package:eco_pop/database/connection.dart';
import 'package:eco_pop/pop/pop.dart';
import 'package:eco_pop/utils/network_status_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
DatabaseReference ref = FirebaseDatabase.instance.ref();

class PopDao {
  Database? _db;

  static const String _tabela = 'pop';
  static const String _id = 'id';
  static const String _descricao = 'descricao';
  static const String _conceito = 'conceito';
  static const String _fonte = 'fonte';
  static const String _formula = 'formula';
  static const String _experimento = 'experimento';
  static const String _padrao = 'padrao';
  static const String _uuid = 'uuid';

  static const String tableSql = 'CREATE TABLE $_tabela('
      '$_id INTEGER PRIMARY KEY,'
      '$_descricao TEXT,'
      '$_conceito TEXT,'
      '$_fonte TEXT,'
      '$_formula TEXT,'
      '$_experimento TEXT,'
      '$_padrao BOOLEAN,'
      '$_uuid TEXT'
      ')';

  static const String _tabelaDados = 'dados_pop';
  static const String _idPop = 'id_pop';
  static const String _quantidade = 'quantidade';
  static const String _tempo = 'tempo';
  static const String _uuidDados = 'uuid';

  static const String tableDadosSql = 'CREATE TABLE $_tabelaDados('
      '$_id INTEGER PRIMARY KEY,'
      '$_idPop INTEGER,'
      '$_quantidade FLOAT,'
      '$_tempo FLOAT,'
      '$_uuidDados TEXT,'
      'FOREIGN KEY ($_idPop) REFERENCES $_tabela($_id) ON DELETE RESTRICT ON UPDATE CASCADE'
      ')';

  List<Pop> _pops = [];
  //salvar
  Future<int> savePop(Pop pop) async {
    //final Database db = await getDatabase();
    _db = await Connection.getDatabase();

    Map<String, dynamic> popMap = _toMap(pop);
    final insertId = await _db!.insert(_tabela, popMap);

    //inserir FB
    return insertId;
  }

  //Salvar dados da população
  Future<int> saveDados(int id, DadosPop dadosPop) async {
    _db = await Connection.getDatabase();
    final Map<String, dynamic> dadosMap = Map();
    dadosMap[_quantidade] = dadosPop.quantidade;
    dadosMap[_tempo] = dadosPop.tempo;
    dadosMap[_uuidDados] = dadosPop.uuid;
    dadosMap[_idPop] = dadosPop.idPop!.id;

    final iddados = await _db!.insert(_tabelaDados, dadosMap);
    print(iddados);
    return iddados; //retornar o id
  }

  Map<String, dynamic> _toMap(Pop pop) {
    final Map<String, dynamic> popMap = Map();
    popMap[_descricao] = pop.descricao;
    popMap[_conceito] = pop.conceito;
    popMap[_fonte] = pop.fonte;
    popMap[_formula] = pop.formula;
    popMap[_experimento] = pop.experimento;
    popMap[_padrao] = pop.padrao;
    popMap[_uuid] = pop.uuid;
    return popMap;
  }

  Future<Pop?> getPopId(int id) async {
    _db = await Connection.getDatabase();

    final List<Map<String, dynamic>> pop =
        await _db!.query(_tabela, where: 'id = ?', whereArgs: [id]);
    //print(pop.descricao);
    //final List<Map<String, dynamic>> resultado = await _db!.query(_tabela);
    //print(resultado);
    Pop? _valor;
    for (Map<String, dynamic> row in pop) {
      _valor = Pop(
        row[_id],
        uuid: row[_uuid],
        descricao: row[_descricao],
        conceito: row[_conceito],
        fonte: row[_fonte],
        formula: row[_formula],
        experimento: row[_experimento],
        padrao: row[_padrao] == 0 ? false : true, //verificar o padrao
      );
    }
    return _valor;
  }

  //gegar todos
  Future<List<Pop>> findAll() async {
    _db = await Connection.getDatabase();
    bool _online = await hasNetwork();
    //verificar se está online

    if (_online == false) {
      deleteAll(); //verificar a logica depois
      _pops = await findAllFB(_tabela);

      for (Pop pop in _pops) {
        /*final DadosPop dados =
            DadosPop(0, uuid: null, idPop: pop, quantidade: null, tempo: null);*/
        Map<String, dynamic> popMap = _toMap(pop);

        await _db!.insert(_tabela, popMap);
        //await saveDados(idPop, dados);
      }
    }
    /*
    const String constulta = """
          SELECT  p.id, p.uuid, p.descricao, p.conceito, p.formula, p.experimento, p.padrao, 
          dp.id as id_dados, dp.id_pop, dp.quantidade, dp.tempo, dp.uuid as uuid_dados
          FROM $_tabela as p, $_tabelaDados as dp 
          WHERE  p.id = dp.id_pop""";
    
    final List<Map<String, dynamic>> resultado = await _db!.rawQuery(constulta);
    */
    final List<Map<String, dynamic>> resultado = await _db!.query(_tabela);

    List<Pop> pops = _toList(resultado);
    print(pops);
    return pops;
  }

  List<Pop> _toList(List<Map<String, dynamic>> resultado) {
    final List<Pop> pops = [];
    for (Map<String, dynamic> row in resultado) {
      final Pop pop = Pop(
        row[_id],
        uuid: row[_uuid],
        descricao: row[_descricao],
        conceito: row[_conceito],
        fonte: row[_fonte],
        formula: row[_formula],
        experimento: row[_experimento],
        padrao: row[_padrao] == 0 ? false : true, //verificar o padrao
      );
      pops.add(pop);
    }
    return pops;
  }

  Future deleteAll() async {
    _db = await Connection.getDatabase();
    await _db!.delete(_tabelaDados);
    await _db!.delete(_tabela);
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
  Future<int> update(Pop pop) async {
    //final db = await getDatabase();
    _db = await Connection.getDatabase();
    final resultado = await _db!
        .update(_tabela, _toMap(pop), where: '$_id = ?', whereArgs: [pop.id]);
    return resultado;
  }

  //##########FIREBASE
  Future<List<Pop>> findAllFB(String url) async {
    //Exemplo: url = 'projetos_padrao/EXPO'
    url = 'projetos_padrao'; //remover
    final snapshot = (await ref.child(url).get());
    final List<Pop> pops = [];
    var i = 0;
    while (i < snapshot.children.length) {
      DataSnapshot data = snapshot.children.elementAt(i);
      final Pop pop = Pop(int.parse(data.child("id").value.toString()),
          uuid: data.key,
          descricao: data.child("descricao").value.toString(),
          conceito: data.child("conceito").value.toString(),
          experimento: data.child("experimento").value.toString(),
          fonte: data.child("fonte").value.toString(),
          formula: data.child("formula").value.toString(),
          padrao: data.child("padrao").value == true);
      pops.add(pop);
      i = i + 1;
    }
    _pops = pops;
    return pops;
  }

  Future<List<Map<String, dynamic>>> findDadosFB(String url) async {
    //Exemplo: url = 'projetos_padrao/EXPO'
    final snapshot = (await ref.child(url).get());
    final List<Map<String, dynamic>> dados = [];
    var i = 0;
    while (i < snapshot.children.length) {
      DataSnapshot data = snapshot.children.elementAt(i);
      final Map<String, dynamic> dadosMap = Map();
      dadosMap['tempo'] = data.child("tempo").value.toString();
      dadosMap['estoque'] = data.child("estoque").value.toString();
      dados.add(dadosMap);
      i = i + 1;
    }
    return dados;
  }

  Future<Pop> findPopFB(String url) async {
    //Exemplo: url = 'projetos_padrao/EXPO'
    final snapshot = (await ref.child(url).get());
    DataSnapshot data = snapshot;
    final Pop pop = Pop(int.parse(data.child("id").value.toString()),
        uuid: data.key,
        descricao: data.child("descricao").value.toString(),
        conceito: data.child("conceito").value.toString(),
        experimento: data.child("experimento").value.toString(),
        fonte: data.child("fonte").value.toString(),
        formula: data.child("formula").value.toString(),
        padrao: data.child("padrao").value == true);

    return pop;
  }
}
