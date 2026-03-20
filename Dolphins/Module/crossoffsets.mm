#import "Dolphins/crossoffsets.h"

/*
 * Offset Values Updated from Onur.dylib Analysis
 * 
 * Structure:
 * - gWorldFun:  GetGWorld function offset
 * - gWorldData: GWorld data offset
 * - gNameFun:   GetGNames function offset  
 * - gNameData:  GNames data offset
 *
 * Source: Onur.dylib (com.tencent.ig - Global Version)
 * - GetGWorld Function:  0x18F260
 * - GWorldNum (Data):    0xBD5BB8
 * - GetGNames Function:  0x1F91C
 * - GNames (Data):       0xBD5C18
 */

@implementation OffsetsManager

+ (OffsetValues)getOffsetsForBundleID:(NSString *)bundleID {
    // Default offsets from Onur.dylib (Global/International)
    OffsetValues defaultOffsets = { 0x18F260, 0xBD5BB8, 0x1F91C, 0xBD5C18 };

if ([bundleID containsString:@"tencent"]) {
    // Global/International version (com.tencent.ig)
    // Updated from Onur.dylib
    return (OffsetValues){ 0x18F260, 0xBD5BB8, 0x1F91C, 0xBD5C18 };
} else if ([bundleID containsString:@"vng"]) {
    // VNG version (Vietnam)
    return (OffsetValues){ 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 };
} else if ([bundleID containsString:@"krmobile"]) {
    // Korean version
    return (OffsetValues){ 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 };
} else if ([bundleID containsString:@"rekoo"]) {
    // Taiwan version
    return (OffsetValues){ 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 };
}

    return defaultOffsets;
}

@end