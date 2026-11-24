--! luart-extensions
import keyboard
import ui
require "canvas"

local win = ui.Window("Test", 500, 500)
local canvas = ui.Canvas(win, 250, 250)
canvas.bgcolor = 0x0F0F0F0FF
canvas.color = 0x000000FF

canvas:center()

local pressed = ""
local current_text = ""

local function hasShift()
  if keyboard.isdown then return keyboard.isdown("SHIFT") end
  if keyboard.isDown then return keyboard.isDown("SHIFT") end
  return false
end

function win:onKey(key)
  win:status("Pressed key: ".. key)
  pressed = tostring(key)
  local shift = hasShift()

  if pressed == "VK_BACK" then
    current_text = current_text:sub(1, -2)
  elseif pressed == "VK_SPACE" then
    current_text = current_text .. " "
  elseif pressed == "VK_OEM_COMMA" then
    current_text = current_text .. (shift and "<" or ",")
  elseif pressed == "VK_OEM_PERIOD" then
    current_text = current_text .. (shift and ">" or ".")
  elseif pressed == "VK_OEM_1" then
    current_text = current_text .. (shift and ":" or ";")
  elseif pressed == "VK_OEM_7" then
    current_text = current_text .. (shift and '"' or "'")
  elseif pressed == "VK_OEM_2" then
    current_text = current_text .. (shift and "?" or "/")
  elseif pressed == "1" then
    current_text = current_text .. (shift and "!" or "1")
  elseif pressed == "VK_RETURN" then
    current_text = current_text .. "No return yet!"
  elseif #pressed == 1 then
    if shift and pressed == "9" then
      current_text = current_text .. "("
    elseif shift and pressed == "0" then
      current_text = current_text .. ")"
    elseif shift then
      current_text = current_text .. pressed:upper()
    else
      current_text = current_text .. pressed:lower()
    end
  end

  canvas:onPaint()
end

function canvas:onPaint()
  self:begin()
  self:clear()
  self:print(current_text, 10, 10)
  self:flip()
end

function win:onResize()
  canvas:center()
  canvas.height = win.height / 2
  canvas.width = win.width / 2
end

await win:showasync()