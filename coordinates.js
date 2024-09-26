.pragma library

/*
  It is common practice to use js files to store constants and config data, define reuseable functions, implementing more complex logic
  .pragma library allows these files to act like singleton files- thus improving performance
  use .pragma library for files that dont need idrect access to QML files
  and instead creates and instance of the js object for each QML object that uses it

  This acted more as a proof-of-concept rather than an actual implementation.
  When we need dynamic drone tracking static data like this might not be sufficent.
  Will look into better options, more-or-less temporary for testing purposes.
*/

var coordinatePairs = [
    { name: "Cal Poly Pomona", lat: 34.059174611493965, lon: -117.82051240067321 },
    { name: "Los Angeles", lat: 34.0522, lon: -118.2437 },
    { name: "San Francisco", lat: 37.7749, lon: -122.4194 }
];

function addCoordinate(name, lat, lon) {
    coordinatePairs.push({ name: name, lat: lat, lon: lon });
}

function getCoordinate(index) {
    return coordinatePairs[index];
}

function getAllCoordinates() {
    return coordinatePairs;
}
