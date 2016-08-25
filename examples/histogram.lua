local pl = require("pl.import_into")()
local ui = require("libui")

-- some metrics
local xoffLeft = 20     -- histogram margins
local yoffTop = 20
local xoffRight = 20
local yoffBottom = 20
local pointRadius = 5

-- and some colors
-- names and values from https://msdn.microsoft.com/en-us/library/windows/desktop/dd370907%28v=vs.85%29.aspx
local colorWhite = ui.Brush { R = 1, G = 1, B = 1, A = 1 }
local colorBlack = ui.Brush { R = 0, G = 0, B = 0, A = 1 }
local colorDodgerBlue = { 0.11764705882353, 0.56470588235294, 1, 1 }

local Histogram = pl.class(ui.Area)

function Histogram:_init(datapoints)
  self:super()
  self.datapoints = datapoints
  self.currentPoint = -1
end

function Histogram:pointLocations(width, height)
  local xs, ys, n = {}, {}
  local xincr = width / 9   -- 10 - 1 to make the last point be at the end
  local yincr = height / 100

  for i = 1, 10 do
    -- get the value of the point
    n = self.datapoints[i].Value
    -- because y=0 is the top but n=0 is the bottom, we need to flip
    n = 100 - n
    xs[i] = xincr * (i - 1)
    ys[i] = yincr * n
  end
  return xs, ys
end

function Histogram:constructGraph(width, height, extend)
  local xs, ys = self:pointLocations(width, height)

  local path = ui.Path()

  path:NewFigure(xs[1], ys[1])
  for i = 2, 10 do
    path:LineTo(xs[i], ys[i])
  end
  
  if extend then
    path:LineTo(width, height)
    path:LineTo(0, height)
    path:CloseFigure()
  end

  path:End()
  return path
end

local function graphSize(clientWidth, clientHeight)
  local graphWidth = clientWidth - xoffLeft - xoffRight
  local graphHeight = clientHeight - yoffTop - yoffBottom
  return graphWidth, graphHeight
end

function Histogram:Draw(p)
  local path = ui.Path()
  local brush = ui.Brush()
  local sp = ui.StrokeParams()
  local m = ui.Matrix()

  -- fill the area with white
  path:AddRectangle(0, 0, p.AreaWidth, p.AreaHeight)
  path:End(path)
  p.Context:Fill(path, colorWhite)

  -- figure out dimensions
  local graphWidth, graphHeight = graphSize(p.AreaWidth, p.AreaHeight)

  -- make a stroke for both the axes and the histogram line
  sp.Cap = ui.LineCap.Flat
  sp.Join = ui.LineJoin.Miter
  sp.Thickness = 2

  -- draw the axes
  path = ui.Path()
  path:NewFigure(xoffLeft, yoffTop)
  path:LineTo(xoffLeft, yoffTop + graphHeight)
  path:LineTo(xoffLeft + graphWidth, yoffTop + graphHeight)
  path:End()
  p.Context:Stroke(path, colorBlack, sp)

  -- now transform the coordinate space so (0, 0) is the top-left corner of the graph
  m:Translate(xoffLeft, yoffTop)
  p.Context:Transform(m)

  -- now get the color for the graph itself and set up the brush
  local graphA
  brush.R, brush.G, brush.B, graphA = table.unpack(self.currentColor)
  -- we set brush->A below to different values for the fill and stroke

  -- now create the fill for the graph below the graph line
  path = self:constructGraph(graphWidth, graphHeight, true)
  brush.A = graphA / 2
  p.Context:Fill(path, brush)

  -- now draw the histogram line
  path = self:constructGraph(graphWidth, graphHeight, false)
  brush.A = graphA
  p.Context:Stroke(path, brush, sp)

  -- now draw the point being hovered over
  if self.currentPoint ~= -1 then
    local xs, ys = self:pointLocations(graphWidth, graphHeight)
    path = ui.Path()
    path:NewFigureWithArc(
      xs[self.currentPoint], ys[self.currentPoint],
      pointRadius,
      0, 6.23,    -- TODO pi
      0)
    path:End()
    -- use the same brush as for the histogram lines
    p.Context:Fill(path, brush)
  end
end

local function inPoint(x, y, xtest, ytest)
  -- TODO switch to using a matrix
  x = x - xoffLeft
  y = y - yoffTop
  return (x >= xtest - pointRadius) and
    (x <= xtest + pointRadius) and
    (y >= ytest - pointRadius) and
    (y <= ytest + pointRadius)
end

function Histogram:MouseEvent(e)
  local graphWidth, graphHeight = graphSize(e.AreaWidth, e.AreaHeight)
  local xs, ys = self:pointLocations(graphWidth, graphHeight)
  local p = -1

  for i = 1, 10 do
    if inPoint(e.X, e.Y, xs[i], ys[i]) then
      p = i
    end
  end

  self.currentPoint = p
  -- TODO only redraw the relevant area
  self:QueueRedrawAll()
end

local function main()
  ui.Init()

  local mainwin = ui.Window("libui Histogram Example", 640, 480, true)
  mainwin.Margined = true
  mainwin.OnClosing = function()
    mainwin:Destroy()
    ui.Quit()
    return false
  end
  ui.OnShouldQuit = function()
    mainwin:Destroy()
    return true
  end
  
  local hbox = ui.HorizontalBox()
  hbox.Padded = true
  mainwin.Child = hbox

  local vbox = ui.VerticalBox()
  vbox.Padded = true
  hbox:Append(vbox, false)

  local datapoints = {}
  local histogram = Histogram(datapoints)
  local onDatapointChanged = function()
    histogram:QueueRedrawAll()
  end
  math.randomseed(os.time())
  for i = 1, 10 do
    local datapoint = ui.Spinbox(0, 100)
    datapoint.Value = math.random(0, 100)
    datapoint.OnChanged = onDatapointChanged
    vbox:Append(datapoint, false)
    datapoints[i] = datapoint
  end
  hbox:Append(histogram, true)

  local colorButton = ui.ColorButton()
  colorButton.Color = colorDodgerBlue
  local onColorChanged = function()
    histogram.currentColor = colorButton.Color
    histogram:QueueRedrawAll()
  end
  colorButton.OnChanged = onColorChanged
  onColorChanged()
  vbox:Append(colorButton, false)

  mainwin:Show()
  ui.Main()
end

main()

