--! luart-extensions
import ui
require "canvas"
import sys
import keyboard

local win = ui.Window("LuaRT Pagina Tekstverwerker", "fixed", 800, 600)
local canvas = ui.Canvas(win, 800, 600)
canvas.align = "all"

local initial_text = "Typ hier om te testen...\nGebruik Backspace, pijltjes, Ctrl+C en Ctrl+V."

local editor = {
    text = initial_text,
    cursor = #initial_text,
    sel_start = nil,
    sel_end = nil,
    page_width = 520,
    page_height = 380,
    line_height = 22,
    current_page = 1
}

local function get_selection()
    if not editor.sel_start or not editor.sel_end or editor.sel_start == editor.sel_end then
        return nil, nil
    end
    if editor.sel_start < editor.sel_end then
        return editor.sel_start, editor.sel_end
    end
    return editor.sel_end, editor.sel_start
end

local function clear_selection()
    editor.sel_start = nil
    editor.sel_end = nil
end

local function delete_selection()
    local a, b = get_selection()
    if a and b then
        editor.text = editor.text:sub(1, a) .. editor.text:sub(b + 1)
        editor.cursor = a
        clear_selection()
        return true
    end
    return false
end

local function insert_text(str)
    delete_selection()
    editor.text = editor.text:sub(1, editor.cursor) .. str .. editor.text:sub(editor.cursor + 1)
    editor.cursor = editor.cursor + #str
end

local function backspace()
    if not delete_selection() and editor.cursor > 0 then
        editor.text = editor.text:sub(1, editor.cursor - 1) .. editor.text:sub(editor.cursor + 1)
        editor.cursor = editor.cursor - 1
    end
end

local function delete_forward()
    if not delete_selection() and editor.cursor < #editor.text then
        editor.text = editor.text:sub(1, editor.cursor) .. editor.text:sub(editor.cursor + 2)
    end
end

local function copy_text()
    local a, b = get_selection()
    if a and b then
        sys.clip = editor.text:sub(a + 1, b)
    end
end

local function cut_text()
    local a, b = get_selection()
    if a and b then
        sys.clip = editor.text:sub(a + 1, b)
        delete_selection()
    end
end

local function paste_text()
    local clip = sys.clip
    if clip and #clip > 0 then
        insert_text(clip:gsub("\r\n", "\n"))
    end
end

local function select_all()
    editor.sel_start = 0
    editor.sel_end = #editor.text
    editor.cursor = #editor.text
end

local function paginate()
    local lines = {}
    local current = ""

    for i = 1, #editor.text do
        local ch = editor.text:sub(i, i)
        if ch == "\n" then
            table.insert(lines, {
                text = current,
                start_idx = i - #current - 1,
                end_idx = i - 1
            })
            current = ""
        else
            current = current .. ch
            if canvas:textwidth(current) > editor.page_width then
                local prev = current:sub(1, -2)
                table.insert(lines, {
                    text = prev,
                    start_idx = i - #prev - 1,
                    end_idx = i - 1
                })
                current = ch
            end
        end
    end

    table.insert(lines, {
        text = current,
        start_idx = #editor.text - #current,
        end_idx = #editor.text
    })

    local max_lines = math.max(1, math.floor(editor.page_height / editor.line_height))
    local pages = {}
    for i = 1, #lines, max_lines do
        local page_lines = {}
        for j = i, math.min(i + max_lines - 1, #lines) do
            table.insert(page_lines, lines[j])
        end
        table.insert(pages, page_lines)
    end

    return pages
end

local function draw_editor()
    canvas:clear(0xE5E7EB)

    local pages = paginate()
    if editor.current_page > #pages then
        editor.current_page = #pages
    end

    local page_x = (canvas.width - editor.page_width) / 2
    local page_y = 30
    local p = pages[editor.current_page] or {}

    canvas:rect(page_x - 10, page_y - 10, editor.page_width + 20, editor.page_height + 20, 0xFFFFFF, 0xCBD5E1)

    for idx, line in ipairs(p) do
        local y = page_y + (idx - 1) * editor.line_height
        canvas:text(line.text, page_x, y, 0x111827)

        if editor.cursor >= line.start_idx and editor.cursor <= line.end_idx then
            local prefix = line.text:sub(1, editor.cursor - line.start_idx)
            local cx = page_x + canvas:textwidth(prefix)
            canvas:line(cx, y, cx, y + editor.line_height - 4, 0x2563EB)
        end
    end

    canvas:text("Pagina " .. editor.current_page .. " / " .. #pages, 15, 15, 0x374151)
end

function win:onChar(ch)
    if ch >= 32 and not keyboard.isdown("Control") then
        insert_text(string.char(ch))
        draw_editor()
    end
end

function win:onKey(key, ctrl, shift)
    local ctrl_down = ctrl or keyboard.isdown("Control")
    local shift_down = shift or keyboard.isdown("Shift")

    if ctrl_down then
        if key == string.byte("C") then
            copy_text()
            return
        elseif key == string.byte("V") then
            paste_text()
            draw_editor()
            return
        elseif key == string.byte("X") then
            cut_text()
            draw_editor()
            return
        elseif key == string.byte("A") then
            select_all()
            draw_editor()
            return
        end
    end

    if shift_down and not editor.sel_start then
        editor.sel_start = editor.cursor
    end

    if key == ui.VK.BACK then
        backspace()
    elseif key == ui.VK.DELETE then
        delete_forward()
    elseif key == ui.VK.RETURN then
        insert_text("\n")
    elseif key == ui.VK.LEFT then
        editor.cursor = math.max(0, editor.cursor - 1)
    elseif key == ui.VK.RIGHT then
        editor.cursor = math.min(#editor.text, editor.cursor + 1)
    end

    if shift_down then
        editor.sel_end = editor.cursor
    elseif key ~= ui.VK.SHIFT then
        clear_selection()
    end

    draw_editor()
end

function canvas:onPaint()
    draw_editor()
end

win:show()
await win:showasync()