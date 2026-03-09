//
//  dobby.h
//  Non-Jailbreak hook interface — CydiaSubstrate yerine Dobby
//
//  libdobby.a zaten Dolphins/lib/ içinde mevcut.
//  Bu header MSHookFunction çağrılarını DobbyHook'a yönlendirir.
//

#ifndef DOBBY_H
#define DOBBY_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Dobby'nin asıl fonksiyonu — libdobby.a'dan link edilir
int DobbyHook(void *address, void *replace, void **origin);

// CydiaSubstrate uyumluluk sarmalayıcısı
// Mevcut MSHookFunction çağrıları değiştirilmeden çalışır
static inline void MSHookFunction(void *symbol, void *hook, void **old) {
    DobbyHook(symbol, hook, old);
}

#ifdef __cplusplus
}
#endif

#endif /* DOBBY_H */
