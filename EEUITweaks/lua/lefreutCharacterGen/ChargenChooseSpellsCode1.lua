`
function specialistFrame(num)
	if spellBook[chargen.currentSpellLevelChoice][chargen.choose_spell[num].key].specialist then
		return 3
	end
	return 0
end
function specialistOrSelectedFrame(num)
	if chargen.choose_spell[rowNumber].known then
		return 4
	end
	if chargen.choose_spell[rowNumber].enabled then
		return 2
	end
	return specialistFrame(num)
end

function chooseSpellOrGeneralHelp()
	if needSpecialist then
		return Infinity_FetchString(engine_mode == 0 and 24318 or 33381)
	end
	local spell = chargen.choose_spell[currentChargenChooseMageSpell]
	if spell then
		local desc = spellBook[chargen.currentSpellLevelChoice][spell.key].desc
		if desc ~= -1 then
			return Infinity_FetchString(desc)
		end
	end
	return Infinity_FetchString(engine_mode == 0 and 24314 or 17250)
end

function nextOrDone()
	if(createCharScreen:HasMoreMageLevels()) then
		return t('NEXT_BUTTON')
	else
		return t('DONE_BUTTON')
	end
end

function autopickSpells()
	local spells = {table.unpack(chargen.choose_spell)}
	local rnd = {}
	for k, v in pairs(spells) do
		local spell = spellBook[chargen.currentSpellLevelChoice][v.key]
		local nb = (spell.autopick and 2 or 0) + (spell.specialist and 1 or 0)
		rnd[spell.name] = math.random() + nb
		v.k = k
	end

	table.sort(spells,
		function(v1, v2)
			local s1 = spellBook[chargen.currentSpellLevelChoice][v1.key]
			local s2 = spellBook[chargen.currentSpellLevelChoice][v2.key]
			return rnd[s1.name] > rnd[s2.name]
		end)
	for _, v in pairs(spells) do
		local spell = spellBook[chargen.currentSpellLevelChoice][v.key]
		if not v.enabled and chargen.extraSpells > 0 then
			createCharScreen:OnLearnMageSpellButtonClick(v.k)
			if chargen.extraSpells == 0 and not createCharScreen:IsDoneButtonClickable() then
				createCharScreen:OnLearnMageSpellButtonClick(v.k)
			end
		end
	end
end
`
