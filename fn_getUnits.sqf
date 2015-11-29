/*!
 * \page fnc_getunits HBNSGE_fnc_getUnits
 *
 * \brief Returns an array containing all infantry units defined by call parameter
 *
 * \param OBJECT, GROUP, SIDE, ARRAY - Entity to extract units from.
 * 
 * \return ARRAY - weapon class names
 * 
 * \par Example
 * \code{.unparsed}
 * west call HBNSGE_fnc_getUnits;
 * \endcode
 * 
 * \author Buschmann
 
 * \since 1.0.0
 */
 
private ["_units"];
_units = [];

if (typeName _this == typeName objNull) then {
	if (isNull _this) exitWith {[]};
	if (_this isKindOf "Man") then {
		_units = [_this];
	};
};

if (typeName _this == typeName grpNull) then {
	if (isNull _this) exitWith {[]};
	_units = units _this;
};

if (typeName _this == typeName []) then {
	if (count _this > 0) then {
		{
			if (_x isKindOf "Man") then {
				_units pushBack _x;
			};
		} forEach _this;
	};
};

if (typeName _this == typeName west) then {
	{
		if (side _x == _this && _x isKindOf "Man" && !(_x call BIS_fnc_isUnitVirtual) && !(isObjectHidden _x)) then {
			_units pushBack _x;
		};
	} forEach allUnits;
};

_units;
