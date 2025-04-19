//
//  DeepArView.m
//  flutter_deepar
//
//  Created by Serdar Coşkun on 15.03.2020.
//

#import "DeepArView.h"
#import <DeepAR/ARView.h>
#import "PluginSingleton.h"
#import "PlatformMessage.h"
#import "PluginMultiFaceData.h"
@interface DeepArView()<ARViewDelegate>

@property (nonatomic, strong) ARView* arView;
@property (nonatomic, assign) BOOL willSendFaceTrackData;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, strong) CameraController *cameraController;
@property (nonatomic, assign) AVCaptureSessionPreset capturePreset;
@end

@implementation DeepArView

- (instancetype)initWithRect:(CGRect)rect andWithViewId:(int64_t)viewId andWithArgs:(id)args{
    self = [super init];
    if (self) {
        self.args = args;
        self.rect = rect;
        self.viewId = viewId;
    }
    return self;
}

- (UIView *)view{
    if (!_arView) {
        [self addObservers];
        
        
        _arView = [[ARView alloc] initWithFrame:_rect];
        NSDictionary* args = (NSDictionary*)_args;
        if ([@"true" isEqualToString:args[@"will_send_face_track_data"]]) {
            _willSendFaceTrackData = YES;
        }else{
            _willSendFaceTrackData = NO;
        }
        [_arView setLicenseKey:_args[@"license"]];
            
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        _currentOrientation = orientation;
        [self.arView initialize];
        self.cameraController = [[CameraController alloc] init];
        self.cameraController.arview = self.arView;
        AVCaptureSessionPreset preset = [self getPresetFromSetting:_args[@"camera_resolution_preset"]];
        if(preset){
            [self.cameraController setPreset:preset];
        }
        [self.cameraController startCamera];
        _arView.delegate = self;
    }
    
    return _arView;
}

- (AVCaptureSessionPreset)getPresetFromSetting:(NSString*)setting{
    AVCaptureSessionPreset preset = AVCaptureSessionPreset1920x1080;
    if ([@"RESOLUTION_PRESET_10920x1080" isEqual:setting]) {
        preset = AVCaptureSessionPreset1920x1080;
    }else if([@"RESOLUTION_PRESET_1280x720" isEqual:setting]){
        preset = AVCaptureSessionPreset1280x720;
    }else if([@"RESOLUTION_PRESET_640x480" isEqual:setting]){
        preset = AVCaptureSessionPreset640x480;
    }else if([@"RESOLUTION_PRESET_DEVICE" isEqual:setting]){
        preset = nil;
    }
    return preset;
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCommandNotification:) name:@"flutter_platform_command" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(didReceiveApplicationWillResignNotification:) name:UIApplicationWillResignActiveNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(didReceiveApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification  object:nil];
    
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"flutter_platform_command" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [self removeObservers];
    NSLog(@"Dealloc PlatformView");
    [_arView shutdown];
    
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification*)notification{
    NSLog(@"Become Active: %@",notification.userInfo);
    
//    [self.cameraController startCamera];
    [_arView resume];
//    [_arView startCamera];
    
}

- (void)didReceiveApplicationWillResignNotification:(NSNotification*)notification{
    NSLog(@"Resign : %@",notification.userInfo);
    if (_arView && [_arView initialized]) {
    
//        [self.cameraController stopCamera];
        [_arView pause];
//        [_arView stopCamera];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"Orientation Change: %li",(long)orientation);
    if (_currentOrientation == orientation) {
        NSLog(@"Orientation is same");
        return;
    }
    _currentOrientation = orientation;
//    [_arView changeOrientationStart];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cameraController setVideoOrientation:orientation];
        [self.cameraController startCamera];
//        [self.arView changeOrientation:orientation];
//        [self.arView startCamera];
    });
    
}

- (void)sendMessageToFlutter:(PlatformMessage*)message{
    [self sendMessageToFlutter:message willLogMessage:YES];
}
- (void)sendMessageToFlutter:(PlatformMessage*)message willLogMessage:(BOOL)willLogMessage{
    [[PluginSingleton sharedInstance] sendMessageToFlutter:[message toDictionary] willLogMessage:willLogMessage];
}




- (void)didReceiveCommandNotification:(NSNotification*)notification{
    NSString* command = notification.userInfo[@"command"];
    if (!command) {
        return;
    }
    if ([@"flip_camera" isEqualToString:command]) {
        [self flipCamera];
    }else if([@"switch_effect_asset" isEqualToString:command]){
        NSDictionary* arguments = [notification.userInfo objectForKey:@"arguments"];
        [self switchEffecthWithSlotName:arguments[@"slot"] andWithEffectPath:arguments[@"path"] andWithFaceId:[arguments[@"face_id"] intValue] isAbsolutePath:NO];
    }else if([@"switch_effect_absolute_path" isEqualToString:command]){
        NSDictionary* arguments = [notification.userInfo objectForKey:@"arguments"];
        [self switchEffecthWithSlotName:arguments[@"slot"] andWithEffectPath:arguments[@"path"] andWithFaceId:[arguments[@"face_id"] intValue] isAbsolutePath:YES];
    }
    else if([@"clear_effect" isEqualToString:command]){
        NSDictionary* arguments = [notification.userInfo objectForKey:@"arguments"];
        [self clearEffectFromSlot:arguments[@"slot"] forFaceId:[arguments[@"face_id"] intValue]];
    }else if([@"take_screenshot" isEqualToString:command]){
        [self takeScreenShot];
    }else if([@"start_video_recording" isEqualToString:command]){
        [self.arView startVideoRecordingWithOutputWidth:720 outputHeight:1280];
//        [self.arView startRecording];
    }else if([@"finish_video_recording" isEqualToString:command]){
        [self.arView finishVideoRecording];
//        [self.arView finishRecording];
    }else if([@"pause_video_recording" isEqualToString:command]){
        [self.arView pauseVideoRecording];
    }else if([@"resume_video_recording" isEqualToString:command]){
        [self.arView resumeVideoRecording];
    }else if([@"pause_camera" isEqualToString:command]){
        [self.arView pause];
    }else if([@"resume_camera" isEqualToString:command]){
        [self.arView resume];
    }
}


