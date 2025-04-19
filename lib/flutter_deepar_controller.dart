import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_deepar/deep_ar_plugin_view.dart';
import 'package:flutter_deepar/flutter_deepar.dart';
import 'package:flutter_deepar/models/camera_resolution_preset.dart';
import 'package:flutter_deepar/plgin_constants.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterDeeparController {
  static const MethodChannel _channel =
      const MethodChannel('flutter_deepar');
  static const _stream = const EventChannel('event_chanel_deepar');

  // ignore: non_constant_identifier_names
  final String IOSLicenseKey;
  // ignore: non_constant_identifier_names
  final String AndroidLicenseKey;

  final DeepARCameraPosition initialCameraPosition;
  final bool willSendFaceTrackData;
  final CameraResolutionPreset cameraResolutionPreset;

  // ignore: unused_field
  StreamSubscription<dynamic>? _eventSubscription;
  Function(PluginMessage)? _eventListener;
  final bool willUseAndroidExternalCameraTexture;
  FlutterDeeparController(this.IOSLicenseKey,this.AndroidLicenseKey,{this.initialCameraPosition:DeepARCameraPosition.front,this.willSendFaceTrackData = false,this.cameraResolutionPreset = CameraResolutionPreset.RESOLUTION_PRESET_DEVICE,required this.willUseAndroidExternalCameraTexture});

  void dispose(){
    try{
      print("removing event listener");
      _eventListener = null;
      _eventSubscription?.cancel();
      _eventSubscription = null;
    }catch(exception){
      print("Catched Excepton");
      if (!(exception is MissingPluginException)) {
        print("Exception occured while dispoing event subscription: $exception");
      }else{
        print("Missing Plugin Exeception thrown!");
      }
    }

  }

  void setEventListener(Function(PluginMessage)? eventListener){
    this._eventListener = eventListener;
  }

  void startStreamListener(){
    print("Started Stream Listener");
    if(_eventSubscription == null){
      _eventSubscription = _stream.receiveBroadcastStream().listen((response){
        if (_eventListener != null) {
          var message = PluginMessage.fromJson(Map<String,dynamic>.from(response));
          _eventListener!(message);
        }
      });
    }
    _channel.invokeMethod(MethodNames.initStreamHandler);
  }

  FlutterDeepArView getWidget(){
    FlutterDeepArView view = FlutterDeepArView(IOSLicenseKey,AndroidLicenseKey,initialCameraPosition, (){
      startStreamListener();
    },
      willSendFaceTrackData : willSendFaceTrackData,
      onOrientationChange: (orientation){
        _updateOrientation();
      },
      onLifecycleChange: (state){
        switch(state){
          case AppLifecycleState.resumed:
            _recreateCamera();
            break;
          case AppLifecycleState.paused:
          case AppLifecycleState.detached:
            _disposeCamera();
            break;
          default:
            print("Life cycle update: $state");
            break;
        }
      },
      cameraResolutionPreset: cameraResolutionPreset,
      willUseAndroidExternalCameraTexture: willUseAndroidExternalCameraTexture,
    );
    return view;
  }

  Future<Map<Permission,PermissionStatus>> checkPermissions() async{
    return [
      Permission.photos,
      Permission.storage,
      Permission.camera,
      Permission.microphone
    ].request();
  }
//
  Future<dynamic> flipCamera(){
    return _channel.invokeMethod(MethodNames.flipCamera);
  }

  ///This method allows user to apply effects to multiple faces (up to 4). The allowed values for the face parameters are 0,1,2,3. Other parameters are the same as for the method above. Different faces should use different slots such as "mask_f0" and "mask_f1" instead of "mask" in the previous example.
  Future<dynamic> switchEffectFromAssets(String slot, String assetPath, {int faceId = 0}){
    return _channel.invokeListMethod(MethodNames.switchEffectFromAsset,{"slot":slot,"path":assetPath,"face_id":faceId});
  }

  Future<dynamic> switchEffectFromAbsolutePath(String slot, String assetPath, {int faceId = 0}){
    return _channel.invokeListMethod(MethodNames.switchEffectFromAbsolutePath,{"slot":slot,"path":assetPath,"face_id":faceId});
  }

  Future<dynamic> clearEffect(String slot, {int faceId = 0}){
    return _channel.invokeListMethod(MethodNames.clearEffect,{"slot":slot,"face_id":faceId});
  }
  Future<dynamic> takeScreenShot(){
    return _channel.invokeListMethod(MethodNames.takeScreenshot,);
  }

  Future<dynamic> startVideoRecording(){
    return _channel.invokeMethod(MethodNames.startVideoRecording);
  }

  Future<dynamic> finishVideoRecording(){
    return _channel.invokeMethod(MethodNames.finishVideoRecording);
  }

  Future<dynamic> pauseVideoRecording(){
    return _channel.invokeMethod(MethodNames.pauseVideoRecording);
  }

  Future<dynamic> resumeVideoRecording(){
    return _channel.invokeMethod(MethodNames.resumeVideoRecording);
  }

  Future<dynamic> pauseRendering(){
    return _channel.invokeMethod(MethodNames.pauseCamera);
  }

  Future<dynamic> resumeRendering(){
    return _channel.invokeMethod(MethodNames.resumeCamera);
  }
  
  Future<dynamic> _updateOrientation(){
    return _channel.invokeListMethod(MethodNames.orientationChanged);
  }

  Future<dynamic> _disposeCamera(){ //Used for disposing camera for situations when app is going to background mode
    return _channel.invokeListMethod(MethodNames.onStopApp);
  }

  Future<dynamic> _recreateCamera(){ //Used for re-initializing camera after returning from background mode
    return _channel.invokeListMethod(MethodNames.onResumeApp);
  }
}