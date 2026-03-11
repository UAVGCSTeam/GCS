#pragma once
#include <QObject>
#include <QByteArray>
#include "UARTLink.h"
#include "UDPLink.h"



extern "C" {
#if __has_include(<mavlink/common/mavlink.h>)
#include <mavlink/common/mavlink.h>
#else
#include <common/mavlink.h>
#endif
}



// include mavlink (common dialect), handle both folder layouts
#if __has_include(<mavlink/common/mavlink.h>)
extern "C" {
#include <mavlink/common/mavlink.h>
}
#elif __has_include(<common/mavlink.h>)
extern "C" {
#include <common/mavlink.h>
}
#else
#error "Cannot find MAVLink headers. Check CMake include dirs and submodule path."
#endif





class UARTLink;
class UDPLink;
class MAVLinkSender : public QObject {
    Q_OBJECT
public:
    explicit MAVLinkSender(UARTLink* link, QObject* parent=nullptr);
    explicit MAVLinkSender(UDPLink*  link, QObject* parent=nullptr);
    bool isLinkOpen() const;
    bool sendTelemRequest(uint8_t sys, uint8_t comp, int command) const;
    bool sendCommand(uint8_t sysID, uint8_t compID,
                    uint16_t command, float p1=0,
                    float p2=0,float p3=0,float p4=0,
                    float p5=0,float p6=0,float p7=0) const;

                    
    /**
     * function sendSetPositionTargetGlobalInt()
     * @brief Sends a MAVLink SET_POSITION_TARGET_GLOBAL_INT command to a target system.
     *
     * This function constructs and transmits a SET_POSITION_TARGET_GLOBAL_INT
     * message, commanding the target vehicle to move to a specified global
     * latitude, longitude, and altitude.
     *
     * The message is configured to:
     * - Use MAV_FRAME_GLOBAL_RELATIVE_ALT_INT (altitude relative to home).
     * - Control position only (latitude, longitude, altitude).
     * - Ignore velocity, acceleration/force, yaw, and yaw rate fields via type mask.
     *
     * The sender system/component IDs are hardcoded as:
     * - sysid  = 255 (typical GCS ID)
     * - compid = 190
     *
     * @param targetSys   Target system ID (vehicle MAVLink system ID).
     * @param targetComp  Target component ID (e.g., autopilot component).
     * @param lat_deg     Target latitude in degrees.
     * @param lon_deg     Target longitude in degrees.
     * @param alt_m       Target altitude in meters (relative to home).
     *
     * @return true if the encoded MAVLink message was successfully written
     *         to the link; false if the link is not open or the write fails.
     *
     * @note isLinkOpen() must return true before sending.
     * @note time_boot_ms is set to 0, which is acceptable for simple GCS
     *       implementations that do not track boot time synchronization.
     *
     * @warning This function does not validate coordinate ranges or altitude
     *          safety constraints. The caller is responsible for ensuring
     *          valid and safe target values.
     */
    bool sendSetPositionTargetGlobalInt(uint8_t targetSys, uint8_t targetComp,
                                        double lat_deg, double lon_deg,
                                        float alt_m) const;

private:
    qint64 writeToLink(const QByteArray& bytes, uint8_t targetSysID) const;
    UARTLink* UARTLink_;
    UDPLink*  UDPLink_;
    QByteArray packCommandLong(uint8_t sys, uint8_t comp,
                               uint16_t command, float p1,
                               float p2=0,float p3=0,float p4=0,
                               float p5=0,float p6=0,float p7=0) const;
};
