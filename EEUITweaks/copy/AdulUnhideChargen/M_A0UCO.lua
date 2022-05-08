-- UNHIDE CHARGEN OPTIONS 1.0

lastChargenClass = nil
lastChargenKit = nil
lastChargenAlignment = nil
allChargenClasses = {}
allChargenAlignments = {}
allChargenProficiencies = {}
allChargenOptionsGenerated = false

function generateAllChargenOptions()
	if (allChargenOptionsGenerated) then return end
	allChargenOptionsGenerated = true
	allChargenClasses = {}
	allChargenAlignments = {}
	allChargenProficiencies = {}
	print_r('Generating all chargen options...')
	createCharScreen:OnMenuButtonClick()							--open gender menu
	toggleMale = 1																		--select male gender
	createCharScreen:OnGenderSelectButtonClick(1)
	Infinity_PopMenu()																--gender menu done
	createCharScreen:OnDoneButtonClick()
	Infinity_PopMenu()																--portrait menu done
	createCharScreen:OnDoneButtonClick()
	createCharScreen:OnMenuButtonClick()							--open race menu
	currentChargenRace = 1														--select human race
	createCharScreen:OnRaceSelectButtonClick(chargen.races[currentChargenRace].id)
	Infinity_PopMenu()																--race menu done
	createCharScreen:OnDoneButtonClick()
	createCharScreen:OnMenuButtonClick()							--open class menu
	currentChargenClass = 1														--select fighter class
	createCharScreen:OnClassSelectButtonClick(chargen.class[currentChargenClass].id)
	createCharScreen:OnDoneButtonClick()							--class menu done
	Infinity_PopMenu('CHARGEN_CLASS')
	Infinity_PopMenu()																--kit menu done
	createCharScreen:OnDoneButtonClick()
	createCharScreen:OnMenuButtonClick()							--open alignment menu
	allChargenAlignments = chargen.alignment					--save alignments
	currentChargenAlignment = 1												--select lawful good alignment
	createCharScreen:OnAlignmentSelectButtonClick(chargen.alignment[currentChargenAlignment].id)
	Infinity_PopMenu()																--alignment menu done
	createCharScreen:OnDoneButtonClick()
	createCharScreen:OnMenuButtonClick()							--open abilities menu
	Infinity_PopMenu()																--abilities menu done
	createCharScreen:OnDoneButtonClick()
	createCharScreen:OnMenuButtonClick()							--open proficiencies menu
	allChargenProficiencies = chargen.proficiency			--save proficiencies
	createCharScreen:OnCancelButtonClick()						--proficiencies menu cancel
	while (createCharScreen:GetCurrentStep() > 3) do createCharScreen:OnMainBackButtonClick() end		--go back to race step
	local knownClasses = {}														--cycle through races
	local raceIndex = 1
	local classIndex = 1
	local kitIndex = 1
	local nextClass = 1
	local tempClass = 1
	while (chargen.races[raceIndex]) do
		createCharScreen:OnMenuButtonClick()									--open race menu
		currentChargenRace = raceIndex												--select race
		createCharScreen:OnRaceSelectButtonClick(chargen.races[currentChargenRace].id)
		Infinity_PopMenu()																		--race menu done
		createCharScreen:OnDoneButtonClick()
		createCharScreen:OnMenuButtonClick()									--open class menu
		classIndex = 1																				--cycle through classes
		while (chargen.class[classIndex]) do
			if (not knownClasses[chargen.class[classIndex].id])	then	--save class
				knownClasses[chargen.class[classIndex].id] = true
				allChargenClasses[nextClass] = chargen.class[classIndex]
				allChargenClasses[nextClass].kits = {}
				allChargenClasses[nextClass].nextKit = 1
				allChargenClasses[nextClass].knownKits = {}
				nextClass = nextClass + 1
			end
			currentChargenClass = classIndex													--select class
			createCharScreen:OnClassSelectButtonClick(chargen.class[currentChargenClass].id)
			createCharScreen:OnDoneButtonClick()											--class menu done
			if (createCharScreen:GetCurrentStep() < 7) then
				Infinity_PopMenu('CHARGEN_CLASS')
				kitIndex = 1																									--cycle through kits
				tempClass = getChargenClassIndex(chargen.class[currentChargenClass].id)
				while (chargen.kit[kitIndex]) do
					if (not allChargenClasses[tempClass].knownKits[chargen.kit[kitIndex].id])	then		--save kit
						allChargenClasses[tempClass].knownKits[chargen.kit[kitIndex].id] = true
						allChargenClasses[tempClass].kits[allChargenClasses[tempClass].nextKit] = chargen.kit[kitIndex]
						allChargenClasses[tempClass].nextKit = allChargenClasses[tempClass].nextKit + 1
					end
					kitIndex = kitIndex + 1
				end
				Infinity_PopMenu()																						--kit menu cancel
				createCharScreen:OnCancelButtonClick()
			else
				createCharScreen:OnMainBackButtonClick()											--go back to class step
				createCharScreen:OnMenuButtonClick()													--open class menu
			end
			classIndex = classIndex + 1
		end
		createCharScreen:OnCancelButtonClick()								--class menu cancel
		Infinity_PopMenu('CHARGEN_CLASS')
		createCharScreen:OnMainBackButtonClick()							--go back to race step
		raceIndex = raceIndex + 1
	end
	createCharScreen:OnMainBackButtonClick()					--go back to gender step
