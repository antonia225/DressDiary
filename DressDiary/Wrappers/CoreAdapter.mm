#import "CoreAdapter.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "DressDiary-Swift.h"
#import "ItemFactory.hpp"
#import "User.hpp"
#import "ClothingItem.hpp"
#import "Outfit.hpp"

#include <cstring>
#include <sstream>
#include <iomanip>

// Helpers for string conversion
static NSString* toNSString(const std::string& s) {
    return [NSString stringWithUTF8String:s.c_str()];
}
static std::string toStdString(NSString* s) {
    if (!s) {
        return {};
    }
    const char *cStr = [s UTF8String];
    return cStr ? std::string(cStr) : std::string();
}

static std::shared_ptr<ClothingItem> buildClothingItemFromManagedObject(NSManagedObject *ciMO) {
    if (!ciMO) {
        return nullptr;
    }

    int identifier = [[ciMO valueForKey:@"id"] intValue];
    std::string color    = toStdString([ciMO valueForKey:@"color"]);
    std::string category = toStdString([ciMO valueForKey:@"category"]);

    std::vector<std::string> matList;
    NSString *matsJoined = [ciMO valueForKey:@"materials"];
    if ([matsJoined isKindOfClass:NSString.class]) {
        NSArray<NSString *> *arr = [matsJoined componentsSeparatedByString:@","];
        for (NSString *m in arr) {
            NSString *trimmed = [m stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmed.length > 0) {
                matList.push_back(toStdString(trimmed));
            }
        }
    }

    NSData *imgData = [ciMO valueForKey:@"imageData"];
    std::vector<uint8_t> imgBytes;
    if (imgData && imgData.length > 0) {
        imgBytes.resize(imgData.length);
        memcpy(imgBytes.data(), imgData.bytes, imgData.length);
    }

    std::shared_ptr<ClothingItem> cppItem = nullptr;

    if (category == "pants") {
        float lungP = [[ciMO valueForKey:@"lungimePants"] floatValue];
        std::string tal;
        id waistValue = [ciMO valueForKey:@"taliePants"];
        if ([waistValue isKindOfClass:NSString.class]) {
            tal = toStdString(waistValue);
        } else if ([waistValue respondsToSelector:@selector(doubleValue)]) {
            std::ostringstream oss;
            oss << std::fixed << std::setprecision(1) << [waistValue doubleValue];
            tal = oss.str();
        } else {
            tal = "";
        }
        cppItem = std::make_shared<Pants>(
            identifier,
            color,
            matList,
            category,
            imgBytes,
            lungP,
            tal
        );
    } else if (category == "jacket") {
        bool wp = [[ciMO valueForKey:@"waterproofJacket"] boolValue];
        cppItem = std::make_shared<Jacket>(
            identifier,
            color,
            matList,
            category,
            imgBytes,
            wp
        );
    } else if (category == "top") {
        std::string sleeve;
        id sleeveValue = [ciMO valueForKey:@"manecaTop"];
        if ([sleeveValue isKindOfClass:NSString.class]) {
            sleeve = toStdString(sleeveValue);
        } else if ([sleeveValue respondsToSelector:@selector(doubleValue)]) {
            std::ostringstream oss;
            oss << std::fixed << std::setprecision(1) << [sleeveValue doubleValue];
            sleeve = oss.str();
        } else {
            sleeve = "";
        }
        std::string decStr;
        NSString *decNS = [ciMO valueForKey:@"decolteuTop"];
        if (decNS && [decNS isKindOfClass:NSString.class]) {
            decStr = toStdString(decNS);
        }
        cppItem = std::make_shared<Top>(
            identifier,
            color,
            matList,
            category,
            imgBytes,
            sleeve,
            decStr
        );
    } else if (category == "shoes") {
        float size = [[ciMO valueForKey:@"shoeSize"] floatValue];
        cppItem = std::make_shared<Shoes>(
            identifier,
            color,
            matList,
            category,
            imgBytes,
            size
        );
    } else {
        // Unknown category, ignore
        return nullptr;
    }

    return cppItem;
}

// User operations

