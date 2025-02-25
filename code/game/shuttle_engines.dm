/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'

/obj/structure/shuttle/window
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "window-whiteship0"
	density = 1
	opacity = 0
	anchored = 1
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/shuttle/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_GLASS)
		return TRUE
	return ..()

/obj/structure/shuttle/engine
	name = "engine"
	density = 1
	anchored = 1.0

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/propulsion/burst
	name = "burst"

/obj/structure/shuttle/engine/propulsion/burst/left
	name = "left"
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	name = "right"
	icon_state = "burst_r"

/obj/structure/shuttle/engine/propulsion/burst/big
	name = "burst"
	icon_state = "thruster_big"
	icon = 'icons/turf/thruster_big.dmi'

/obj/structure/shuttle/engine/propulsion/burst/huge
	name = "burst"
	icon_state = "thruster_huge"
	icon = 'icons/turf/thruster_huge.dmi'

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"
