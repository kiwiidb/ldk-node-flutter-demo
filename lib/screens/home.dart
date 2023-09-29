// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldk_node_flutter_quickstart/widgets/widgets.dart';
import 'package:ldk_node_flutter_quickstart/controllers/nodecontroller.dart';

class Home extends StatelessWidget {
  final NodeControlller nodeController = Get.put(NodeControlller());
  Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context),
        body: SingleChildScrollView(
          child: GetX<NodeControlller>(builder: (nodeController) {
            print(nodeController.started);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: !nodeController.started.value
                  ? Container()
                  : Column(
                      children: [
                        /* Balance */
                        BalanceWidget(
                          balance: nodeController.balance.value,
                        ),
                        SubmitButton(
                          text: 'List Channels',
                          callback: nodeController.listChannels,
                        ),
                        /* ChannelsActionBar */
                        ChannelListWidget()
                      ],
                    ),
            );
          }),
        ),
      ),
    );
  }
}
