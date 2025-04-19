//
//	PluginMultiFaceData.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "PluginMultiFaceData.h"

NSString *const kPluginMultiFaceDataPluginFaceData = @"PluginFaceData";

@interface PluginMultiFaceData ()
@end
@implementation PluginMultiFaceData


-(instancetype)initWithMultiFaceData:(MultiFaceData)multiFaceData{
    self = [super init];
    if (self) {
        NSMutableArray* dataArray = @[].mutableCopy;
        for (int i = 0; i<4; i++) {
            FaceData facedata = multiFaceData.faceData[i];
            PluginFaceData* data = [PluginFaceData new];
            data.faceNumber = i;
            data.isDetected =facedata.detected;
            data.faceRect = [self getArrrayFromStruct:facedata.faceRect];
            data.landmarks = [self getArrrayFromStruct:facedata.landmarks];
            data.landmarks2d = [self getArrrayFromStruct:facedata.landmarks2d];
            data.poseMatrix = [self getArrrayFromStruct:facedata.poseMatrix];
            data.rotation = [self getArrrayFromStruct:facedata.rotation];
            data.translation = [self getArrrayFromStruct:facedata.translation];
            [dataArray addObject:data];
        }
        self.pluginFaceData = dataArray;
    }
    return self;
}

- (NSArray*)getArrrayFromStruct:(float[]) data{
    NSMutableArray* array = [NSMutableArray new];
    for(int i = 0;i<sizeof(data);i++){
        [array addObject:@(data[i])];
    }
    return array;
}


/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(dictionary[kPluginMultiFaceDataPluginFaceData] != nil && [dictionary[kPluginMultiFaceDataPluginFaceData] isKindOfClass:[NSArray class]]){
		NSArray * pluginFaceDataDictionaries = dictionary[kPluginMultiFaceDataPluginFaceData];
		NSMutableArray * pluginFaceDataItems = [NSMutableArray array];
		for(NSDictionary * pluginFaceDataDictionary in pluginFaceDataDictionaries){
			PluginFaceData * pluginFaceDataItem = [[PluginFaceData alloc] initWithDictionary:pluginFaceDataDictionary];
			[pluginFaceDataItems addObject:pluginFaceDataItem];
		}
		self.pluginFaceData = pluginFaceDataItems;
	}
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.pluginFaceData != nil){
		NSMutableArray * dictionaryElements = [NSMutableArray array];
		for(PluginFaceData * pluginFaceDataElement in self.pluginFaceData){
			[dictionaryElements addObject:[pluginFaceDataElement toDictionary]];
		}
		dictionary[kPluginMultiFaceDataPluginFaceData] = dictionaryElements;
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
	if(self.pluginFaceData != nil){
		[aCoder encodeObject:self.pluginFaceData forKey:kPluginMultiFaceDataPluginFaceData];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.pluginFaceData = [aDecoder decodeObjectForKey:kPluginMultiFaceDataPluginFaceData];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	PluginMultiFaceData *copy = [PluginMultiFaceData new];

	copy.pluginFaceData = [self.pluginFaceData copy];

	return copy;
}
@end