end

function getChargenClassIndex(id)
	local i = 1
	while (allChargenClasses[i]) do
		if (allChargenClasses[i].id == id) then
			return i
		end
		i = i + 1
	end
	return 0
end

function getClassDisabled(id)
	local i = 1
	while (chargen.class[i]) do
		if (chargen.class[i].id == id) then
			return false
		end
		i = i + 1
	end
	return true
end

function getClassHelpText()
	class = allChargenClasses[currentChargenClass]
	if class then
		return Infinity_FetchString(class.desc)
	else
		return Infinity_FetchString(17242)
	end
end

function getKitDisabled(id)
	local i = 1
	while (chargen.kit[i]) do
		if (chargen.kit[i].id == id) then
			return false
		end
		i = i + 1
	end
	return true
end

function getKitHelpText()
	kit = allChargenClasses[currentChargenClass].kits[currentChargenKit]
	if kit then
		return Infinity_FetchString(kit.desc)
	else
		return Infinity_FetchString(17242)
	end
end

function getAlignmentDisabled(id)
	local i = 1
	while (chargen.alignment[i]) do
		if (chargen.alignment[i].id == id) then
			return false
		end
		i = i + 1
	end
	return true
end

function getAlignmentHelpText()
	alignment = allChargenAlignments[currentChargenAlignment]
	if alignment then
		return Infinity_FetchString(alignment.desc)
	else
		return Infinity_FetchString(9602)
	end
end

profRowDict = {}
function translateProficiencyRows()
	profRowDict = {}
	local i = 1
	local j = 1
	while (allChargenProficiencies[i]) do
		j = 1
		while (chargen.proficiency[j]) do
			if (allChargenProficiencies[i].id == chargen.proficiency[j].id) then
				profRowDict[i] = j
				j = 1000
			end
			j = j + 1
		end
		i = i + 1
	end
end

function getTranslatedProficiencyEnabled(row)
	if (not profRowDict) then
		return true
	elseif (profRowDict[row] and chargen.proficiency[profRowDict[row]]) then
		return true
	end
	return false
end

function getTranslatedProficiency(row)
	if (not profRowDict) then
		return chargen.proficiency[row]
	elseif (profRowDict[row] and chargen.proficiency[profRowDict[row]]) then
		return chargen.proficiency[profRowDict[row]]
	end
	return {value = 0, max = 0}
end

function getProficiencyHelpText()
	local prof = allChargenProficiencies[currentChargenProficiency]
	local skill = chargen.thief_skill[currentChargenThiefSkill]
	if prof and prof.desc ~= -1 then
		return Infinity_FetchString(prof.desc)
	elseif skill and skill.desc ~= -1 then
		return Infinity_FetchString(skill.description)
	else
		if(chargen.levelingUp) then
			if(levelUpInfoToggle == 1) then
				return chargen.charInfo
			else
				return chargen.levelInfo
			end
		else
		return Infinity_FetchString(9588)
	end
	end
end

function plusButtonClickable(row)
	if (not profRowDict) then
	elseif (profRowDict[row] and chargen.proficiency[profRowDict[row]]) then
		row = profRowDict[row]
	else
		return false
	end
	local clickable =  (chargen.proficiency[row].value < chargen.proficiency[row].max)
	clickable = clickable and chargen.extraProficiencySlots > 0
	return clickable
end

function minusButtonClickable(row)
	if (not profRowDict) then
	elseif (profRowDict[row] and chargen.proficiency[profRowDict[row]]) then
		row = profRowDict[row]
	else
		return false
	end
	return (chargen.proficiency[row].value > chargen.proficiency[row].min)
end