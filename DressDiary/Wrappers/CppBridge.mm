#import "CppBridge.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "CoreAdapter.h"
#import "CurrentUser.hpp"
#import "DataManager.hpp"
#import "ClothingItem.hpp"
#import "ItemFactory.hpp"
#import "Items.hpp"
#import "Outfit.hpp"
#import "User.hpp"
#import "Utilities.hpp"

#include <functional>
#include <memory>
#include <string>
#include <vector>
#include <unordered_map>

using namespace std;

// Helper: convertește NSArray<NSString *> în vector<string>
static vector<string> toStdStringVector(NSArray<NSString *> *array) {
    vector<string> result;
    for (NSString *str in array) {
        result.push_back(string([str UTF8String]));
    }
    return result;
}

// Helper: construiește NSDictionary pentru un ClothingItem C++
static NSDictionary<NSString *, id> *dictFromClothingItem(const shared_ptr<ClothingItem> &item) {
    NSNumber *itemId = [NSNumber numberWithInt:item->getId()];
    NSString *category = [NSString stringWithUTF8String:item->getCategory().c_str()];
    NSString *color = [NSString stringWithUTF8String:item->getColor().c_str()];

    // materials
    vector<string> mats = item->getMaterials();
    NSMutableArray<NSString *> *matArray = [NSMutableArray arrayWithCapacity:mats.size()];
    for (const auto &m : mats) {
        [matArray addObject:[NSString stringWithUTF8String:m.c_str()]];
    }

    // image
    const vector<uint8_t> &bytes = item->getImage();
    NSData *imageData = nil;
    if (!bytes.empty()) {
        imageData = [NSData dataWithBytes:bytes.data() length:bytes.size()];
    } else {
        imageData = [NSData data];
    }

    NSMutableDictionary<NSString *, id> *dict = [@{
        @"id"         : itemId,
        @"category"   : category,
        @"color"      : color,
        @"materials"  : (matArray.count ? matArray : @[]),
        @"image"      : imageData
    } mutableCopy];

    auto pantsPtr = std::dynamic_pointer_cast<Pants>(item);
    if (pantsPtr) {
        dict[@"pantLength"] = @(pantsPtr->getLungime());
        dict[@"pantWaist"] = [NSString stringWithUTF8String:pantsPtr->getTalie().c_str()];
    }

    auto jacketPtr = std::dynamic_pointer_cast<Jacket>(item);
    if (jacketPtr) {
        dict[@"jacketWaterproof"] = @(jacketPtr->isWaterproof());
    }

    auto topPtr = std::dynamic_pointer_cast<Top>(item);
    if (topPtr) {
        dict[@"topSleeveType"] = [NSString stringWithUTF8String:topPtr->getManeca().c_str()];
        dict[@"topNeckline"] = [NSString stringWithUTF8String:topPtr->getDecolteu().c_str()];
    }

    auto shoesPtr = std::dynamic_pointer_cast<Shoes>(item);
    if (shoesPtr) {
        dict[@"shoeSize"] = @(shoesPtr->getSizeShoes());
    }

    return dict;
}

// Helper: construiește NSDictionary pentru un Outfit C++
static NSDictionary<NSString *, id> *dictFromOutfit(
    const shared_ptr<Outfit> &outfit,
    const unordered_map<int, shared_ptr<ClothingItem>> &itemsById
) {
    NSString *outfitId  = [NSString stringWithUTF8String:outfit->getId().c_str()];
    NSString *name      = [NSString stringWithUTF8String:outfit->getName().c_str()];
    NSString *dateAdded = [NSString stringWithUTF8String:outfit->getDateAdded().c_str()];
    NSString *season    = [NSString stringWithUTF8String:outfit->getSeason().c_str()];
    const auto &itemIds = outfit->getItemIds();
    NSMutableArray<NSNumber *> *itemIdsArray = [NSMutableArray arrayWithCapacity:itemIds.size()];
    NSMutableArray<NSDictionary *> *itemDicts = [NSMutableArray arrayWithCapacity:itemIds.size()];
    for (int identifier : itemIds) {
        [itemIdsArray addObject:@(identifier)];
        auto it = itemsById.find(identifier);
        if (it != itemsById.end() && it->second) {
            [itemDicts addObject:dictFromClothingItem(it->second)];
        }
    }
    return @{
        @"id"        : outfitId,
        @"name"      : name,
        @"dateAdded" : dateAdded,
        @"season"    : season,
        @"items"     : (itemDicts.count ? itemDicts : @[]),
        @"itemIds"   : (itemIdsArray.count ? itemIdsArray : @[])
    };
}

@implementation CppBridge

#pragma mark – User