bool objcCreateUser(const std::string& username,
                    const std::string& name,
                    const std::string& password)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Check if username already exists
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count > 0) {
        return false;
    }

    // Create new User managed object
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"CDUser"
                                           inManagedObjectContext:ctx];
    NSManagedObject *userMO = [[NSManagedObject alloc] initWithEntity:ent
                                                 insertIntoManagedObjectContext:ctx];
    [userMO setValue:toNSString(username) forKey:@"username"];
    [userMO setValue:toNSString(name)     forKey:@"name"];
    [userMO setValue:toNSString(password) forKey:@"password"];

    // Default values for new user
    [userMO setValue:@"" forKey:@"lastLoginDate"];
    [userMO setValue:@0  forKey:@"streak"];
    [userMO setValue:@NO forKey:@"darkMode"];

    if (![ctx save:&err]) {
        NSLog(@"Error creating User: %@", err.localizedDescription);
        return false;
    }
    return true;
}

std::shared_ptr<User> objcLoginUser(const std::string& username,
                                    const std::string& password)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch user by username & password
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@ AND password == %@",
                       toNSString(username), toNSString(password)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count == 0) {
        return nullptr;
    }

    NSManagedObject *userMO = results.firstObject;
    std::string u = toStdString([userMO valueForKey:@"username"]);
    std::string n = toStdString([userMO valueForKey:@"name"]);
    std::string p = toStdString([userMO valueForKey:@"password"]);
    std::string lastDate = toStdString([userMO valueForKey:@"lastLoginDate"]);
    bool dark = [[userMO valueForKey:@"darkMode"] boolValue];
    int streakValue = [[userMO valueForKey:@"streak"] intValue];

    auto cppUser = std::make_shared<User>(u, n, p);
    cppUser->setLastLogIn(lastDate);
    cppUser->setStreak(streakValue == 0 ? 1 : streakValue);
    cppUser->setDarkMode(dark);
    return cppUser;
}

bool objcUpdateUserLoginMeta(const std::string& username,
                             const std::string& lastLoginDate,
                             int streak)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch user by username
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count == 0) {
        return false;
    }

    NSManagedObject *userMO = results.firstObject;
    [userMO setValue:toNSString(lastLoginDate) forKey:@"lastLoginDate"];
    [userMO setValue:@(streak)            forKey:@"streak"];
    if (![ctx save:&err]) {
        NSLog(@"Error updating login meta: %@", err.localizedDescription);
        return false;
    }
    return true;
}

bool objcUpdateUserDarkMode(const std::string& username,
                            bool isDarkMode)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count == 0) {
        return false;
    }

    NSManagedObject *userMO = results.firstObject;
    [userMO setValue:@(isDarkMode) forKey:@"darkMode"];
    if (![ctx save:&err]) {
        NSLog(@"Error updating dark mode: %@", err.localizedDescription);
        return false;
    }
    return true;
}

std::shared_ptr<User> objcRecoverUser(const std::string& username) {
    NSString *uname = [NSString stringWithUTF8String:username.c_str()];

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = app.persistentContainer.viewContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"username == %@", uname];

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (results.count > 0) {
        NSManagedObject *cdUser = results.firstObject;

        std::string u  = [[cdUser valueForKey:@"username"] UTF8String];
        std::string n  = [[cdUser valueForKey:@"name"] UTF8String];
        std::string ld = [[cdUser valueForKey:@"lastLoginDate"] UTF8String];
        bool isDark    = [[cdUser valueForKey:@"darkMode"] boolValue];
        int streak     = [[cdUser valueForKey:@"streak"] intValue];

        auto user = std::make_shared<User>(u, n, "");
        user->setDarkMode(isDark);
        user->setLastLogIn(ld);
        user->setStreak(streak == 0 ? 1 : streak);

        return user;
    }

    NSLog(@"[objcRecoverUser] No user found with username %@", uname);
    return nullptr;
}

// ClothingItem operations

