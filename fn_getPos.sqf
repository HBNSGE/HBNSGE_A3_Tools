/* ---------------------------------------------------------
Function: HBNSGE_fnc_getPos

Description:
	Returns the position of an entity and checks if it is valid.
	If it is not valid, it returns an empty array. So you should
	check for an empty array after using this.
	
Parameters:
	Marker, Object, Location, Group or Position
	
Example:
	_position = (group player) call HBNSGE_fnc_checkPos;
	
Returns:
	Position (AGL) - [X,Y,Z]
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

_pos = _this call CBA_fnc_getPos;
_pos = _pos call HBNSGE_fnc_checkPos;
_pos;