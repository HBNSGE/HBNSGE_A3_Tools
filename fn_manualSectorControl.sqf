/*!
 * \page fnc_manualsectorcontrol HBNSGE_fnc_manualSectorControl
 * \brief Places a laptop on the position of a sector module to seize the sector manually.
 * 
 * The laptop gets an action to take control over the sector, so it is not sufficient
 * to place units in the sector but one has to take over control manually at the laptop.
 *
 * Placement and direction of the laptop are taken from the Sector Control module values.
 *
 * Should be placed in the init line of a sector module.
 *
 * \param 0 OBJECT - Sector module/logic
 * \param 1 BOOLEAN - If true, a camo tent will be placed, too. (default: false)
 *
 * \return Nothing
 * 
 * \par Example
 * \code{.unparsed}
 * [this, true] call HBNSGE_fnc_manualSectorControl;
 * \endcode
 * 
 * \author Buschmann
 * 
 * \since 1.0.0
 */

if (!isServer) exitWith {};
 
private ["_logic", "_logicParent","_table","_laptop","_buildTent"];

_logic		= param [0, objNull, [objNull]];
_buildTent	= param [1, false, [false]];

if (isNull _logic) exitWith {};
if ((typeOf _logic != "ModuleSector_F") && (typeOf _logic != "ModuleSectorDummy_F")) exitWith {};

_logicParent = _logic;
if (typeOf _logic == "ModuleSectorDummy_F") then {
	{
		if (typeOf _x == "ModuleSector_F") then {_logicParent = _x;};
	} foreach (synchronizedobjects _logic);
};

_logicParent setVariable ["CostInfantry", "0.0001", true];
_logicParent setVariable ["CostWheeled", "0.0001", true];
_logicParent setVariable ["CostTracked", "0.0001", true];
_logicParent setVariable ["CostWater", "0.0001", true];
_logicParent setVariable ["CostAir", "0.0001", true];
_logicParent setVariable ["CostPlayers", "0.0001", true];

// _table = "Land_CampingTable_F" createVehicle position _logic;
_table = createVehicle ["Land_CampingTable_F", position _logic, [], 0, "CAN_COLLIDE"];
_table setDir (getDir _logic);
_table allowDamage false;
_table enableSimulation false;

_laptop = "Land_Laptop_unfolded_F" createVehicle position _table;
_laptop attachTo [_table, [0,0,0.56]];
_laptop allowDamage false;
_laptop enableSimulation false;

// _laptop addAction ["Take control", {[_this select 3, side (_this select 1)] call BIS_fnc_moduleSector}, _logicParent, 6, true, true, "", "(vehicle _this == _this) AND ((_target distance2D _this) < 2)"];

[_laptop, ["Take control", {[_this select 3, side (_this select 1)] call BIS_fnc_moduleSector}, _logicParent, 6, true, true, "", "(vehicle _this == _this) AND ((_target distance2D _this) < 2)"]] remoteExecCall ["addAction", 0, true];

if (_buildTent) then {
	private ["_tent", "_logicPos"];
	_logicPos = position _logic;
	_tent = createVehicle ["CamoNet_INDP_open_F", position _table, [], 0, "CAN_COLLIDE"];
	_tent setDir (getDir _logic);
};
