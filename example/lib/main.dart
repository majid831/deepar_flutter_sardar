import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deepar/flutter_deepar_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_deepar/flutter_deepar.dart';

void main(){
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(new MyApp());
      });
    }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldState,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder:(context)=>Container(
            color: Colors.transparent,
            child: Center(
              child: ElevatedButton(child: Text("Click to start Deepar"),onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DeepArPage()));
              },),
            ),
          ),
        ),
      ),
    );
  }
}

class DeepArPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _DeepArPageState();
  }
}

class _DeepArPageState extends State<DeepArPage>{

  bool isRecording = false;


  Map<int,Set<SampleEffects>> appliedEffects = Map();
  int numberOfFacesDetected = 0;
  int selectedFaceId = -1;

  bool isPermissionGranted = false;
  String permissionMessage = "Please grant permissions in order to continue";

  late final FlutterDeeparController _controller;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight])
        .then((_) {
        print("Orientation set");
    });
    _controller = FlutterDeeparController(
        "4d0cc9472576bd4bce03943ac936f23a59c8929f6f8f2b31607ca3ce417fd41c72f38d5a17e51803",
        "365aa5b07669043baeee48060ee6f2a558a85a95c8b3e69a2840ab1aef2eae80ef04e13d4dc2417e",
        initialCameraPosition: DeepARCameraPosition.front,
        cameraResolutionPreset: CameraResolutionPreset.RESOLUTION_PRESET_DEVICE,
      willUseAndroidExternalCameraTexture: true
    );
    _controller.setEventListener(this.pluginEventHandler);
    askForPermissions();
    super.initState();
  }

  void askForPermissions(){

    _controller.checkPermissions().then((resultMap){
      print("Permission Status: $resultMap");
      isPermissionGranted = true;
      resultMap.keys.forEach((k){
        if(k == Permission.camera && resultMap[k] != PermissionStatus.granted){
          permissionMessage += "Please give permission to Camera\n";
          isPermissionGranted = false;
        }else if(k == Permission.storage && resultMap[k] != PermissionStatus.granted){
          permissionMessage += "Please give permission to To Storage in order to record video and photos\n";
        }else if(k == Permission.microphone && resultMap[k] != PermissionStatus.granted){
          permissionMessage += "Please give permission to To Microphone in order to record video\n";
        }
        setState(() {

        });
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      print("Orientation set");
    });
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deep Ar"),
      ),
      body: Stack(
        children: <Widget>[
          isPermissionGranted ? _controller.getWidget() : Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(permissionMessage),
                  SizedBox(height: 16,),
                  ElevatedButton(
                    child: Text("Ask for permissions again"),
                    onPressed: askForPermissions,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.flip),
              onPressed: () => _controller.flipCamera(),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.mobile_screen_share,color: Colors.white,),
                  onPressed: ()=>_controller.takeScreenShot(),
                ),
                IconButton(
                  icon: Icon(Icons.videocam, color:  isRecording ? Colors.red : Colors.white,),
                  onPressed: (){
                    if (isRecording) {
                      _controller.finishVideoRecording();
                    }else{
                      _controller.startVideoRecording();
                    }
                  },
                )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context,index){
                        if (index == 0) {
                          return InkWell(
                            child: Card(
                              child: Container(
                                color: index < numberOfFacesDetected ? (selectedFaceId == index ? Colors.lightGreen : Colors.white) : Colors.grey,
                                width: 60,
                                child: Center(child: Text("Apply To All")),
                              ),
                            ),
                            onTap: index < numberOfFacesDetected ?  (){
                              selectedFaceId = -1;
                            } : null,
                          );
                        }
                        return InkWell(
                          child: Card(
                            child: Container(
                              color: index < numberOfFacesDetected ? (selectedFaceId == index-1 ? Colors.lightGreen : Colors.white) : Colors.grey,
                              width: 60,
                              child: Center(child: Text("Face $index")),
                            ),
                          ),
                          onTap: index < numberOfFacesDetected ?  (){
                            selectedFaceId = index-1;
                          } : null,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: SampleEffects.values.length,
                        itemBuilder: (context,index){
                          SampleEffects effect = SampleEffects.values[index];
                          bool isEffectApplied = appliedEffects.containsKey(selectedFaceId) && (appliedEffects[selectedFaceId]?.contains(effect) ?? false);
                          return SizedBox(
                            width: 150,
                            child: InkWell(
                              child: Card(
                                color: isEffectApplied ? Colors.lightGreen : Colors.white,
                                child: Center(
                                  child: Text(SampleEffectHelper.getName(SampleEffects.values[index]),style: Theme.of(context).textTheme.headline6,),
                                ),
                              ),
                              onTap: ()=>applyOrRemoveEffect(SampleEffects.values[index],faceId: selectedFaceId),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void applyOrRemoveEffect(SampleEffects effect,{int faceId = -1}){

    if (faceId == -1) { //We will apply to all faces.
      applyEffecttoSingleFace(0, effect);
    }else{
      applyEffecttoSingleFace(faceId, effect);
    }

    setState(() {

    });
  }

  void applyEffecttoSingleFace(int faceId, SampleEffects effect){
    String slotName = "${effect.toString()}";
    if (!appliedEffects.containsKey(faceId)) {
      appliedEffects[faceId] = Set();
    }
    if (appliedEffects[faceId]?.contains(effect) ?? false) { //We will remove the effect
      _controller.clearEffect(slotName,faceId: faceId);
      appliedEffects[faceId]?.remove(effect);
    }else{ //We will add the effect
      appliedEffects[faceId]?.add(effect);
      _controller.switchEffectFromAssets(slotName, SampleEffectHelper.getAssetPath(effect),faceId: faceId);
    }
  }

  void pluginEventHandler(PluginMessage message){
    switch(message.actionEnum){
      case PluginActionEnum.undefined_action:
        print("Unhandled acition!: ${message.toJson()}");
        break;
      case PluginActionEnum.finish_prepare_video_recording:
        print("Finished preparing video recording");
        break;
      case PluginActionEnum.did_start_video_recording:
        setState(() {
          isRecording = true;
        });
        print("Started video recording");
        break;
      case PluginActionEnum.did_finish_video_recording:
        setState(() {
          isRecording = false;
        });
        print("Did finish video recording. Video File Path is: ${message.strValue}");
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Video Record Success"),
            content: Text("The video has been recorded to: ${message.strValue}"),
            actions: <Widget>[
              TextButton(
                child: Text("Preview"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>PreviewPage(message.strValue ?? "",true)));
                }
              ),
              TextButton(
                child: Text("Close"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
        break;
      case PluginActionEnum.error_video_recording:
        setState(() {
          isRecording = false;
        });
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Video Record Fail!"),
            content: Text("There was an error occured while reting to record: ${message.strValue}"),
          );
        });
        print("There was an error occured while recording video: ${message.strValue}");
        break;
      case PluginActionEnum.screenshot:
        print("Screenshot taken: ${message.strValue}");
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Screenshot Success"),
              content: Text("The image has been saved to: ${message.strValue}"),
              actions: <Widget>[
                TextButton(
                    child: Text("Preview"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (context)=>PreviewPage(message.strValue ?? "",false)));
                    }
                ),
                TextButton(
                  child: Text("Close"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        );
        break;
      case PluginActionEnum.did_initialize:
        print("DeepAR Plugin has been initialized");
        break;
      case PluginActionEnum.face_visible:
        print("Face visibility changed: ${message.numValue}");
        break;
      case PluginActionEnum.face_tracked:
        //This is the callback location for face tracking data. This callback generated too much data so we are not logging this event
        //You can convert this string to MultiFaceTrackData object found in models/face_track_model.dart

      //MultiFaceTrackData multiFaceTrackData = MultiFaceTrackData.fromRawJson(message.strValue);

        break;
      case PluginActionEnum.number_of_visible_faces_changed:
//        print("Number of visible faces changed: ${message.numValue}");
        setState(() {
          numberOfFacesDetected = message.numValue ?? 0;
        });
        break;
      case PluginActionEnum.did_finish_shutdown:
        print("The plugin has been shut down");
        break;
      case PluginActionEnum.image_visibility_changed:
        print("Image visibility changed: ${message.numValue}");
        break;
      case PluginActionEnum.did_switch_effect:
        print("Did switch effect. changed slot is:${message.strValue}");
        break;
      default:
        break;
    }
  }
}
class SampleEffectHelper{
  static String getName(SampleEffects effect){
    return effect.toString().replaceAll("SampleEffects.", "");
  }
  static String getAssetPath(SampleEffects effect){
    return "assets/deepar_masks/${getName(effect)}";
  }
}
enum SampleEffects{
  gold_face,
  aviators,
  bigmouth,
  bleachbypass,
  blizzard,
  dalmatian,
  drawingmanga,
  fatify,
  filmcolorperfection,
  fire,
  flowers,
  grumpycat,
  heart,
  kanye,
  koala,
  lion,
  mudMask,
  obama,
  pug,
  rain,
  realvhs,
  sepia,
  slash,
  sleepingmask,
  smallface,
  teddycigar,
  tripleface,
  tv80,
  twistedface,
  background_segmentation,
  hair_segmentation
}


class PreviewPage extends StatefulWidget{
  final String filePath;
  final bool isVideoFile;
  PreviewPage(this.filePath,this.isVideoFile);
  createState()=>PreviewPageState();
}

class PreviewPageState extends State<PreviewPage>{

  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void dispose() {
    if (_controller != null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.isVideoFile) {
      _controller = VideoPlayerController.file(File(widget.filePath));
      _initializeVideoPlayerFuture = _controller?.initialize();
    }  
    super.initState();
  }

  void showSaveAlert(String path){
    showDialog(
        context: context,
        builder: (c){
          return AlertDialog(
            title: Text("Save Media"),
            content: Text("${widget.isVideoFile ? "Video" : "Image"} saved gallery"),
          );
        }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    File file = File(widget.filePath);
    if (!file.existsSync()) {
      print("FILE NOT FOUND!");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async{
              if(widget.isVideoFile){
                var file = File(widget.filePath);
                print("File: ${file.path}");
                var ex = await getExternalStorageDirectory();
                print("external: $ex");
                PhotoManager.editor.saveVideo(file, title: "Deepar Video",relativePath: "Movies/LinxApp")
                // PhotoManager.editor.saveVideo(file,relativePath: "Movies/LinxApp")
                    .then((value) => print("Video Entity: ${value?.title}"));
              }else{
                PhotoManager.editor.saveImageWithPath(widget.filePath,relativePath: "Pictures/LinxApp",title: "Deepar Photo")
                .then((value){
                  print("Entity: ${value?.title}");
                  value?.file.then((value) => print("File Path: ${value?.path}"));
                });
              }
            },
          )
        ],
      ),
      body: Container(
        child: !widget.isVideoFile ? Image.file(File(widget.filePath)) :
        FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the VideoPlayer.
              return AspectRatio(
                aspectRatio: _controller?.value.aspectRatio ?? 1,
                // Use the VideoPlayer widget to display the video.
                child: VideoPlayer(_controller!),
              );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: widget.isVideoFile ? FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller?.value.isPlaying ?? false) {
              _controller?.pause();
            } else {
              // If the video is paused, play it.
              _controller?.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          (_controller?.value.isPlaying ?? false) ? Icons.pause : Icons.play_arrow,
        ),
      ) : null,

    );
  }
}
