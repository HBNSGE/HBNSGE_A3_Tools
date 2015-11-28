/*!
 * \page fnc_heliflyto HBNSGE_fnc_heliFlyTo
 *
 * \brief Lets a helicopter fly from on point to anohter.
 * 
 * \param 0 OBJECT - The helicopter to use.
 * \param 1 OBJECT, position ARRAY or marker STRING - The destination position.
 * \param 2 NUMBER - The altitude while flying to the destination.
 * \param 3 NUMBER - The altitude at the destination. Values lower 0 disable it. (optional, default: -1)
 * \param 4 CODE or STRING - Callback code or script file that will be executed after the helicopter has reached it's destination and optional destination altitiude.
 * 
 * \return Script Handle
 * 
 * \par Example
 * \code{.unparsed}
 * _scriptHandle = [_heli, "destinationMarker"] spawn HBNSGE_fnc_heliFlyTo;
 * \endcode
 * 
 * \author Buschmann
 *
 * \since 1.0.0
 */

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