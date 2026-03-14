#import "Dolphins/crossoffsets.h"

@implementation OffsetsManager

+ (OffsetValues)getOffsetsForBundleID:(NSString *)bundleID {
    OffsetValues defaultOffsets =  { 0x104bd8740, 0x10A0557E0, 0x102A62208, 0x10A566E00 };  // Ваши значения по умолчанию

if ([bundleID containsString:@"tencent"]) {
    return (OffsetValues){ 0x104bd8740, 0x10A0557E0, 0x102A62208, 0x10A566E00 };
} else if ([bundleID containsString:@"vng"]) {
    return (OffsetValues){ 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 };
} else if ([bundleID containsString:@"krmobile"]) {
    return (OffsetValues){ 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 };
} else if ([bundleID containsString:@"rekoo"]) {
    return (OffsetValues){ 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 };
}

    return defaultOffsets;
}

@end
