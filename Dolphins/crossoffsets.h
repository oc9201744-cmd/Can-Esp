#import <Foundation/Foundation.h>

typedef struct {
    long gWorldFun;
    long gWorldData;
    long gNameFun;
    long gNameData;
} OffsetValues;

@interface OffsetsManager : NSObject

+ (OffsetValues)getOffsetsForBundleID:(NSString *)bundleID;

@end