#pragma once

#include "ClothingItem.hpp"
#include "Outfit.hpp"
#include <string>
#include <vector>

class User {
    // date de logare
    std::string username;
    std::string password;
    std::string name;
    
    // statistici
    int streak = 0;
    std::string lastLogIn;
    
    // preferinte tema
    bool darkMode = false;
    
    // colectia de obiecte
    std::vector<std::shared_ptr<ClothingItem>> clothingItems;
    std::vector<std::shared_ptr<Outfit>> outfits;
    
public:
    User(const std::string& _username, const std::string& _name, const std::string& _password)
    : username(_username), name(_name), password(_password), lastLogIn("") {}
    ~User() = default;
    
    // getters
    const std::string& getName() const { return name; }
    const std::string& getUsername() const { return username; }
    const std::string& getPassword() const { return password; }
    bool isDarkMode() const { return darkMode; }
    int getStreak() const { return streak; }
    const std::string& getLastLogIn() const { return lastLogIn; }
    
    // setters
    void setDarkMode(bool toggle) { darkMode = toggle; }
    void setLastLogIn(std::string date) { lastLogIn = date; }
    
    // pentru streak
    void incrementStreak() { streak += 1; }
    void resetStreak() { streak = 0; }
    void setStreak(int value) { streak = value; }
    
    // clothingItems management
    const std::vector<std::shared_ptr<ClothingItem>>& getClothingItems() const { return clothingItems; }
    
    void addClothingItem(std::shared_ptr<ClothingItem> item) {
        clothingItems.push_back(std::move(item));
    }
    
    // outfits management
    const std::vector<std::shared_ptr<Outfit>>& getOutfits() const { return outfits; }
    
    void addOutfit(std::shared_ptr<Outfit> outfit) {
        outfits.push_back(std::move(outfit));
    }
};
