#import <UIKit/UIKit.h>

@interface PluginFaceData : NSObject

@property (nonatomic, assign) NSInteger faceNumber;
@property (nonatomic, strong) NSArray<NSNumber*> * faceRect;
@property (nonatomic, strong) NSArray<NSNumber*> * landmarks;
@property (nonatomic, strong) NSArray<NSNumber*> * landmarks2d;
@property (nonatomic, strong) NSArray<NSNumber*> * poseMatrix;
@property (nonatomic, strong) NSArray<NSNumber*> * rotation;
@property (nonatomic, strong) NSArray<NSNumber*> * translation;
@property (nonatomic, assign) BOOL isDetected;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
