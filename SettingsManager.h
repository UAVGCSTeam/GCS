#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>

/*
 * SettingsManager - Settings storage using QSettings
 * Automatically saves/loads settings to platform-specific storage:
 *   - Windows: Registry (HKEY_CURRENT_USER\Software\GCS\GroundControlStation)
 *   - Mac: ~/Library/Preferences/com.GCS.GroundControlStation.plist
 * 
 * Settings are stored per-user and never committed to the project codebase.
 */

/*
 * Qt uses Q_PROPERTY to expose C++ data to QML.
 * READ: how QML gets the value, WRITE: how QML sets the value, NOTIFY: signal when value changes.
 * https://doc.qt.io/qt-6/properties.html
 */

class SettingsManager : public QObject
{
    Q_OBJECT

    // Appearance settings
    Q_PROPERTY(QString currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY currentThemeChanged)
    Q_PROPERTY(int     textSizeBase READ textSizeBase WRITE setTextSizeBase NOTIFY textSizeBaseChanged)
    Q_PROPERTY(QString fontFamily   READ fontFamily   WRITE setFontFamily   NOTIFY fontFamilyChanged)

    // Startup settings
    Q_PROPERTY(double homeLat                READ homeLat                WRITE setHomeLat                NOTIFY homeLatChanged)
    Q_PROPERTY(double homeLong               READ homeLong               WRITE setHomeLong               NOTIFY homeLongChanged)
    Q_PROPERTY(bool   leaveAtLastMapLocation READ leaveAtLastMapLocation WRITE setLeaveAtLastMapLocation NOTIFY leaveAtLastMapLocationChanged)

    // Last map position (for "leave at last location" feature)
    Q_PROPERTY(double lastMapLat  READ lastMapLat  WRITE setLastMapLat  NOTIFY lastMapLatChanged)
    Q_PROPERTY(double lastMapLong READ lastMapLong WRITE setLastMapLong NOTIFY lastMapLongChanged)
    Q_PROPERTY(double lastMapZoom READ lastMapZoom WRITE setLastMapZoom NOTIFY lastMapZoomChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);
    ~SettingsManager();

    // Appearance getters
    QString currentTheme() const;
    int textSizeBase() const;
    QString fontFamily() const;

    // Appearance setters
    void setCurrentTheme(const QString &theme);
    void setTextSizeBase(int size);
    void setFontFamily(const QString &family);

    // Startup getters
    double homeLat() const;
    double homeLong() const;
    bool leaveAtLastMapLocation() const;

    // Startup setters
    void setHomeLat(double lat);
    void setHomeLong(double lon);
    void setLeaveAtLastMapLocation(bool enabled);

    // Last map position getters
    double lastMapLat() const;
    double lastMapLong() const;
    double lastMapZoom() const;

    // Last map position setters
    void setLastMapLat(double lat);
    void setLastMapLong(double lon);
    void setLastMapZoom(double zoom);

signals:
    void currentThemeChanged();
    void textSizeBaseChanged();
    void fontFamilyChanged();
    void homeLatChanged();
    void homeLongChanged();
    void leaveAtLastMapLocationChanged();
    void lastMapLatChanged();
    void lastMapLongChanged();
    void lastMapZoomChanged();

private:
    // QSettings handles reading/writing to disk automatically
    QSettings m_settings;
};

#endif 
