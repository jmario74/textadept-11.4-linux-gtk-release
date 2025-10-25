-- ONLY FOR TEXTADEPT 11.4 LINUX GTK

--[[ KEYBOARD SHOTCUTS:
Custom find marker = ctrl+kp4
Custom find = ctrl+f
Copy file path to clipboard = ctrl+alt+c
Duplicate multi-line/selection = ctrl+d
Custom copy multi-line/selection = ctrl+c
Custom undo = ctrl+z
Custom redo = ctrl+Z
Toggle auto indent = ctrl+f7
Toggle auto pairs = ctrl+f8
Toggle scrollbars = ctrl+f9
Toggle line numbers = ctrl+f10
Toggle Menubar = ctrl+f11
Toggle Tabs = ctrl+f12
Toggle word wrap override = ctrl+alt+\
Toggle word wrap caret = ctrl+alt+/
insert CSS marker = ctrl+kp2
insert comment marker = ctrl+kp1
insert marker = ctrl+kp3
add/remove block comment = ctrl+kp5
asterisk title comment = ctrl+kp6
hash title comment = ctrl+kp7
toggle all = ctrl+esc
command = ctrl+e
language comment = ctrl+/
rectangular select = alt+left mouse button
preferences = ctrl+p
]]

events.connect(events.VIEW_NEW,function()
	textadept.session.load(_USERHOME..'/session')
end)

-- on start with split will cause all tabs to be split
local index = 1;
events.connect(events.QUIT,function()
	view:unsplit()
end,index)

-- Some local colors (/themes/dark.lua)
local white = 0xFFFFFF
local light_black = 0x333333
local black = 0x1A1A1A
local dark_green = 0x1A661A
local red = 0x4D4D99
local teal = 0x99994D
local dark_pink = 0x6666B3
local dark_lavender = 0xB36666
local orange = 0x4D99E6

-- Adjust the default theme's font and size.
if not CURSES then
  -- linux DPI set at 1.15
	-- if "size = 13", linux terminal font size 13
  -- if "size = 15", linux terminal font size 14
  -- linux DPI set at 1.19
	-- if "size = 12", linux terminal font size 12
  view:set_theme('dark', {font = 'DejaVu Sans Mono', size = 12})
end

--[[ used to get key value
events.connect(events.KEYPRESS, function(key)
	ui.statusbar_text = key
end)
]]

-- Display file path in status bar if OS is set to hide title bar of apps
keys.KEYSYMS[65505] = 'oink'-- shift key
local fileName = buffer.filename
local function statusbar_filename()
	-- indicate if file has unsaved changes
	if buffer.modify and buffer.filename then
		fileName = '~' .. buffer.filename
	else
		fileName = buffer.filename
	end
	ui.statusbar_text = fileName
end
events.connect(events.UPDATE_UI,statusbar_filename)
events.connect(events.FILE_AFTER_SAVE,statusbar_filename)
events.connect(events.FOCUS,statusbar_filename)
keys['oink'] = statusbar_filename
keys['ctrl+oink'] = statusbar_filename
keys['esc'] = statusbar_filename

-- when there is no more undo and still being pressed prevent the status bar text from getting cleared
local function custom_undo()
	buffer.undo()
	ui.statusbar_text = fileName
end
keys['ctrl+z'] = custom_undo

-- when there is no more redo and still being pressed prevent the status bar text from getting cleared
local function custom_redo()
	buffer.redo()
	ui.statusbar_text = fileName
end
-- ctrl+(shift+z), (shift+z) = Z
keys['ctrl+Z'] = custom_redo

-- custom find
keys['ctrl+f'] = function()
	ui.find.find_entry_text = buffer.get_sel_text()
	local str = buffer.get_text()
	local len = string.len(str)
	buffer.indicator_clear_range(0,len)
	ui.find.focus()
	ui.find.find_next()
	ui.find.find_prev()

  ui.statusbar_text = fileName
end
ui.find.highlight_all_matches = true
view.indic_fore[ui.find.INDIC_FIND] = white
view.indic_alpha[ui.find.INDIC_FIND] = 0

-- color selection
local function setSelectnColor()
	view.sel_alpha = 30
	view.element_color[view.ELEMENT_SELECTION_INACTIVE_BACK] = white | 0X20000000
	view.element_color[view.ELEMENT_SELECTION_ADDITIONAL_BACK] = white | 0X20000000
	view.element_color[view.ELEMENT_SELECTION_SECONDARY_BACK] = white | 0X20000000
