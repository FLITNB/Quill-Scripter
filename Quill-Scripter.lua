--! luart-extensions
import keyboard
import sys
import ui
require "canvas"

-- create a window
local win = ui.Window("Test", 500, 500)
win:loadicon("resources\\winicon.ico")

-- create a canvas
local canvas = ui.Canvas(win, 250, 250)
canvas.bgcolor = 0x0F0F0F0FF
canvas.color = 0x000000FF

local lines = { "" }
local line_height = 18
local cursor_visible = true

-- configure the input of the keys
function win:onKey(key)
  local pressed = tostring(key)
  local shift = keyboard.isdown("SHIFT")
  win:status("Pressed key: " .. pressed)

  if pressed == "VK_RETURN" then
    lines[#lines + 1] = ""
    
  elseif pressed == "VK_BACK" then
    local last = lines[#lines]
    if #last > 0 then
      lines[#lines] = last:sub(1, -2)
    elseif #lines > 1 then
      table.remove(lines)
    end
    
  elseif pressed == "VK_SPACE" then
    lines[#lines] = lines[#lines] .. " "
  elseif pressed == "VK_OEM_COMMA" then
    lines[#lines] = lines[#lines] .. (shift and "<" or ",")
  elseif pressed == "VK_OEM_PERIOD" then
    lines[#lines] = lines[#lines] .. (shift and ">" or ".")
  elseif pressed == "VK_OEM_1" then
    lines[#lines] = lines[#lines] .. (shift and ":" or ";")
  elseif pressed == "VK_OEM_2" then
    lines[#lines] = lines[#lines] .. (shift and "?" or "/")
  elseif pressed == "VK_OEM_3" then
    lines[#lines] = lines[#lines] .. (shift and "~" or "`")
  elseif pressed == "VK_OEM_4" then
    lines[#lines] = lines[#lines] .. (shift and "{" or "[")
  elseif pressed == "VK_OEM_5" then
    lines[#lines] = lines[#lines] .. (shift and "|" or "\\")
  elseif pressed == "VK_OEM_6" then
    lines[#lines] = lines[#lines] .. (shift and "}" or "]")
  elseif pressed == "VK_OEM_7" then
    lines[#lines] = lines[#lines] .. (shift and '"' or "'")
  
  elseif #pressed == 1 then
    if shift and pressed == "0" then
      lines[#lines] = lines[#lines] .. ")"
    elseif shift and pressed == "1" then
      lines[#lines] = lines[#lines] .. "!"
    elseif shift and pressed == "2" then
      lines[#lines] = lines[#lines] .. "@"
    elseif shift and pressed == "3" then
      lines[#lines] = lines[#lines] .. "#"
    elseif shift and pressed == "4" then
      lines[#lines] = lines[#lines] .. "$"
    elseif shift and pressed == "5" then
      lines[#lines] = lines[#lines] .. "%"
    elseif shift and pressed == "6" then
      lines[#lines] = lines[#lines] .. "^"
    elseif shift and pressed == "7" then
      lines[#lines] = lines[#lines] .. "&"
    elseif shift and pressed == "8" then
      lines[#lines] = lines[#lines] .. "*"
    elseif shift and pressed == "9" then
      lines[#lines] = lines[#lines] .. "("
    elseif shift then
      lines[#lines] = lines[#lines] .. pressed:upper()
    else
      lines[#lines] = lines[#lines] .. pressed:lower()
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
    local last_line = lines[#lines]
    local last_y = 10 + (#lines - 1) * line_height
    local text_size = self:measure(last_line)
    local cursor_x = 10 + text_size.width
    
    self:line(cursor_x, last_y, cursor_x, last_y + line_height -    2)
  end

  self:flip()
end

-- Resize and center the canvas when the window gets resized
function win:onResize()
  canvas:center()
  canvas.height = win.height / 2
  canvas.width = win.width / 2
end

-- Resize and center the canvas when the window gets created
function win:onCreate()
  canvas:center()
  canvas.height = win.height / 2
  canvas.width = win.width / 2
  
  local blink = async function()
    while win.visible do
      sleep(500)
      cursor_visible = not cursor_visible
      canvas:onPaint()
    end
  end
  blink()
end

await win:showasync()