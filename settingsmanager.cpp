#include "settingsmanager.h"

/*
 * QSettings API:
 *   m_settings.value(key, default) - Reads value from storage, returns default if not found
 *   m_settings.setValue(key, value) - Writes value to storage (auto-saves to disk)
 */

// Constructor - initializes QSettings with organization/app name for storage path
SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
    , m_settings("GCS", "GroundControlStation")
{
}

// =============================================================================
// APPEARANCE SETTINGS
// =============================================================================

QString SettingsManager::currentTheme() const {
    return m_settings.value("appearance/theme", "dark").toString();
}

void SettingsManager::setCurrentTheme(const QString &theme) {
    if (currentTheme() != theme) {
        m_settings.setValue("appearance/theme", theme);
        emit currentThemeChanged();
    }
}

int SettingsManager::textSizeBase() const {
    return m_settings.value("appearance/textSizeBase", 12).toInt();
}

void SettingsManager::setTextSizeBase(int size) {
    if (textSizeBase() != size) {
        m_settings.setValue("appearance/textSizeBase", size);
        emit textSizeBaseChanged();
    }
}

QString SettingsManager::fontFamily() const {
    return m_settings.value("appearance/fontFamily", "Arial").toString();
}

void SettingsManager::setFontFamily(const QString &family) {
    if (fontFamily() != family) {
        m_settings.setValue("appearance/fontFamily", family);
        emit fontFamilyChanged();
    }
}

// =============================================================================
// STARTUP SETTINGS
// =============================================================================

double SettingsManager::homeLat() const {
    return m_settings.value("startup/homeLat", 34.059174611493965).toDouble();
}

void SettingsManager::setHomeLat(double lat) {
    if (homeLat() != lat) {
        m_settings.setValue("startup/homeLat", lat);
        emit homeLatChanged();
    }
}

double SettingsManager::homeLong() const {
    return m_settings.value("startup/homeLong", -117.82051240067321).toDouble();
}

void SettingsManager::setHomeLong(double lon) {
    if (homeLong() != lon) {
        m_settings.setValue("startup/homeLong", lon);
        emit homeLongChanged();
    }
}

bool SettingsManager::leaveAtLastMapLocation() const {
    return m_settings.value("startup/leaveAtLastMapLocation", false).toBool();
}

void SettingsManager::setLeaveAtLastMapLocation(bool enabled) {
    if (leaveAtLastMapLocation() != enabled) {
        m_settings.setValue("startup/leaveAtLastMapLocation", enabled);
        emit leaveAtLastMapLocationChanged();
    }
}

// =============================================================================
// LAST MAP POSITION (for "leave at last location" feature)
// =============================================================================

double SettingsManager::lastMapLat() const {
    return m_settings.value("map/lastLat", 34.059174611493965).toDouble();
}

void SettingsManager::setLastMapLat(double lat) {
    if (lastMapLat() != lat) {
        m_settings.setValue("map/lastLat", lat);
        emit lastMapLatChanged();
    }
}

double SettingsManager::lastMapLong() const {
    return m_settings.value("map/lastLong", -117.82051240067321).toDouble();
}

void SettingsManager::setLastMapLong(double lon) {
    if (lastMapLong() != lon) {
        m_settings.setValue("map/lastLong", lon);
        emit lastMapLongChanged();
    }
}

double SettingsManager::lastMapZoom() const {
    return m_settings.value("map/lastZoom", 16.0).toDouble();
}

void SettingsManager::setLastMapZoom(double zoom) {
    if (lastMapZoom() != zoom) {
        m_settings.setValue("map/lastZoom", zoom);
        emit lastMapZoomChanged();
    }
}