end
events.connect(events.FOCUS,setSelectnColor)
events.connect(events.RESET_AFTER,setSelectnColor)
events.connect(events.BUFFER_NEW, setSelectnColor)
events.connect(events.FILE_OPENED, setSelectnColor)

-- Launch maximized
ui.maximized = true

-- Multi-edit (ctrl+LM) click or esc to end
buffer.multiple_selection = true
buffer.additional_selection_typing = true

-- Markers
view.marker_back[textadept.bookmarks.MARK_BOOKMARK] = white
view.marker_alpha[textadept.bookmarks.MARK_BOOKMARK] = 25

-- Highlight all occurrences of the selected word.
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
view.indic_fore[textadept.editing.INDIC_HIGHLIGHT] = white
view.indic_alpha[textadept.editing.INDIC_HIGHLIGHT] = 0

-- Indent guide color
--lexer.styles.indent_guide = {fore = dark_green, back = dark_green}-- display more intense color
lexer.styles.indent_guide = {fore = dark_green}

-- Token styles, embedded (<?php)
lexer.styles.embedded = {fore = red}
lexer.styles.keyword = {fore = dark_lavender}
lexer.styles.number = {fore = dark_pink}
lexer.styles.variable = {fore = teal}

-- Highlighted selected word
view.element_color[view.ELEMENT_SELECTION_BACK] = white
view.element_color[view.ELEMENT_CARET_LINE_BACK] = black
view.element_color[view.ELEMENT_CARET_ADDITIONAL] = black

-- Caret
view.element_color[view.ELEMENT_CARET] = white
view.caret_line_back = light_black
view.caret_line_frame = 2
view.element_color[view.ELEMENT_CARET_ADDITIONAL] = orange

-- Bracket match, removed in version 12.2
view.indic_fore[textadept.editing.INDIC_BRACEMATCH] = white

-- Default indentation settings for all buffers.
buffer.use_tabs = true
buffer.tab_width = 2

-- Always use PEP-8 indentation style for Python files.
events.connect(events.LEXER_LOADED, function(name)
  if name ~= 'python' then return end
  buffer.tab_width = 2
  buffer.use_tabs = false
  view.view_ws = view.WS_VISIBLEALWAYS
end)

-- Word wrap type
view.wrap_indent_mode = view.WRAPINDENT_DEEPINDENT
view.wrap_mode = view.WRAP_WORD

-- no typeover character ")"
textadept.editing.typeover_chars[string.byte(')')] = false
textadept.editing.typeover_chars[string.byte(']')] = false
textadept.editing.typeover_chars[string.byte('}')] = false
textadept.editing.typeover_chars[string.byte("'")] = false
textadept.editing.typeover_chars[string.byte('"')] = false

-- remove trailing spaces on save
textadept.editing.strip_trailing_spaces = true

