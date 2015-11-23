/* ---------------------------------------------------------
Function: HBNSGE_fnc_checkPos

Description:
	Checks if the given array is a valid position array.
	If not, it returns an empty array. So after calling
	this function, you should check for an empty array.
	
Parameters:
	Any
	
Example:
	_position = _position call HBNSGE_fnc_checkPos;
	
Returns:
	Position Array - [X,Y,Z]
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

_pos = _this;

if (typeName _pos != "ARRAY") then {
	_pos = [];
};

if ((count _pos) != 3) then {
	_pos = [];
};

if ((count _this) > 0) then {

	_noScalarContent = false;

	{
		if (typeName _x != "SCALAR") then {_noScalarContent = true};
	} forEach _pos;

	if (_noScalarContent) then {
		_pos = [];
	};
};

// let's assume that [0,0,0] mostly is not a wanted position
if ((count _this) > 0) then {

	_onlyZeroContent = 0;
	
	{
		_onlyZeroContent = _onlyZeroContent + _x;
	} forEach _pos;

	if (_onlyZeroContent == 0) then {
		_pos = [];
	};
};

_pos;