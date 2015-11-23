/* ---------------------------------------------------------
Function: HBNSGE_fnc_realisticEjection

Description:
	Orders the given group to leave the given vehicle and take radial
	positions around the vehicle.
	
Parameters:
	0: OBJECT - vehicle to leave
	1 (optional): GROUP - group to leave vehicle, if null, all units in cargo will leave.
	2 (optional): NUMBER - radius around vehicle to take positions in
	
Example:
	[_heli, _battleGroup, 7] call HBNSGE_fnc_realisticEjection;
	
Returns:
	Position Array - [X,Y,Z]
	
Author:
	Buschmann
	
Since:
	1.0.0
--------------------------------------------------------- */

private ["_veh","_grp","_cargo","_radius","_destinations","_nearest"];

_veh	= param [0,objNull,[objNull]];
_grp	= param [1,grpNull,[grpNull]];
_radius	= param [2,7,[0]];

if (isNull _veh) exitWith {};

if (isNull _grp) then {
	_cargo = assignedCargo _veh;
	if (count _cargo > 0) then {
		_grp = group (_cargo select 0);
	};
};

if (isNull _grp) exitWith {};

_destinations = [_veh,_grp,_radius,true] call BT_fnc_getRadialPositions;

{
	_nearest = [_x, _destinations] call BT_fnc_getNearest;
	
	[_x,_nearest select 0,"MIDDLE",100,_veh] spawn BT_fnc_leaveAndMove;
	
	_destinations = [_destinations, _nearest select 1] call BIS_fnc_removeIndex;
	
	sleep 2;

} forEach units _grp;



