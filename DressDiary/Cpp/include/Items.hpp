#pragma once

#include <string>
#include <vector>
#include "ClothingItem.hpp"
#include "Utilities.hpp"

// pantaloni
class Pants : public virtual ClothingItem
{
    float lungime;
    std::string talie;

public:
    Pants(int id_, const std::string &color_, const std::vector<std::string> &materials_, const std::string &category_, const std::vector<std::uint8_t> &image_, float lungime_, std::string talie_)
        : ClothingItem(id_, color_, materials_, category_, image_), lungime(lungime_), talie(talie_)
    {
        lungime = roundToOneDecimal(lungime);
    }

    // getters
    float getLungime() const { return lungime; }
    const std::string &getTalie() const { return talie; }
};

// top-uri
class Top : public ClothingItem
{
    std::string tipManeca;
    std::string tipDecolteu;

public:
    Top(int id_, const std::string &color_, const std::vector<std::string> &materials_, const std::string &category_, const std::vector<std::uint8_t> &image_, const std::string &tipManeca_, const std::string &tipDecolteu_)
        : ClothingItem(id_, color_, materials_, category_, image_), tipManeca(tipManeca_), tipDecolteu(tipDecolteu_) {}

    // getters
    const std::string &getManeca() const { return tipManeca; }
    const std::string &getDecolteu() const { return tipDecolteu; }
};

// jachete
class Jacket : public virtual ClothingItem
{
    bool waterproof;

public:
    Jacket(int id_, const std::string &color_, const std::vector<std::string> &materials_, const std::string &category_, const std::vector<std::uint8_t> &image_, bool waterproof_)
        : ClothingItem(id_, color_, materials_, category_, image_), waterproof(waterproof_) {}

    // getters
    bool isWaterproof() const { return waterproof; }
};

// shoes
class Shoes : public virtual ClothingItem
{
    float size;

public:
    Shoes(int id_, const std::string &color_, const std::vector<std::string> &materials_, const std::string &category_, const std::vector<std::uint8_t> &image_, float size_)
        : ClothingItem(id_, color_, materials_, category_, image_), size(size_)
    {
        size = roundToOneDecimal(size);
    }

    // getters
    int getSizeShoes() const { return size; }
};
