/*!
 * \page fnc_leaveandmove HBNSGE_fnc_leaveAndMove
 *
 * \brief Order the given unit to leave the current vehicle and move to a position on which it stops in the given position until the given condition is met.
 * 
 * \param 0 OBJECT - The unit that should leave the vehicle and move to the destination position.
 * \param 1 ARRAY - The destination position the unit should move to.
 * \param 2 STRING (optional) - The standing position the unit should take when reaching the destination ("UP", "DOWN", "MIDDLE",...)
 * \param 3 NUMBER (optional) - If vehicle is given in parameter 4, the unit will wait on the given destination until the distance to the given vehicle is greater that this number. If no vehicle is given, the unit will stay for this number in seconds.
 * \param 4 OBJECT (optional) - The vehicle mentioned in (3). Should be the vehicle the unit left, but can also be any other object. If not null, the unit will stay on its postion until the distance between unit and this object is greater than the number given in parameter 3 in meters.
 * 
 * \return Script Handle
 * 
 * \par Example
 * \code{.unparsed}
 * _scriptHandle = [soldier, [123456,111222,0],"MIDDLE",75,heli] spawn HBNSGE_fnc_leaveAndMove;
 * \endcode
 * 
 * \author Buschmann
 *
 * \since 1.0.0
 */

private ["_unit","_destination","_unitPos","_condition","_vehicle"];

_unit			= param [0,objNull,[objNull]];
_destination	= param [1,[],[[]]];
_unitPos		= param [2,"",[""]];
_condition		= param [3,0,[0]];
_vehicle		= param [4,objNull,[objNull]];

if ((leader _unit == _unit) && (isPlayer _unit)) exitWith {};

unassignVehicle _unit;

if (isPlayer _unit) then {
	_unit commandMove _destination;
} else {
	_unit doMove _destination;
};

waitUntil {unitReady _unit};

if (!(leader _unit == _unit)) then {
	doStop _unit;
};

if (_unitPos != "") then {
	_unit setUnitPos _unitPos;
};

if (_condition > 0 && !(isPlayer leader _unit)) then {
	if (isNull _vehicle) then {
		sleep _condition;
	} else {
		waitUntil {(_unit distance _vehicle) > _condition}
	};
	
	_unit setUnitPos "AUTO";
	if (_unit != leader _unit) then {
		if (isPlayer _unit) then {
			_unit commandFollow leader _unit;
		} else {
			_unit doFollow leader _unit;
		};
	};
};