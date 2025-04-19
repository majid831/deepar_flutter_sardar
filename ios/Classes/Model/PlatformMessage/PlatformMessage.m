//
//	PlatformMessage.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "PlatformMessage.h"

NSString *const kPlatformMessageAction = @"action";
NSString *const kPlatformMessageDescriptionField = @"description";
NSString *const kPlatformMessageNumValue = @"numValue";
NSString *const kPlatformMessageStrValue = @"strValue";
NSString *const kPlatforMessageIsSuccess = @"isSuccess";

@interface PlatformMessage ()
@end
@implementation PlatformMessage


-(instancetype)initWithAction:(NSString*)action{
    self = [super init];
    if (self) {
        self.action = action;
        self.isSuccess = YES;
    }
    return self;
}


/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
    self.isSuccess = YES;
	if(![dictionary[kPlatformMessageAction] isKindOfClass:[NSNull class]]){
		self.action = dictionary[kPlatformMessageAction];
	}	
	if(![dictionary[kPlatformMessageDescriptionField] isKindOfClass:[NSNull class]]){
		self.descriptionField = dictionary[kPlatformMessageDescriptionField];
	}	
	if(![dictionary[kPlatformMessageNumValue] isKindOfClass:[NSNull class]]){
		self.numValue = [dictionary[kPlatformMessageNumValue] integerValue];
	}

	if(![dictionary[kPlatformMessageStrValue] isKindOfClass:[NSNull class]]){
		self.strValue = dictionary[kPlatformMessageStrValue];
	}
    
    if(![dictionary[kPlatforMessageIsSuccess] isKindOfClass:[NSNull class]]){
        self.isSuccess = [dictionary[kPlatforMessageIsSuccess] boolValue];
    }
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.action != nil){
		dictionary[kPlatformMessageAction] = self.action;
	}
	if(self.descriptionField != nil){
		dictionary[kPlatformMessageDescriptionField] = self.descriptionField;
	}
	dictionary[kPlatformMessageNumValue] = @(self.numValue);
    dictionary[kPlatforMessageIsSuccess] = @(self.isSuccess);
	if(self.strValue != nil){
		dictionary[kPlatformMessageStrValue] = self.strValue;
	}
    
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if(self.action != nil){
		[aCoder encodeObject:self.action forKey:kPlatformMessageAction];
	}
	if(self.descriptionField != nil){
		[aCoder encodeObject:self.descriptionField forKey:kPlatformMessageDescriptionField];
	}
	[aCoder encodeObject:@(self.numValue) forKey:kPlatformMessageNumValue];	if(self.strValue != nil){
		[aCoder encodeObject:self.strValue forKey:kPlatformMessageStrValue];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.action = [aDecoder decodeObjectForKey:kPlatformMessageAction];
	self.descriptionField = [aDecoder decodeObjectForKey:kPlatformMessageDescriptionField];
	self.numValue = [[aDecoder decodeObjectForKey:kPlatformMessageNumValue] integerValue];
	self.strValue = [aDecoder decodeObjectForKey:kPlatformMessageStrValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	PlatformMessage *copy = [PlatformMessage new];

	copy.action = [self.action copy];
	copy.descriptionField = [self.descriptionField copy];
	copy.numValue = self.numValue;
	copy.strValue = [self.strValue copy];

	return copy;
}
@end
