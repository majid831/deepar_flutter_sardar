//
//  PluginSingleton.m
//  flutter_deepar
//
//  Created by Serdar Coşkun on 15.03.2020.
//

#import "PluginSingleton.h"
@interface PluginSingleton()

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation PluginSingleton

+ (instancetype)sharedInstance
{
    static PluginSingleton *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PluginSingleton alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)registerEventChannel:(FlutterEventChannel *)eventChannel{
    self.eventChannel = eventChannel;
    [self.eventChannel setStreamHandler:self];
}

- (void)sendMessageToFlutter:(id)message willLogMessage:(BOOL)willLogMessage{
    if (self.eventSink) {
        if (willLogMessage) {
            NSLog(@"Sending message to sink: %@",message);
        }
        self.eventSink(message);
    }
}

#pragma mark - <FlutterStreamHandler> delegate

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events{
    NSLog(@"🔥On Listen Event Sink from singleton");
    self.eventSink = events;
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments{
    NSLog(@"Did Receive Event Sink Cancel");
    self.eventSink = nil;
    return nil;
}

@end