+ (BOOL)createUser:(NSString *)username
               name:(NSString *)name
           password:(NSString *)password
{
    std::string u = [username UTF8String];
    std::string n = [name UTF8String];
    std::string p = [password UTF8String];

    bool ok = DataManager::getInstance().createUser(u, n, p);
    if (ok) {
        auto userPtr = DataManager::getInstance().loginUser(u, p);
        if (userPtr) {
            CurrentUser::getInstance().setUser(userPtr);
        }
    }
    return ok;
}

+ (nullable NSString *)loginUser:(NSString *)username
                        password:(NSString *)password
{
    std::string u = [username UTF8String];
    std::string p = [password UTF8String];
    auto cppUser = DataManager::getInstance().loginUser(u, p);
    if (!cppUser) {
        return nil;
    }
    return [NSString stringWithUTF8String:cppUser->getUsername().c_str()];
}

+ (void)setDarkMode:(BOOL)isDark {
    auto user = CurrentUser::getInstance().getUser();
    if (!user) {
        NSLog(@"[CppBridge] Cannot set dark mode without a logged in user.");
        return;
    }
    user->setDarkMode(isDark);
    objcUpdateUserDarkMode(user->getUsername(), isDark);
}

+ (BOOL)getDarkMode {
    auto user = CurrentUser::getInstance().getUser();
    if (!user) {
        return NO;
    }
    return user->isDarkMode();
}

+ (int)getCurrentStreak {
    auto user = CurrentUser::getInstance().getUser();
    if (user) {
        return user->getStreak();
    }
    return 0;
}

+ (int)getClothingItemCountForUser:(NSString *)username {
    std::string u = [username UTF8String];
    return static_cast<int>(DataManager::getInstance().getClothingItemsCount(u));
}

+ (int)getOutfitCountForUser:(NSString *)username {
    std::string u = [username UTF8String];
    return DataManager::getInstance().getOutfitCount(u);
}

+ (BOOL)recoverUserFromCoreData:(NSString *)username {
    std::string u = [username UTF8String];
    auto userPtr = objcRecoverUser(u);
    if (userPtr) {
        CurrentUser::getInstance().setUser(userPtr);
        return YES;
    }
    NSLog(@"[CppBridge] Failed to recover user from Core Data");
    return NO;
}

+ (NSString *)getCurrentName {
    auto user = CurrentUser::getInstance().getUser();
    if (!user) {
        NSLog(@"[CppBridge] No current user found.");
        return @"";
    }
    std::string name = user->getName();
    return [NSString stringWithUTF8String:name.c_str()];
}

#pragma mark – ClothingItem

+ (NSArray<NSDictionary *> *)fetchClothingItemsForUser:(NSString *)username {
    std::string u = [username UTF8String];
    auto cppItems = DataManager::getInstance().getClothingItems(u);
    NSMutableArray<NSDictionary *> *result = [NSMutableArray arrayWithCapacity:cppItems.size()];
    for (auto &itemPtr : cppItems) {
        [result addObject:dictFromClothingItem(itemPtr)];
    }
    return result;
}

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
                         image:(NSData * _Nullable)imageData
{
    std::string u   = [username UTF8String];
    std::string c   = [color UTF8String];
    std::string cat = [category UTF8String];

    vector<string> mats = toStdStringVector(materials);

    vector<uint8_t> bytes;
    if (imageData != nil && imageData.length > 0) {
        const uint8_t *rawPtr = (const uint8_t *)imageData.bytes;
        bytes.assign(rawPtr, rawPtr + imageData.length);
    }

    int newId = objcGenerateNextClothingItemId();
    shared_ptr<ClothingItem> cppItem;

    if ([category isEqualToString:@"pants"]) {
        std::string waist = pantWaist ? [pantWaist UTF8String] : "";
        cppItem = std::make_shared<Pants>(
            newId,
            c,
            mats,
            cat,
            bytes,
            pantLength,
            waist
        );
    } else if ([category isEqualToString:@"jacket"]) {
        cppItem = std::make_shared<Jacket>(
            newId,
            c,
            mats,
            cat,
            bytes,
            jacketWaterproof
        );
    } else if ([category isEqualToString:@"top"]) {
        std::string sleeve = topSleeveType ? [topSleeveType UTF8String] : "";
        std::string neckline = topNeckline ? [topNeckline UTF8String] : "";
        cppItem = std::make_shared<Top>(
            newId,
            c,
            mats,
            cat,
            bytes,
            sleeve,
            neckline
        );
    } else if ([category isEqualToString:@"shoes"]) {
        cppItem = std::make_shared<Shoes>(
            newId,
            c,
            mats,
            cat,
            bytes,
            shoeSize
        );
    } else {
        NSLog(@"[CppBridge] Unsupported category %@", category);
        return NO;
    }

    if (!cppItem) {
        return NO;
    }

    bool succes = DataManager::getInstance().saveClothingItem(u, *cppItem);
    return succes ? YES : NO;
}

