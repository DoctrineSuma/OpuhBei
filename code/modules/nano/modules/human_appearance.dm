/datum/nano_module/appearance_changer
	name = "Appearance Editor"
	available_to_ai = FALSE
	var/flags = APPEARANCE_ALL_HAIR
	var/mob/living/carbon/human/owner = null
	var/list/valid_species = list()
	var/list/valid_hairstyles = list()
	var/list/valid_facial_hairstyles = list()

	var/check_whitelist
	var/list/whitelist
	var/list/blacklist

/datum/nano_module/appearance_changer/New(location, mob/living/carbon/human/H, check_species_whitelist = 1, list/species_whitelist = list(), list/species_blacklist = list())
	..()
	owner = H
	src.check_whitelist = check_species_whitelist
	src.whitelist = species_whitelist
	src.blacklist = species_blacklist

/datum/nano_module/appearance_changer/Topic(ref, href_list, datum/topic_state/state = GLOB.default_state)
	if(..())
		return 1

	if(href_list["race"])
		if(can_change(APPEARANCE_RACE) && (href_list["race"] in valid_species))
			if(owner.change_species(href_list["race"]))
				cut_and_generate_data()
				return 1
	if(href_list["gender"])
		if(can_change(APPEARANCE_GENDER) && (href_list["gender"] in owner.species.genders))
			if(owner.change_gender(href_list["gender"]))
				owner.sanitize_body()
				cut_and_generate_data()
				return 1
	if(href_list["bodybuild"])
		if(can_change(APPEARANCE_BODY_BUILD))
			var/body_builds = owner.species.get_body_build_datum_list(owner.gender)
			var/new_body_build = input(usr, "Choose your character's body build:", "Body Build", null) as null|anything in body_builds
			if(new_body_build && can_still_topic(state))
				if(owner.change_body_build(new_body_build))
					return 1
	if(href_list["skin_tone"])
		if(can_change_skin_tone())
			var/new_s_tone = input(usr, "Choose your character's skin-tone:\n1 (lighter) - [owner.species.max_skin_tone()] (darker)", "Skin Tone", -owner.s_tone + 35) as num|null
			if(isnum(new_s_tone) && can_still_topic(state) && owner.species.species_appearance_flags & HAS_SKIN_TONE_NORMAL)
				new_s_tone = 35 - max(min(round(new_s_tone), owner.species.max_skin_tone()), 1)
				return owner.change_skin_tone(new_s_tone)
	if(href_list["skin_color"])
		if(can_change_skin_color())
			var/new_skin = tgui_color_picker(usr, "Choose your character's skin colour: ", "Skin Color", rgb(owner.r_skin, owner.g_skin, owner.b_skin))
			if(new_skin && can_still_topic(state))
				var/r_skin = hex2num(copytext(new_skin, 2, 4))
				var/g_skin = hex2num(copytext(new_skin, 4, 6))
				var/b_skin = hex2num(copytext(new_skin, 6, 8))
				if(owner.change_skin_color(r_skin, g_skin, b_skin))
					update_dna()
					return 1
	if(href_list["hair"])
		if(can_change(APPEARANCE_HAIR) && (href_list["hair"] in valid_hairstyles))
			if(owner.change_hair(href_list["hair"]))
				update_dna()
				return 1
	if(href_list["hair_color"])
		if(can_change(APPEARANCE_HAIR_COLOR))
			var/new_hair = tgui_color_picker(usr, "Please select hair color.", "Hair Color", rgb(owner.r_hair, owner.g_hair, owner.b_hair))
			if(new_hair && can_still_topic(state))
				var/r_hair = hex2num(copytext(new_hair, 2, 4))
				var/g_hair = hex2num(copytext(new_hair, 4, 6))
				var/b_hair = hex2num(copytext(new_hair, 6, 8))
				if(owner.change_hair_color(r_hair, g_hair, b_hair))
					update_dna()
					return 1
	if(href_list["hair_s_color"])
		if(can_change(APPEARANCE_HAIR_COLOR))
			var/new_hair = tgui_color_picker(usr, "Please select secoundary hair color.", "Secondary Hair Color", rgb(owner.r_hair, owner.g_hair, owner.b_hair))
			if(new_hair && can_still_topic(state))
				var/r_hair = hex2num(copytext(new_hair, 2, 4))
				var/g_hair = hex2num(copytext(new_hair, 4, 6))
				var/b_hair = hex2num(copytext(new_hair, 6, 8))
				if(owner.change_s_hair_color(r_hair, g_hair, b_hair))
					update_dna()
					return 1
	if(href_list["facial_hair"])
		if(can_change(APPEARANCE_FACIAL_HAIR) && (href_list["facial_hair"] in valid_facial_hairstyles))
			if(owner.change_facial_hair(href_list["facial_hair"]))
				update_dna()
				return 1
	if(href_list["facial_hair_color"])
		if(can_change(APPEARANCE_FACIAL_HAIR_COLOR))
			var/new_facial = tgui_color_picker(usr, "Please select facial hair color.", "Facial Hair Color", rgb(owner.r_facial, owner.g_facial, owner.b_facial))
			if(new_facial && can_still_topic(state))
				var/r_facial = hex2num(copytext(new_facial, 2, 4))
				var/g_facial = hex2num(copytext(new_facial, 4, 6))
				var/b_facial = hex2num(copytext(new_facial, 6, 8))
				if(owner.change_facial_hair_color(r_facial, g_facial, b_facial))
					update_dna()
					return 1
	if(href_list["eye_color"])
		if(can_change(APPEARANCE_EYE_COLOR))
			var/new_eyes = tgui_color_picker(usr, "Please select eye color.", "Eye Color", rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes))
			if(new_eyes && can_still_topic(state))
				var/r_eyes = hex2num(copytext(new_eyes, 2, 4))
				var/g_eyes = hex2num(copytext(new_eyes, 4, 6))
				var/b_eyes = hex2num(copytext(new_eyes, 6, 8))
				if(owner.change_eye_color(r_eyes, g_eyes, b_eyes))
					update_dna()
					return 1

	return 0