#pragma mark - command interface

- (void)flipCamera{
    
    AVCaptureDevicePosition position = [self.cameraController position];
   if (position == AVCaptureDevicePositionFront) {
       position = AVCaptureDevicePositionBack;
   }else{
       position = AVCaptureDevicePositionFront;
   }
   [self.cameraController setPosition:position];
}

- (void)switchEffecthWithSlotName:(NSString*)slotName
                andWithEffectPath:(NSString*)effectPath
                    andWithFaceId:(int)faceId
                   isAbsolutePath:(BOOL)isAbsolutePath{
    NSString* filePath = effectPath;
    if(!isAbsolutePath){
        filePath = [NSString stringWithFormat:@"%@/Frameworks/App.framework/flutter_assets/%@",[[NSBundle mainBundle] bundlePath],effectPath];
    }
    slotName = [NSString stringWithFormat:@"%@_f%i",slotName,faceId];
    [_arView switchEffectWithSlot:slotName path:filePath face:faceId];
}

-(void)clearEffectFromSlot:(NSString*)slotName forFaceId:(int)faceId{
    slotName = [NSString stringWithFormat:@"%@_f%i",slotName,faceId];
    [_arView switchEffectWithSlot:slotName path:nil face:faceId];
}

- (void)takeScreenShot{
    [_arView takeScreenshot];
}

- (NSURL*)saveDataToTempDirectory:(NSData*)data withFileName:(NSString*)fileName andWithCacheFolderName:(NSString*)cacheFolder{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* tempFilePath = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:cacheFolder];
    NSError* error;
    [fileManager createDirectoryAtURL:tempFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    NSURL* fileUrl = [tempFilePath URLByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:fileUrl.absoluteString]) {
        [fileManager removeItemAtURL:fileUrl error:nil];
    }
    @try {
        [data writeToURL:fileUrl atomically:YES];
    } @catch (NSException *exception) {
        NSLog(@"Error writing file to disk: %@",exception);
    }
    return fileUrl;
}

#pragma mark <ARViewDelegate>

// Called when the finished the preparing for video recording.
- (void)didFinishPreparingForVideoRecording{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"finish_prepare_video_recording"];
    [self sendMessageToFlutter:message];
}

// Called when the video recording is started.
- (void)didStartVideoRecording{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"did_start_video_recording"];
    [self sendMessageToFlutter:message];
}

// Called when the video recording is finished and video file is saved.
- (void)didFinishVideoRecording:(NSString*)videoFilePath{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"did_finish_video_recording"];
    message.strValue = videoFilePath;
    [self sendMessageToFlutter:message];
}

// Called if there is error encountered while recording video
- (void)recordingFailedWithError:(NSError*)error{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"error_video_recording"];
    message.strValue = [error localizedDescription];
    message.isSuccess = NO;
    [self sendMessageToFlutter:message];
}

// Called when screenshot is taken
- (void)didTakeScreenshot:(UIImage *)screenshot{
    NSLog(@"did take screenshot");
    NSURL* path = [self saveDataToTempDirectory:UIImageJPEGRepresentation(screenshot, 0.80) withFileName:[NSString stringWithFormat:@"screenshot_%@.jpg",[[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""]] andWithCacheFolderName:@"screenshots"];
    PlatformMessage* message = [PlatformMessage new];
    message.action = @"screenshot";
    message.strValue = [[path absoluteString] stringByReplacingOccurrencesOfString:@"file:///" withString:@"/"];
    [self sendMessageToFlutter:message];
}

// Called when the engine initialization is complete. Do not call ARView methods before initialization.
- (void)didInitialize{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"did_initialize"];
    [self sendMessageToFlutter:message];
}

// Called when the face appears or disappears.
- (void)faceVisiblityDidChange:(BOOL)faceVisible{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"face_visible"];
    message.numValue = faceVisible ? 1 : 0;
    [self sendMessageToFlutter:message];
}



- (void)faceTracked:(MultiFaceData)faceData{
    if (_willSendFaceTrackData) {
        PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"face_tracked"];
        NSDictionary* dataDict = [[[PluginMultiFaceData alloc] initWithMultiFaceData:faceData] toDictionary];
        message.strValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil] encoding:NSUTF8StringEncoding];
        [self sendMessageToFlutter:message willLogMessage:NO];
    }
}

- (void)numberOfFacesVisibleChanged:(NSInteger)facesVisible{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"number_of_visible_faces_changed"];
    message.numValue = facesVisible;
    [self sendMessageToFlutter:message];
}

- (void)didFinishShutdown{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"did_finish_shutdown"];
    [self sendMessageToFlutter:message];
}

- (void)imageVisibilityChanged:(NSString*)gameObjectName imageVisible:(BOOL)imageVisible{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"image_visibility_changed"];
    message.strValue = gameObjectName;
    message.numValue = imageVisible ? 1 : 0;
    [self sendMessageToFlutter:message];
}

- (void)didSwitchEffect:(NSString*)slot{
    PlatformMessage* message = [[PlatformMessage alloc] initWithAction:@"did_switch_effect"];
    message.strValue = slot;
    [self sendMessageToFlutter:message];
}

@end
