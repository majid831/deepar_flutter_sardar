#import <UIKit/UIKit.h>

@interface PlatformMessage : NSObject

@property (nonatomic, strong) NSString * action;
@property (nonatomic, strong) NSString * descriptionField;
@property (nonatomic, assign) NSInteger numValue;
@property (nonatomic, strong) NSString * strValue;
@property (nonatomic, assign) BOOL isSuccess;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithAction:(NSString*)action;
-(NSDictionary *)toDictionary;
@end
