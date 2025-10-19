#pragma once

#include <memory>
#include "User.hpp"

// design pattern - Singleton

class CurrentUser {
    CurrentUser() = default;

    CurrentUser(const CurrentUser&) = delete;
    CurrentUser& operator=(const CurrentUser&) = delete;

    std::shared_ptr<User> user_ = nullptr;
    
public:
    // Returnează instanța unică
    static CurrentUser& getInstance() {
        static CurrentUser instance;
        return instance;
    }

    // Setează utilizatorul curent (stochează shared_ptr<User>)
    void setUser(std::shared_ptr<User> user) {
        user_ = std::move(user);
    }

    // Obține pointerul la utilizatorul curent (poate fi nullptr dacă nu e logat nimeni)
    std::shared_ptr<User> getUser() const {
        return user_;
    }

    // Verifică dacă există un utilizator logat
    bool hasUser() const {
        return user_ != nullptr;
    }
};
