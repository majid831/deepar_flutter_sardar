//
//  PluginSingleton.h
//  flutter_deepar
//
//  Created by Serdar Coşkun on 15.03.2020.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "DeepArViewFactory.h"
NS_ASSUME_NONNULL_BEGIN

@interface PluginSingleton : NSObject<FlutterStreamHandler>

@property (nonatomic, strong) FlutterEventChannel* eventChannel;

+ (instancetype)sharedInstance;
- (void)registerEventChannel:(FlutterEventChannel *)eventChannel;
- (void)sendMessageToFlutter:(id)message willLogMessage:(BOOL)willLogMessage;
@end

NS_ASSUME_NONNULL_END
