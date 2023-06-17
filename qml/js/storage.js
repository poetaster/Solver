/*
 * This file is part of Solver.
 * Copyright (C) 2021  blueprint@poetaster.de based on code from
 * Copyright (C) 2018-2019  Mirian Margiani (harbour-meteoswiss)
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Solver.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.pragma library
.import QtQuick.LocalStorage 2.0 as LS


var initialized = false

function defaultFor(arg, val) { return typeof arg !== 'undefined' ? arg : val; }

function error(summary, details) {
    details = details.toString();
    console.error("Database error:", summary, details);
    dbErrorNotification.previewBody = summary; // short error description
    dbErrorNotification.summary = summary; // same as previewBody
    dbErrorNotification.body = details; // details on the error
    dbErrorNotification.publish();
}

function getDatabase() {
    var db = LS.LocalStorage.openDatabaseSync("Solver", "1.0", "Solver Database", 10000);

    if (!initialized) {
        initialized = true;
        doInit(db);
    }

    return db;
}

function doInit(db) {
    // Database tables: (primary key in all-caps)
    // locations: LOCATION_ID, name, latitude, longitude
    // settings: SETTING, value

    db.transaction(function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS integral(\
            id INTEGER NOT NULL PRIMARY KEY,\
            integrand TEXT NOT NULL, \
            type INTEGER NOT NULL DEFAULT 0,\
            dims INTEGER NOT NULL DEFAULT 0,\
            diff1 TEXT NOT NULL DEFAULT "x",\
            diff2 TEXT NOT NULL DEFAULT "y",\
            diff3 TEXT NOT NULL DEFAULT "z",\
            limInf1 INTEGER NOT NULL DEFAULT 0,\
            limSup1 INTEGER NOT NULL DEFAULT 1,\
            limInf2 INTEGER NOT NULL DEFAULT 0,\
            limSup2 INTEGER NOT NULL DEFAULT 1,\
            limInf3 INTEGER NOT NULL DEFAULT 0,\
            limSup3 INTEGER NOT NULL DEFAULT 1,\
            )');
        tx.executeSql('CREATE TABLE IF NOT EXISTS derivative(\
            id INTEGER NOT NULL PRIMARY KEY,\
            expression TEXT NOT NULL, \
            var1 TEXT NOT NULL DEFAULT "x",\
            numvar1 INTEGER NOT NULL DEFAULT 0,\
            var2 TEXT NOT NULL DEFAULT "y",\
            numvar2 INTEGER NOT NULL DEFAULT 0,\
            var3 TEXT NOT NULL DEFAULT "z",\
            numvar3 INTEGER NOT NULL DEFAULT 0,\
            )');
        tx.executeSql('CREATE TABLE IF NOT EXISTS limit(\
            id INTEGER NOT NULL PRIMARY KEY,\
            expression TEXT NOT NULL, \
            direction INTEGER NOT NULL DEFAULT 0,\
            variable TEXT NOT NULL DEFAULT "x",\
            point TEXT NOT NULL DEFAULT "pi",\
            )');
        tx.executeSql('CREATE TABLE IF NOT EXISTS integral(\
            id INTEGER NOT NULL PRIMARY KEY,\
            expleft TEXT NOT NULL DEFAULT "6/(5-sqrt(x))", \
            expright TEXT NOT NULL DEFAULT "sqrt(x)", \
            var1 TEXT NOT NULL DEFAULT "x",\
            var2 TEXT,\
            var3 TEXT,\
            )');
        tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT NOT NULL PRIMARY KEY, value TEXT)');
    });
}

function simpleQuery(query, values, getSelectedCount) {
    var db = getDatabase();
    var res = undefined;
    values = defaultFor(values, []);

    if (!query) {
        console.log("error: empty query");
        return undefined;
    }

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql(query, values);

            if (rs.rowsAffected > 0) {
                res = rs.rowsAffected;
            } else {
                res = 0;
            }

            if (getSelectedCount === true) {
                res = rs.rows.length;
            }
        });
    } catch(e) {
        console.log("error in query: '"+ e +"', values=", values);
        res = undefined;
    }

    return res;
}

function vacuumDatabase() {
    var db = getDatabase();

    try {
        db.transaction(function(tx) {
            // VACUUM cannot be executed inside a transaction, but the LocalStorage
            // module cannot execute queries without one. Thus we have to manually
            // end the transaction from inside the transaction...
            var rs = tx.executeSql("END TRANSACTION;");
            var rs2 = tx.executeSql("VACUUM;");
        });
    } catch(e) {
        console.log("error in query: '"+ e);
    }
}

function addLocation(locationData) {
    var lat = defaultFor(locationData.lat, 0);
    var lon = defaultFor(locationData.lon, 0);
    var name = defaultFor(locationData.name, null);
    //var id =  getLocationsCount() + 100;
    var res = simpleQuery('INSERT INTO locations VALUES (?,?,?,?);', [, name, lat, lon ]);
    if (res !== 0 && !res) {
        console.log("error: failed to save location " + name + " to db");
    }
    return res;
}

function removeLocation(locationId) {
    var res = simpleQuery('DELETE FROM locations WHERE location_id=?;', [locationId]);
    if (!res) {
        console.log("error: failed to remove location " + locationId + " from db");
    }

    return res;
}


function getLocationsList() {
    var db = getDatabase();
    var res = [];

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations;', []);
            for (var i = 0; i < rs.rows.length; i++) {
                res.push(rs.rows.item(i).location_id);
            }
        });
    } catch(e) {
        console.log("error while loading locations list")
    }

    return res;
}

function getLocationsCount() {
    var db = getDatabase();
    var res = 0;

    try {
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM locations;', []);
            res = rs.rows.length;
        });
    } catch(e) {
        console.log("error while loading locations count")
    }

    return res;
}

function getLocationData(locationId) {
    var db = getDatabase();
    var res = {location_id:"",lat:"",lon:"",name:""};

    try {
        db.transaction(function(tx) {
            var rs = undefined;

            if (locationId) {
                rs = tx.executeSql('SELECT * FROM locations WHERE location_id=?;', [locationId]);
            } else {
                rs = tx.executeSql('SELECT * FROM locations ORDER BY name ASC;');
            }

            for (var i = 0; i < rs.rows.length; i++) {
                res.location_id = rs.rows.item(i).location_id;
                res.name = rs.rows.item(i).name;
                res.lat = rs.rows.item(i).lat;
                res.lon = rs.rows.item(i).lon;
                /*res.push({
                    locationId: rs.rows.item(i).location_id,
                    lat: rs.rows.item(i).lat,
                    lon: rs.rows.item(i).lon,
                    name: rs.rows.item(i).name,
                });*/
            }
        });
    } catch(e) {
        console.log("error while loading locations data for " + locationId)
        return [];
    }

    return res;
}

