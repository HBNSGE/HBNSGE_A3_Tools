/*!
 * \page fnc_isweapon HBNSGE_fnc_isWeapon
 *
 * \brief Returns true if the given string belongs to a weapon class.
 *
 * This function checks for weapons that can be used by single soldiers
 * as primary weapon, handgun or launcher.
 *
 * \param STRING - Class name.
 * 
 * \return BOOLEAN - true if the string is a weapon class.
 * 
 * \par Example
 * \code{.unparsed}
 * "LMG_Mk200_F" call HBNSGE_fnc_isWeapon;
 * \endcode
 * 
 * \author Buschmann
 
 * \since 1.0.0
 */
 
if (typeName _this != "STRING") exitWith { false };

private ["_type"];

_type = getNumber (configFile >> "CfgWeapons" >> _this >> "type");
_ret = false;

switch (_type) do {
	case 1;
	case 2;
	case 4: { _ret = true; };
	default { _ret = false; };
};
_ret;