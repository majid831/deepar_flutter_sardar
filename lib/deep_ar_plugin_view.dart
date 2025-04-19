import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deepar/flutter_deepar.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class FlutterDeepArView extends StatefulWidget{

  final Function postInitCallback;
  final String iosLicenseKey;
  final String androidLicenseKey;
  final DeepARCameraPosition initialCameraPosition;
  final bool willSendFaceTrackData;
  final Function(Orientation)? onOrientationChange;
  final Function(AppLifecycleState)? onLifecycleChange;
  final CameraResolutionPreset cameraResolutionPreset;
  final bool willUseAndroidExternalCameraTexture;
  FlutterDeepArView(this.iosLicenseKey,this.androidLicenseKey,this.initialCameraPosition,this.postInitCallback,
      {this.willSendFaceTrackData = false,this.onOrientationChange,this.onLifecycleChange,this.cameraResolutionPreset = CameraResolutionPreset.RESOLUTION_PRESET_DEVICE, required this.willUseAndroidExternalCameraTexture});

  @override
  State<StatefulWidget> createState() {

    return _FlutterDeepArViewState();
  }
}

class _FlutterDeepArViewState extends State<FlutterDeepArView> with WidgetsBindingObserver{

  bool didSetStream = false;
  Widget? platformView;
  Orientation? currentOrientation; //Needed for handling orientation in android


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (widget.onLifecycleChange !=null) {
      widget.onLifecycleChange!(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return getPlatformView();
  }


  Widget getPlatformView(){
    if (platformView == null) {
      if (Platform.isIOS) {
        platformView = UiKitView(
          viewType: "plugin_deep_ar_view",
          creationParams: {
            "license":widget.iosLicenseKey,
            "initial_camera_position":widget.initialCameraPosition.toString(),
            "will_send_face_track_data":widget.willSendFaceTrackData ? "true" : "false",
            "camera_resolution_preset":widget.cameraResolutionPreset.toString().replaceAll("DeepARCameraResolutionPreset.", "")
          },
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (id){
            widget.postInitCallback();
          },
        );
      }else{
        platformView = OrientationBuilder(
          builder:(ctx,orientation)
          {
            if (currentOrientation == null) {
              currentOrientation = orientation;
            }else if(currentOrientation != orientation && widget.onOrientationChange != null){
              widget.onOrientationChange!(orientation);
              currentOrientation = orientation;
            }
            print({
              "license": widget.androidLicenseKey,
              "initial_camera_position":
              widget.initialCameraPosition.toString(),
              "will_send_face_track_data":
              widget.willSendFaceTrackData ? "true" : "false",
              "camera_resolution_preset":widget.cameraResolutionPreset.getSettingValue(),
              "will_use_external_camera_texture":widget.willUseAndroidExternalCameraTexture
            });
            // return PlatformViewLink(
            //   viewType: 'plugin_deep_ar_view',
            //   surfaceFactory: (
            //       BuildContext context,
            //       PlatformViewController controller,
            //       ) {
            //     return AndroidViewSurface(
            //       controller: controller as AndroidViewController,
            //       gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            //       hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            //
            //     );
            //   },
            //   onCreatePlatformView: (PlatformViewCreationParams params) {
            //     final ExpensiveAndroidViewController controller =
            //     PlatformViewsService.initExpensiveAndroidView(
            //       id: params.id,
            //       viewType: 'plugin_deep_ar_view',
            //       layoutDirection: TextDirection.ltr,
            //       creationParams: {
            //         "license": widget.androidLicenseKey,
            //         "initial_camera_position":
            //         widget.initialCameraPosition.toString(),
            //         "will_send_face_track_data":
            //         widget.willSendFaceTrackData ? "true" : "false",
            //         "camera_resolution_preset":widget.cameraResolutionPreset.getSettingValue(),
            //         "will_use_external_camera_texture":widget.willUseAndroidExternalCameraTexture,
            //       },
            //       creationParamsCodec: const StandardMessageCodec(),
            //       // onFocus: () => params.onFocusChanged(true),
            //     );
            //     controller.addOnPlatformViewCreatedListener(
            //       params.onPlatformViewCreated,
            //     );
            //     controller.addOnPlatformViewCreatedListener((id) {
            //       widget.postInitCallback();
            //     });
            //     // controller.addOnPlatformViewCreatedListener(
            //     //   params.onPlatformViewCreated,
            //     // );
            //     // controller.addOnPlatformViewCreatedListener(
            //     //   onPlatformViewCreated,
            //     // );
            //     // controller.create();
            //     return controller;
            //   },
            // );

            return AndroidView(
              viewType: "plugin_deep_ar_view",
              creationParams: {
                "license": widget.androidLicenseKey,
                "initial_camera_position":
                    widget.initialCameraPosition.toString(),
                "will_send_face_track_data":
                    widget.willSendFaceTrackData ? "true" : "false",
                "camera_resolution_preset":widget.cameraResolutionPreset.getSettingValue(),
                "will_use_external_camera_texture":widget.willUseAndroidExternalCameraTexture,
              },
              creationParamsCodec: StandardMessageCodec(),
              onPlatformViewCreated: (id) {
                widget.postInitCallback();
              },

            );
          },
        );
      }
    }
    return platformView!;
  }
}