#pragma once

#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <string>
#include <algorithm>
#include <cmath>
#include <stdexcept>

namespace detail {
    using namespace std::chrono;

    // Parse "DD-MM-YYYY" into year_month_day with strict calendar validation
    inline year_month_day parseDMY_YMD(const std::string& s) {
        if (s.size() != 10 || s[2] != '-' || s[5] != '-') {
            throw std::invalid_argument("Date must be in format DD-MM-YYYY");
        }
        int d = 0, m = 0, y = 0;
        try {
            d = std::stoi(s.substr(0, 2));
            m = std::stoi(s.substr(3, 2));
            y = std::stoi(s.substr(6, 4));
        } catch (...) {
            throw std::invalid_argument("Invalid numeric values in date string");
        }
        year_month_day ymd{ year{y}, month{static_cast<unsigned>(m)}, day{static_cast<unsigned>(d)} };
        if (!ymd.ok()) {
            throw std::invalid_argument("Invalid calendar date");
        }
        return ymd;
    }

    // Formateaza YMD ca "DD-MM-YYYY"
    inline std::string formatDMY(const std::chrono::year_month_day& ymd) {
        std::ostringstream oss;
        oss << std::setfill('0') << std::setw(2) << unsigned(ymd.day()) << "-"
            << std::setfill('0') << std::setw(2) << unsigned(ymd.month()) << "-"
            << int(ymd.year());
        return oss.str();
    }

    // Convert YMD to std::tm at midnight local components (no TZ conversion)
    inline std::tm to_tm(const std::chrono::year_month_day& ymd) {
        std::tm tm{};
        tm.tm_mday = static_cast<int>(unsigned(ymd.day()));
        tm.tm_mon  = static_cast<int>(unsigned(ymd.month())) - 1; // 0-based
        tm.tm_year = static_cast<int>(ymd.year()) - 1900;         // from 1900
        tm.tm_hour = 0; tm.tm_min = 0; tm.tm_sec = 0; tm.tm_isdst = -1;
        return tm;
    }

    // Portable localtime helper
    inline std::tm makeLocalTm(std::time_t t) {
        std::tm out{};
#if defined(_WIN32)
        localtime_s(&out, &t);
#else
        localtime_r(&t, &out);
#endif
        return out;
    }
}

// Returneaza data de azi in format "DD-MM-YYYY" (LOCAL TIME)
inline std::string getTodayDate() {
    std::time_t now = std::time(nullptr);
    std::tm tm = detail::makeLocalTm(now);
    std::ostringstream oss;
    oss << std::setfill('0') << std::setw(2) << tm.tm_mday << "-"
        << std::setfill('0') << std::setw(2) << (tm.tm_mon + 1) << "-"
        << (tm.tm_year + 1900);
    return oss.str();
}

// Converteste string-ul "DD-MM-YYYY" intr-un std::tm (compat cu codul existent)
inline std::tm parseDMY(const std::string& s) {
    const auto ymd = detail::parseDMY_YMD(s);     // strict validation
    return detail::to_tm(ymd);                    // normalized components
}

// Returneaza numarul de zile intre doua date "DD-MM-YYYY" (data2 - data1)
inline int daysBetween(const std::string& date1, const std::string& date2) {
    using namespace std::chrono;
    const sys_days d1{ detail::parseDMY_YMD(date1) };
    const sys_days d2{ detail::parseDMY_YMD(date2) };
    return static_cast<int>((d2 - d1).count());
}

// Rotunjeste la o singura zecimala (corect si pentru negative)
template <typename T>
inline T roundToOneDecimal(T number) {
    return std::round(number * T(10)) / T(10);
}
