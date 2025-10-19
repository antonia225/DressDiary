#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CppBridge : NSObject

#pragma mark – User

+ (BOOL)createUser:(NSString *)username
               name:(NSString *)name
           password:(NSString *)password;

+ (nullable NSString *)loginUser:(NSString *)username
                        password:(NSString *)password;

+ (int)getClothingItemCountForUser:(NSString *)username;
+ (int)getOutfitCountForUser:(NSString *)username;
+ (void)setDarkMode:(BOOL)isDark;
+ (BOOL)getDarkMode;
+ (NSString *)getCurrentName;
+ (int)getCurrentStreak;
+ (BOOL)recoverUserFromCoreData:(NSString *)username;

#pragma mark – ClothingItem

/**
 Fetch-ează toate ClothingItem-urile pentru un user.
 Fiecare NSDictionary conține:
   @"id": NSNumber (int),
   @"category": NSString,
   @"color": NSString,
   @"materials": NSArray<NSString *>,
   @"image": NSData,
   @"pantLength": NSNumber (double, opțional),
   @"pantWaist": NSString (opțional),
   @"jacketWaterproof": NSNumber (BOOL, opțional),
   @"topSleeveType": NSString (opțional),
   @"topNeckline": NSString (opțional),
   @"shoeSize": NSNumber (double, opțional)
*/
+ (NSArray<NSDictionary *> *)fetchClothingItemsForUser:(NSString *)username;

/**
 Salvează un ClothingItem nou pentru user.
 @param username       – username-ul proprietarului
 @param color          – culoarea articolului
 @param materials      – array de NSString cu materialele
 @param category       – categoria articolului (ex. "pants", "jacket", "top")
 @param pantLength     – lungimea pentru `pants` (Float). Ignorat dacă nu e pants.
 @param pantWaist      – talia pentru `pants` (NSString). Ignorat dacă nu e pants.
 @param jacketWaterproof – `BOOL` pentru `jacket` (waterproof). Ignorat dacă nu e jacket.
 @param topSleeveType  – tipul mânecii pentru `top` (NSString). Ignorat dacă nu e top.
 @param topNeckline    – tip de decolteu pentru `top` (NSString). Ignorat dacă nu e top.
 @param shoeSize       – mărimea pentru `shoes` (Float). Ignorat dacă nu e shoes.
 @param imageData        – NSData conținând bytes-ul imaginii
 @return YES dacă a reușit salvarea, NO altfel.
*/
+ (BOOL)saveClothingItemForUser:(NSString *)username
                          color:(NSString *)color
                      materials:(NSArray<NSString *> *)materials
                       category:(NSString *)category
                    pantLength:(float)pantLength
                      pantWaist:(NSString * _Nullable)pantWaist
              jacketWaterproof:(BOOL)jacketWaterproof
                topSleeveType:(NSString * _Nullable)topSleeveType
                  topNeckline:(NSString * _Nullable)topNeckline
                      shoeSize:(float)shoeSize
                         image:(NSData * _Nullable)imageData;

/**
 Șterge ClothingItem-ul cu id-ul dat pentru user.
 @return YES dacă a găsit și a șters elementul, NO altfel.
*/
+ (BOOL)deleteClothingItemForUser:(NSString *)username
                           itemId:(int)itemId;

#pragma mark – Outfit

/**
 Fetch-ează toate Outfit-urile pentru un user.
 Fiecare NSDictionary conține:
   @"id": NSString,
   @"name": NSString,
   @"dateAdded": NSString (format "DD-MM-YYYY"),
   @"season": NSString,
   @"items": NSArray<NSDictionary *> *,
   @"itemIds": NSArray<NSNumber *> *
*/
+ (NSArray<NSDictionary *> *)fetchOutfitsForUser:(NSString *)username;

/**
 Salvează un Outfit nou pentru user.
 @param username  – username-ul proprietarului
 @param name      – numele outfit-ului
 @param dateAdded – data adăugării ("DD-MM-YYYY")
 @param season    – sezonul (“vara”, “iarna” etc.)
 @param itemIds   – NSArray<NSNumber *> cu id-urile articolelor componente
 @return YES dacă a reușit salvarea, NO altfel.
*/
+ (BOOL)saveOutfitForUser:(NSString *)username
                     name:(NSString *)name
                dateAdded:(NSString *)dateAdded
                   season:(NSString *)season
                  itemIds:(NSArray<NSNumber *> *)itemIds;

/**
 Șterge Outfit-ul cu id-ul dat pentru user.
 @return YES dacă a găsit și a șters outfit-ul, NO altfel.
*/
+ (BOOL)deleteOutfitForUser:(NSString *)username
                  outfitId:(NSString *)outfitId;

/**
 Returnează sugestia de outfit pentru ziua curentă (bazat pe sezon).
 Dacă nu există niciun outfit pentru sezonul curent, returnează nil.
 Formatul NSDictionary este același ca la fetchOutfitsForUser: cheile
   @"id", @"name", @"dateAdded", @"season", @"items", @"itemIds"
*/
+ (nullable NSDictionary *)getTodaySuggestionForUser:(NSString *)username;

#pragma mark – Filtrare simplă

/**
 Filtrează ClothingItem-urile după culoare.
 Returnează array de NSDictionary ca la fetchClothingItemsForUser.
*/
+ (NSArray<NSDictionary *> *)fetchAndFilterItemsForUser:(NSString *)username
                                                 color:(NSString *)color;

/**
 Filtrează Outfit-urile după sezon.
 Returnează array de NSDictionary ca la fetchOutfitsForUser.
*/
+ (NSArray<NSDictionary *> *)fetchAndFilterOutfitsForUser:(NSString *)username
                                                   season:(NSString *)season;

@end

NS_ASSUME_NONNULL_END
