if (!isServer) exitWith {};

private ["_veh", "_parachute", "_altitude"];

_veh = param [0,objNull,[objNull]];
_altitude = param [1, 300, [1]];

if (isNull _veh) exitWith { echo "No vehicle given."; };

_veh setPos
[
	getPos _veh select 0,
	getPos _veh select 1,
	_altitude
];

_parachute = createVehicle ["B_Parachute_02_F", [0,0,0], [], 0, "FLY"];
_parachute setDir (getDir _veh);
_parachute setPos (getPos _veh);

_veh attachTo [_parachute, [0,2,0]];