/datum/nano_module/appearance_changer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	if(!owner || !owner.species)
		return

	generate_data(check_whitelist, whitelist, blacklist)
	var/list/data = host.initial_data()

	data["specimen"] = owner.species.name
	data["gender"] = owner.gender
	data["body_build"] = owner.body_build
	data["change_race"] = can_change(APPEARANCE_RACE)
	if(data["change_race"])
		var/species[0]
		for(var/specimen in valid_species)
			species[++species.len] =  list("specimen" = specimen)
		data["species"] = species

	data["change_gender"] = can_change(APPEARANCE_GENDER)
	if(data["change_gender"])
		var/genders[0]
		for(var/gender in owner.species.genders)
			genders[++genders.len] =  list("gender_name" = gender2text(gender), "gender_key" = gender)
		data["genders"] = genders
	data["change_body_build"] = can_change(APPEARANCE_BODY_BUILD)
	data["change_skin_tone"] = can_change_skin_tone()
	data["change_skin_color"] = can_change_skin_color()
	data["change_eye_color"] = can_change(APPEARANCE_EYE_COLOR)
	data["change_hair"] = can_change(APPEARANCE_HAIR)
	if(data["change_hair"])
		var/hair_styles[0]
		for(var/hair_style in valid_hairstyles)
			hair_styles[++hair_styles.len] = list("hairstyle" = hair_style)
		data["hair_styles"] = hair_styles
		data["hair_style"] = owner.h_style

	data["change_facial_hair"] = can_change(APPEARANCE_FACIAL_HAIR)
	if(data["change_facial_hair"])
		var/facial_hair_styles[0]
		for(var/facial_hair_style in valid_facial_hairstyles)
			facial_hair_styles[++facial_hair_styles.len] = list("facialhairstyle" = facial_hair_style)
		data["facial_hair_styles"] = facial_hair_styles
		data["facial_hair_style"] = owner.f_style

	data["change_hair_color"] = can_change(APPEARANCE_HAIR_COLOR)
	data["change_facial_hair_color"] = can_change(APPEARANCE_FACIAL_HAIR_COLOR)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "appearance_changer.tmpl", "[src]", 800, 450, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/appearance_changer/proc/update_dna()
	if(owner && (flags & APPEARANCE_UPDATE_DNA))
		owner.update_dna()

/datum/nano_module/appearance_changer/proc/can_change(flag)
	return owner && (flags & flag)

/datum/nano_module/appearance_changer/proc/can_change_skin_tone()
	return owner && (flags & APPEARANCE_SKIN) && owner.species.species_appearance_flags & HAS_A_SKIN_TONE

/datum/nano_module/appearance_changer/proc/can_change_skin_color()
	return owner && (flags & APPEARANCE_SKIN) && owner.species.species_appearance_flags & HAS_SKIN_COLOR

/datum/nano_module/appearance_changer/proc/cut_and_generate_data()
	// Making the assumption that the available species remain constant
	valid_facial_hairstyles.Cut()
	valid_facial_hairstyles.Cut()
	generate_data()

/datum/nano_module/appearance_changer/proc/generate_data()
	if(!owner)
		return
	if(!valid_species.len)
		valid_species = owner.generate_valid_species(check_whitelist, whitelist, blacklist)
	if(!valid_hairstyles.len || !valid_facial_hairstyles.len)
		valid_hairstyles = owner.generate_valid_hairstyles(check_gender = 0)
		valid_facial_hairstyles = owner.generate_valid_facial_hairstyles()
