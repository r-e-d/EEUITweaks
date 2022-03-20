`
function reinitQuests()
	for questIdx, quest in pairs(quests) do
		local noquest = true
		for objIdx,objective in pairs(quest.objectives) do
			local noobjective = true
			for entryIdx,entry in pairs(objective.entries) do
				if quests[questIdx].objectives[objIdx].entries[entryIdx].stateType ~= const.ENTRY_TYPE_NONE and quests[questIdx].objectives[objIdx].entries[entryIdx].stateType ~= nil then
					noobjective = false
				end
			end
			if noobjective then
				quests[questIdx].objectives[objIdx].stateType = const.ENTRY_TYPE_NONE
			end
			if quests[questIdx].objectives[objIdx].stateType ~= const.ENTRY_TYPE_NONE and quests[questIdx].objectives[objIdx].stateType ~= nil then
				noquest = false
			end
		end
		if noquest then
			quests[questIdx].stateType = const.ENTRY_TYPE_NONE
		end
	end
end
function initQuests()
	--instead of always searching the quests, just map entry ids to their quests
	entryToQuest = {}
	buildQuestsTable()
	for questIdx, quest in pairs(quests) do
		quests[questIdx].stateType = const.ENTRY_TYPE_NONE
		for objIdx,objective in pairs(quest.objectives) do
			quests[questIdx].objectives[objIdx].stateType = const.ENTRY_TYPE_NONE
			for entryIdx,entry in pairs(objective.entries) do
				quests[questIdx].objectives[objIdx].entries[entryIdx].stateType = const.ENTRY_TYPE_NONE
				entryToQuest[entry.id] = questIdx
			end
		end
	end
end
function compareByRecvTime(o1,o2)
	if(o1 == nil) then return false end
	if(o2 == nil) then return true end
	if(not o1.recvTime and not o2.recvTime) then return false end
	if(not o1.recvTime) then return false end
	if(not o2.recvTime) then return true end
	return o1.recvTime > o2.recvTime
end
function buildEntry(text, recvTime, stateType, chapter, timeStamp)
	local entry =
	{
		text = text,
		recvTime = recvTime,
		stateType = stateType,
		timeStamp = timeStamp,
		chapters = {}
	}
	entry.chapters[chapter] = 1
	return entry
end
function createEntry(questId, objectiveId, entryId, previousObjectives, subGroup)
	local quest = findQuest(questId)
	if(not quest) then
		Infinity_Log("Failed to create entry: " .. entryId .. "for quest: " .. questId)
		return
	end

	--parse the entry out into an objective and entry
	local entry = {}
	local objective = {}
	entry.text = ""
	entry.previousObjectives = {} --this feature will be unused for now.
	entry.id = entryId
	
	--set up this entry's subgroup
	entry.subGroup = subGroup
	if(subGroup) then
		if(not subGroups[subGroup]) then subGroups[subGroup] = {} end
		table.insert(subGroups[subGroup],entry)
	end
	
	--This code is different if we're sod or BG
	local lineCount = 1
	local fullStr = Infinity_FetchString(entryId)
	for line in string.gmatch(fullStr, "[^\r\n]+") do
		if(lineCount == 1) then
			--objective text is first line.
			objective.text = line
		end
		if(lineCount > 1) then
			--entry text is everything after first
			entry.text = entry.text .. line .. "\n"
		end
		lineCount = lineCount + 1
	end
	if(lineCount == 2) then
		--it looks like sometimes entries are just an unbroken paragraph
		--in this case the entry should get the paragraph and the objective gets nothing
		--note lineCount == 2 is a bit misleading, there's only one line in this case.
		entry.text = objective.text
		objective.text = Infinity_FetchString(quest.text)
	end
	objective.entries = {entry}
	table.insert(quest.objectives,objective)
end
function setSelectedQuest(id)
	--set to the correct state
	local quest = quests[entryToQuest[id]]
	journalMode = 2
	if(not quest) then return end
	journalMode = 0
	for k,objective in pairs(quest.objectives) do
		for k2,entry in pairs(objective.entries) do
			if(entry.id == id) then
				if entry.stateType == const.ENTRY_TYPE_COMPLETE then
					journalMode = 1
				end
				if entry.stateType == const.ENTRY_TYPE_INFO then
					journalMode = 2
				end
				if entry.stateType == const.ENTRY_TYPE_USER then
					journalMode = 3
				end
				break
			end
		end
	end
	updateDisplayJournal()
end

--Update a journal entry by the strref/journalId
function updateJournalEntry(journalId, recvTime, stateType, chapter, timeStamp)
	if stateType == const.ENTRY_TYPE_USER then
		local entry = buildEntry(journalId, recvTime, stateType, chapter, timeStamp)
		table.insert(userNotes,entry)

		--update display data
		buildQuestDisplay()
		return
	end

	--find the quest that is parent to this entry.
	--NOTE this can be placed in a loop if there needs to be more than quest to an entry
	--this would just mean entryToQuest returns a table that we iterate over
	local questId = entryToQuest[journalId]
	if questId == nil or stateType == const.ENTRY_TYPE_INFO then
		--add loose entries into the looseEntries table so they still get displayed.
		for _,entry in pairs(looseEntries) do
			if entry.text == journalId then
				return
			end
		end
		local entry = buildEntry(journalId, recvTime, stateType, chapter, timeStamp)
		table.insert(looseEntries,entry)

		--update display data
		buildQuestDisplay()
		return
	end

	local quest = quests[questId]
	if quest == nil then
		print_r("JOURNAL ERROR - no quest entry associated with questId "..questId)
		return
	end

	local previous = nil
	--traverse quest to find objective and entry
	for objIdx,objective in pairs(quest.objectives) do
		for entryIdx,entry in pairs(objective.entries) do
			if(entry.id == journalId) then
				--now we know where our quest, objective, and entry are
				--update quest, objective and entry appropriately
				entry.recvTime = recvTime
				entry.stateType = stateType
				if(not entry.chapters) then entry.chapters = {} end
				entry.chapters[chapter] = 1
				entry.timeStamp = timeStamp
				objective.entries[entryIdx] = entry

				objective.recvTime = recvTime
				if(not objective.chapters) then objective.chapters = {} end
				objective.chapters[chapter] = 1
				if(objective.stateType ~= const.ENTRY_TYPE_COMPLETE) then
					objective.stateType = stateType
				end
				quest.objectives[objIdx] = objective

				quest.recvTime = recvTime
				if(not quest.chapters) then quest.chapters = {} end
				quest.chapters[chapter] = 1
				if(quest.stateType ~= const.ENTRY_TYPE_COMPLETE) then
					quest.stateType = stateType
				end

				--mark any previous objective as complete
				if(entry.previous ~= nil) then
					for objIdx2,objective2 in pairs(quest.objectives) do
						for k, prevObj in pairs(entry.previous) do
							if(prevObj == objective2.text) then
								quest.objectives[objIdx2].stateType = const.ENTRY_TYPE_COMPLETE
							end
						end
					end
				end

				quests[questId] = quest

				--remove all in subgroup (except myself!)
				if(stateType == const.JOURNAL_STATE_COMPLETE and entry.subGroup) then
					for k,v in pairs(subGroups[entry.subGroup]) do
						if(v.id ~= entry.id) then
							removeJournalEntry(v.id)
						end
					end
				end
			end
		end
	end
	--sort the objectives.
	table.sort(quest.objectives,compareByRecvTime)

	--update display data
	buildQuestDisplay()
end

--this should maybe be done recursively, but i kinda want direct control over each level
function buildQuestDisplay()
	--this is basically just a flatten
	questDisplay = {}
	for k,quest in pairs(quests) do
		--skip inactive quests
		if(quest.stateType ~= nil and quest.stateType ~= const.ENTRY_TYPE_NONE) then
			quest.quest = 1 -- tell the renderer what type of entry this is
			table.insert(questDisplay, quest)
			local curQuestIdx = #questDisplay --we'll need to modify current quest with it's children, store a reference.
			local questChildren = {}
			for k2,objective in pairs(quest.objectives) do
				if(objective.stateType ~= const.ENTRY_TYPE_NONE) then
					objective.objective = 1
					objective.parent = curQuestIdx

					if(objective.stateType ~= const.ENTRY_TYPE_INFO) then
						--info entries should not go into quests
						table.insert(questDisplay, objective)
						table.insert(questChildren, #questDisplay)
					end
					local curObjectiveIdx = #questDisplay
					local objectiveChildren = {}
					for k3,entry in pairs(objective.entries) do
						entry.entry = 1
						entry.parent = curObjectiveIdx
						table.insert(questDisplay, entry)
						table.insert(objectiveChildren, #questDisplay)
					end
					questDisplay[curObjectiveIdx].children = objectiveChildren
				end
			end
			questDisplay[curQuestIdx].children = questChildren
		end
	end

	--add the loose entries (entries without quests) to the journal display
	table.sort(looseEntries, compareByRecvTime)
	journalDisplay = {}
	for k,entry in pairs(looseEntries) do
		local title  = {}
		title.title = 1
		title.text = entry.timeStamp
		title.chapters = entry.chapters
		table.insert(journalDisplay,title)
		entry.entry = 1
		table.insert(journalDisplay,entry)
	end

	--add the user entries to the user display
	table.sort(userNotes, compareByRecvTime)
	userDisplay = {}
	for k,entry in pairs(userNotes) do
		local title  = {}
		title.title = 1
		title.text = entry.timeStamp
		title.chapters = entry.chapters
		table.insert(userDisplay,title)
		entry.entry = 1
		table.insert(userDisplay,entry)
	end
end
function containsChapter(tab, chapter)
	if(not tab) then return nil end
	return tab[chapter]
end
function childrenContainsChapter(children)
	for k,v in pairs(children) do
		if containsChapter(questDisplay[v].chapters,chapter) then
			return questDisplay[v].chapters
		end
	end
	return nil
end
function getFinished(row)
	local rowTab =  questDisplay[row]
	if rowTab.parent ~= nil then return getFinished(rowTab.parent) end
	if rowTab.stateType == const.ENTRY_TYPE_COMPLETE then return 1 else return 0 end
end
function questEnabled(row)
	return questDisplay[row] and questDisplay[row].quest and containsChapter(questDisplay[row].chapters,chapter) and childrenContainsChapter(questDisplay[row].children)
end
function getQuestText(row)
	local rowTab =  questDisplay[row]
	if (rowTab == nil) then return nil end
	return Infinity_FetchString(rowTab.text)
end
function objectiveEnabled(row)
	local rowTab =  questDisplay[row]
	if(rowTab == nil or rowTab.objective == nil or not containsChapter(rowTab.chapters,chapter)) then return nil end
	if(questEnabled(rowTab.parent) and not questDisplay[rowTab.parent].hidden) then return 1 else return nil end
end
function getObjectiveText(row)
	local rowTab =  questDisplay[row]
	if (rowTab == nil) then return nil end
	local text = rowTab.text
	if rowTab.entries[1].timeStamp ~= nil then
		text = text .. '\n' .. rowTab.entries[1].timeStamp
	end
	return text
end
function entryEnabled(row)
	local rowTab = questDisplay[row]
	if(rowTab == nil or rowTab.entry == nil or not containsChapter(rowTab.chapters,chapter)) then return nil end
	if(objectiveEnabled(rowTab.parent) and not questDisplay[rowTab.parent].hidden) then return 1 else return nil end
end
function getEntryText(row)
	local text = questDisplay[row].text
	if text:byte(#text) ~= 10 then
		text = text .. '\n'
	end
	return text
end
function getTitleEnabled(display, row)
	return display[row].title and containsChapter(display[row].chapters,chapter)
end
function getTitleText(display, row)
	return display[row].text
end
function getJournalEnabled(display, row)
	return display[row].entry and containsChapter(display[row].chapters,chapter)
end
function getJournalText(display, row)
	local text = Infinity_FetchString(display[row].text)
	if(text == nil or text == "") then
		text = display[row].text
	end
	return text
end
function getJournalEntryRef(display, row)
	local entry = display[row]
	if(not entry) then return end
	if(entry.title) then
		return display[row + 1].text
	else
		return entry.text
	end
end
function pauseJournal()
	if not worldScreen:CheckIfPaused() then
		worldScreen:TogglePauseGame(true)
	end
end
journalMode = 0
editMode = 0
`