/* ---------------------------------------------------------
Function: HBNSGE_fnc_getNearest

Description:
	Returns the nearest position out of an array of positions.
	Compoared to objects position.
	
	Returns an array containing the nearest position and the index in the positions array.
	
Parameters:
	0: OBJECT - any object
	1: ARRAY of ARRAYs - position arrays in an array
	
Example:
	[player, [[1,2,3],[4,5,6],[7,8,9],[10,11,12]]] call HBNSGE_fnc_getNearest;
	
Returns:
	ARRAY - 0: nearest position, 1: index in provided array
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

private ["_obj","_positions","_nearest","_distance","_dist","_idx"];

_obj		= param [0, objNull, [objNull]];
_positions	= param [1, [], [[]]];

if (isNull _obj) exitWith {};
if (count _positions == 0) exitWith {};

_nearest = [];
_distance = 100000;
_idx = 0;

{
	_dist = (_obj distance _x);
	if (_dist <  _distance) then {
		_distance = _dist;
		_nearest = _x;
		_idx = _forEachIndex;
	};
} forEach _positions;

[_nearest,_idx];