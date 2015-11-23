/* ---------------------------------------------------------
Function: HBNSGE_fnc_slingVehicleSpawn

Description:
	Spawns a vehicle and transports it via helicopter slingload to the destination position.
	
	Can be an existing vehicle or a string to create a n
	
Parameters:
	0:
	  OBJECT - existing vehicle that will be transported
	  STRING - vehicle name that will be created and transported
	1: SIDE - the side for which the vehicle will be slingload spawned, used to determine the helicopter type
	2: OBJECT, MARKER or POSITION - start point from where the vehicle will be transported to destination, if vehicle is not at that position, it
									will be set to that position
	3: OBJECT, MARKER or POSITION - destination where the vehicle will be transported to
	4 (optional): NUMBER - delay to wait until slingload starts (default: no delay)
	5 (optional): NUMBER - notification type
					0 - no notification (default)
					1 - notification
					2 - chat message
					3 - radio message
	6 (optional): STRING - notification string or radio message class from description.ext, notification and chat message can include a placeholder for map grid
	
Example:
	["B_MRAP_01_F", west, "startMarker", "destinationMarker"] call HBNSGE_fnc_slingVehicleSpawn;
	
Returns:
	NOTHING
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

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
