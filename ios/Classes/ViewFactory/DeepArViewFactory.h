//
//  DeepArViewFactory.h
//  flutter_deepar
//
//  Created by Serdar Coşkun on 20.02.2020.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@interface DeepArViewFactory :NSObject<FlutterPlatformViewFactory>

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args;
- (UIView*)view;
@end

NS_ASSUME_NONNULL_END
