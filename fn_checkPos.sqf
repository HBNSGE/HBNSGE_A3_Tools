/*!
 * \page fnc_checkpos HBNSGE_fnc_checkPos
 * \brief Checks if the given parameter is a valid position array.
 * 
 * If not, it returns and empty array, otherwise it returns the input array if it is valid.
 * 
 * So, after calling this function, you should check for an empty array
 * 
 * \param ANY
 * 
 * \return ARRAY
 * 
 * \par Example
 * \code{.unparsed}
 * _position = _position call HBNSGE_fnc_checkPos;
 * \endcode
 * 
 * \author Buschmann
 * 
 * \since 1.0.0
 */

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