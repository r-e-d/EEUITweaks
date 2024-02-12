`
function priestPageInfo()
	if characters[id].hasShamanBook then
		return t("SPELLS_CAN_CAST_LABEL") .. ": " .. characters[id].priestDetails[currentSpellLevel].slotsRemaining .. "/" .. characters[id].priestDetails[currentSpellLevel].maxMemorized
	else
		return t("MEMORIZED_LABEL") .. ": " .. #bottomSpells .. "/" .. characters[id].priestDetails[currentSpellLevel].maxMemorized
	end
end

function filterMemorizedPriestSpells()
	local out = {}
	currentSpellLevel = math.min(currentSpellLevel, 7)
	for k,v in pairs(characters[id].priestSpells[currentSpellLevel]) do
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

showPriestMemorizationFlash = false

function refreshPriestBook()
	if currentSpellLevel == nil then
		currentSpellLevel = 1
	end
	if characters[id].hasClericBook then
		newBottomSpells = filterMemorizedPriestSpells()
		bottomSpells = newBottomSpells
		bottomSpellsPlaceHolder = makeBlankTable(characters[id].priestDetails[currentSpellLevel].maxMemorized)
	else
		bottomSpells = {}
		bottomSpellsPlaceHolder = {}
	end
end

function setPriestBookLevel(num, noSound)
	currentBookSpell = 0
	if noSound ~= true and num ~= currentSpellLevel then
		Infinity_PlaySound('GAM_06')
	end
	currentSpellLevel = num
	refreshPriestBook()
end

function createPriestMemorizationSparkle(x,y,w,h, fromList, listIndex)
	Infinity_InstanceAnimation("TEMPLATE_priestMemorizationSparkle","FLASHBR",x,y,w,h,fromList,listIndex)
	memorizationFlashes[currentAnimationID][1] = true
	memorizationFlashes[currentAnimationID][3] = false
	currentAnimationID = currentAnimationID + 1
	if currentAnimationID > #(memorizationFlashes) then
		currentAnimationID = 1
	end
end

function unmemorizingPriestSpell(resref)
	createPriestMemorizationSparkle(62 * (cellNumber - 1), 0, 62, 62, 'memorizedListPriest', currentBottomSpell)
end

function removePriestSpell(idx)
	showPriestMemorizationFlash = false
	priestScreen:UnmemorizeSpell(bottomSpells[idx].level, bottomSpells[idx].memorizedIndex)
	Infinity_PlaySound('GAM_44')
end
`
