/*!
 * \page fnc_helilanding HBNSGE_fnc_heliLanding
 *
 * \brief Lands the specified helicopter on the given position.
 *
 * If approach type is "GET OUT", units in cargo will leave the helicopter and group in
 * a circle around the vehicle. If approach type is "GET IN", the helicopter will wait for units to board it.
 *
 * Automatic ejection happens only if the leader of the group in cargo is not a human player.
 *
 * If a flyaway position is set, the helicopter will move to that position after specified group has board or left the vehicle.
 *
 * Units in cargo position have to be assigned to this position.
 * 
 * \param 0 OBJECT - The helicopter to use.
 * \param 1 OBJECT - The destination helipad.
 * \param 2 (optional) STRING - Approach tiype (default: "LAND")
 *	\arg \c "LAND" - Helicopter will land at destination and wait for further orders.
 *	\arg \c "GET IN" - Helicopter will land and wait for units to board it.
 *	\arg GET OUT - Helicopter will land and units in cargo will disembark and group around the heli.
 * \param 3 (optional) - Destination after finishing task.
 *	\arg \c OBJECT - Destination helipad to fly to and land after the landing and boarding or ejection part has finished.
 *	\arg \c ARRAY - Destination position to fly to after the landing and boarding or eection part has finished.
 * \param 4 (optional) NUMBER - Altitude above ground level the ejection or boarding task start (default: 2)
 * \param 5 (optional) GROUP - Group that is in the cargo or that should board the vehicle. If approach is \c "GET IN", group has to be specified. (default: empty)
 * \param 6 (optional) - Callback code that is executed after the helicopter has landed and before the disembarkation or embarkation starts.
 *	\arg \c CODE - Code to execute.
 *	\arg \c STRING - Script file to execute.
 * \param 7 (optional) - Callback code that is executed after the helicopter has reached it's fly away destination.
 *	\arg \c CODE - Code to execute.
 *	\arg \c STRING - Script file to execute.
 * \param 8 (optional) STRING - Marker name. If string is given, an appropriate marker will be create on the destination helipad.
 * \param 9 (optional) STRING - Marker text.
 *
 * \return Script Handle
 * 
 * \par Example
 * \code{.unparsed}
 * [heli1,helipad1,"GET OUT"] spawn HBNSGE_fnc_heliLanding;
 * \endcode
 * 
 * \author Buschmann
 *
 * \since 1.0.0
 */

private ["_heli","_pos","_approach","_height","_flyaway","_grp","_cargo","_leader","_crewCnt","_landCallBack","_flyAwayCallBack","_markerName","_markerText"];

_heli				= param [0,objNull,[objNull]];
_pos				= param [1,objNull,[objNull]];
_approach			= param [2,"LAND",[""]];
_flyaway			= param [3,[],[[],objNull]];
_height				= param [4,2,[0]];
_grp				= param [5,grpNull,[grpNull]];
_landCallBack		= param [6,{},[{},""]];
_flyAwayCallBack	= param [7,{},[{},""]];
_markerName			= param [8,"",[""]];
_markerText			= param [9,"",[""]];

if (isNull _heli) exitWith {["You have to specify a helicopter object."] call BIS_fnc_error;};
if (isNull _pos) exitWith {["You have to specify a destination object."] call BIS_fnc_error;};

if (isNull _grp) then {
	_cargo = assignedCargo _heli;
	if (count _cargo > 0) then {
		_grp = group (_cargo select 0);
	};
} else {
	_cargo = assignedCargo _heli;
};

if (typeName _flyaway != "ARRAY") then {
	if (typeName _flyaway != "OBJECT") exitWith {["_flyaway has to be either an object or a position array."] call BIS_fnc_error;};
	_flyaway = getPos _flyaway;
};

if (_markerName != "") then {
	private ["_mrk","_mrkColor"];
	_mrk = createMarker [_markerName,getPos _pos];
	_mrk setMarkerShape "ICON";
	_mrk setMarkerType "mil_pickup";
	_mrkColor = switch (side _heli) do {
		case west: { "ColorBLUFOR" };
		case east: { "ColorOPFOR" };
		case resistance: { "ColorIndependent" };
		case civilian: { "ColorCivilian" };
		default { "Default" };
	};
	_mrk setMarkerColor _mrkColor;
	if (_markerText != "") then {
		_mrk setMarkerText _markerText;
	};
};

