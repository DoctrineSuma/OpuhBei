/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || stat) return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(incapacitated())
		return

	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"] && modifiers["alt"])
		CtrlAltClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		if(modifiers["shift"])
			ShiftMiddleClickOn(A)
		else
			MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	face_atom(A) // change direction to face what you clicked on

	if(control_disabled || !canClick())
		return

	if(multitool_mode && isobj(A))
		var/obj/O = A
		var/datum/extension/interactive/multitool/MT = get_extension(O, /datum/extension/interactive/multitool)
		if(MT)
			MT.interact(aiMulti, src)
			return

	if(silicon_camera.in_camera_mode)
		silicon_camera.camera_mode_off()
		silicon_camera.captureimage(A, usr)
		return

	/*
		AI restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
	else
	*/
	A.add_hiddenprint(src)
	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/MouseDrop() //AI cant user crawl
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/CtrlAltClickOn(atom/A)
	if(!control_disabled && A.AICtrlAltClick(src))
		return
	..()

/mob/living/silicon/ai/ShiftClickOn(atom/A)
	if(!control_disabled && A.AIShiftClick(src))
		return
	..()

/mob/living/silicon/ai/CtrlClickOn(atom/A)
	if(!control_disabled && A.AICtrlClick(src))
		return
	..()

/mob/living/silicon/ai/AltClickOn(atom/A)
	if(!control_disabled && A.AIAltClick(src))
		return
	..()

/mob/living/silicon/ai/MiddleClickOn(atom/A)
	if(!control_disabled && A.AIMiddleClick(src))
		return
	..()

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/

/atom/proc/AICtrlAltClick()

/obj/machinery/door/airlock/AICtrlAltClick() // Electrifies doors.
	if(usr.incapacitated())
		return

	if(!CanUseTopic(usr))
		return

	if(!electrified_until)
		// permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "1"))
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "0"))
	return 1

/atom/proc/AICtrlShiftClick()
	return

/atom/proc/AIShiftClick()
	return

/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(usr.incapacitated())
		return

	if(!CanUseTopic(usr))
		return

	if(density)
		Topic(src, list("command"="open", "activate" = "1"))
	else
		Topic(src, list("command"="open", "activate" = "0"))
	return 1

/atom/proc/AICtrlClick()
	return

/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(usr.incapacitated())
		return

	if(!CanUseTopic(usr))
		return

	if(locked)
		Topic(src, list("command"="bolts", "activate" = "0"))
	else
		Topic(src, list("command"="bolts", "activate" = "1"))
	return 1

/obj/machinery/power/apc/AICtrlClick() // turns off/on APCs.
	if(usr.incapacitated())
		return

	if(!CanUseTopic(usr))
		return

	Topic(src, list("breaker"="1"))
	return 1

/obj/machinery/turret_control_panel/AICtrlClick() //turns off/on Turrets
	if(usr.incapacitated())
		return

	if(world.time >= last_enabled + toggle_cooldown)
		last_enabled = world.time
		enabled = !enabled
		update_turrets()
		update_icon()
	else
		show_splash_text(usr, "Turrets recalibrating!")

	return TRUE

/atom/proc/AIAltClick(atom/A)
	return AltClick(A)

/obj/machinery/turret_control_panel/AIAltClick() //toggles lethal on turrets
	if(usr.incapacitated())
		return

	targeting_settings?.lethal_mode = !targeting_settings?.lethal_mode
	update_turrets()
	return TRUE

/obj/machinery/atmospherics/binary/pump/AIAltClick()
	return AltClick()

/atom/proc/AIMiddleClick(mob/living/silicon/user)
	return 0

/obj/machinery/door/airlock/AIMiddleClick() // Toggles door bolt lights.
	if(usr.incapacitated())
		return
	if(..())
		return

	if(!src.lights)
		Topic(src, list("command"="lights", "activate" = "1"))
	else
		Topic(src, list("command"="lights", "activate" = "0"))
	return 1

//
// Override AdjacentQuick for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (cameranet && cameranet.is_turf_visible(T))

/mob/living/silicon/ai/face_atom(atom/A)
	if(eyeobj)
		eyeobj.face_atom(A)


// QOL feature, clicking on turf can toogle doors
/turf/attack_ai(mob/user)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	// QOL feature, clicking on turf can toogle doors
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.attack_hand(user)
		return TRUE
	var/obj/machinery/door/firedoor/FD = locate(/obj/machinery/door/firedoor) in contents
	if(FD)
		FD.attack_hand(user)
		return TRUE

/turf/AICtrlClick(mob/user)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.AICtrlClick(user)
		return
	return ..()

/turf/AIAltClick(mob/user)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.AIAltClick(user)
		return
	return ..()

/turf/AIShiftClick(mob/user)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.AIShiftClick(user)
		return
	return ..()
