/// Ranged chain lightning attack. Bounces between up to chain_count extra mobs within chain_range tiles of the initial target.
/datum/targetable/arcfiend/arcFlash
	name = "Arc Flash"
	desc = "Unleash a ranged bolt of electricity towards a creature. Nearby targets will also be shocked by chain lightning, although with reduced effectiveness."
	icon_state = "arcflash"
	cooldown = 12 SECONDS
	pointCost = 50
	target_anything = TRUE
	targeted = TRUE

	/// The amount of power used when shocking a mob.
	var/wattage = 600 KILO WATT
	/// Max range (in tiles) between mobs to chain between.
	var/chain_range = 3
	/// Max number of additional mobs to chain to.
	var/chain_count = 2

	tryCast(atom/target, params)
		if (target == src.holder.owner)
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (!ismob(target))
			boutput(src.holder.owner, SPAN_ALERT("You can only cast this on mobs!"))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (!IN_RANGE(src.holder.owner, target, (WIDE_TILE_WIDTH / 2)))
			boutput(src.holder.owner, SPAN_ALERT("That is too far away!"))
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		return ..()

	cast(atom/target)
		. = ..()
		arcFlash(src.holder.owner, target, src.wattage)

		var/list/exempt_targets = list(src.holder.owner, target)
		var/mob/chain_source = target
		var/mob/chain_target = null
		for (var/i in 1 to src.chain_count)
			var/list/potential_targets = list()
			for (var/mob/M in range(src.chain_range, get_turf(chain_source)))
				if ((M in exempt_targets) || isobserver(M) || isintangible(M))
					continue
				potential_targets.Add(M)
			if (length(potential_targets))
				chain_target = pick(potential_targets)
				exempt_targets += chain_target
			else
				break
			arcFlash(chain_source, chain_target, (src.wattage / (i + 1)))
			logTheThing(LOG_COMBAT, src.holder.owner, "[key_name(src.holder.owner)] hit [key_name(target)] with chain lightning [log_loc(src.holder.owner)].")
			chain_source = chain_target
