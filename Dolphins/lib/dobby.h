#ifndef DOBBY_H
#define DOBBY_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Dobby'nin ana hook fonksiyonu
// target_ptr: Hook atmak istediğin orijinal fonksiyonun adresi
// replace_ptr: Kendi yazdığın hook fonksiyonunun adresi
// origin_ptr: Orijinal fonksiyonu çağırmak istersen kullanacağın pointer (isteğe bağlı)
int DobbyHook(void *target_ptr, void *replace_ptr, void **origin_ptr);

// Bellek yazma/yama (patch) fonksiyonu
// address: Yazılacak adres
// buffer: Yazılacak veri
// len: Veri uzunluğu
int DobbyCodePatch(void *address, uint8_t *buffer, uint32_t len);

// Register (kayıtçı) seviyesinde loglama/izleme yapmak için (opsiyonel)
typedef void (*dobby_instrument_callback_t)(void *address, void *registers);
int DobbyInstrument(void *address, dobby_instrument_callback_t pre_handler);

// Verilen adresteki hook'u kaldırmak için
int DobbyDestroy(void *address);

#ifdef __cplusplus
}
#endif

#endif
