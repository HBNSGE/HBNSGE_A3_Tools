/*!
 * \page fnc_getradialpositions HBNSGE_fnc_getRadialPositions
 *
 * \brief Returns an array of positions around an object or in a circle in front of the object.	
 *
 * \param 0 OBJECT - The object to get positions around for.
 * \param 1 GROUP - The group that should go into position around the object.
 * \param 2 NUMBER - Radius of the positions' circle around the object. (optional, default: 7)
 * \param 3 BOOLEAN - Set to true get positions around object, set to false to get positions in front of object (optional, default: true)
 * 
 * \return ARRAY - Positions (AGL)
 * 
 * \par Example
 * \code{.unparsed}
 * _destinations = [heli, battleGroup, 10] call HBNSGE_fnc_getRadialPositions
 * \endcode
 * 
 * \author Buschmann
 
 * \since 1.0.0
 */

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