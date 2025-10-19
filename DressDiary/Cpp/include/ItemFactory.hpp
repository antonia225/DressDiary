#pragma once

#include <string>
#include <memory>
#include <vector>
#include "ClothingItem.hpp"
#include "Items.hpp"
#include "Outfit.hpp"

class ItemFactory {
public:
    // crearea diferitelor tipuri de haine
    template <typename T, typename... Args>
    static std::shared_ptr<T> create(Args&&... args) {
        return std::make_shared<T>(std::forward<Args>(args)...);
    }

    // crearea unui outfit
    static std::shared_ptr<Outfit> createOutfit(
        const std::string& id,
        const std::string& name,
        const std::string& dateAdded,
        const std::string& season,
        const std::vector<std::shared_ptr<ClothingItem>>& items = {},
        const std::vector<int>& itemIds = {},
        const std::vector<OutfitItemPlacement>& layout = {}
    ) {
        auto outfit = std::make_shared<Outfit>(id, name, season, dateAdded);
        if (!items.empty())
            outfit->setItems(items);
        else if (!itemIds.empty())
            outfit->setItemIds(itemIds);
        if (!layout.empty())
            outfit->setLayout(layout);
        return outfit;
    }
};