std::vector<std::shared_ptr<ClothingItem>> objcFetchClothingItems(const std::string& username)
{
    std::vector<std::shared_ptr<ClothingItem>> result;

    // 1) Obținem contextul Core Data
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // 2) Luăm User MO după username
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return result;  // nu există user sau eroare
    }
    NSManagedObject *userMO = uResults.firstObject;

    // 3) Luăm toate ClothingItem‐urile ale lui userMO
    NSFetchRequest *itemFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDClothingItem"];
    itemFetch.predicate = [NSPredicate predicateWithFormat:@"owner == %@", userMO];
    NSError *iErr = nil;
    NSArray *items = [ctx executeFetchRequest:itemFetch error:&iErr];
    if (iErr) {
        return result;  // eroare la fetch
    }

    for (NSManagedObject *ciMO in items) {
        auto cppItem = buildClothingItemFromManagedObject(ciMO);
        if (cppItem) {
            result.push_back(cppItem);
        }
    }

    return result;
}

bool objcSaveClothingItem(const std::string& username,
                          const ClothingItem& item)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Create ClothingItem MO
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"CDClothingItem"
                                           inManagedObjectContext:ctx];
    NSManagedObject *ciMO = [[NSManagedObject alloc] initWithEntity:ent
                                              insertIntoManagedObjectContext:ctx];
    [ciMO setValue:@(item.getId())       forKey:@"id"];
    [ciMO setValue:toNSString(item.getColor())     forKey:@"color"];

    // Join materials vector into a comma-separated string
    const auto& matVec = item.getMaterials();
    NSMutableArray *matStrings = [NSMutableArray array];
    for (const auto& m : matVec) {
        [matStrings addObject:toNSString(m)];
    }
    NSString *joinedMats = [matStrings componentsJoinedByString:@","];
   [ciMO setValue:joinedMats forKey:@"materials"];

    std::string category = item.getCategory();
    [ciMO setValue:toNSString(category)   forKey:@"category"];

    // ImageData
    const auto& imgVec = item.getImage();
    if (!imgVec.empty()) {
        NSData *data = [NSData dataWithBytes:imgVec.data() length:imgVec.size()];
        [ciMO setValue:data forKey:@"imageData"];
    }

    if (category == "pants") {
        if (const Pants* pants = dynamic_cast<const Pants*>(&item)) {
            [ciMO setValue:@(pants->getLungime()) forKey:@"lungimePants"];
            [ciMO setValue:toNSString(pants->getTalie()) forKey:@"taliePants"];
        }
    } else if (category == "jacket") {
        if (const Jacket* jacket = dynamic_cast<const Jacket*>(&item)) {
            [ciMO setValue:@(jacket->isWaterproof()) forKey:@"waterproofJacket"];
        }
    } else if (category == "top") {
        if (const Top* top = dynamic_cast<const Top*>(&item)) {
            [ciMO setValue:toNSString(top->getManeca()) forKey:@"manecaTop"];
            [ciMO setValue:toNSString(top->getDecolteu()) forKey:@"decolteuTop"];
        }
    } else if (category == "shoes") {
        if (const Shoes* shoes = dynamic_cast<const Shoes*>(&item)) {
            [ciMO setValue:@(shoes->getSizeShoes()) forKey:@"shoeSize"];
        }
    }

    [ciMO setValue:userMO forKey:@"owner"];
    NSError *saveErr = nil;
    if (![ctx save:&saveErr]) {
        NSLog(@"Error saving ClothingItem: %@", saveErr.localizedDescription);
        return false;
    }
    return true;
}

bool objcDeleteClothingItem(const std::string& username,
                            int itemId)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Fetch ClothingItem by id and owner
    NSFetchRequest *ciFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDClothingItem"];
    ciFetch.predicate = [NSPredicate predicateWithFormat:@"id == %d AND owner == %@", itemId, userMO];
    NSError *ciErr = nil;
    NSArray *ciResults = [ctx executeFetchRequest:ciFetch error:&ciErr];
    if (ciErr || ciResults.count == 0) {
        return false;
    }
    NSManagedObject *ciMO = ciResults.firstObject;
    NSSet *relatedOutfits = [ciMO valueForKey:@"outfits"];
    if ([relatedOutfits isKindOfClass:NSSet.class] && relatedOutfits.count > 0) {
        for (NSManagedObject *outfitMO in relatedOutfits) {
            NSMutableSet *itemsRelation = [outfitMO mutableSetValueForKey:@"items"];
            [itemsRelation removeObject:ciMO];
        }
    }
    [ctx deleteObject:ciMO];
    NSError *delErr = nil;
    if (![ctx save:&delErr]) {
        NSLog(@"Error deleting ClothingItem: %@", delErr.localizedDescription);
        return false;
    }
    return true;
}

