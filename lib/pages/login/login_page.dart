import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

import '../../utils/utils.dart';
import '../meeting/meeting_page.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<MeetingController>(() => MeetingController());
  }
}

class LoginController extends GetxController {
  final _meetingController = Get.find<MeetingController>();
  late SharedPreferences prefs;
  late var _server = ''.obs;
  late var _sid = ''.obs;

  @override
  @mustCallSuper
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    _server.value = prefs.getString('server') ?? '68.183.230.61';
    _sid.value = prefs.getString('room') ?? 'test room';
  }

  bool handleJoin(){
    if (_server.value.length == 0 || _sid.value.length == 0) {
      return false;
    }

    prefs.setString('server', _server.value);
    prefs.setString('room', _sid.value);
    _meetingController.connect();
    Get.toNamed('/meeting');
    return true;

  }

  Future<bool> requestPermission()async{
    if(!kIsWeb){
      var statusCamera = await Permission.camera.request();
      var statusMic = await Permission.microphone.request();

      return statusCamera.isGranted && statusMic.isGranted;
    }else{
      // Web Permission Handling

      try{
        await html.window.navigator.mediaDevices!.getUserMedia({'video': true, 'audio': true});
        return true;
      }catch(e){
        print("Error Permission ${e.toString()}");
        return false;
      }

    }

  }
}

class LoginView extends GetView<LoginController> {
  Widget buildJoinView(context) {
    return Align(
        alignment: Alignment(0, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 260.0,
                  child: Obx(() => TextField(
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10.0),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12)),
                          hintText: 'Enter Ion Server.'),
                      onChanged: (value) {
                        controller._server.value = value;
                      },
                      controller:
                          TextEditingController.fromValue(TextEditingValue(
                        text: controller._server.value,
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${controller._server.value}'.length)),
                      ))))),
              SizedBox(
                  width: 260.0,
                  child: Obx(() => TextField(
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12)),
                        hintText: 'Enter RoomID.',
                      ),
                      onChanged: (value) {
                        controller._sid.value = value;
                      },
                      controller:
                          TextEditingController.fromValue(TextEditingValue(
                        text: controller._sid.value,
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: '${controller._sid}'.length)),
                      ))))),
              SizedBox(width: 260.0, height: 48.0),
              InkWell(
                child: Container(
                  width: 220.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: string2Color('#e13b3f'),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Join',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () async{
                  if(await controller.requestPermission()){
                    if (!controller.handleJoin()) {
                      Get.dialog(AlertDialog(
                        title: Text('Room/Server is empty'),
                        content: Text('Please input room/server!'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ok'),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ));
                    }
                  }else{
                    Get.dialog(AlertDialog(
                      title: Text("Permission Required"),
                      content: Text("Camera and Microphone Permission are required to join the meeting"),
                      actions: [
                        TextButton(
                            onPressed: () => Get.back(),
                            child: Text("Ok"))
                      ],
                    ));
                  }
                },
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
          appBar: orientation == Orientation.portrait
              ? AppBar(
                  title: const Text('Genius Class'),
                )
              : null,
          body: Stack(children: <Widget>[
            Center(child: buildJoinView(context)),
            Positioned(
              bottom: 6.0,
              right: 6.0,
              child: TextButton(
                onPressed: () {
                  Get.toNamed('/settings');
                },
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
              ),
            ),
          ]));
    });
  }
}
