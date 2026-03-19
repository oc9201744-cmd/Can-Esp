#import "Dolphins/crossoffsets.h"

@implementation OffsetsManager

+ (OffsetValues)getOffsetsForBundleID:(NSString *)bundleID {
    OffsetValues defaultOffsets =  { 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0, 0x10A34E980 };  // Yeni güncellenmiş değerler

if ([bundleID containsString:@"tencent"]) {
    return (OffsetValues){ 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0, 0x10A34E980 };
} else if ([bundleID containsString:@"vng"]) {
    return (OffsetValues){ 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0, 0x10A34E980 };
} else if ([bundleID containsString:@"krmobile"]) {
    return (OffsetValues){ 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0, 0x10A34E980 };
} else if ([bundleID containsString:@"rekoo"]) {
    return (OffsetValues){ 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0, 0x10A34E980 };
}

    return defaultOffsets;
}

@end