/* ---------------------------------------------------------
Function: HBNSGE_fnc_heliFlyTo

Description:
	Lets a helicopter fly from one point to another.
	
Parameters:
	0: OBJECT - the helicopter to use
	1: OBJECT, POSITION or MARKER - the destination position
	2 (optional): NUMBER - the fly height while reaching the destination
	3 (optional): NUMBER - the destination height, script will end or callback will be executed after heli has reached this height
	4 (Optional): CODE - code that is called after the helicopter has reached its extraction position (default: {})
				  STRING - script file to execute after the helicopter has reached its extraction position
	
Example:
	_scriptHandle = [_heli, "destinationMarker"] spawn HBNSGE_fnc_heliFlyTo;
	
Returns:
	NOTHING
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

if (!isServer) exitWith {};

private ["_heli","_dest","_height","_destHeight","_callback"];

_heli 		= 	param [0, objNull, [objNull]];
_dest		=	param [1, objNull, [objNull,"",[]]];
_height		= 	param [2, 0, [0]];
_destHeight = 	param [3, -1, [0]];
_callback	= 	param [4,{},[{},""]];

if (isNull _heli) exitWith {["You have to specify a helicopter."] call BIS_fnc_error;};
if (!(_heli isKindOf "Helicopter")) exitWith {["You have to specify a helicopter."] call BIS_fnc_error;};

// get position of the destination
_dest = _dest call HBNSGE_fnc_getPos;
if ((count _dest) != 3) exitWith {["You have to specify a destination."] call BIS_fnc_error;};

sleep 2;

if (_height > 0) then {
	_heli flyInHeight _height;
};

(group _heli) addWaypoint [_dest, 1];

sleep 3;

while { ( (alive _heli) && !(unitReady _heli) ) } do
{
   sleep 1;
};


if ((_destHeight > -1) && (alive _heli)) then {

	_heli flyInHeight _destHeight;
	
	if (_destHeight > _height) then {
		while { ((getPos _heli select 2 < _destHeight) && (alive _heli)) } do
		{
			sleep 1;
		};
	} else {
		while { ((getPos _heli select 2 > _destHeight) && (alive _heli)) } do
		{
			sleep 1;
		};
	};
};

if (typeName _callback == "CODE") then {
	_heli call _callback;
} else {
	if (_callback != "") then {
		_null = _heli execVM _callback;
	};
};