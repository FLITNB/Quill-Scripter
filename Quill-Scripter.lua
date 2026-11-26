--! luart-extensions
import keyboard
import sys
import ui
require "canvas"

-- create a window
local win = ui.Window("Quill Scripter", 500, 500)
win:loadicon("resources\\winicon.ico")

-- create a canvas
local canvas = ui.Canvas(win, 250, 250)
canvas.bgcolor = 0x0F0F0F0FF
canvas.color = 0x000000FF

local lines = { "" }
local line_height = 18

local cursor_visible = true
local cursor_row = 1
local cursor_col = 0

-- make the size of the canvas a4 according to the window
local function updateA4Size()
  local ratio = 1.1414
  
  local margin = 40
  local max_width = win.width - (margin * 2)
  local max_height = win.height - (margin * 2)
  
  local w = max_width
  local h = w * ratio
  
  if h > max_height then
    h = max_height
    w = h / ratio
  end
  
  canvas.width = math.floor(w)
  canvas.height = math.floor(h)
  canvas:center()
end

local function addText(char)
  local current = lines[cursor_row]
  local before = current:sub(1, cursor_col)
  local after = current:sub(cursor_col + 1)
  local updated = before .. char .. after
  
  if canvas:measure(updated).width > canvas.width - 20 and #current > 0 then
    if cursor_col == #current then
      table.insert(lines, cursor_row + 1, char)
      cursor_row =  cursor_row + 1
      cursor_col = 1
    else
      local last_char = update:sub(-1)
      lines[cursor_row] = updated:sub(1, -2)
      table.insert(lines, cursor_row + 1, last_char)
      cursor_col = cursor_col + 1
    end
  else
    lines[cursor_row] = updated
    cursor_col = cursor_col + 1
  end
end

-- configure the input of the keys
function win:onKey(key)
  local pressed = tostring(key)
  local shift = keyboard.isdown("SHIFT")
  win:status("Pressed key: " .. pressed)

  if pressed == "VK_RETURN" then
    local current = lines[cursor_row]
    local before = current:sub(1, cursor_col)
    local after = current:sub(cursor_col + 1)
    
    lines[cursor_row] = before
    table.insert(lines, cursor_row + 1, after)
    cursor_row = cursor_row + 1
    cursor_col = 0
    
    
  elseif pressed == "VK_BACK" then
    if cursor_col > 0 then
      local current = lines[curso_row]
      local before = current:sub(1, cursor_col - 1)
      local after = current:sub(cursor_col + 1)
      lines[cursor_row] = before .. after
      cursor_col = cursor_col -1
    elseif cursor_row > 1 then
      local prev_len = #lines[cursor_row - 1]
      lines[cursor_row - 1] = lines[cursor_row - 1] .. lines[cursor_row]
      table.remove(lines, cursor_row)
      cursor_row = cursor_row - 1
      cursor_col = prev_len
    end 
    
  elseif pressed == "VK_SPACE" then
    addText(" ")
  elseif pressed == "VK_OEM_COMMA" then
    addText(shift and "<" or ",")
  elseif pressed == "VK_OEM_PERIOD" then
    addText(shift and ">" or ".")
  elseif pressed == "VK_OEM_1" then
    addText(shift and ":" or ";")
  elseif pressed == "VK_OEM_2" then
    addText(shift and "?" or "/")
  elseif pressed == "VK_OEM_3" then
    addText(shift and "~" or "`")
  elseif pressed == "VK_OEM_4" then
    addText(shift and "{" or "[")
  elseif pressed == "VK_OEM_5" then
    addText(shift and "|" or "\\")
  elseif pressed == "VK_OEM_6" then
    addText(shift and "}" or "]")
  elseif pressed == "VK_OEM_7" then
    addText(shift and '"' or "'")
  elseif pressed == "VK_LEFT" then
    if cursor_col > 0 then
      cursor_col = cursor_col - 1
    elseif cursor_row > 1 then
      cursor_row = cursor_row - 1
      cursor_col = #lines[cursor_row]
    end
  elseif pressed == "VK_RIGHT" then
    if cursor_col < #lines[cursor_row] then
      cursor_col = cursor_col + 1
    elseif cursor_row < #lines then
      cursor_row = cursor_row + 1
      cursor_col = 0
    end
  elseif pressed == "VK_UP" then
    if cursor_row > 1 then
      cursor_row = cursor_row - 1
      if cursor_col > #lines[cursor_row] then
        cursor_col = #lines[cursor_row]
      end
    end
  elseif pressed == "VK_DOWN" then
    if cursor_row < #lines then
      cursor_row = cursor_row + 1
      if cursor_col > #lines[cursor_row] then
        cursor_col = #lines[cursor_row]
      end
    end
  
  elseif #pressed == 1 then
    if shift and pressed == "0" then
      addText(")")
    elseif shift and pressed == "1" then
      addText("!")
    elseif shift and pressed == "2" then
      addText("@")
    elseif shift and pressed == "3" then
      addText("#")
    elseif shift and pressed == "4" then
      addText("$")
    elseif shift and pressed == "5" then
      addText("%")
    elseif shift and pressed == "6" then
      addText("^")
    elseif shift and pressed == "7" then
      addText("&")
    elseif shift and pressed == "8" then
      addText("*")
    elseif shift and pressed == "9" then
      addText("(")
    elseif shift then
      addText(pressed:upper())
    else
      addText(pressed:lower())
    end
  end

  cursor_visible = true
  canvas:onPaint()
end

-- print the text on the canvas when it's redrawn
function canvas:onPaint()
  self:begin()
  self:clear()

  for i, line in ipairs(lines) do
    local y = 10 + (i - 1) * line_height
    self:print(line, 10, y)
  end
  
  if cursor_visible then
    local active_line = lines[cursor_row]
    local text_before_cursor = active_line:sub(1, cursor_col)
    local cursor_y = 10 + (cursor_row - 1) * line_height
    local text_size = self:measure(text_before_cursor)
    local cursor_x = 10 + text_size.width
    
    self:line(cursor_x, cursor_y, cursor_x, cursor_y + line_height - 2)
  end

  self:flip()
end

-- Resize and center the canvas when the window gets resized
function win:onResize()
  updateA4Size()
end

-- Resize and center the canvas when the window gets created
function win:onCreate()
  updateA4Size()
  
  local blinkCursor = async function()
    while win.visible do
      sleep(500)
      cursor_visible = not cursor_visible
      canvas:onPaint()
    end
  end
  blinkCursor()
end

await win:showasync()