_heli move (getPos _pos);

sleep 3;

while { ( (alive _heli) && !(unitReady _heli) ) } do
{
   sleep 1;
};

if (alive _heli) then
{
   _heli land _approach;
};

if (_approach == "GET OUT") then {
	if (["CfgRadio","BtScriptsHeloGetOutGetReady"] call BIS_fnc_getCfgIsClass) then {
		[[(driver _heli), "BtScriptsHeloGetOutGetReady"],"vehicleRadio",_grp] call BIS_fnc_MP;
	};
};

_heli animateDoor ["Door_L",1,false];
_heli animateDoor ["Door_R",1,false];

while { ((getPos _heli select 2 > _height) && (alive _heli)) } do
{
	sleep 1;
};

if (typeName _landCallBack == "CODE") then {
	[_heli] call _landCallBack;
} else {
	if (_landCallBack != "") then {
		_null = execVM _landCallBack;
	};
};

if (alive _heli) then {

	_crewCnt = count (crew _heli);

	if (_approach == "GET OUT") then
	{
		_leader = leader _grp;
		_crewCnt = _crewCnt - (count _cargo);
		
		_heli flyInHeight 0;
	
		if (count _flyaway == 0) then {
			_heli engineOn false;
		};
		
		if (["CfgRadio","BtScriptsHeloGetOutGo"] call BIS_fnc_getCfgIsClass) then {
			[[(driver _heli), "BtScriptsHeloGetOutGo"],"vehicleRadio",_grp] call BIS_fnc_MP;
		};

		if ((!isPlayer _leader) && (!isNull _grp)) then {
			_ejectHandler = [_heli,_grp] spawn BT_fnc_realisticEjection;
			while { (count (crew _heli)) > (_crewCnt) } do {sleep 1; };
			sleep 10;
		};

		if ((isPlayer _leader) && (!isNull _grp)) then {
			while { (count (crew _heli)) > (_crewCnt) } do {sleep 1; };
			{unassignVehicle _x} forEach units _grp;
			sleep 10;
		};

		if (count _flyaway > 1) then {
			_heli animateDoor ["Door_L",0,false];
			_heli animateDoor ["Door_R",0,false];
			_heli flyInHeight 40;
			_heli move _flyaway;
			
			if (typeName _flyAwayCallBack == "CODE") then {
				while { ( (alive _heli) && !(unitReady _heli) ) } do { sleep 1; };
				[_heli] call _flyAwayCallBack;
			} else {
				if (_flyAwayCallBack != "") then {
					while { ( (alive _heli) && !(unitReady _heli) ) } do { sleep 1; };
					_null = execVM _flyAwayCallBack;
				};
			};
		};
	};
	
	if (_approach == "GET IN") then
	{
		_leader = leader _grp;
	
		if (count _flyaway == 0) then {
			_heli engineOn false;
		} else {
		
			sleep 3;
		
			if (isPlayer _leader) then {
			
			} else {
			
				private ["_enterWp"];
				
				{ _x assignAsCargo _heli } forEach units _grp;
				
				_enterWp = _grp addWaypoint [_heli,0];
				_enterWp setWaypointType "GETIN";
				_grp setCurrentWaypoint _enterWp;
			};
			
			if (count _flyaway > 1) then {
		
				waitUntil { (count (crew _heli) == (_crewCnt + (count (units _grp)))) };
			
				_heli animateDoor ["Door_L",0,false];
				_heli animateDoor ["Door_R",0,false];
				_heli flyInHeight 40;
				_heli move _flyaway;
				
				if (typeName _flyAwayCallBack == "CODE") then {
					while { ( (alive _heli) && !(unitReady _heli) ) } do { sleep 1; };
					[_heli] call _flyAwayCallBack;
				} else {
					if (_flyAwayCallBack != "") then {
						while { ( (alive _heli) && !(unitReady _heli) ) } do { sleep 1; };
						_null = execVM _flyAwayCallBack;
					};
				};
			};
		};
	};
};