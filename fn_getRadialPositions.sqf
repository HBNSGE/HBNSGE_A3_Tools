/* ---------------------------------------------------------
Function: HBNSGE_fnc_getRadialPositions

Description:
	Returns an array of positions around an object or in a circle
    in front of the object.	Amount of positions returned is
	determined by the count of members in the given group.
	
Parameters:
	0: OBJECT - the object to get positions around for
	1: GROUP - the group that should go in position around the object
	2: NUMBER - the radius of the position circle around the object
	3: BOOL - set to true to position around object, set to false to
	          position in front of object (default: true)
	
Example:
	_position = (group player) call HBNSGE_fnc_checkPos;
	
Returns:
	ARRAY of Positions (AGL) - [X,Y,Z]
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

private ["_obj","_grp","_rad","_around","_pos","_relPos","_cnt","_offset","_destinations"];

_obj	= param [0,objNull,[objNull]];
_grp	= param [1,grpNull,[grpNull]];
_rad	= param [2,7,[0]];
_around	= param [3,true,[true]];

if (isNull _obj) exitWith {["You have to specify a main object to group around."] call BIS_fnc_error;};

if (isNull _grp) then {
	_grp = group _obj;
};

if (isNull _grp) exitWith {};

_cnt = count (units _grp);
_offset = floor (360 / _cnt);
_destinations = [];

if (_around) then {
	_pos = getPos _obj;
} else {
	_pos = [getPos _obj, _radius / 2, 180] call BIS_fnc_relPos;
};

{
	_relPos = [_pos, _radius, 0 + ((_forEachIndex + 1) * _offset)] call BIS_fnc_relPos;
	
	[_destinations, _relPos] call BIS_fnc_arrayPush;
	
} forEach units _grp;

_destinations;