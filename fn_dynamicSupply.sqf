/*!
 * \page fnc_dynamicsuppy HBNSGE_fnc_dynamicSupply
 *
 * \brief Fills a cargo object dynamically with supply materials.
 *
 * Adds ammunition and other supplies to the defined object's cargo space,
 * based on weapons currently in use by the requesting forces.
 *
 * This function only returns weapons like rifles, handguns and launchers. There
 * is no check for duplicate entries in the returned array.
 *
 * \param 0 OBJECT - Object to add the supply (crate, vehicle, etc.).
 * \param 1 OBJECT, GROUP, SIDE, ARRAY - Requesting units. Ammo for the weapons of this unit will be stored in the object.
 * \param 2 NUMBER (optional) - Add medical supplies (default: 1)
 *	\arg \c 0 - no medical supply
 *	\arg \c 1 - ArmA 3 vanilla medical supply
 *	\arg \c 2 - ACE 3 standard medical supply
 *	\arg \c 3 - ACE 3 extended medical supply
 * 
 * \return Nothing
 * 
 * \par Example
 * \code{.unparsed}
 * group player call HBNSGE_fnc_getWeapons;
 * \endcode
 * 
 * \author Buschmann
 *
 * \since 1.0.0
 *
 * \todo Add items for ACE 3 extended medical supply, currently using the same as for basic.
 */

if (!isServer) exitWith{};
private ["_obj", "_requester", "_medical", "_addWeapons", "_addMagazines", "_addItems", "_addBackpacks", "_singleUseMags", "_singleUseWeapons", "_magazines", "_weapons", "_requesterCount"];

_obj			= param [0, objNull, [objNull]];
_requester		= param [1, objNull, [objNull, grpNull, west, []]];
_medical		= param [2, 1, [0]];
_addWeapons		= param [3, [], [[]]];
_addMagazines	= param [4, [], [[]]];
_addItems		= param [5, [], [[]]];
_addBackpacks	= param [6, [], [[]]];

if (isNull _obj) exitWith {};

_requesterCount = count (_requester call HBNSGE_fnc_getUnits);
if (_requesterCount == 0) exitWith{};

// define magazine classes of single use weapons
_singleUseMags = ["BWA3_Pzf3_IT","BWA3_RGW90_HH"];
_singleUseWeapons = [];

clearweaponcargoGlobal _obj;
clearmagazinecargoGlobal _obj;
clearitemcargoGlobal _obj;
clearBackpackCargoGlobal _obj;

// get all weapons of the requesters
_weapons = _requester call HBNSGE_fnc_getWeapons;

// get one random magzine class for each weapon
_magazines = [_weapons,1] call HBNSGE_fnc_getMagazines;

_fn_getSingleUseWeapon = {
	_ret = "";
	switch (_this) do {
		case "BWA3_Pzf3_IT": { _ret = "BWA3_Pzf3_Loaded"; };
		case "BWA3_RGW90_HH": { _ret = "BWA3_RGW90_Loaded"; };
		default { _ret = ""; };
	};
	_ret;
};

// get magazine count based on type, respective usage of cargo space
_fn_getMagCount = {
	private ["_type"];
	_type = getNumber (configfile >> "CfgMagazines" >> _this >> "type");
	_ret = switch (_type) do {
		case 256;
		case 512: { 5 };
		case 768;
		case 1024;
		case 1280;
		case 1536: { 2 };
		default { 1 };
	};
	_ret;
};

if (count _magazines > 0) then {

	// remove the classes of magazines for single use weapons fromo the magazine array
	// and add their respective weapon tot the _singleUseWeapons array
	private ["_magPos", "_magCount"];
	_magPos = 0;
	_magCount = 0;
	{
		while ({_magPos > -1}) do {
			_magPos = _magazines find _x;
			if (_magPos > -1) then {
				_magazines deleteAt _magPos;
				_singleUseWeapons pushBack (_x call _fn_getSingleUseWeapon);
			};
		};
	} forEach _singleUseMags;

	// adds the magazines to the cargo
	{
		_magCount = _x call _fn_getMagCount;
		_obj addMagazineCargoGlobal [_x, _magCount];
	} forEach _magazines;
	
	// adds the single use weapons to the cargo
	if (count _singleUseWeapons > 0) then
	{
		{
			_obj addWeaponCargoGlobal [_x,1];
		} forEach _singleUseWeapons;
	};
};

// add optional additional items to the cargo

if (_medical == 1) then {
	_obj addItemCargoGlobal ["Medikit", 2];
	_obj addItemCargoGlobal ["FirstAidKit", _requesterCount * 3];
};

if (_medical == 2) then {
	_obj addItemCargoGlobal ["ACE_bloodIV_500", _requesterCount];
	_obj addItemCargoGlobal ["ACE_epinephrine", _requesterCount];
	_obj addItemCargoGlobal ["ACE_morphine", _requesterCount * 2];
	_obj addItemCargoGlobal ["ACE_fieldDressing", _requesterCount * 4];
};

if (_medical == 3) then {
	_obj addItemCargoGlobal ["ACE_bloodIV_500", _requesterCount];
	_obj addItemCargoGlobal ["ACE_epinephrine", _requesterCount];
	_obj addItemCargoGlobal ["ACE_morphine", _requesterCount * 2];
	_obj addItemCargoGlobal ["ACE_fieldDressing", _requesterCount * 4];
};

if (count _addWeapons > 0) then {
	{
		_obj addWeaponCargoGlobal [_x, 1];
	} forEach _addWeapons;
};


if (count _addBackpacks > 0) then {
	{
		_obj addBackpackCargoGlobal [_x, 1];
	} forEach _addBackpacks;
};


if (count _addItems > 0) then {
	{
		_obj addItemCargoGlobal [_x, 1];
	} forEach _addItems;
};


if (count _addMagazines > 0) then {
	{
		_obj addMagazineCargoGlobal [_x, 1];
	} forEach _addMagazines;
};
