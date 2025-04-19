# flutter_deepar_example

A Flutter Plugin for implementing DeepAr on IOS and Android. 
 

## Getting Started

### Android Installation

- Due to latest Gradle updates, here are things thats need to be done: 

- create a directory named 'deepar' in the 'android/app' folder of the main project
- copy the deepar.aar found in the "android/deepar" folder of the plugin into the new folder. 


- You have to remove the `GeneratedPluginRegistrant.registerWith(flutterEngine);` line from your MainActivity.java file of your main Project.
This line is no longer needed in newer flutter versions and causes memory leaks with plugins. 

```java
public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }
}
```

- Also Add These lines into your proguard.rules file for production build

```
  -keepclassmembers class ai.deepar.ar.DeepAR { *; }
```


!! Don't forget to build the apk with --no-shrink
flutter build apk --no-shrink --release



### IOS Installation

- You have to add following values into the Info.plist file of your ios project: 

	`<key>NSCameraUsageDescription</key>
	<string>Your Camera Usage Description Text</string>`
	
	`<key>NSMicrophoneUsageDescription</key>
	<string>Your Microphone Usage Description Text</string>`
	
	`<key>NSPhotoLibraryAddUsageDescription</key>
	<string>Photo Library Usage Description Text for saving photos</string>`
	
	`<key>NSPhotoLibraryUsageDescription</key>
	<string>Photo  Usage Description Text for adding photos</string>`
	
	`<key>io.flutter.embedded_views_preview</key>
	<string>YES</string>`
  


- You also have to edit your PodFile of your IOS project and update the last like like this according to permission handler updates:
More detailed explanation can be found in https://pub.dev/packages/permission_handler


	`
	  post_install do |installer|
  		installer.pods_project.targets.each do |target|
  			flutter_additional_ios_build_settings(target)
  			target.build_configurations.each do |config|
  			config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  				'$(inherited)',
  				'PERMISSION_CAMERA=1',
  				'PERMISSION_MICROPHONE=1',
  				'PERMISSION_PHOTOS=1',
  			]
			end
  		end
  	end
  `
	
## Flutter Usage

In order to interact with  the plugin, you have to instantinate the controller object first:
```dart
FlutterDeeparController(this.IOSLicenseKey,this.AndroidLicenseKey,{this.initialCameraPosition:DeepARCameraPosition.front, this.willSendFaceTrackData = false});
```

The constructor parameters are:

**IOSLicenseKey**: IOS License obtained from the DeepAr developer portal.

**AndroidLicenseKey**: Android License obtained from the DeepAr developer portal.

**initialCameraPosition**: An optional constructor parameter. Default value is "front" (selfie cam). Possible values are:

**willSendFaceTrackData**: Disabled by default due to performance issues. not recomended to use unless there is a reason;

```dart
enum DeepARCameraPosition{
  front, back
}
```

**Also don't forget to dispose the controller when the page is being disposed or you will have memory leaks and crash problems**
```dart
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
```


After initialization, we also have to set event listener in order to receive real time feedback from the plugin. 

```dart
_controller.setEventListener(this.pluginEventHandler);
```

The Plugin Event Handler is defined as following: 
```dart
void pluginEventHandler(PluginMessage message)
```


PluginMessage is an object serialized from the messages coming from the native library with following values:
```dart
class PluginMessage {

  PluginActionEnum actionEnum; //enum value of the action
  String action; //int value of the actionEnum
  String description; //description field, used for debugging purposes only 
  int numValue; //numeric value of the action (if available) 
  String strValue; //string value (if available)
  bool isSuccess; // return if there is an error
}
```

The most important element of this class is the `PluginActionEnum` value. This value determines the type of action returned from the native plugin. 
the action values are defined as followed:

