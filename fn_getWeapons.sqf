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

private ["_weapons", "_units"];

_weapons = [];
_units = _this call HBNSGE_fnc_getUnits;

if (count _units == 0) exitWith {[]};

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

{
	_weapons append ((weapons _x) call _fn_extractWeapons);
} forEach _units;

_weapons;
