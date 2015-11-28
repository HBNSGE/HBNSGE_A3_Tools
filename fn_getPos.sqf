/*!
 * \page fnc_getpos HBNSGE_fnc_getPos
 * \brief Returns the position of an entity and checks if it is valid.
 *
 * If it is not valid, it returns an empty array. So you should check for an empty array after using this.
 * 
 * \param Marker STRING, OBJECT, position ARRAY, GROUP
 * 
 * \return ARRAY - Position (AGL)
 * 
 * \par Example
 * \code{.unparsed}
 * _position = (group player) call HBNSGE_fnc_checkPos;
 * \endcode
 * 
 * \author Buschmann
 * \since 1.0.0
 */

_pos = _this call CBA_fnc_getPos;
_pos = _pos call HBNSGE_fnc_checkPos;
_pos;