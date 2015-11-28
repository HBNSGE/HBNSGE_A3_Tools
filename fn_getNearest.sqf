/*!
 * \page fnc_getnearest HBNSGE_fnc_getNearest
 * \brief Returns the nearest position out of an array of positions compared to object's position.
 * 
 * \param 0 OBJECT - Any object.
 * \param 1 ARRAY of ARRAYs - List of positions.
 * 
 * \return ARRAY
 *	\arg \c 0 - nearest position
 *	\arg \c 1 - index of this position in the checked array
 * 
 * \par Example
 * \code{.unparsed}
 * _nearestPos = [player, [[1,2,3],[4,5,6],[7,8,9],[10,11,12]]] call HBNSGE_fnc_getNearest;
 * \endcode
 * 
 * \author Buschmann
 * \since 1.0.0
 */
 
private ["_obj","_positions","_nearest","_distance","_dist","_idx"];

_obj		= param [0, objNull, [objNull]];
_positions	= param [1, [], [[]]];

if (isNull _obj) exitWith {};
if (count _positions == 0) exitWith {};

_nearest = [];
_distance = 100000;
_idx = 0;

{
	_dist = (_obj distance _x);
	if (_dist <  _distance) then {
		_distance = _dist;
		_nearest = _x;
		_idx = _forEachIndex;
	};
} forEach _positions;

[_nearest,_idx];