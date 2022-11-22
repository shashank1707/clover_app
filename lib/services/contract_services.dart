import 'package:clover_app/helpers/shared_preferences.dart';
import 'package:clover_app/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart';

class ContractServices {
  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = contract_address;
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'CloverToken'),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<String> callFunction(
      String functionName, List<dynamic> args, Web3Client ethClient) async {
        String privateKey = await SPServices().getPrivateKey();
    DeployedContract contract = await loadContract();
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract, function: ethFunction, parameters: args),
      chainId: 80001,
    );
    return result;
  }

  Future<List<dynamic>> ask(
      String funcName, List<dynamic> args, Web3Client ethClient) async {
    final contract = await loadContract();
    final ethFunction = contract.function(funcName);
    final result =
        ethClient.call(contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<List<dynamic>> balanceOf(String address, Web3Client ethClient) async {
    List<dynamic> result = await ask(
        'balanceOf',
        [EthereumAddress.fromHex(address)],
        ethClient);
    return result;
  }

  Future<dynamic> transfer(String address, Web3Client ethClient, int amount) async {
    String result = await callFunction(
        'transfer',
        [
          EthereumAddress.fromHex(address),
          BigInt.from(amount)
        ],
        ethClient);
    return result;
  }
}
