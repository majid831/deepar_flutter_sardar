//
//	PluginFaceData.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "PluginFaceData.h"

NSString *const kPluginFaceDataFaceNumber = @"faceNumber";
NSString *const kPluginFaceDataFaceRect = @"faceRect";
NSString *const kPluginFaceDataLandmarks = @"landmarks";
NSString *const kPluginFaceDataLandmarks2d = @"landmarks2d";
NSString *const kPluginFaceDataPoseMatrix = @"poseMatrix";
NSString *const kPluginFaceDataRotation = @"rotation";
NSString *const kPluginFaceDataTranslation = @"translation";
NSString *const kPluginFaceDataIsDetected = @"faceDetected";

@interface PluginFaceData ()
@end
@implementation PluginFaceData




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kPluginFaceDataFaceNumber] isKindOfClass:[NSNull class]]){
		self.faceNumber = [dictionary[kPluginFaceDataFaceNumber] integerValue];
	}

	if(![dictionary[kPluginFaceDataFaceRect] isKindOfClass:[NSNull class]]){
		self.faceRect = dictionary[kPluginFaceDataFaceRect];
	}	
	if(![dictionary[kPluginFaceDataLandmarks] isKindOfClass:[NSNull class]]){
		self.landmarks = dictionary[kPluginFaceDataLandmarks];
	}	
	if(![dictionary[kPluginFaceDataLandmarks2d] isKindOfClass:[NSNull class]]){
		self.landmarks2d = dictionary[kPluginFaceDataLandmarks2d];
	}	
	if(![dictionary[kPluginFaceDataPoseMatrix] isKindOfClass:[NSNull class]]){
		self.poseMatrix = dictionary[kPluginFaceDataPoseMatrix];
	}	
	if(![dictionary[kPluginFaceDataRotation] isKindOfClass:[NSNull class]]){
		self.rotation = dictionary[kPluginFaceDataRotation];
	}	
	if(![dictionary[kPluginFaceDataTranslation] isKindOfClass:[NSNull class]]){
		self.translation = dictionary[kPluginFaceDataTranslation];
	}
    if(![dictionary[kPluginFaceDataIsDetected] isKindOfClass:[NSNull class]]){
        self.isDetected = [dictionary[kPluginFaceDataIsDetected] boolValue];
    }
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kPluginFaceDataFaceNumber] = @(self.faceNumber);
	if(self.faceRect != nil){
		dictionary[kPluginFaceDataFaceRect] = [self getJsonSafeArrayFromArray:self.faceRect];
	}
	if(self.landmarks != nil){
		dictionary[kPluginFaceDataLandmarks] = [self getJsonSafeArrayFromArray:self.landmarks];
	}
	if(self.landmarks2d != nil){
		dictionary[kPluginFaceDataLandmarks2d] = [self getJsonSafeArrayFromArray:self.landmarks2d];
	}
	if(self.poseMatrix != nil){
		dictionary[kPluginFaceDataPoseMatrix] = [self getJsonSafeArrayFromArray:self.poseMatrix];
	}
	if(self.rotation != nil){
		dictionary[kPluginFaceDataRotation] = [self getJsonSafeArrayFromArray:self.rotation];
	}
	if(self.translation != nil){
		dictionary[kPluginFaceDataTranslation] = [self getJsonSafeArrayFromArray:self.translation];
	}
    dictionary[kPluginFaceDataIsDetected] = @(self.isDetected);
	return dictionary;

}

- (NSArray<NSNumber*>*)getJsonSafeArrayFromArray:(NSArray<NSNumber*>*)array{
    NSMutableArray<NSNumber*>* mutableArray = @[].mutableCopy;
    for (int i = 0; i<array.count; i++) {
        if(!array[i] || isnan(array[i].floatValue)){
            NSLog(@"Nan Value Captured");
            [mutableArray addObject:@(0.0f)];
        }else{
            [mutableArray addObject:array[i]];
        }
    }
    return mutableArray.copy;
}
/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:@(self.faceNumber) forKey:kPluginFaceDataFaceNumber];	if(self.faceRect != nil){
		[aCoder encodeObject:self.faceRect forKey:kPluginFaceDataFaceRect];
	}
	if(self.landmarks != nil){
		[aCoder encodeObject:self.landmarks forKey:kPluginFaceDataLandmarks];
	}
	if(self.landmarks2d != nil){
		[aCoder encodeObject:self.landmarks2d forKey:kPluginFaceDataLandmarks2d];
	}
	if(self.poseMatrix != nil){
		[aCoder encodeObject:self.poseMatrix forKey:kPluginFaceDataPoseMatrix];
	}
	if(self.rotation != nil){
		[aCoder encodeObject:self.rotation forKey:kPluginFaceDataRotation];
	}
	if(self.translation != nil){
		[aCoder encodeObject:self.translation forKey:kPluginFaceDataTranslation];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.faceNumber = [[aDecoder decodeObjectForKey:kPluginFaceDataFaceNumber] integerValue];
	self.faceRect = [aDecoder decodeObjectForKey:kPluginFaceDataFaceRect];
	self.landmarks = [aDecoder decodeObjectForKey:kPluginFaceDataLandmarks];
	self.landmarks2d = [aDecoder decodeObjectForKey:kPluginFaceDataLandmarks2d];
	self.poseMatrix = [aDecoder decodeObjectForKey:kPluginFaceDataPoseMatrix];
	self.rotation = [aDecoder decodeObjectForKey:kPluginFaceDataRotation];
	self.translation = [aDecoder decodeObjectForKey:kPluginFaceDataTranslation];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	PluginFaceData *copy = [PluginFaceData new];

	copy.faceNumber = self.faceNumber;
	copy.faceRect = [self.faceRect copy];
	copy.landmarks = [self.landmarks copy];
	copy.landmarks2d = [self.landmarks2d copy];
	copy.poseMatrix = [self.poseMatrix copy];
	copy.rotation = [self.rotation copy];
	copy.translation = [self.translation copy];

	return copy;
}
@end
