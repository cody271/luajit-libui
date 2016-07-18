local ui = require("libui")

local function makeBasicControlsPage()
  local vbox = ui.VerticalBox()
  vbox.Padded = true

  local hbox = ui.HorizontalBox()
  hbox.Padded = true
  vbox:Append(hbox, false)

  hbox:Append(ui.Button("Button"), false)
  hbox:Append(ui.Checkbox("Checkbox"), false)

  vbox:Append(ui.Label("This is a label. Right now, labels can only span one line."), false)
  vbox:Append(ui.HorizontalSeparator(), false)

  local group = ui.Group("Entries")
  group.Margined = true
  vbox:Append(group, true)

  local entryForm = ui.Form()
  entryForm.Padded = true
  group.Child = entryForm

  entryForm:Append("Entry", ui.Entry(), false)
  entryForm:Append("Password Entry", ui.PasswordEntry(), false)
  entryForm:Append("Search Entry", ui.SearchEntry(), false)
  entryForm:Append("Multiline Entry", ui.MultilineEntry(), true)
  entryForm:Append("Multiline Entry No Wrap", ui.NonWrappingMultilineEntry(), true)

  return vbox
end

local function makeNumbersPage()
  local hbox = ui.HorizontalBox()
  hbox.Padded = true

  local group = ui.Group("Numbers")
  group.Margined = true
  hbox:Append(group, true)

  local vbox = ui.VerticalBox()
  vbox.Padded = true
  group.Child = vbox

  local spinbox = ui.Spinbox(0, 100)
  local slider = ui.Slider(0, 100)
  local pbar = ui.ProgressBar()
  spinbox.OnChanged = function()
    slider.Value = spinbox.Value
    pbar.Value = spinbox.Value
  end
  slider.OnChanged = function()
    spinbox.Value = slider.Value
    pbar.Value = slider.Value
  end
  vbox:Append(spinbox, false)
  vbox:Append(slider, false)
  vbox:Append(pbar, false)

  local ip = ui.ProgressBar()
  ip.Value = -1
  vbox:Append(ip, false)

  group = ui.Group("Lists")
  group.Margined = true
  hbox:Append(group, true)

  vbox = ui.VerticalBox()
  vbox.Padded = true
  group.Child = vbox

  local cbox = ui.Combobox()
  cbox:Append("Combobox Item 1")
  cbox:Append("Combobox Item 2")
  cbox:Append("Combobox Item 3")
  vbox:Append(cbox, false)

  local ecbox = ui.EditableCombobox()
  ecbox:Append("Editable Item 1")
  ecbox:Append("Editable Item 2")
  ecbox:Append("Editable Item 3")
  vbox:Append(ecbox, false)

  local rb = ui.RadioButtons()
  rb:Append("Radio Button 1")
  rb:Append("Radio Button 2")
  rb:Append("Radio Button 3")
  vbox:Append(rb, false)

  return hbox
end

local function makeDataChoosersPage(mainwin)
  local hbox = ui.HorizontalBox()
  hbox.Padded = true

  local vbox = ui.VerticalBox()
  vbox.Padded = true
  hbox:Append(vbox, false)

  vbox:Append(ui.DatePicker(), false)
  vbox:Append(ui.TimePicker(), false)
  vbox:Append(ui.DateTimePicker(), false)

  vbox:Append(ui.FontButton(), false)
  vbox:Append(ui.ColorButton(), false)

  hbox:Append(ui.VerticalSeparator(), false)

  vbox = ui.VerticalBox()
  vbox.Padded = true
  hbox:Append(vbox, true)

  local grid = ui.Grid()
  grid.Padded = true
  vbox:Append(grid, false)

  local button = ui.Button("Open File")
  local entry = ui.Entry()
  entry.ReadOnly = true
  button.OnClicked = function()
    local filename = ui.OpenFile(mainwin) or "(cancelled)"
    entry.Text = filename
  end
  grid:Append(button,
    0, 0, 1, 1,
    false, ui.Align.Fill, false, ui.Align.Fill)
  grid:Append(entry,
    1, 0, 1, 1,
    true, ui.Align.Fill, false, ui.Align.Fill);

  button = ui.Button("Save File")
  --FIXME
  local entry = ui.Entry()
  entry.ReadOnly = true
  button.OnClicked = function()
    local filename = ui.SaveFile(mainwin) or "(cancelled)"
    entry.Text = filename
  end
  grid:Append(button,
    0, 1, 1, 1,
    false, ui.Align.Fill, false, ui.Align.Fill)
  grid:Append(entry,
    1, 1, 1, 1,
    true, ui.Align.Fill, false, ui.Align.Fill)

  local msggrid = ui.Grid()
  msggrid.Padded = true
  grid:Append(msggrid,
    0, 2, 2, 1,
    0, ui.Align.Center, 0, ui.Align.Start)

  button = ui.Button("Message Box")
  button.OnClicked = function()
    ui.MsgBox(mainwin,
      "This is a normal message box.",
      "More detailed information can be shown here.")
  end
  msggrid:Append(button,
    0, 0, 1, 1,
    false, ui.Align.Fill, false, ui.Align.Fill)
  button = ui.Button("Error Box")
  button.OnClicked = function()
    ui.MsgBoxError(mainwin,
      "This message box describes an error.",
      "More detailed information can be shown here.")
  end
  msggrid:Append(button,
    1, 0, 1, 1,
    false, ui.Align.Fill, false, ui.Align.Fill)

  return hbox
end

local function main()
  ui.Init()

  local mainwin = ui.Window("libui Control Gallery", 640, 480, true)
  mainwin.OnClosing = function()
    ui.Quit()
    return true
  end
  ui.OnShouldQuit = function()
    mainwin:Destroy()
    return true
  end

  local tab = ui.Tab()
  mainwin.Child = tab
  mainwin.Margined = true

  tab:Append("Basic Controls", makeBasicControlsPage())
  tab:SetMargined(0, true)

  tab:Append("Numbers and Lists", makeNumbersPage())
  tab:SetMargined(1, true)

  tab:Append("Data Choosers", makeDataChoosersPage(mainwin))
  tab:SetMargined(2, true)

  mainwin:Show()
  ui.Main()
end

main()