// --------------------
// Outfit operations
// --------------------

std::vector<std::shared_ptr<Outfit>> objcFetchOutfits(const std::string& username)
{
    std::vector<std::shared_ptr<Outfit>> result;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return result;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Fetch Outfit by owner
    NSFetchRequest *oFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDOutfit"];
    oFetch.predicate = [NSPredicate predicateWithFormat:@"owner == %@", userMO];
    NSError *oErr = nil;
    NSArray *outfits = [ctx executeFetchRequest:oFetch error:&oErr];
    if (oErr) {
        return result;
    }

    for (NSManagedObject *oMO in outfits) {
        std::string id        = toStdString([oMO valueForKey:@"id"]);
        std::string name      = toStdString([oMO valueForKey:@"name"]);
        std::string dateAdded = toStdString([oMO valueForKey:@"dateAdded"]);
        std::string season    = toStdString([oMO valueForKey:@"season"]);

        NSSet *itemsSet = [oMO valueForKey:@"items"];
        std::vector<std::shared_ptr<ClothingItem>> cppItems;
        std::vector<int> componentIds;
        if ([itemsSet isKindOfClass:NSSet.class] && itemsSet.count > 0) {
            NSArray *sortedItems = [[itemsSet allObjects] sortedArrayUsingDescriptors:@[
                [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]
            ]];
            cppItems.reserve(sortedItems.count);
            componentIds.reserve(sortedItems.count);
            for (NSManagedObject *ciMO in sortedItems) {
                int identifier = [[ciMO valueForKey:@"id"] intValue];
                componentIds.push_back(identifier);
                auto itemPtr = buildClothingItemFromManagedObject(ciMO);
                if (itemPtr) {
                    cppItems.push_back(itemPtr);
                }
            }
        }
        std::vector<OutfitItemPlacement> layoutEntries;
        NSDictionary<NSString *, NSAttributeDescription *> *attributes = oMO.entity.attributesByName;
        if (attributes[@"layoutJSON"]) {
            NSString *layoutJSON = [oMO valueForKey:@"layoutJSON"];
            if ([layoutJSON isKindOfClass:NSString.class] && layoutJSON.length > 0) {
                NSData *data = [layoutJSON dataUsingEncoding:NSUTF8StringEncoding];
                if (data) {
                    NSError *jsonErr = nil;
                    NSArray *candidateArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
                    if (!jsonErr && [candidateArray isKindOfClass:NSArray.class]) {
                        for (NSDictionary *entry in candidateArray) {
                            NSNumber *itemIdNum = entry[@"itemId"];
                            NSNumber *xNum = entry[@"x"];
                            NSNumber *yNum = entry[@"y"];
                            if (itemIdNum && xNum && yNum) {
                                layoutEntries.push_back({
                                    itemIdNum.intValue,
                                    xNum.doubleValue,
                                    yNum.doubleValue
                                });
                            }
                        }
                    }
                }
            }
        }

        auto cppOutfit = ItemFactory::createOutfit(id, name, dateAdded, season, cppItems, componentIds, layoutEntries);

        result.push_back(cppOutfit);
    }
    return result;
}

