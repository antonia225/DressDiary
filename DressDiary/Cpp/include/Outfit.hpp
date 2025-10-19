#pragma once

#include <string>
#include <vector>
#include <algorithm>
#include <memory>
#include "ClothingItem.hpp"

struct OutfitItemPlacement
{
    int itemId;
    double normalizedX;
    double normalizedY;
};

class Outfit
{
    std::string id;
    std::string name;
    std::string season;
    std::string dateAdded;
    std::vector<int> itemIds;
    std::vector<OutfitItemPlacement> layout;

public:
    Outfit(const std::string &id_, const std::string &name_, const std::string &season_, const std::string &dateAdded_)
        : id(id_), name(name_), season(season_), dateAdded(dateAdded_) {}
    ~Outfit() = default;

    // getters
    const std::string &getId() const { return id; }
    const std::string &getName() const { return name; }
    const std::string &getDateAdded() const { return dateAdded; }
    const std::string &getSeason() const { return season; }
    const std::vector<int> &getItemIds() const { return itemIds; }
    const std::vector<OutfitItemPlacement> &getLayout() const { return layout; }

    // setters
    void setName(const std::string &newName) { name = newName; }
    void setItems(const std::vector<std::shared_ptr<ClothingItem>> &newItems)
    {
        itemIds.clear();
        itemIds.reserve(newItems.size());
        for (const auto &ci : newItems)
            if (ci)
                itemIds.push_back(ci->getId());
    }
    void setItemIds(const std::vector<int> &ids) { itemIds = ids; }
    void setLayout(const std::vector<OutfitItemPlacement> &entries) { layout = entries; }
    void clearItems()
    {
        itemIds.clear();
        layout.clear();
    }

    // clothing items management
    void addItem(std::shared_ptr<ClothingItem> item)
    {
        if (!item)
            return;
        itemIds.push_back(item->getId());
    }

    void removeItem(int itemId)
    {
        itemIds.erase(std::remove(itemIds.begin(), itemIds.end(), itemId), itemIds.end());
    }

    bool operator==(const Outfit &other) const
    {
        auto ids1 = itemIds;
        auto ids2 = other.itemIds;
        std::sort(ids1.begin(), ids1.end());
        std::sort(ids2.begin(), ids2.end());
        return ids1 == ids2;
    }
};
