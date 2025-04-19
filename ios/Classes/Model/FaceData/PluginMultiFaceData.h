#import <UIKit/UIKit.h>
#import "PluginFaceData.h"
#import <DeepAR/ARView.h>
@interface PluginMultiFaceData : NSObject

@property (nonatomic, strong) NSArray<PluginFaceData*> * pluginFaceData;

-(instancetype)initWithMultiFaceData:(MultiFaceData)multiFaceData;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