bool objcSaveOutfit(const std::string& username,
                    const Outfit& outfit)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Create Outfit MO
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"CDOutfit"
                                           inManagedObjectContext:ctx];
    NSManagedObject *oMO = [[NSManagedObject alloc] initWithEntity:ent
                                              insertIntoManagedObjectContext:ctx];
    [oMO setValue:toNSString(outfit.getId())        forKey:@"id"];
    [oMO setValue:toNSString(outfit.getName())      forKey:@"name"];
    [oMO setValue:toNSString(outfit.getDateAdded()) forKey:@"dateAdded"];
   [oMO setValue:toNSString(outfit.getSeason())    forKey:@"season"];
    [oMO setValue:userMO forKey:@"owner"];

    const auto& componentIds = outfit.getItemIds();
    if (!componentIds.empty()) {
        NSMutableArray<NSNumber *> *ids = [NSMutableArray arrayWithCapacity:componentIds.size()];
        for (int itemId : componentIds) {
            [ids addObject:@(itemId)];
        }

        NSFetchRequest *itemsFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDClothingItem"];
        itemsFetch.predicate = [NSPredicate predicateWithFormat:@"owner == %@ AND id IN %@", userMO, ids];
        NSError *itemErr = nil;
        NSArray *linkedItems = [ctx executeFetchRequest:itemsFetch error:&itemErr];
        if (!itemErr) {
            NSMutableSet *itemsRelation = [oMO mutableSetValueForKey:@"items"];
            for (NSManagedObject *ciMO in linkedItems) {
                [itemsRelation addObject:ciMO];
            }
        } else {
            NSLog(@"Error fetching clothing items for outfit save: %@", itemErr.localizedDescription);
        }
    }

    NSDictionary<NSString *, NSAttributeDescription *> *outfitAttributes = oMO.entity.attributesByName;
    if (outfitAttributes[@"layoutJSON"]) {
        const auto& layoutEntries = outfit.getLayout();
        if (!layoutEntries.empty()) {
            NSMutableArray<NSDictionary *> *layoutArray = [NSMutableArray arrayWithCapacity:layoutEntries.size()];
            for (const auto &entry : layoutEntries) {
                [layoutArray addObject:@{
                    @"itemId" : @(entry.itemId),
                    @"x"      : @(entry.normalizedX),
                    @"y"      : @(entry.normalizedY)
                }];
            }
            NSError *jsonErr = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:layoutArray options:0 error:&jsonErr];
            if (!jsonErr && jsonData) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [oMO setValue:jsonString forKey:@"layoutJSON"];
            }
        } else {
            [oMO setValue:nil forKey:@"layoutJSON"];
        }
    }

    NSError *saveErr = nil;
    if (![ctx save:&saveErr]) {
        NSLog(@"Error saving Outfit: %@", saveErr.localizedDescription);
        return false;
    }
    return true;
}

bool objcDeleteOutfit(const std::string& username,
                      const std::string& outfitId)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Fetch Outfit by id and owner
    NSFetchRequest *oFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDOutfit"];
    oFetch.predicate = [NSPredicate predicateWithFormat:@"id == %@ AND owner == %@", toNSString(outfitId), userMO];
    NSError *oErr = nil;
    NSArray *oResults = [ctx executeFetchRequest:oFetch error:&oErr];
    if (oErr || oResults.count == 0) {
        return false;
    }
    NSManagedObject *oMO = oResults.firstObject;
    [ctx deleteObject:oMO];

    NSError *delErr = nil;
    if (![ctx save:&delErr]) {
        NSLog(@"Error deleting Outfit: %@", delErr.localizedDescription);
        return false;
    }
    return true;
}

int objcGenerateNextClothingItemId()
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    static int lastGeneratedId = -1;
    if (lastGeneratedId < 0) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDClothingItem"];
        request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO] ];
        request.fetchLimit = 1;
        NSError *err = nil;
        NSArray *results = [ctx executeFetchRequest:request error:&err];
        if (!err && results.count > 0) {
            NSManagedObject *ciMO = results.firstObject;
            lastGeneratedId = [[ciMO valueForKey:@"id"] intValue];
        } else {
            lastGeneratedId = 0;
        }
    }

    lastGeneratedId += 1;
    return lastGeneratedId;
}

std::string objcGenerateNextOutfitId()
{
    NSUUID *uuid = [NSUUID UUID];
    NSString *uuidString = [uuid UUIDString];
    return std::string([uuidString UTF8String]);
}