-- custom get selected text
local bufStartArr = {}
local bufEndArr = {}
local len = 0
local selText = ''
local subStr = ''
local bufStart = 0
local bufEnd = 0
local textArr = {}
local arrOnce = 1
-- used in "local function dup()"
local bufTextArr = {}
events.connect(events.UPDATE_UI, function(updated)
  if not (updated & buffer.UPDATE_SELECTION) then end

  --ui.statusbar_text = buffer.selection_start - buffer.selection_end

  -- get the length of the string
  len = math.abs(buffer.selection_start - buffer.selection_end)

  -- returns multi-selected text as one string
  selText = buffer:get_sel_text()

  -- for each selection the "len" variable will be set at zero and will increment on highlight
  if len > 0 then
    -- the multi-selected text is one string, separate each one using its start and end points
    local startPoint = math.abs(len - #buffer:get_sel_text()) + 1
    local endPoint = #buffer:get_sel_text()
    --ui.statusbar_text = string.sub(selText, math.abs(len - #buffer:get_sel_text()) + 1, #buffer:get_sel_text())
    --ui.statusbar_text = math.abs(len - #buffer:get_sel_text()) .. '##' .. selText .. '##' .. #buffer:get_sel_text()
    subStr = string.sub(selText, startPoint, endPoint)

    bufStart = buffer.selection_start
    bufEnd = bufStart + #subStr

    arrOnce = 1
  else
    -- this runs for every caret move

    --ui.statusbar_text = 'bufStart:' .. bufStart .. '##' .. 'bufEnd:' .. bufEnd .. '##' .. 'subStr:' .. subStr

    -- "bufStart" and bufEnd" do not insert at zero position
    if not buffer.selection_empty and arrOnce ~= 0 then
      -- transfer collected data from "len" to arrays for storage
      table.insert(textArr, subStr)
      table.insert(bufStartArr, bufStart)
      table.insert(bufEndArr, bufEnd)

      -- used in "local function dup()"
      bufTextArr[bufEnd] = subStr-- use selected text end pos as index to match it with the sorted text end positions

      arrOnce = 0
    end
  end

  --ui.statusbar_text = #bufStartArr
end)

-- runs when there is no highlighted text
events.connect(events.UPDATE_UI, function(updated)
  if not (updated & buffer.UPDATE_CONTENT) then end
  if selText == '' then
    subStr = ''
    bufStart = 0
    bufEnd = 0
    textArr = {}
    bufStartArr = {}
    bufEndArr = {}
    bufTextArr = {}
    collectgarbage()
  end
end)

-- Copy file path to clipboard
local function copy_file_path()
	ui.clipboard_text = buffer.filename
	statusbar_filename()
end
keys['ctrl+alt+c'] = copy_file_path

-- Override default word wrap
local function word_wrap_override()
	if view.wrap_mode == view.WRAP_NONE then
		view.wrap_mode = view.WRAP_WORD
	else
		view.wrap_mode = view.WRAP_NONE
		-- inadvertly scrolls when word wrap is toggled, switch out of the buffer then back while using "updateWrapModeState()" to keep the word wrap status and maintain the scroll position, when switching buffers the scroll position is maintained
		view:goto_buffer(1)-- switch out of the buffer
		view:goto_buffer(-1)-- then swicth back to the buffer
	end
end
keys['ctrl+alt+\\'] = word_wrap_override

-- Custom word wrap
local onwrap = false
local function custom_word_wrap()
	if view.wrap_mode == view.WRAP_NONE then
		view.wrap_mode = view.WRAP_WORD
	else
		view.wrap_mode = view.WRAP_NONE
	end
	onwrap = true
end
keys['ctrl+alt+/'] = custom_word_wrap
-- Inadvertly scrolls when word wrap is toggled, keep caret in view on word wrap
local function word_wrap_caret()
	if onwrap then
		local currCaretPos = buffer.current_pos
		buffer:home_wrap()
		buffer.goto_pos(currCaretPos)
		view:vertical_center_caret()
		onwrap = false;
	end
end
events.connect(events.UPDATE_UI,word_wrap_caret)

-- Duplicate multi-line/selection
local mrk = 'ǻ' .. '⧞'-- separated so when using multi-line duplicate on this file
local function dup()
  local onDup = 0
  local dupMov = 0

  if len > 0 then
    -- add the last selected values
    bufTextArr[bufEnd] = subStr-- use selected text end pos as index to match it with the sorted text end positions
    table.insert(bufEndArr, bufEnd)

    onDup = 1
  else
    buffer.line_duplicate()
  end

  -- IMPORTANT!, SORT THE ARRAY BEFORE USE, THE VALUES MUST BE FROM LOW TO HIGH, SAME ORDER AS THE CHARACTER POSITIONS IN THE DOCUMENT
	table.sort(bufEndArr)

  if onDup ~= 0 then
    for i=1, #bufEndArr do
      if i ~= 1 then
        -- the markers take up space and will move the postitions in the document, except for the first one
        dupMov = dupMov + #mrk
        buffer:goto_pos(bufEndArr[i] + dupMov)
      end
      if i == 1 then
        buffer:goto_pos(bufEndArr[i])
      end

      -- do not record this action in undo history
      buffer.undo_collection = false

      -- add markers to the positions where the duplicate stings are to be inserted
      buffer:insert_text(buffer.current_pos, mrk)

      -- once the markers are in place
      if i == #bufEndArr then
        -- begin inserting the duplicate strings for each marker
        for i=1, #bufEndArr do
          -- find & replace the markers, this is so when the duplicate strings take up space the markers moves as well along with the positions; less code needed to get the moving positions
          local pos = buffer:search_next(buffer.FIND_REGEXP, mrk)-- find the marker and get its position

          buffer.undo_collection = false-- do not record this action in undo history

          buffer:goto_pos(pos)-- move caret to the back of the marker

          buffer.undo_collection = true-- record undo history again

          buffer.new_line()-- drop the marker one line down respecting auto indent if active

          buffer.undo_collection = false-- do not record this action in undo history

          pos = buffer.current_pos-- update the "pos" variable with the caret's current position

          buffer:delete_range(pos, string.len(mrk))-- marker has served it purpose go ahead and delete it

          buffer.undo_collection = true-- record undo history again

          buffer:insert_text(pos, bufTextArr[bufEndArr[i]])-- insert the duplicate string where the marker was using the updated "pos" variable

          if i == #bufEndArr then
            -- reset all of this for the next use of this function
            dupMov = 0
            onDup = 0
          end
        end
      end
    end
	end
end
keys['ctrl+d'] = dup

-- custom copy
local function custom_copy()
  -- get "subStr" that has not been transferred to array
  if len > 0 then table.insert(textArr, subStr) end

  buffer:copy_text(table.concat(textArr,"\n"))
  --buffer:copy_text(table.concat(textArr," "))

  ui.statusbar_text = fileName
end
keys['ctrl+c'] = custom_copy

--toggle indentation 2 & 4
io.detect_indentation = false
buffer.use_tabs = false
buffer.tab_width = 2

-- Toggle auto indent
local is_autoindent = false
local function toggle_autoindent()
	if not is_autoindent then
		textadept.editing.auto_indent = true
	else
		textadept.editing.auto_indent = false
	end
	is_autoindent = not is_autoindent

  ui.statusbar_text = fileName
end
keys['ctrl+f7'] = toggle_autoindent
--events.connect(events.INITIALIZED,toggle_autoindent)

-- Toggle auto pairs
local is_autopairs = false
local auto_pairs = textadept.editing.auto_pairs
local function toggle_autopairs()
	if not is_autopairs then
		textadept.editing.auto_pairs = nil
	else
		textadept.editing.auto_pairs = auto_pairs
	end
	is_autopairs = not is_autopairs

  ui.statusbar_text = fileName
end
keys['ctrl+f8'] = toggle_autopairs

-- Toggle scrollbars
local isScrollbars = false
local scrolBarState = false;
local function toggle_scrollbars()
	if not isScrollbars then
		scrolBarState = false
	else
		scrolBarState = true
	end

	view.v_scroll_bar = scrolBarState
	view.h_scroll_bar = scrolBarState

	isScrollbars = not isScrollbars

  ui.statusbar_text = fileName
end
keys['ctrl+f9'] = toggle_scrollbars

-- Toggle line numbers
local isLinenum = false
local mWdt = {}
local mWdtState = {}
local isFld = false
local function toggle_linenum()
	if not isLinenum then
		for i=1,view.margins do
			mWdt[i] = view.margin_width_n[i]
			mWdtState[i] = 0
		end
	else
		for i=1,view.margins do
			mWdtState[i] = mWdt[i]
		end
	end
	for i=1,view.margins do
		view.margin_width_n[i] = mWdtState[i]
	end
	if view.size ~= nil then
		view.margin_width_n[3] = mWdt[3]
	end
	isLinenum = not isLinenum

  ui.statusbar_text = fileName
end
keys['ctrl+f10'] = toggle_linenum

-- Toggle Tabs
local isTabs = false
local function toggle_tabs()
	if not isTabs then
		ui.tabs = false
	else
		ui.tabs = true
	end
	isTabs = not isTabs

  ui.statusbar_text = fileName
end
keys['ctrl+f12'] = toggle_tabs

-- Toggle Menubar
local isMenubar = false
local menubar = textadept.menu.menubar
--keys['ctrl+f11'] = function()
local function toggle_menubar()
	if not isMenubar then
		textadept.menu.menubar = nil
	else
		textadept.menu.menubar = menubar
	end
	isMenubar = not isMenubar

  ui.statusbar_text = fileName
end
keys['ctrl+f11'] = toggle_menubar
--events.connect(events.INITIALIZED,toggle_menubar)

-- toggle all custom toggles
function toggle_all()
	toggle_linenum()
	toggle_autoindent()
	toggle_autopairs()
	toggle_scrollbars()
	--toggle_tabs()

  ui.statusbar_text = fileName
end
keys['ctrl+esc'] = toggle_all

-- keep scroll bar consistent in all opened files
function updateState()
	-- update tabs on state of...
	for i=1,view.margins do
		view.margin_width_n[i] = mWdtState[i]
	end
	view.v_scroll_bar = scrolBarState
	view.h_scroll_bar = scrolBarState
	if view.size ~= nil then
		view.margin_width_n[3] = mWdt[3]
	end
end
events.connect(events.BUFFER_AFTER_SWITCH,updateState)
events.connect(events.BUFFER_NEW,updateState)
events.connect(events.FILE_OPENED,updateState)
events.connect(events.FOCUS,updateState)
events.connect(events.UPDATE_UI,updateState)
--events.connect(events.VIEW_AFTER_SWITCH,updateState)

-- toggle all custom toggles on startup; has to be after "function updateState()" or will cause error
local once = false
events.connect(events.VIEW_NEW,function()
	if not once then
		toggle_all()
		once = true
	end
end)

-- keep wrap mode consistent in all opened files
view.wrap_mode = view.WRAP_NONE
local wrpmd
function getWrapModeState()
	wrpmd = view.wrap_mode
end
events.connect(events.BUFFER_BEFORE_SWITCH,getWrapModeState)
function updateWrapModeState()
	view.wrap_mode = wrpmd
end
events.connect(events.BUFFER_AFTER_SWITCH,updateWrapModeState)

-- insert comment marker
local function cmrk()
	--buffer.add_text('// ⌘')
	buffer.add_text(' ❖ ')
end
keys['ctrl+kp1'] = cmrk

-- insert CSS marker
local function cssmrk()
	buffer.add_text('/* ⌘ */')
end
keys['ctrl+kp2'] = cssmrk

-- insert marker
local function mrk()
	buffer.add_text(' ⌘')
end
keys['ctrl+kp3'] = mrk

-- Custom find marker
local function fnd_mrk()
	ui.find.find_entry_text = '⌘'
	ui.find.focus()
	ui.find.find_next()
	ui.find.find_prev()
end
keys['ctrl+kp4'] = fnd_mrk

-- add/remove block comment
local comMrk = 'Ø' .. 'ד'
local function blok_commnt()
  local mov = 0

  if len > 0 then
    -- add the last selected values
    bufTextArr[bufEnd] = subStr
    table.insert(bufStartArr, bufStart)
    table.insert(bufEndArr, bufEnd)
  end

  -- IMPORTANT!, SORT THE ARRAY BEFORE USE, THE VALUES MUST BE FROM LOW TO HIGH, SAME ORDER AS THE CHARACTER POSITIONS
  table.sort(bufStartArr)
  table.sort(bufEndArr)

  if #bufStartArr > 0 then
    for i=1, #bufStartArr do
      if i ~= 1 then
        -- markers take up space, adjust next position to compensate
        mov = mov + #comMrk
        buffer:goto_pos(bufStartArr[i] + mov)
      end
      if i == 1 then
        buffer:goto_pos(bufStartArr[i])
      end

      -- do not record in undo history, marker insert action
      buffer.undo_collection = false

      --insert a marker at the start of each selection
      buffer:insert_text(buffer.current_pos, comMrk)

      if i == #bufStartArr then
        -- after all markers have been placed
        for i=1, #bufStartArr do
          -- look for the markers and use its position, the markers adjust position as inserts and removes are done on the document
          local pos = buffer:search_next(buffer.FIND_REGEXP, comMrk)

          -- do not record in undo history, marker delete action
          buffer.undo_collection = false

          -- marker no longer needed
          buffer:delete_range(pos, #comMrk)

          -- only if or not block comment
          if string.find(bufTextArr[bufEndArr[i]],"/[*]") == nil and string.find(bufTextArr[bufEndArr[i]], "[*]/") == nil then
            -- record in undo history insert
            buffer.undo_collection = true
            buffer:insert_text(pos, '/*')
            buffer:insert_text(pos + #bufTextArr[bufEndArr[i]] + #'*/', '*/')
          elseif string.find(bufTextArr[bufEndArr[i]], "/[*]") ~= nil or string.find(bufTextArr[bufEndArr[i]], "[*]/") ~= nil then
            local newText = bufTextArr[bufEndArr[i]]:gsub("/[*]", "")
            newText = newText:gsub("[*]/", "")
            buffer:set_target_range(pos, pos + #bufTextArr[bufEndArr[i]])
            buffer.undo_collection = true
            buffer:replace_target(newText)
          end
        end
      end
    end
  elseif #bufEndArr == 0 then
    buffer:insert_text(buffer.current_pos, '/*  */')
    buffer:set_empty_selection(buffer.current_pos + 3)
  end
end
keys['ctrl+kp5'] = blok_commnt

-- insert hash title comment (#)
local function hshCmnt()
	buffer.add_text('/* ################################################################################')
  buffer.new_line()
  buffer.add_text('# ')
  buffer.new_line()
  buffer.add_text('# ')
  buffer.new_line()
  local endHsh = '################################################################################ */'
  buffer.add_text(endHsh)
  buffer.goto_pos(buffer.current_pos - (#endHsh + 4))
end
keys['ctrl+kp7'] = hshCmnt

-- insert asterisk title comment (*)
local function astxCmnt()
	buffer.add_text('/**')
  buffer.new_line()
  buffer.add_text('* ')
  buffer.new_line()
  buffer.add_text('* ')
  buffer.new_line()
  local endAtrx = '* */'
  buffer.add_text(endAtrx)
  buffer.goto_pos(buffer.current_pos - (#endAtrx + 4))
end
keys['ctrl+kp6'] = astxCmnt

--[[ display brace match line number
events.connect(events.UPDATE_UI, function(updated)
	if not (updated & buffer.UPDATE_SELECTION) then return end
	local line1 =  buffer:line_from_position(buffer.current_pos)
	-- if brace match is -1 on no match; line from position will return 1
	local line2 = buffer:line_from_position(buffer:brace_match(buffer.current_pos, 0))

	if line2 == 1 then return end

	--ui.statusbar_text = line2

	local lines = line1 -  line2

	--ui.statusbar_text = lines

	if lines > 0 then
		view.call_tip_position = true
	else
		view.call_tip_position = false
	end

	--ui.statusbar_text = math.abs(lines)

	if line2 ~= 1 and math.abs(lines) > 100 then
		--view:call_tip_show(buffer:brace_match(buffer.current_pos, 0), 'BRACE MATCH!')
		ui.statusbar_text = fileName .. ' BRACE MATCH: ' .. line2
	end
end)
]]

--[[ detect scrolling
events.connect(events.UPDATE_UI, function(updated)
  if not (updated & buffer.UPDATE_V_SCROLL) then end
  -- code here on scroll...
end)
]]

--[[ from Eric Anderson in textadept github show & tell
-- show opening block in status bar, closing block must not have space before it
function string.trim(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end

events.connect(events.UPDATE_UI, function(updated)
  -- We only care when the cursor moves
  if not (updated & buffer.UPDATE_SELECTION) then return end

  local line = buffer:line_from_position(buffer.current_pos)
  local line_text = buffer.get_line(line)
  local blank = line_text == "\n"

  -- Starting line is blank so nothing to match up against
  if blank then return end

  -- First line can't match up to anything so return early otherwise we get an
  -- error trying to read the previous line.
  if line <= 1 then return end

  local cur_indent = buffer.line_indentation[line]
  local prev_indent = buffer.line_indentation[line-1]

  -- If the previous line is not nested, return early as we are not ending a indention match
  if prev_indent <= cur_indent then return end

  repeat
    line = line - 1
    prev_indent = buffer.line_indentation[line]
    line_text = buffer:get_line(line)
    blank = line_text == "\n"
  until prev_indent <= cur_indent and not blank

  line_text = line_text:trim()

  if line_text == '/*' then return end
  if line_text == '/**' then return end

	--ui.statusbar_text = buffer:line_from_position(buffer.current_pos) - line

	if buffer:line_from_position(buffer.current_pos) - line > 60 then
  	--view:call_tip_show(buffer.current_pos, line_text)
		ui.statusbar_text = fileName .. ' BLOCK START: ' .. line_text
	end
end)
]]

events.connect(events.VIEW_NEW,function()
	for i = 1, #arg do
		local filename = lfs.abspath(arg[i], arg[-1])
		if lfs.attributes(filename) then -- not a switch
			io.open_file(filename)
			updateState()
		end
	end
end)
