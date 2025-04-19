//
//  DeepArView.h
//  flutter_deepar
//
//  Created by Serdar Coşkun on 15.03.2020.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@interface DeepArView : NSObject<FlutterPlatformView>

@property(nonatomic, assign)CGRect rect;
@property(nonatomic, assign)int64_t viewId;
@property(nonatomic, assign)id args;

- (instancetype)initWithRect:(CGRect)rect andWithViewId:(int64_t)viewId andWithArgs:(id)args;

- (UIView*)view;
@end

NS_ASSUME_NONNULL_END
