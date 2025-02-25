import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:path_provider/path_provider.dart';

class NodeControlller extends GetxController {
  final testMnemonic =
      'bring tone raw miss kitten service hurry silk trade outside arrange deputy';
  final storagePath = '${getApplicationDocumentsDirectory()}/LDK_NODE';
  final albyTestnetLND1Pubkey =
      '020a90c9961c6fc71a2d1a55bcfe12de950f6ce0a639dd0483746ac5de48edbac4';
  final albyTestnetLND1Host = "67.207.77.188";
  final albyTestnetLND1Port = 9735;

  final esploraUrl = "https://mempool.space/testnet/api";
  final rgsGossipSource =
      "https://rapidsync.lightningdevkit.org/testnet/snapshot";

  var started = false.obs;
  var balance = 0.obs;
  final TextEditingController invoiceAmountController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();
  var channels = <ldk.ChannelDetails>[].obs;
  late ldk.Node ldkNode;

  Future<void> connect(String host, int port, String nodeId) async {
    await ldkNode.connect(
        nodeId: ldk.PublicKey(internal: nodeId),
        address: ldk.NetAddress.iPv4(addr: host, port: port),
        persist: true);
  }

  start(String host, int port, String pubkey) async {
    try {
      final _ = await ldkNode.start();
      var peers = await ldkNode.listPeers();
      print(peers.length);
      if (peers.isEmpty) {
        await connect(host, 9735, pubkey);
      }
    } on Exception catch (e) {
      print("Error in starting Node");
      print(e);
    }
  }

  buildNode(
    String mnemonic,
    String storagePath,
    String esplora,
    String rgs,
  ) async {
    print('Storage Path: $storagePath');
    final builder = ldk.Builder()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(internal: mnemonic))
        .setListeningAddress(
            const ldk.NetAddress.iPv4(addr: '127.0.0.1', port: 3004))
        .setNetwork(ldk.Network.testnet)
        .setStorageDirPath(storagePath)
        .setGossipSourceRgs(rgsServerUrl: rgsGossipSource)
        .setEsploraServer(esploraServerUrl: esploraUrl);
    ldkNode = await builder.build();
  }

  @override
  void onInit() async {
    //init ldk
    print("building node..");
    await buildNode(testMnemonic, storagePath, esploraUrl, rgsGossipSource);
    print("starting node..");
    await start(
        albyTestnetLND1Host, albyTestnetLND1Port, albyTestnetLND1Pubkey);
    started.value = true;
    print("connected");
    super.onInit();
  }

  listChannels() async {
    channels.value = await ldkNode.listChannels();
    balance.value = (channels[0].balanceMsat / 1000).round();
    print(balance.value);
    print(channels.value.length);
  }

  Future<String> receivePayment() async {
    var amount = int.parse(invoiceAmountController.text);
    final invoice = await ldkNode.receivePayment(
        amountMsat: amount * 1000, description: '', expirySecs: 10000);
    print(invoice.internal.toString());
    return invoice.internal.toString();
  }

  Future<String> sendPayment() async {
    final paymentHash = await ldkNode.sendPayment(
        invoice: ldk.Invoice(internal: invoiceController.text));
    final res = await ldkNode.payment(paymentHash: paymentHash);
    return "${res?.status}";
  }

  Future<void> closeChannel(
      ldk.ChannelId channelId, ldk.PublicKey nodeId) async {
    await ldkNode.closeChannel(
      channelId: channelId,
      counterpartyNodeId: nodeId,
    );

    await listChannels();
  }

  stop() async {
    await ldkNode.stop();
  }
}
