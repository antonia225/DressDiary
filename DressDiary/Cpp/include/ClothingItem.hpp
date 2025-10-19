#pragma once

#include <string>
#include <vector>
#include <cstdint>
#include <iosfwd>

class ClothingItem
{
    int id;
    std::string color;
    std::vector<std::string> materials;
    std::string category;
    std::vector<uint8_t> image;     // imaginea este transformata in biti in swift

public:
    ClothingItem(int id_, const std::string &color_, const std::vector<std::string> &materials_, const std::string &category_, const std::vector<std::uint8_t> &image_)
        : id(id_), color(color_), materials(materials_), category(category_), image(image_) {}
    virtual ~ClothingItem() = default;

    // getters
    int getId() const { return id; }
    std::string getColor() const { return color; }
    const std::vector<std::string>& getMaterials() const { return materials; }
    std::string getCategory() const { return category; }
    const std::vector<uint8_t>& getImage() const { return image; }

    // pentru removeItem
    bool operator== (int otherId) const {
        return getId() == otherId;
    }
};
