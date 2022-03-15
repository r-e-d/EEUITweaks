`
step = 1
worldNPCDialogText = ""
worldPlayerDialogChoices = {}

function dialogEntryGreyed()
	return not worldScreen:GetInControlOfDialog()
end

function getDialogPaddingText()
	local x,y,w,h = Infinity_GetArea("worldPlayerDialogChoicesList")
	local zoom = tonumber(Infinity_GetINIValue('Fonts','Zoom','100'))
	local dialogHeight = Infinity_GetContentHeight(styles.normal.font, w, getDialogText(2), styles.normal.point * zoom / 100, 0, styles.normal.useFontZoom) + 12
	local i = 1
	while i <= #worldPlayerDialogChoices do
		dialogHeight = dialogHeight + Infinity_GetContentHeight(styles.normal.font, w, worldPlayerDialogChoices[i].text, styles.normal.point * zoom / 100, 0, styles.normal.useFontZoom)
		i = i + 1
	end
	local text = ""
	local lineHeight = Infinity_GetContentHeight(styles.normal.font, w, text, styles.normal.point * zoom / 100, 0, styles.normal.useFontZoom)
	while dialogHeight + lineHeight < h do
		text = text .. "\n"
		lineHeight = Infinity_GetContentHeight(styles.normal.font, w, text, styles.normal.point * zoom / 100, 0, styles.normal.useFontZoom)
	end
	return text
end

function resizeDialog()
	buildResponsesList()
	step = 1
end

function dialogScroll(top, height, contentHeight)
	if worldNPCDialogText == '' then
		return nil
	end
	
	if step == 1 then
		step = 2
		return -contentHeight
	end

	return nil
end

function dragDialogMessagesY(newY)
	local x,y,w,hOld = Infinity_GetArea("worldDialogBackground")
	h = hOld - newY
	if h < 210 then
		newY = hOld - 210
	elseif h > 700 then
		newY = hOld - 700
	end

	adjustItemGroup({"dialogHandleY","worldDialogPortraitArea"},0,newY,0,0)
	adjustItemGroup({"worldDialogBackground","worldPlayerDialogChoicesList","worldPlayerDialogFake"},0,newY,0,-newY)
end

function getDialogEntryText(row)
	local text = worldPlayerDialogChoices[row].text
	if (row == worldPlayerDialogSelection) then
		--Color the text white when selected
		text = string.gsub(text, "%^0xff212eff", "^0xffffffff")
	end
	return text
end

function getDialogText(row)
	local idx1 = worldMessageBoxText:len()
	local idx2 = worldNPCDialogText:len()

	while idx2 > 0 do
		local c1 = worldMessageBoxText:byte(idx1)
		local c2 = worldNPCDialogText:byte(idx2)

		if c1 ~= c2 then
			if c1 == 58 and worldMessageBoxText:byte(idx1 - 1) == c2 then
				idx1 = idx1 - 1
				c1 = worldMessageBoxText:byte(idx1)
			elseif c2 == 10 and worldNPCDialogText:byte(idx2 - 1) == c1 then
				idx2 = idx2 - 1
				c2 = worldNPCDialogText:byte(idx2)
			elseif c1 == 32 and c2 == 10 and worldMessageBoxText:byte(idx1 - 1) == 58 then
				idx1 = idx1 - 1
				c1 = 10
			end
		end

		if c1 ~= c2 then
			break
		end

		idx1 = idx1 - 1
		idx2 = idx2 - 1
	end

	return trim(row == 1 and worldMessageBoxText:sub(1, idx1) or worldMessageBoxText:sub(idx1 + 1))
end

function B3Split(inputstr, sep)
	sep = sep or "%s"
	local t = {}
	for field, s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do
		table.insert(t, field)
		if s == "" then
			return t
		end
	end
end

B3DialogTable = {}
B3DialogTextI = -1
B3DialogResponsesStart = -1
B3DialogResponsesEnd = -1

function makeDialogTable()
	B3DialogTable = B3Split(getDialogText(1), "\n")
	B3DialogTextI = #B3DialogTable + 1
	B3DialogResponsesStart = B3DialogTextI + 1
	B3DialogResponsesEnd = B3DialogResponsesStart + #worldPlayerDialogChoices - 1
	if step == 2 then
		table.insert(B3DialogTable, getDialogText(2))
		for _, v in pairs(worldPlayerDialogChoices) do
			table.insert(B3DialogTable, v.text)
		end
		local paddingText = getDialogPaddingText()
		table.insert(B3DialogTable, paddingText)
	end
	return B3DialogTable
end

function getDialogPortrait()
	if worldNPCDialogPortrait ~= nil and worldNPCDialogPortrait:sub(-1) == 'S' then
		for _, entry in ipairs(Infinity_GetFilesOfType("BMP")) do
			if entry[1] == worldNPCDialogPortrait:sub(1, -2) .. 'M' then
				return entry[1]
			end
		end
	end
	return worldNPCDialogPortrait
end
`
