/*!
 * \page fnc_slingVehicleSpawn HBNSGE_fnc_slingVehicleSpawn
 * \brief Spawns a new vehicle in a more realistic way via helicopter slingload.
 *
 * This function can either resupply an external spawned vehicle (0) to a destination (3) or
 * can spawn the vehicle (0) by itself and transports it to the destination (3) point. When calling
 * this function, an appropriate helicopter will be spawned at the start postion (2) and the
 * vehicle that should be delivered as a respawn will be either set to the heli's position if
 * it has been spawned by an external command/function or it will also be spawned at the heli's position by this script.
 *
 * The helicopter will then slingload the vehicle and transport it to the real spawn position for the troops.
 * 
 * You can optionally set a delay (4) for the start of the delivery as well as a notification (5,6) about successfull
 * delivery. 
 * 
 * \param 0 OBJECT or STRING - Externally spawned vehicle that will be transported or string of a vehicle class to be spawned and transported by this script.
 * \param 1 SIDE - The side for which the vehicle will be slingloaded, used to determine the helicopter type.
 * \param 2 OBJECT, MARKER or POSITION - Start point from where the vehicle will be transported to destination (3), if vehicle is not at that position, it will be set to that position.
 * \param 3 OBJECT, MARKER or POSITION - Destination where the vehicle will be transported to.
 * \param 4 NUMBER - Delay to wait until slingload starts (optional) (default: no delay)
 * \param 5 NUMBER - Notification type.
 *		\arg \c 0 - no notification (default)
 * 		\arg \c 1 - notification
 * 		\arg \c 2 - chat message
 * 		\arg \c 3 - radio message
 * \param 6 STRING - Notification string or radio message class from description.ext, notification and chat message can include a placeholder for map grid. (optional)
 * 
 * \par Example
 * \code{.unparsed}
 * ["B_MRAP_01_F", west, "startMarker", "destinationMarker"] call HBNSGE_fnc_slingVehicleSpawn;
 * \endcode
 *
 * \return Nothing
 *
 * \author Buschmann
 *
 * \since 1.0.0
 */
 

if (!isServer) exitWith {};

private ["_cargo", "_side", "_start", "_dest", "_cargoStartEqual", "_heli", "_heliClass", "_notifyType", "_notifyMsg", "_supportGroup", "_delay"];

// check if all required params are set
if (count _this < 4) exitWith {};

_cargo		= param [0, objNull, [objNull, ""]];
_side		= _this select 1;
_start		= param [2, objNull, [objNull,"",[]]];
_dest		= param [3, objNull, [objNull,"",[]]];
_delay		= param [4, 0, [0]];
_notifyType	= param [5, 0, [0]];
_notifyMsg	= param [6, "", [""]];

if (typeName _cargo == typeName "") then {
};

// exit script if cargo is not an object
if (isNull _cargo) exitWith {["You have to specify a valid cargo object."] call BIS_fnc_error;};

// get destination position
_dest = _dest call HBNSGE_fnc_getPos;
if (count _dest != 3) exitWith {["You have to specify a valid destination position."] call BIS_fnc_error;};

// get start position
_start = _start call HBNSGE_fnc_getPos;

// if start position could not be determined, set the cago position as start position and set _cargoStartEqual to true
_cargoStartEqual = false;

if (count _start != 3) then {_start = getPos _cargo; _cargoStartEqual = true};

_start = [_start, 20, 150, 20, 0, 5, 0] call BIS_fnc_findSafePos;

if (!_cargoStartEqual) then {
	_cargo setPos _start;
};

switch (_side) do {
	case west: {_heliClass = "B_Heli_Transport_03_unarmed_F";};
	case east: {_heliClass = "O_Heli_Transport_04_F";};
	default {_heliClass = "";};
};

if (_heliClass == "") exitWith {["Can not determine the side."] call BIS_fnc_error;};

_supportGroup = createGroup _side;

_heli = createVehicle [_heliClass, [(_start select 0), _start select 1, 12], [], 0, "FLY"];
_heli flyInHeight 10;

[_heli, _supportGroup] call BIS_fnc_spawnCrew;

// _pilotClass createUnit [_start, _supportGroup, "this assignAsDriver _heli; this moveInDriver _heli", 0.6, "LIEUTENANT"];
// _pilotClass createUnit [_start, _supportGroup, "this assignAsTurret [_heli,[0]]; this moveInTurret [_heli,[0]]", 0.6, "SERGEANT"];

_heli setPos [(getPos _heli select 0), (getPos _heli select 1), 10];

_transportHandle = [_heli, _cargo, _dest, [], _notifyType, _notifyMsg, {{deleteVehicle _x;} forEach crew _heli; deleteVehicle _heli;}] spawn HBNSGE_fnc_slingVehicleTransport;