+ (BOOL)deleteClothingItemForUser:(NSString *)username
                           itemId:(int)itemId
{
    std::string u = [username UTF8String];
    return DataManager::getInstance().deleteClothingItem(u, itemId);
}

#pragma mark – Outfit

+ (NSArray<NSDictionary *> *)fetchOutfitsForUser:(NSString *)username {
    std::string u = [username UTF8String];
    auto cppOutfits = DataManager::getInstance().getOutfits(u);
    auto cppItems = DataManager::getInstance().getClothingItems(u);
    unordered_map<int, shared_ptr<ClothingItem>> itemsById;
    itemsById.reserve(cppItems.size());
    for (auto &itemPtr : cppItems) {
        if (itemPtr) {
            itemsById[itemPtr->getId()] = itemPtr;
        }
    }

    NSMutableArray<NSDictionary *> *result = [NSMutableArray arrayWithCapacity:cppOutfits.size()];
    for (auto &oPtr : cppOutfits) {
        [result addObject:dictFromOutfit(oPtr, itemsById)];
    }
    return result;
}

+ (BOOL)saveOutfitForUser:(NSString *)username
                     name:(NSString *)name
                dateAdded:(NSString *)dateAdded
                   season:(NSString *)season
                  itemIds:(NSArray<NSNumber *> *)itemIds
{
    std::string u    = [username UTF8String];
    std::string nm   = [name UTF8String];
    std::string date = [dateAdded UTF8String];
    std::string s    = [season UTF8String];
    std::vector<int> ids;
    ids.reserve(itemIds.count);
    for (NSNumber *num in itemIds) {
        ids.push_back(num.intValue);
    }

    std::string newId = objcGenerateNextOutfitId();
    auto cppOutfit = ItemFactory::createOutfit(newId, nm, date, s, {}, ids);
    return DataManager::getInstance().saveOutfit(u, *cppOutfit);
}

+ (BOOL)deleteOutfitForUser:(NSString *)username
                  outfitId:(NSString *)outfitId
{
    std::string u   = [username UTF8String];
    std::string oid = [outfitId UTF8String];
    return DataManager::getInstance().deleteOutfit(u, oid);
}

+ (nullable NSDictionary *)getTodaySuggestionForUser:(NSString *)username {
    std::string u = [username UTF8String];
    auto suggestion = DataManager::getInstance().getTodaySuggestion(u);
    if (!suggestion) {
        return nil;
    }
    auto cppItems = DataManager::getInstance().getClothingItems(u);
    unordered_map<int, shared_ptr<ClothingItem>> itemsById;
    itemsById.reserve(cppItems.size());
    for (auto &itemPtr : cppItems) {
        if (itemPtr) {
            itemsById[itemPtr->getId()] = itemPtr;
        }
    }
    return dictFromOutfit(suggestion, itemsById);
}

#pragma mark – Filtrare simplă

+ (NSArray<NSDictionary *> *)fetchAndFilterItemsForUser:(NSString *)username
                                                  color:(NSString *)color
{
    std::string u = [username UTF8String];
    std::string c = [color UTF8String];
    auto items = DataManager::getInstance().getClothingItems(u);
    NSMutableArray<NSDictionary *> *result = [NSMutableArray array];
    for (auto &itemPtr : items) {
        if (!itemPtr) { continue; }
        if (c.empty() || itemPtr->getColor() == c) {
            [result addObject:dictFromClothingItem(itemPtr)];
        }
    }
    return result;
}

+ (NSArray<NSDictionary *> *)fetchAndFilterOutfitsForUser:(NSString *)username
                                                    season:(NSString *)season
{
    std::string u = [username UTF8String];
    std::string s = [season UTF8String];
    auto outfits = DataManager::getInstance().getOutfits(u);
    auto items = DataManager::getInstance().getClothingItems(u);
    unordered_map<int, shared_ptr<ClothingItem>> itemsById;
    itemsById.reserve(items.size());
    for (auto &itemPtr : items) {
        if (itemPtr) {
            itemsById[itemPtr->getId()] = itemPtr;
        }
    }

    NSMutableArray<NSDictionary *> *result = [NSMutableArray array];
    for (auto &oPtr : outfits) {
        if (!oPtr) { continue; }
        if (s.empty() || oPtr->getSeason() == s) {
            [result addObject:dictFromOutfit(oPtr, itemsById)];
        }
    }
    return result;
}

@end
