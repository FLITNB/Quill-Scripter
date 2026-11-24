--! luart-extensions
import ui

local win = ui.Window("Type window", 500, 400)
win:loadicon("./resources/winicon.ico")

local booktext = "Jouw boek begint hier"

local edit = ui.Edit(win, booktext, 20, 50, 10, 10)
edit.wordwrap = true
edit:center()

win.menu = ui.Menu()
local editMenu = win.menu:insert(1, "Edit", ui.Menu("Kopiëren\tCtrl+C", "Plakken\tCtrl+V", "Alles selecteren\tCtrl+A"))

function editMenu.submenu:onClick(item)
  if item.text == "Kopiëren\tCtrl+C" then
    print("Succesfully copied!")
    edit:copy()
  end
  if item.text == "Plakken\tCtrl+V" then
    print("Pasted succesfully!")
    edit:paste()
  end
end

win:show()

local function changeTheme()
  if ui.systheme == "dark" then
    ui.theme = "dark"
  end
  
  if ui.systheme == "light" then
    ui.theme = "light"
  end
end

local function updateSize()
  local ratio = 1.414
  
  local margin = 40
  local max_width = win.width - (margin * 2)
  local max_height = win.height - (margin * 2)
  
  local w = max_width
  local h = w * ratio
  
  if h > max_height then
    h = max_height
    w = h / ratio
  end
  
  edit.width = math.floor(w)
  edit.height = math.floor(h)
  edit:center()
end

function edit:onClick()  
  if edit.text == booktext then
    edit.text = ""
  end
end

function win:onClick()
  if edit.text == "" then
    edit.text = booktext
  end
end

function win:onCreate()
  updateSize()
end

function win:onResize()
  updateSize()
end

changeTheme()

await win:showasync()