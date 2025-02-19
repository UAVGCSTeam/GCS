#ifndef DRONEMANAGER_H
#define DRONEMANAGER_H

#include <vector>
#include "droneclass.h"
/* This will read from our cpp list of drones
 * We will be able to dynamically read this list and create what we need
 * TODO:
 * Based on read in data of the drones, create it so it updates
 * the numbers like charge amount etc.
 * This is as much as I could do right now without proper data or even drone connection
 *
 * Make drone list item selectable and display real data.
 *                      Make fire page as well-we need real time fire data for this page.
 *                                              Make header allocate those numbers dynamically.
 *                                              Make drone symbols update based on status.
 *
 */
class droneManager
{
public:
    droneManager();
    DroneClass &droneClass;
    std::vector<DroneClass> droneList;

    void addDroneToList();
};

#endif // DRONEMANAGER_H
