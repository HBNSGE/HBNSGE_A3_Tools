/* ---------------------------------------------------------
Function: HBNSGE_fnc_slingVehicleTransport

Description:
	Transports a vehicle from one point to another via helicopter
	sling load and flies back to start position.
	
Parameters:
	0: OBJECT - the helicopter to use
	1: OBJECT - the cargo to lift
	2: OBJECT, POSITION or MARKER - the destination position
	3 (optional): OBJECT, POSITION or marker STRING - the extraction position, if not specified it will be the initial heli position
	4 (optional): NUMBER - notification type
					0 - no notification (default)
					1 - notification
					2 - chat message
					3 - radio message
	5 (optional): STRING - notification string or radio message class from description.ext, notification and chat message can include a placeholder for map grid
	6 (Optional): CODE - code that is called after the helicopter has reached its extraction position, _this is the helicopter (default: {})
				  STRING - script file to execute after the helicopter has reached its extraction position, _this is the helicopter
	
Example:
	_scriptHandle = [_heli, _mrap, "destinationMarker"] spawn HBNSGE_fnc_slingVehicleTransport;
	
Returns:
	Script Handler
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

if (!isServer) exitWith {};

private ["_cargo", "_heli", "_start", "_dest", "_flyHeight", "_callback", "_notification"];

// check if all required params are set
if (count _this < 3) exitWith {};

_heli			= param [0, objNull, [objNull]];
_cargo			= param [1, objNull, [objNull]];
_dest			= param [2, objNull, [objNull,"",[]]];
_start			= param [3, objNull, [objNull,"",[]]];
_notification	= param [4, 0, [0]];
_notifyMsg		= param [5, "", [""]];
_callback		= param [6, {}, [{},""]];

// exit script if cargo is not an object
if (isNull _cargo) exitWith {["You have to specify a valid cargo object."] call BIS_fnc_error;};
if (isNull _heli) exitWith {["You have to specify a valid heli object."] call BIS_fnc_error;};
if (!(_heli isKindOf "Helicopter")) exitWith {["You have to specify a helicopter."] call BIS_fnc_error;};

// get start position
_start = _start call HBNSGE_fnc_getPos;
if (count _start != 3) then {_start = _heli call HBNSGE_fnc_getPos;};
if (count _start != 3) exitWith {["You have to specify a valid start position."] call BIS_fnc_error;};

// get destination position
_dest = _dest call HBNSGE_fnc_getPos;
if (count _dest != 3) exitWith {["You have to specify a valid destination position."] call BIS_fnc_error;};

if (((getPos _heli) distance (getPos _cargo)) < 12) then {
	_heli setSlingLoad _cargo;
} else {

	[_heli, (getPos _cargo), 0, "HOOK", "AWARE", "BLUE", "FULL"] call CBA_fnc_addWaypoint;

	sleep 3;

	while { ( (alive _heli) && !(unitReady _heli) ) } do
	{
	   sleep 1;
	};

};

if ((alive _heli) && (alive _cargo)) then
{
	private ["_flyToHandle"];
	_flyToHandle = [_heli, _dest, 0, 12] spawn HBNSGE_fnc_heliFlyTo;
	waitUntil {scriptDone _flyToHandle};

	[_heli, _dest, 0, "UNHOOK"] call CBA_fnc_addWaypoint;

	sleep 3;

	while { ( (alive _heli) && !(unitReady _heli) ) } do
	{
	   sleep 1;
	};
	
	while {((getSlingLoad _heli) == _cargo)} do 
	{
		sleep 1;
	};
};

if ((_notification > 0) && (alive _heli) && (alive _cargo)) then {	

	sleep 3;

	private ["_vehType", "_cfgVeh", "_displayName", "_picture", "_respawnName","_side", "_hq"];
	_vehType = typeOf _cargo;
	_cfgVeh = configfile >> "cfgvehicles" >> _vehType;
	_displayName = gettext (_cfgVeh >> "displayName");
	_side = side _heli;
	_hq = _side call BIS_fnc_moduleHQ;

	if (_notification == 1) then {
		if (_notifyMsg == "") then {_notifyMsg = "str_a3_bis_fnc_respawnmenuposition_grid";};
		_notifyMsg = [_notifyMsg] call BIS_fnc_localize;
		_picture = (gettext (_cfgVeh >> "picture")) call bis_fnc_textureVehicleIcon;
		_respawnName = format [_notifyMsg ,mapgridposition (position _cargo)];
		[["RespawnVehicle",[_displayName,_respawnName,_picture]],"BIS_fnc_showNotification",_side] call bis_fnc_mp;
	};
	
	if (_notification == 2) then {
		if (_notifyMsg == "") then {_notifyMsg = "str_a3_bis_fnc_respawnmenuposition_grid";};
		_notifyMsg = [_notifyMsg] call BIS_fnc_localize;
		_notifyMsg = format [_notifyMsg, mapgridposition (position _cargo)];
		[_hq, _notifyMsg] remoteExecCall ["sideChat", _side];
	};
	
	if (_notification == 3) then {
		[_hq, _notifyMsg] remoteExecCall ["sideRadio", _side];
	};
};

if (alive _heli) then {
	sleep 3;

	[_heli, _start, 0, "MOVE", "AWARE", "BLUE", "FULL"] call CBA_fnc_addWaypoint;

	sleep 3;

	while { ( (alive _heli) && !(unitReady _heli) ) } do
	{
	   sleep 1;
	};
};

if (alive _heli) then {
	if (typeName _callback == "CODE") then {
		_heli call _callback;
	} else {
		if (_callback != "") then {
			_null = _heli execVM _callback;
		};
	};
};
