/*!
 * \page fnc_getmagazines HBNSGE_fnc_getMagazines
 *
 * \brief Returns an array of magazine class names for the given weapon class names.
 *
 * \param 0 ARRAY - Weapon class names.
 * \param 1 NUMBER - Select option.
 *	\arg \c 0 - Select the first magazine class.
 *	\arg \c 1 - Select a random magazine class.
 *	\arg \c 2 - Select all magazine classes.
 * 
 * \return ARRAY - Magazine class names.
 * 
 * \par Example
 * \code{.unparsed}
 * _mags = [["srifle_GM6_LRPS_F", "hgun_Pistol_heavy_01_MRD_F"], 1] call HBNSGE_fnc_getMagazines;
 * \endcode
 * 
 * \author Buschmann
 
 * \since 1.0.0
 */

if (typeName _this != "ARRAY") exitWith {};
if ((count _this) == 0) exitWith {};

private ["_weapons", "_selectOption", "_magazines", "_magazineClasses", "_weaponExists"];

_weapons		= param [0, [], [[]]];
_selectOption	= param [1, 0, [0]];

if ((count _weapons) == 0) exitWith {};

_magazines = [];

{
	_weaponExists = isClass (configFile >> "CfgWeapons" >> _x);
	_magazineClasses = getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
	
	if (count _magazineClasses > 0 && _weaponExists) then {
	
		if (_selectOption == 0) then {
			_magazines pushBack (_magazineClasses select 0);
		};
	
		if (_selectOption == 1) then {
			_magazines pushBack (_magazineClasses call BIS_fnc_selectRandom);
		};
		
		if (_selectOption == 2) then {
			_magazines append _magazineClasses;
		};
	}
	
} forEach _weapons;

_magazines;