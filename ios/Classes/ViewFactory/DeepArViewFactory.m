//
//  DeepArViewFactory.m
//  flutter_deepar
//
//  Created by Serdar Coşkun on 20.02.2020.
//

#import "DeepArViewFactory.h"
#import "DeepArView.h"
@interface DeepArViewFactory()




@end
@implementation DeepArViewFactory


- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args{
    return [[DeepArView alloc] initWithRect:frame andWithViewId:viewId andWithArgs:args];
}


- (NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}



@end
