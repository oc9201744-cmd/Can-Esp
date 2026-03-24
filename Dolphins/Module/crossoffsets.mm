#import "Dolphins/crossoffsets.h"

@implementation OffsetsManager

+ (OffsetValues)getOffsetsForBundleID:(NSString *)bundleID {
    
    // ============================================================
    // !! DİKKAT !! Bu adresler her oyun güncellemesinde DEĞİŞİR!
    // iOS_UEDumper çalıştırıp Log.txt'den alman lazım.
    // ASLR nedeniyle her oyun açılışında kayabilir.
    // ============================================================
    
    // DEFAULT OFFSETLER - iOS_UEDumper'dan alınan son değerler
    // !!! BUNLARI YENİ DUMP'TAN ALDIĞIN DEĞERLERLE DEĞİŞTİR !!!
    OffsetValues defaultOffsets = {
        .gWorldFun = 0x102A62208,    // GWorld function adresi
        .gWorldData = 0x10A566E00,   // GWorld data adresi
        .gNameFun = 0x104bd8740,     // GNames function adresi
        .gNameData = 0x10a1178b0     // GNames data adresi
    };

    // ============================================================
    // Bölge bazlı GWorld/GNames adresleri
    // iOS_UEDumper'dan alınan güncel değerler
    // ============================================================
    
    if ([bundleID containsString:@"tencent"]) {
        // Global (GL) - GÜNCEL
        return (OffsetValues){
            .gWorldFun = 0x102A62208,
            .gWorldData = 0x10A566E00,
            .gNameFun = 0x104bd8740,
            .gNameData = 0x10a1178b0
        };
    } 
    else if ([bundleID containsString:@"vng"]) {
        // VNG
        return (OffsetValues){
            .gWorldFun = 0x1028791CC,
            .gWorldData = 0x10A171A00,
            .gNameFun = 0x104510EF0,
            .gNameData = 0x109AAA1A0
        };
    } 
    else if ([bundleID containsString:@"krmobile"]) {
        // KR
        return (OffsetValues){
            .gWorldFun = 0x102AD71F8,
            .gWorldData = 0x10A47D400,
            .gNameFun = 0x10476F14C,
            .gNameData = 0x109DB5940
        };
    } 
    else if ([bundleID containsString:@"rekoo"]) {
        // REKOO
        return (OffsetValues){
            .gWorldFun = 0x102AAAB0C,
            .gWorldData = 0x10A453300,
            .gNameFun = 0x104742830,
            .gNameData = 0x109D8B830
        };
    }

    return defaultOffsets;
}

@end
