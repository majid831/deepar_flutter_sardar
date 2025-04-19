#import "FlutterDeeparPlugin.h"
#import "PluginSingleton.h"
#import "DeepArViewFactory.h"
@interface FlutterDeeparPlugin()<FlutterStreamHandler>

@property (nonatomic, strong) NSObject<FlutterPluginRegistrar>*registrar;
@property (nonatomic, strong) FlutterMethodChannel* channel;
@property (nonatomic, strong) FlutterEventChannel* eventChannel;

@end

@implementation FlutterDeeparPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_deepar"
                                     binaryMessenger:[registrar messenger]];
    FlutterDeeparPlugin* instance = [[FlutterDeeparPlugin alloc] init];
    [instance initializePluginWithMethodChannel:channel andWithRegistrar:registrar];
    [registrar addMethodCallDelegate:instance channel:channel];
    
}

- (void)initializePluginWithMethodChannel:(FlutterMethodChannel*)channel andWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar{
    self.channel = channel;
    self.registrar = registrar;
    self.eventChannel = [FlutterEventChannel eventChannelWithName:@"event_chanel_deepar" binaryMessenger:registrar.messenger];
    DeepArViewFactory* factory = [[DeepArViewFactory alloc] init];
    [self.registrar registerViewFactory:factory withId:@"plugin_deep_ar_view"];
    [[PluginSingleton sharedInstance] registerEventChannel:self.eventChannel];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"Method: %@, Args: %@", call.method, call.arguments);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"flutter_platform_command" object:nil userInfo:@{@"command":call.method, @"arguments":call.arguments ? call.arguments : @""}];
    result(nil);
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    NSLog(@"On Cancel With Argunemts: %@",arguments);
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    NSLog(@"On Listen With Argunemts: %@",arguments);
    return nil;
}

@end
