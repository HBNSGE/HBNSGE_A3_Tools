/*!
 * \page fnc_getweapons HBNSGE_fnc_getWeapons
 *
 * \brief Returns an array of currently equipped weapon class names for the given unit(s).
 *
 * This function only returns weapons like rifles, handguns and launchers. There
 * is no check for duplicate entries in the returned array.
 *
 * \param OBJECT, GROUP, SIDE, ARRAY - Units to get weapons from.
 * 
 * \return ARRAY - weapon class names
 * 
 * \par Example
 * \code{.unparsed}
 * group player call HBNSGE_fnc_getWeapons;
 * \endcode
 * 
 * \author Buschmann
 
 * \since 1.0.0
 */

private ["_weapons"];

_weapons = [];

// extracts the strings from an array that in fact represents a weapon
_fn_extractWeapons = {
	_wps = [];
	
	{
		if (_x call HBNSGE_fnc_isWeapon) then {
			_wps pushBack _x;
		};
	} forEach _this;
		
	_wps;
};

// get all weapons for a single object
if (typeName _this == "OBJECT") then {
	if (isNull _this) exitWith {};
	_weapons = (weapons _this) call _fn_extractWeapons;
};

// get all weapons of a group
if (typeName _this == "GROUP") then {
	if (isNull _this) exitWith {};
	{
		_weapons append ((weapons _x) call _fn_extractWeapons);
	} forEach units _this;
};

// get all weapons of a side
if (typeName _this == typeName west) then {
	{
		if (side _x == _this) then {
			_weapons append ((weapons _x) call _fn_extractWeapons);
		};
	} forEach allUnits;
}; 


// get all weapons of units in an array
if (typeName _this == "ARRAY") then {
	if ((count _this) == 0) exitWith {};
	{
		if (!isNull _x) then {
			_weapons append ((weapons _x) call _fn_extractWeapons);
		};
	} forEach _this;
};

_weapons;