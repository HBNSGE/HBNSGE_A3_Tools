/*!
 * \page fnc_slingVehicleTransport HBNSGE_fnc_slingVehicleTransport
 *
 * \brief Transports an object from one point to another via helicopter sling load and flies back to start position.
 * 
 * \param 0 OBJECT - The helicopter to use.
 * \param 1 OBJECT - The cargo to lift.
 * \param 2 OBJECT, POSITION or MARKER - The destination position.
 * \param 3 OBJECT, POSITION or MARKER - The Extraction position, if not specified it will be the initial heli position. (optional)
 * \param 4 NUMBER - Notification type.  (optional)
 * 	\arg \c 0 - no notification (default)
 * 	\arg \c 1 - notification
 * 	\arg \c 2 - chat message
 * 	\arg \c 3 - radio message
 * \param 5 STRING - Notification string or radio message class from description.ext, notification and chat message can include a placeholder for map grid. (optional)
 * \param 6 CODE or STRING - Code or script file that is executed after the helicopter has reached its extraction position. _this is the helicopter.
 * 
 * \return Script Handle
 * 
 * \par Example
 * \code{.unparsed}
 * _scriptHandle = [heli, mrap, "destinationMarker"] spawn HBNSGE_fnc_slingVehicleTransport;
 * \endcode
 * 
 * \author Buschmann
 *
 * \since 1.0.0
 */
 

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

// exit script if heli is not an object or a helicopter
if (isNull _heli) exitWith {["You have to specify a valid heli object."] call BIS_fnc_error;};
if (!(_heli isKindOf "Helicopter")) exitWith {["You have to specify a helicopter."] call BIS_fnc_error;};

// get start position
_start = _start call HBNSGE_fnc_getPos;
if (count _start != 3) then {_start = _heli call HBNSGE_fnc_getPos;};
if (count _start != 3) exitWith {["You have to specify a valid start position."] call BIS_fnc_error;};

// get destination position
_dest = _dest call HBNSGE_fnc_getPos;
if (count _dest != 3) exitWith {["You have to specify a valid destination position."] call BIS_fnc_error;};

// if heli is near to the cargo, initiate the slingload, otherwise order the heli to fly to the cargo's position and slingload it
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

// send the heli to the destination and wait until it has reached it
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


// send notifications if configured
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
		[["RespawnVehicle",[_displayName,_respawnName,_picture]],"BIS_fnc_showNotification",_side] call BIS_fnc_MP;
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


// send heli back to start position and wait until it has reached it
if (alive _heli) then {
	sleep 3;

	[_heli, _start, 0, "MOVE", "AWARE", "BLUE", "FULL"] call CBA_fnc_addWaypoint;

	sleep 3;

	while { ( (alive _heli) && !(unitReady _heli) ) } do
	{
	   sleep 1;
	};
};

//execute callback if heli has reached the start position
if (alive _heli) then {
	if (typeName _callback == "CODE") then {
		_heli call _callback;
	} else {
		if (_callback != "") then {
			_null = _heli execVM _callback;
		};
	};
};