| Enum Value        | Description           |
| ------------- |:-------------:|
| did_start_video_recording      | video recording has started (used for updating the ui, etc..) |
| did_finish_video_recording      | video recording has been finished. the "strValue" of this message contains the video file path |
| error_video_recording      | there was an error occured while recording video.  strValue contains error content |
| screenshot  | Screenshot has been taken. strValue contains the screenshot file location |
| did_initialize  | The plugin has been initialized |
| face_visible  | indicated that the plugin has detected a face |
| face_tracked  | **See Face Track Data Section** |
| number_of_visible_faces_changed  | number of visible faces changed (max. nmber of detactable faces is 4 |
| did_finish_shutdown  | the plugin has been shut down |
| did_switch_effect  | the effect has been changed. the changed slot number is in strValue |

### Face Track Data

The plugin returns Face Track Data in each frame. This object contains 3-Dimensional face data and number of tarcked faces. returned with each frame
keep in mind that this data is quite verbose and might impact app performance if there are too much job done in this message type. 
MultiFaceTrackData object contains 4 individual face data objects 1 for each face.

```dart
class PluginFaceData {
  bool faceDetected; //determines the if the face detected with the face id equal to the order of this element in multifacetrackdata object.
  int faceNumber;
  List<double> faceRect;
  List<double> landmarks;
  List<double> landmarks2D;
  List<double> poseMatrix;
  List<double> rotation;
  List<double> translation;
}
```

## Listener Full usage example
```dart
void pluginEventHandler(PluginMessage message){
    switch(message.actionEnum){
      case PluginActionEnum.undefined_action:
        print("Unhandled acition!: ${message.toJson()}");
        break;
      case PluginActionEnum.finish_prepare_video_recording:
        print("Finished preparing video recording");
        break;
      case PluginActionEnum.did_start_video_recording:
        print("Started video recording");
        break;
      case PluginActionEnum.did_finish_video_recording:
        print("Did finish video recording. Video File Path is: ${message.strValue}");
        break;
      case PluginActionEnum.error_video_recording:
        print("There was an error occured while recording video: ${message.strValue}");
        break;
      case PluginActionEnum.screenshot:
        print("Screenshot taken: ${message.strValue}");
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
        break;
      case PluginActionEnum.number_of_visible_faces_changed:
        print("Number of visible faces changed: ${message.numValue}");
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
    }
  }
```


## Using Effects

### 1. Adding Assets to projects
There are 2 ways to add effects to the project: 

#### Adding effects by adding into "assets" folder of the flutter project
You can add effect assets into the flutter assets folder, and defining them in the assets of `pubspec.yaml`. 

If you are using an assets bumndled with your app through the assets folder you can use the following function: 
```dart
_controller.switchEffectFromAssets({SLOT_NAME}}, {ASSET_PATH}},faceId: {FACE_ID}});
```

Parameters for this function is: 

**SLOT_NAME**: name of the slot. If you want to combine effetcs, slot name shuold be unique for each added effect
**ASSET_PATH**: asset path of the effect that you defined in the pubspec.yaml(i.e assets/deepar_masks/aviators)
**FACE_ID**: default is 0. values between 0-3.

#### Adding effect by downloading or other ways (outside the app bundle)
You might want to let user download the asset from the internet and use that effect. in scenarios like this, you have to provide the file path instead of asset path for the plugin


```dart
_controller.switchEffectFromAbsolutePath({SLOT_NAME}}, {ABSOLUTE_PATH}},faceId: {FACE_ID}});
```

Parameters for this function is: 

**SLOT_NAME**: name of the slot. If you want to combine effetcs, slot name shuold be unique for each added effect
**ABSOLUTE_PATH**: absolute path of the object saved from the internet. 
**FACE_ID**: default is 0. values between 0-3.

## Other Controller Actions
```dart
Future<dynamic> flipCamera(); //Flips the camera
Future<dynamic> clearEffect(String slot, {int faceId = 0}); //Clears the effect form the relevant slow and faceId
Future<dynamic> takeScreenShot(); //Takes screenshot and returns the path value to the event listener
Future<dynamic> startVideoRecording(); //Starts video recording
Future<dynamic> finishVideoRecording(); //Stops video recording and returns the path value to the event listener
Future<dynamic> pauseVideoRecording(); //Pauses video recording
Future<dynamic> resumeVideoRecording(); //Resumes Video recording
Future<dynamic> pauseRendering(); //Pauses the deepar rendering (i.e then the app is going to background mode)
Future<dynamic> resumeRendering(); //Resumes the plugin 
```
