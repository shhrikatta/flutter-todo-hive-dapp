import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:todolist_hivedb/utils/Constants.dart';
import 'package:web3dart/web3dart.dart';

import 'database.dart';

class ToDoListModel extends ChangeNotifier {
  late ToDoDataBase db;
  List<Task> toDoList = [];
  bool isLoading = true;
  late int taskCount;
  final String _rpcUrl = "http://192.168.0.106:7545";
  // final String _wsUrl = "ws://127.0.0.1:7545/";

  late Web3Client _web3client;
  late String _abiCode;

  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late EthereumAddress _ownerAddress;
  late DeployedContract _deployedContract;

  late ContractFunction _todoCount;
  late ContractFunction _todos;
  late ContractFunction _createTask;
  late ContractFunction _updateTask;
  late ContractFunction _deleteTask;
  late ContractFunction _toggleCompleteTask;
  var myBox = Hive.box('box');
  List<Task> listToDo = [];

  ToDoListModel() {
    init();
  }

  Future<void> init() async {
    print("*********************** init ***************************");
    db = ToDoDataBase();

    _web3client = Web3Client(
      _rpcUrl,
      Client(),
/*       socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
 */
    );

    await getAbi();
    print("*********************** getAbi ***************************");
    await getCredentials();
    print("*********************** getCredentials ***************************");
    await getDeployedContract();
    print(
        "*********************** getDeployedContract ***************************");
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString(Constant.todoContractFile);
    var jsonAbi = jsonDecode(abiStringFile);

    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    print("*********************** inside getAbi ***************************");
  }

  Future<void> getCredentials() async {
    _credentials =
        await _web3client.credentialsFromPrivateKey(Constant.privateKey);
    _ownerAddress = await _credentials.extractAddress();
    print(
        "*********************** inside getCredentials ***************************");
  }

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ToDoContract"), _contractAddress);

    _createTask = _deployedContract.function("createTask");
    _updateTask = _deployedContract.function("updateTask");
    _todoCount = _deployedContract.function("taskCount");
    _deleteTask = _deployedContract.function("deleteTask");
    _todos = _deployedContract.function("todos");

    print(
        "*********************** inside getDeployedContract ***************************");
    await getTodos();
  }

  getTodos() async {
    print(
        "*********************** inside getTodos ***************************");
    List totalTaskList = await _web3client.call(
      contract: _deployedContract,
      function: _todoCount,
      params: [],
    );

    BigInt totalTask = totalTaskList[0];
    taskCount = totalTask.toInt();
    toDoList.clear();

    for (var i = 0; i < taskCount; i++) {
      var temp = await _web3client.call(
        contract: _deployedContract,
        function: _todos,
        params: [BigInt.from(i)],
      );

      if (temp[1] != "") {
        var currTask = Task(
          id: (temp.first as BigInt).toInt(),
          name: temp[1],
          isCompleted: temp[2],
        );

        toDoList.add(currTask);
      }
    }

    if (toDoList.isNotEmpty) {
      toDoList = toDoList.reversed.toList();

      listToDo.clear();
      listToDo.addAll(toDoList);
      db.updateData(listToDo);
    } else {
      // if (myBox.get(ToDoDataBase.key) == null) {
      db.updateData([
        Task(id: -1, name: "To Do 1", isCompleted: false),
      ]);
      // }
    }

    listToDo = db.loadData();
    isLoading = false;
    notifyListeners();
  }

  addTask(String taskName) async {
    isLoading = true;
    notifyListeners();

    await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createTask,
        parameters: [taskName],
      ),
    );

    await getTodos();
  }

  updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();

    await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _deployedContract,
        function: _updateTask,
        parameters: [BigInt.from(id), taskNameData],
      ),
    );

    await getTodos();
  }

  deleteTask(int id) async {
    isLoading = true;
    notifyListeners();

    await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _deployedContract,
        function: _deleteTask,
        parameters: [BigInt.from(id)],
      ),
    );

    await getTodos();
  }

  toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();

    await _web3client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _deployedContract,
        function: _toggleCompleteTask,
        parameters: [BigInt.from(id)],
      ),
    );

    await getTodos();
  }
}

class Task {
  final int id;
  final String name;
  final bool isCompleted;
  Task({required this.id, required this.name, required this.isCompleted});
}
