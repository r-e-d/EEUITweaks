`
function magePageInfo()
	if bookMode == 0 then -- Regular
		if characters[id].hasSorcererBook then
			return t("SPELLS_CAN_CAST_LABEL") .. ": " .. characters[id].mageDetails[currentSpellLevel].slotsRemaining .. "/" .. characters[id].mageDetails[currentSpellLevel].maxMemorized
		else
			return t("MEMORIZED_LABEL") .. ": " .. #bottomSpells .. "/" .. characters[id].mageDetails[currentSpellLevel].maxMemorized
		end
	elseif bookMode == 1 then -- Sequencer/Contingency
		return t("SPELLS_LABEL") .. " :" .. #bottomSpells .. "/" .. #bottomSpellsPlaceHolder
	end
	return ""
end

mageBookStrings = {
	SPWI908 = {tip = engine_mode == 0 and 24615 or 55373, title = 'CHAIN_CONTINGENCY_TITLE', action = "ADD_SPELLS_CONTINGENCY_LABEL"},
	SPWI617 = {tip = engine_mode == 0 and 24615 or 55373, title = 'CONTINGENCY_TITLE', action = "ADD_SPELLS_CONTINGENCY_LABEL"},
	SPWI809 = {tip = engine_mode == 0 and 24617 or 55372, title = 'SPELL_TRIGGER_TITLE', action = "ADD_SPELLS_TRIGGER_LABEL"},
	SPWI710 = {tip = engine_mode == 0 and 24616 or 60420, title = 'SPELL_SEQUENCER_TITLE', action = "ADD_SPELLS_SEQUENCER_LABEL"},
	SPWI420 = {tip = engine_mode == 0 and 24616 or 60420, title = 'MINOR_SEQUENCER_TITLE', action = "ADD_SPELLS_SEQUENCER_LABEL"},
}

contingencyDescription = 0

function mageBookTitle()
	if bookMode == 1 and mageBookStrings[contingencyResRef] then
		return t(mageBookStrings[contingencyResRef].title)
	end
	return t('MAGE_SPELLS_TITLE')
end
function mageBookAction()
	if bookMode == 1 and mageBookStrings[contingencyResRef] then
		return t(mageBookStrings[contingencyResRef].action)
	end
	return characters[id].name
end

function makeBlankTable(num)
	local out = {}
	for i = 1,num do
		table.insert(out, {})
	end
	return out
end

function contingencyComplete()
	if showContingency then
		return #bottomSpells == #bottomSpellsPlaceHolder and (currentContingencyCondition or 0) > 0 and (currentContingencyTarget or 0) > 0
	end
	return #bottomSpells == #bottomSpellsPlaceHolder
end

function getSpellOpacity(num)
	if bottomSpells[num].castable == 0 then
		return 100
	end
	return 255
end

function getSpellHighlight(num)
	if currentSpellLevel == num then
		return 2
	end
	return 0
end

function filterMemorizedMageSpells()
	local out = {}
	currentSpellLevel = math.min(currentSpellLevel, 9)
	for k,v in pairs(characters[id].mageSpells[currentSpellLevel]) do
		for i=v.memorizedCount, 1, -1 do
			local spell = deepcopy(v)
			if(i <= v.castableCount) then
				spell.castable = 1
			else
				spell.castable = 0
			end
			table.insert(out, spell)
		end
	end
	return out
end

function filterContingencyMageSpells()
	local out = {}
	if characters[id].mageSpells ~= nil and characters[id].mageSpells[currentSpellLevel] ~= nil then
		for k,v in pairs(characters[id].mageSpells[currentSpellLevel]) do
			if v.castableCount > 0 and mageScreen:SpellAllowedForContingency(v.level, v.resref) then
				table.insert(out, v)
			end
		end
	end
	if characters[id].priestSpells ~= nil and characters[id].priestSpells[currentSpellLevel] ~= nil then
		for k,v in pairs(characters[id].priestSpells[currentSpellLevel]) do
			if v.castableCount > 0 and mageScreen:SpellAllowedForContingency(v.level, v.resref) then
				table.insert(out, v)
			end
		end
	end
	return out
end

function findFirstDifferenceInSpellList(oldList, newList)
	local ret = -1
	local spellIndex = 1

	if oldList ~= nil and newList ~= nil then
		while oldList[spellIndex] ~= nil do
			if newList[spellIndex] == nil then
				ret = spellIndex
				break
			end
			if oldList[spellIndex].icon ~= newList[spellIndex].icon then
				ret = spellIndex
				break
			end
			spellIndex = spellIndex + 1
		end
		if oldList[spellIndex] == nil and newList[spellIndex] ~= nil then
			ret = spellIndex
		end
	end

	return ret
end

selectedSpell = nil
showMageMemorizationFlash = false

function refreshMageBook()
	if currentSpellLevel == nil then
		currentSpellLevel = 1
	end
	if bookMode == 0 then
		if characters[id].hasMageBook then
			bookSpells = characters[id].mageSpells[currentSpellLevel]
			newBottomSpells = filterMemorizedMageSpells()
			bottomSpells = newBottomSpells
			bottomSpellsPlaceHolder = makeBlankTable(characters[id].mageDetails[currentSpellLevel].maxMemorized)
		else
			bookSpells = characters[id].mageSpells[currentSpellLevel]
			bottomSpells = {}
			bottomSpellsPlaceHolder = {}
		end
	elseif bookMode == 1 then
		bookSpells = filterContingencyMageSpells()
		bottomSpells = sequencerSpells
		bottomSpellsPlaceHolder = makeBlankTable(contingencyMaxSpells)
		contingencyDescription = mageBookStrings[contingencyResRef].tip
	end
end

function setMageBookLevel(num, noSound)
	currentBookSpell = 0
	if noSound ~= true and num ~= currentSpellLevel then
		Infinity_PlaySound('GAM_05')
	end
	currentSpellLevel = num
	mageScreen:SetSpellLevel(num - 1)
	refreshMageBook()
end

currentAnimationID = 1
updateCounterMemorizationSparkles = 1

function updateMemorizationSparkles()
	local sparkleNumber = 1
	updateCounterMemorizationSparkles = updateCounterMemorizationSparkles + 1
	if updateCounterMemorizationSparkles > 2 then
		updateCounterMemorizationSparkles = 1
		for sparkleNumber = 1, #(memorizationFlashes), 1 do
			if memorizationFlashes[sparkleNumber][1] == true then
				memorizationFlashes[sparkleNumber][2] = memorizationFlashes[sparkleNumber][2] + 1
				if memorizationFlashes[sparkleNumber][2] > 7 then
					memorizationFlashes[sparkleNumber][1] = false
					memorizationFlashes[sparkleNumber][2] = 0
					memorizationFlashes[sparkleNumber][3] = true
				end
			end
		end
	end
end

function destroyMemorizationSparkle(instanceId)
	local ret = memorizationFlashes[instanceId][3]
	memorizationFlashes[instanceId][3] = false
	return ret
end

function showMemorizationSparkle(instanceId)
	updateMemorizationSparkles()
	return memorizationFlashes[instanceId][1]
end

function createMageMemorizationSparkle(x,y,w,h, fromList, listIndex)
	Infinity_InstanceAnimation("TEMPLATE_mageMemorizationSparkle","FLASHBR",x,y,w,h,fromList,listIndex)
	memorizationFlashes[currentAnimationID][1] = true
	memorizationFlashes[currentAnimationID][3] = false
	currentAnimationID = currentAnimationID + 1
	if currentAnimationID > #(memorizationFlashes) then
		currentAnimationID = 1
	end
end

function unmemorizingMageSpell(resref)
	createMageMemorizationSparkle(62 * (cellNumber - 1), 0, 62, 62, 'memorizedListMage', currentBottomSpell)
	Infinity_PlaySound('GAM_44')
end

function removeMageSpell(idx)
	showMageMemorizationFlash = false
	mageScreen:UnmemorizeSpell(bottomSpells[idx].level, bottomSpells[idx].memorizedIndex)
end

function spellTooltip(spells, cellNumber)
	local idx = 4 * (currentBookSpell - 1) + cellNumber
	if spells[idx] then
		return Infinity_FetchString(spells[idx].name)
	end
	return ''
end

memorizationFlashes =
{
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false},
	{false, 0, false}
}
function makeTable(length)
	local t = {}
	for i=1,length do
		table.insert(t, 1, '')
	end
	return t
end

fontcolors['D'] = 'FFA9D4FF'
fontcolors['S'] = 'FF0066FF'
fontcolors['H'] = 'FF00B7FF'
`
