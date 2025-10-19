#pragma once

#include <memory>
#include <string>
#include <vector>

class User;
class ClothingItem;
class Outfit;

// User operations
bool objcCreateUser(const std::string &username,
                    const std::string &name,
                    const std::string &password);

std::shared_ptr<User> objcLoginUser(const std::string &username,
                                    const std::string &password);

bool objcUpdateUserLoginMeta(const std::string &username,
                             const std::string &lastLoginDate,
                             int streak);

bool objcUpdateUserDarkMode(const std::string &username, bool isDarkMode);

std::shared_ptr<User> objcRecoverUser(const std::string &username);

// Clothing item operations
std::vector<std::shared_ptr<ClothingItem>> objcFetchClothingItems(const std::string &username);

bool objcSaveClothingItem(const std::string &username, const ClothingItem &item);

bool objcDeleteClothingItem(const std::string &username, int itemId);

// Outfit operations
std::vector<std::shared_ptr<Outfit>> objcFetchOutfits(const std::string &username);

bool objcSaveOutfit(const std::string &username, const Outfit &outfit);

bool objcDeleteOutfit(const std::string &username, const std::string &outfitId);

int objcGenerateNextClothingItemId();
std::string objcGenerateNextOutfitId();
