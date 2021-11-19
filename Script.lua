repeat wait()
until game:IsLoaded()
local ui = game:GetService("CoreGui"):FindFirstChild("Island V2 | Blox Fruit (Open-Beta)")
if ui then
   ui:Destroy()
end
-- init
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- services
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new

-- additional
local utility = {}

-- themes
local objects = {}
local themes = {
Background = Color3.fromRGB(15,15,15), 
Glow = Color3.fromRGB(0, 0, 0), 
Accent = Color3.fromRGB(10, 10, 10), 
LightContrast = Color3.fromRGB(20, 20, 20), 
DarkContrast = Color3.fromRGB(10,10,10),  
TextColor = Color3.fromRGB(0, 0, 255)
}

do
function utility:Create(instance, properties, children)
   local object = Instance.new(instance)

   for i, v in pairs(properties or {}) do
      object[i] = v

      if typeof(v) == "Color3" then -- save for theme changer later
         local theme = utility:Find(themes, v)

         if theme then
            objects[theme] = objects[theme] or {}
            objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})

            table.insert(objects[theme][i], object)
         end
      end
   end

   for i, module in pairs(children or {}) do
      module.Parent = object
   end

   return object
end

function utility:Tween(instance, properties, duration, ...)
   tween:Create(instance, tweeninfo(duration, ...), properties):Play()
end

function utility:Wait()
   run.RenderStepped:Wait()
   return true
end

function utility:Find(table, value) -- table.find doesn't work for dictionaries
   for i, v in  pairs(table) do
      if v == value then
         return i
      end
   end
end

function utility:Sort(pattern, values)
   local new = {}
   pattern = pattern:lower()

   if pattern == "" then
      return values
   end

   for i, value in pairs(values) do
      if tostring(value):lower():find(pattern) then
         table.insert(new, value)
      end
   end

   return new
end

function utility:Pop(object, shrink)
   local clone = object:Clone()

   clone.AnchorPoint = Vector2.new(0.5, 0.5)
   clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
   clone.Position = UDim2.new(0.5, 0, 0.5, 0)

   clone.Parent = object
   clone:ClearAllChildren()

   object.ImageTransparency = 1
   utility:Tween(clone, {Size = object.Size}, 0.2)

   spawn(function()
      wait(0.2)

      object.ImageTransparency = 0
      clone:Destroy()
   end)

   return clone
end

function utility:InitializeKeybind()
   self.keybinds = {}
   self.ended = {}

   input.InputBegan:Connect(function(key)
      if self.keybinds[key.KeyCode] then
         for i, bind in pairs(self.keybinds[key.KeyCode]) do
            bind()
         end
      end
   end)

   input.InputEnded:Connect(function(key)
      if key.UserInputType == Enum.UserInputType.MouseButton1 then
         for i, callback in pairs(self.ended) do
            callback()
         end
      end
   end)
end

function utility:BindToKey(key, callback)

   self.keybinds[key] = self.keybinds[key] or {}

   table.insert(self.keybinds[key], callback)

   return {
      UnBind = function()
         for i, bind in pairs(self.keybinds[key]) do
            if bind == callback then
               table.remove(self.keybinds[key], i)
            end
         end
      end
   }
end

function utility:KeyPressed() -- yield until next key is pressed
   local key = input.InputBegan:Wait()

   while key.UserInputType ~= Enum.UserInputType.Keyboard	 do
      key = input.InputBegan:Wait()
   end

   wait() -- overlapping connection

   return key
end

function utility:DraggingEnabled(frame, parent)

   parent = parent or frame

   -- stolen from wally or kiriot, kek
   local dragging = false
   local dragInput, mousePos, framePos

   frame.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
         dragging = true
         mousePos = input.Position
         framePos = parent.Position

         input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
               dragging = false
            end
         end)
      end
   end)

   frame.InputChanged:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseMovement then
         dragInput = input
      end
   end)

   input.InputChanged:Connect(function(input)
      if input == dragInput and dragging then
         local delta = input.Position - mousePos
         parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
      end
   end)

end

function utility:DraggingEnded(callback)
   table.insert(self.ended, callback)
end

end

-- classes

local library = {} -- main
local page = {}
local section = {}

do
library.__index = library
page.__index = page
section.__index = section

-- new classes

function library.new(title)
   local container = utility:Create("ScreenGui", {
      Name = title,
      Parent = game.CoreGui
   }, {
      utility:Create("ImageLabel", {
         Name = "Main",
         BackgroundTransparency = 1,
         Position = UDim2.new(0.25, 0, 0.052435593, 0),
         Size = UDim2.new(0, 511, 0, 428),
         Image = "rbxassetid://4641149554",
         ImageColor3 = themes.Background,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(4, 4, 296, 296)
      }, {
         utility:Create("ImageLabel", {
            Name = "Glow",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -15, 0, -15),
            Size = UDim2.new(1, 30, 1, 30),
            ZIndex = 0,
            Image = "rbxassetid://5028857084",
            ImageColor3 = themes.Glow,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276)
         }),
         utility:Create("ImageLabel", {
            Name = "Pages",
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(0, 0, 0, 38),
            Size = UDim2.new(0, 126, 1, -38),
            ZIndex = 3,
            Image = "rbxassetid://5012534273",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 4, 296, 296)
         }, {
            utility:Create("ScrollingFrame", {
               Name = "Pages_Container",
               Active = true,
               BackgroundTransparency = 1,
               Position = UDim2.new(0, 0, 0, 10),
               Size = UDim2.new(1, 0, 1, -20),
               CanvasSize = UDim2.new(0, 0, 0, 314),
               ScrollBarThickness = 0
            }, {
               utility:Create("UIListLayout", {
                  SortOrder = Enum.SortOrder.LayoutOrder,
                  Padding = UDim.new(0, 10)
               })
            })
         }),
         utility:Create("ImageLabel", {
            Name = "TopBar",
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 38),
            ZIndex = 5,
            Image = "rbxassetid://4595286933",
            ImageColor3 = themes.Accent,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 4, 296, 296)
         }, {
            utility:Create("TextLabel", { -- title
               Name = "Title",
               AnchorPoint = Vector2.new(0, 0.5),
               BackgroundTransparency = 1,
               Position = UDim2.new(0, 12, 0, 19),
               Size = UDim2.new(1, -46, 0, 16),
               ZIndex = 5,
               Font = Enum.Font.GothamBold,
               Text = title,
               TextColor3 = themes.TextColor,
               TextSize = 14,
               TextXAlignment = Enum.TextXAlignment.Left
            })
         })
      })
   })

   utility:InitializeKeybind()
   utility:DraggingEnabled(container.Main.TopBar, container.Main)

   return setmetatable({
      container = container,
      pagesContainer = container.Main.Pages.Pages_Container,
      pages = {}
   }, library)
end

function page.new(library, title, icon)
   local button = utility:Create("TextButton", {
      Name = title,
      Parent = library.pagesContainer,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 26),
      ZIndex = 3,
      AutoButtonColor = false,
      Font = Enum.Font.Gotham,
      Text = "",
      TextSize = 14
   }, {
      utility:Create("TextLabel", {
         Name = "Title",
         AnchorPoint = Vector2.new(0, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 40, 0.5, 0),
         Size = UDim2.new(0, 76, 1, 0),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.65,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      icon and utility:Create("ImageLabel", {
         Name = "Icon", 
         AnchorPoint = Vector2.new(0, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 12, 0.5, 0),
         Size = UDim2.new(0, 16, 0, 16),
         ZIndex = 3,
         Image = "rbxassetid://" .. tostring(icon),
         ImageColor3 = themes.TextColor,
         ImageTransparency = 0.64
      }) or {}
   })

   local container = utility:Create("ScrollingFrame", {
      Name = title,
      Parent = library.container.Main,
      Active = true,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Position = UDim2.new(0, 134, 0, 46),
      Size = UDim2.new(1, -142, 1, -56),
      CanvasSize = UDim2.new(0, 0, 0, 466),
      ScrollBarThickness = 3,
      ScrollBarImageColor3 = themes.DarkContrast,
      Visible = false
   }, {
      utility:Create("UIListLayout", {
         SortOrder = Enum.SortOrder.LayoutOrder,
         Padding = UDim.new(0, 10)
      })
   })

   return setmetatable({
      library = library,
      container = container,
      button = button,
      sections = {}
   }, page)
end

function section.new(page, title)
   local container = utility:Create("ImageLabel", {
      Name = title,
      Parent = page.container,
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -10, 0, 28),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.LightContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(4, 4, 296, 296),
      ClipsDescendants = true
   }, {
      utility:Create("Frame", {
         Name = "Container",
         Active = true,
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Position = UDim2.new(0, 8, 0, 8),
         Size = UDim2.new(1, -16, 1, -16)
      }, {
         utility:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 2,
            Font = Enum.Font.GothamSemibold,
            Text = title,
            TextColor3 = themes.TextColor,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
         }),
         utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
         })
      })
   })

   return setmetatable({
      page = page,
      container = container.Container,
      colorpickers = {},
      modules = {},
      binds = {},
      lists = {},
   }, section) 
end

function library:addPage(...)

   local page = page.new(self, ...)
   local button = page.button

   table.insert(self.pages, page)

   button.MouseButton1Click:Connect(function()
      self:SelectPage(page, true)
   end)

   return page
end

function page:addSection(...)
   local section = section.new(self, ...)

   table.insert(self.sections, section)

   return section
end

-- functions

function library:setTheme(theme, color3)
   themes[theme] = color3

   for property, objects in pairs(objects[theme]) do
      for i, object in pairs(objects) do
         if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
            objects[i] = nil -- i can do this because weak tables :D
         else
            object[property] = color3
         end
      end
   end
end

function library:toggle()

   if self.toggling then
      return
   end

   self.toggling = true

   local container = self.container.Main
   local topbar = container.TopBar

   if self.position then
      utility:Tween(container, {
         Size = UDim2.new(0, 511, 0, 428),
         Position = self.position
      }, 0.2)
      wait(0.2)

      utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
      wait(0.2)

      container.ClipsDescendants = false
      self.position = nil
   else
      self.position = container.Position
      container.ClipsDescendants = true

      utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
      wait(0.2)

      utility:Tween(container, {
         Size = UDim2.new(0, 511, 0, 0),
         Position = self.position + UDim2.new(0, 0, 0, 428)
      }, 0.2)
      wait(0.2)
   end

   self.toggling = false
end

-- new modules

function library:Notify(title, text, callback)

   -- overwrite last notification
   if self.activeNotification then
      self.activeNotification = self.activeNotification()
   end

   -- standard create
   local notification = utility:Create("ImageLabel", {
      Name = "Notification",
      Parent = self.container,
      BackgroundTransparency = 1,
      Size = UDim2.new(0, 200, 0, 60),
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.Background,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(4, 4, 296, 296),
      ZIndex = 3,
      ClipsDescendants = true
   }, {
      utility:Create("ImageLabel", {
         Name = "Flash",
         Size = UDim2.new(1, 0, 1, 0),
         BackgroundTransparency = 1,
         Image = "rbxassetid://4641149554",
         ImageColor3 = themes.TextColor,
         ZIndex = 5
      }),
      utility:Create("ImageLabel", {
         Name = "Glow",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, -15, 0, -15),
         Size = UDim2.new(1, 30, 1, 30),
         ZIndex = 2,
         Image = "rbxassetid://5028857084",
         ImageColor3 = themes.Glow,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(24, 24, 276, 276)
      }),
      utility:Create("TextLabel", {
         Name = "Title",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0, 8),
         Size = UDim2.new(1, -40, 0, 16),
         ZIndex = 4,
         Font = Enum.Font.GothamSemibold,
         TextColor3 = themes.TextColor,
         TextSize = 14.000,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("TextLabel", {
         Name = "Text",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 1, -24),
         Size = UDim2.new(1, -40, 0, 16),
         ZIndex = 4,
         Font = Enum.Font.Gotham,
         TextColor3 = themes.TextColor,
         TextSize = 12.000,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("ImageButton", {
         Name = "Accept",
         BackgroundTransparency = 1,
         Position = UDim2.new(1, -26, 0, 8),
         Size = UDim2.new(0, 16, 0, 16),
         Image = "rbxassetid://5012538259",
         ImageColor3 = themes.TextColor,
         ZIndex = 4
      }),
      utility:Create("ImageButton", {
         Name = "Decline",
         BackgroundTransparency = 1,
         Position = UDim2.new(1, -26, 1, -24),
         Size = UDim2.new(0, 16, 0, 16),
         Image = "rbxassetid://5012538583",
         ImageColor3 = themes.TextColor,
         ZIndex = 4
      })
   })

   -- dragging
   utility:DraggingEnabled(notification)

   -- position and size
   title = title or "Notification"
   text = text or ""

   notification.Title.Text = title
   notification.Text.Text = text

   local padding = 10
   local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

   notification.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
   notification.Size = UDim2.new(0, 0, 0, 60)

   utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
   wait(0.2)

   notification.ClipsDescendants = false
   utility:Tween(notification.Flash, {
      Size = UDim2.new(0, 0, 0, 60),
      Position = UDim2.new(1, 0, 0, 0)
   }, 0.2)

   -- callbacks
   local active = true
   local close = function()

      if not active then
         return
      end

      active = false
      notification.ClipsDescendants = true

      library.lastNotification = notification.Position
      notification.Flash.Position = UDim2.new(0, 0, 0, 0)
      utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)

      wait(0.2)
      utility:Tween(notification, {
         Size = UDim2.new(0, 0, 0, 60),
         Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)
      }, 0.2)

      wait(0.2)
      notification:Destroy()
   end

   self.activeNotification = close

   notification.Accept.MouseButton1Click:Connect(function()

      if not active then 
         return
      end

      if callback then
         callback(true)
      end

      close()
   end)

   notification.Decline.MouseButton1Click:Connect(function()

      if not active then 
         return
      end

      if callback then
         callback(false)
      end

      close()
   end)
end

function section:addButton(title, callback)
   local button = utility:Create("ImageButton", {
      Name = "Button",
      Parent = self.container,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.DarkContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298)
   }, {
      utility:Create("TextLabel", {
         Name = "Title",
         BackgroundTransparency = 1,
         Size = UDim2.new(1, 0, 1, 0),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.10000000149012
      })
   })

   table.insert(self.modules, button)
   --self:Resize()

   local text = button.Title
   local debounce

   button.MouseButton1Click:Connect(function()

      if debounce then
         return
      end

      -- animation
      utility:Pop(button, 10)

      debounce = true
      text.TextSize = 0
      utility:Tween(button.Title, {TextSize = 14}, 0.2)

      wait(0.2)
      utility:Tween(button.Title, {TextSize = 12}, 0.2)

      if callback then
         callback(function(...)
            self:updateButton(button, ...)
         end)
      end

      debounce = false
   end)

   return button
end

function section:addToggle(title, default, callback)
   local toggle = utility:Create("ImageButton", {
      Name = "Toggle",
      Parent = self.container,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.DarkContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298)
   },{
      utility:Create("TextLabel", {
         Name = "Title",
         AnchorPoint = Vector2.new(0, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0.5, 1),
         Size = UDim2.new(0.5, 0, 1, 0),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.10000000149012,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("ImageLabel", {
         Name = "Button",
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Position = UDim2.new(1, -50, 0.5, -8),
         Size = UDim2.new(0, 40, 0, 16),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = themes.LightContrast,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      }, {
         utility:Create("ImageLabel", {
            Name = "Frame",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 2, 0.5, -6),
            Size = UDim2.new(1, -22, 1, -4),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.TextColor,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
         })
      })
   })

   table.insert(self.modules, toggle)
   --self:Resize()

   local active = default
   local active = default
   self:updateToggle(toggle, nil, active)

   toggle.MouseButton1Click:Connect(function()
      active = not active
      self:updateToggle(toggle, nil, active)

      if callback then
         callback(active, function(...)
            self:updateToggle(toggle, ...)
         end)
      end
   end)

   return toggle
end

function section:addTextbox(title, default, callback)
   local textbox = utility:Create("ImageButton", {
      Name = "Textbox",
      Parent = self.container,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.DarkContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298)
   }, {
      utility:Create("TextLabel", {
         Name = "Title",
         AnchorPoint = Vector2.new(0, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0.5, 1),
         Size = UDim2.new(0.5, 0, 1, 0),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.10000000149012,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("ImageLabel", {
         Name = "Button",
         BackgroundTransparency = 1,
         Position = UDim2.new(1, -110, 0.5, -8),
         Size = UDim2.new(0, 100, 0, 16),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = themes.LightContrast,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      }, {
         utility:Create("TextBox", {
            Name = "Textbox", 
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.GothamSemibold,
            Text = default or "",
            TextColor3 = themes.TextColor,
            TextSize = 11
         })
      })
   })

   table.insert(self.modules, textbox)
   --self:Resize()

   local button = textbox.Button
   local input = button.Textbox

   textbox.MouseButton1Click:Connect(function()

      if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then
         return
      end

      utility:Tween(textbox.Button, {
         Size = UDim2.new(0, 200, 0, 16),
         Position = UDim2.new(1, -210, 0.5, -8)
      }, 0.2)

      wait()

      input.TextXAlignment = Enum.TextXAlignment.Left
      input:CaptureFocus()
   end)

   input:GetPropertyChangedSignal("Text"):Connect(function()

      if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then -- i know, i dont like this either
         utility:Pop(button, 10)
      end

      if callback then
         callback(input.Text, nil, function(...)
            self:updateTextbox(textbox, ...)
         end)
      end
   end)

   input.FocusLost:Connect(function()

      input.TextXAlignment = Enum.TextXAlignment.Center

      utility:Tween(textbox.Button, {
         Size = UDim2.new(0, 100, 0, 16),
         Position = UDim2.new(1, -110, 0.5, -8)
      }, 0.2)

      if callback then
         callback(input.Text, true, function(...)
            self:updateTextbox(textbox, ...)
         end)
      end
   end)

   return textbox
end

function section:addKeybind(title, default, callback, changedCallback)
   local keybind = utility:Create("ImageButton", {
      Name = "Keybind",
      Parent = self.container,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.DarkContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298)
   }, {
      utility:Create("TextLabel", {
         Name = "Title",
         AnchorPoint = Vector2.new(0, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0.5, 1),
         Size = UDim2.new(1, 0, 1, 0),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.10000000149012,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("ImageLabel", {
         Name = "Button",
         BackgroundTransparency = 1,
         Position = UDim2.new(1, -110, 0.5, -8),
         Size = UDim2.new(0, 100, 0, 16),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = themes.LightContrast,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      }, {
         utility:Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.GothamSemibold,
            Text = default and default.Name or "None",
            TextColor3 = themes.TextColor,
            TextSize = 11
         })
      })
   })

   table.insert(self.modules, keybind)
   --self:Resize()

   local text = keybind.Button.Text
   local button = keybind.Button

   local animate = function()
      if button.ImageTransparency == 0 then
         utility:Pop(button, 10)
      end
   end

   self.binds[keybind] = {callback = function()
      animate()

      if callback then
         callback(function(...)
            self:updateKeybind(keybind, ...)
         end)
      end
   end}

   if default and callback then
      self:updateKeybind(keybind, nil, default)
   end

   keybind.MouseButton1Click:Connect(function()

      animate()

      if self.binds[keybind].connection then -- unbind
         return self:updateKeybind(keybind)
      end

      if text.Text == "None" then -- new bind
         text.Text = "..."

         local key = utility:KeyPressed()

         self:updateKeybind(keybind, nil, key.KeyCode)
         animate()

         if changedCallback then
            changedCallback(key, function(...)
               self:updateKeybind(keybind, ...)
            end)
         end
      end
   end)

   return keybind
end

function section:addColorPicker(title, default, callback)
   local colorpicker = utility:Create("ImageButton", {
      Name = "ColorPicker",
      Parent = self.container,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.DarkContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298)
   },{
      utility:Create("TextLabel", {
         Name = "Title",
         AnchorPoint = Vector2.new(0, 0.5),
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0.5, 1),
         Size = UDim2.new(0.5, 0, 1, 0),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.10000000149012,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("ImageButton", {
         Name = "Button",
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Position = UDim2.new(1, -50, 0.5, -7),
         Size = UDim2.new(0, 40, 0, 14),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = Color3.fromRGB(255, 255, 255),
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      })
   })

   local tab = utility:Create("ImageLabel", {
      Name = "ColorPicker",
      Parent = self.page.library.container,
      BackgroundTransparency = 1,
      Position = UDim2.new(0.75, 0, 0.400000006, 0),
      Selectable = true,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0, 162, 0, 169),
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.Background,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298),
      Visible = false,
   }, {
      utility:Create("ImageLabel", {
         Name = "Glow",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, -15, 0, -15),
         Size = UDim2.new(1, 30, 1, 30),
         ZIndex = 0,
         Image = "rbxassetid://5028857084",
         ImageColor3 = themes.Glow,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(22, 22, 278, 278)
      }),
      utility:Create("TextLabel", {
         Name = "Title",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0, 8),
         Size = UDim2.new(1, -40, 0, 16),
         ZIndex = 2,
         Font = Enum.Font.GothamSemibold,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 14,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("ImageButton", {
         Name = "Close",
         BackgroundTransparency = 1,
         Position = UDim2.new(1, -26, 0, 8),
         Size = UDim2.new(0, 16, 0, 16),
         ZIndex = 2,
         Image = "rbxassetid://5012538583",
         ImageColor3 = themes.TextColor
      }), 
      utility:Create("Frame", {
         Name = "Container",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 8, 0, 32),
         Size = UDim2.new(1, -18, 1, -40)
      }, {
         utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
         }),
         utility:Create("ImageButton", {
            Name = "Canvas",
            BackgroundTransparency = 1,
            BorderColor3 = themes.LightContrast,
            Size = UDim2.new(1, 0, 0, 60),
            AutoButtonColor = false,
            Image = "rbxassetid://5108535320",
            ImageColor3 = Color3.fromRGB(255, 0, 0),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
         }, {
            utility:Create("ImageLabel", {
               Name = "White_Overlay",
               BackgroundTransparency = 1,
               Size = UDim2.new(1, 0, 0, 60),
               Image = "rbxassetid://5107152351",
               SliceCenter = Rect.new(2, 2, 298, 298)
            }),
            utility:Create("ImageLabel", {
               Name = "Black_Overlay",
               BackgroundTransparency = 1,
               Size = UDim2.new(1, 0, 0, 60),
               Image = "rbxassetid://5107152095",
               SliceCenter = Rect.new(2, 2, 298, 298)
            }),
            utility:Create("ImageLabel", {
               Name = "Cursor",
               BackgroundColor3 = themes.TextColor,
               AnchorPoint = Vector2.new(0.5, 0.5),
               BackgroundTransparency = 1.000,
               Size = UDim2.new(0, 10, 0, 10),
               Position = UDim2.new(0, 0, 0, 0),
               Image = "rbxassetid://5100115962",
               SliceCenter = Rect.new(2, 2, 298, 298)
            })
         }),
         utility:Create("ImageButton", {
            Name = "Color",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 4),
            Selectable = false,
            Size = UDim2.new(1, 0, 0, 16),
            ZIndex = 2,
            AutoButtonColor = false,
            Image = "rbxassetid://5028857472",
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
         }, {
            utility:Create("Frame", {
               Name = "Select",
               BackgroundColor3 = themes.TextColor,
               BorderSizePixel = 1,
               Position = UDim2.new(1, 0, 0, 0),
               Size = UDim2.new(0, 2, 1, 0),
               ZIndex = 2
            }),
            utility:Create("UIGradient", { -- rainbow canvas
               Color = ColorSequence.new({
                  ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), 
                  ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), 
                  ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), 
                  ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), 
                  ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), 
                  ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)), 
                  ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
               })
            })
         }),
         utility:Create("Frame", {
            Name = "Inputs",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 158),
            Size = UDim2.new(1, 0, 0, 16)
         }, {
            utility:Create("UIListLayout", {
               FillDirection = Enum.FillDirection.Horizontal,
               SortOrder = Enum.SortOrder.LayoutOrder,
               Padding = UDim.new(0, 6)
            }),
            utility:Create("ImageLabel", {
               Name = "R",
               BackgroundTransparency = 1,
               BorderSizePixel = 0,
               Size = UDim2.new(0.305, 0, 1, 0),
               ZIndex = 2,
               Image = "rbxassetid://5028857472",
               ImageColor3 = themes.DarkContrast,
               ScaleType = Enum.ScaleType.Slice,
               SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
               utility:Create("TextLabel", {
                  Name = "Text",
                  BackgroundTransparency = 1,
                  Size = UDim2.new(0.400000006, 0, 1, 0),
                  ZIndex = 2,
                  Font = Enum.Font.Gotham,
                  Text = "R:",
                  TextColor3 = themes.TextColor,
                  TextSize = 10.000
               }),
               utility:Create("TextBox", {
                  Name = "Textbox",
                  BackgroundTransparency = 1,
                  Position = UDim2.new(0.300000012, 0, 0, 0),
                  Size = UDim2.new(0.600000024, 0, 1, 0),
                  ZIndex = 2,
                  Font = Enum.Font.Gotham,
                  PlaceholderColor3 = themes.DarkContrast,
                  Text = "255",
                  TextColor3 = themes.TextColor,
                  TextSize = 10.000
               })
            }),
            utility:Create("ImageLabel", {
               Name = "G",
               BackgroundTransparency = 1,
               BorderSizePixel = 0,
               Size = UDim2.new(0.305, 0, 1, 0),
               ZIndex = 2,
               Image = "rbxassetid://5028857472",
               ImageColor3 = themes.DarkContrast,
               ScaleType = Enum.ScaleType.Slice,
               SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
               utility:Create("TextLabel", {
                  Name = "Text",
                  BackgroundTransparency = 1,
                  ZIndex = 2,
                  Size = UDim2.new(0.400000006, 0, 1, 0),
                  Font = Enum.Font.Gotham,
                  Text = "G:",
                  TextColor3 = themes.TextColor,
                  TextSize = 10.000
               }),
               utility:Create("TextBox", {
                  Name = "Textbox",
                  BackgroundTransparency = 1,
                  Position = UDim2.new(0.300000012, 0, 0, 0),
                  Size = UDim2.new(0.600000024, 0, 1, 0),
                  ZIndex = 2,
                  Font = Enum.Font.Gotham,
                  Text = "255",
                  TextColor3 = themes.TextColor,
                  TextSize = 10.000
               })
            }),
            utility:Create("ImageLabel", {
               Name = "B",
               BackgroundTransparency = 1,
               BorderSizePixel = 0,
               Size = UDim2.new(0.305, 0, 1, 0),
               ZIndex = 2,
               Image = "rbxassetid://5028857472",
               ImageColor3 = themes.DarkContrast,
               ScaleType = Enum.ScaleType.Slice,
               SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
               utility:Create("TextLabel", {
                  Name = "Text",
                  BackgroundTransparency = 1,
                  Size = UDim2.new(0.400000006, 0, 1, 0),
                  ZIndex = 2,
                  Font = Enum.Font.Gotham,
                  Text = "B:",
                  TextColor3 = themes.TextColor,
                  TextSize = 10.000
               }),
               utility:Create("TextBox", {
                  Name = "Textbox",
                  BackgroundTransparency = 1,
                  Position = UDim2.new(0.300000012, 0, 0, 0),
                  Size = UDim2.new(0.600000024, 0, 1, 0),
                  ZIndex = 2,
                  Font = Enum.Font.Gotham,
                  Text = "255",
                  TextColor3 = themes.TextColor,
                  TextSize = 10.000
               })
            }),
         }),
         utility:Create("ImageButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 20),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
         }, {
            utility:Create("TextLabel", {
               Name = "Text",
               BackgroundTransparency = 1,
               Size = UDim2.new(1, 0, 1, 0),
               ZIndex = 3,
               Font = Enum.Font.Gotham,
               Text = "Submit",
               TextColor3 = themes.TextColor,
               TextSize = 11.000
            })
         })
      })
   })

   utility:DraggingEnabled(tab)
   table.insert(self.modules, colorpicker)
   --self:Resize()

   local allowed = {
      [""] = true
   }

   local canvas = tab.Container.Canvas
   local color = tab.Container.Color

   local canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
   local colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition

   local draggingColor, draggingCanvas

   local color3 = default or Color3.fromRGB(255, 255, 255)
   local hue, sat, brightness = 0, 0, 1
   local rgb = {
      r = 255,
      g = 255,
      b = 255
   }

   self.colorpickers[colorpicker] = {
      tab = tab,
      callback = function(prop, value)
         rgb[prop] = value
         hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
      end
   }

   local callback = function(value)
      if callback then
         callback(value, function(...)
            self:updateColorPicker(colorpicker, ...)
         end)
      end
   end

   utility:DraggingEnded(function()
      draggingColor, draggingCanvas = false, false
   end)

   if default then
      self:updateColorPicker(colorpicker, nil, default)

      hue, sat, brightness = Color3.toHSV(default)
      default = Color3.fromHSV(hue, sat, brightness)

      for i, prop in pairs({"r", "g", "b"}) do
         rgb[prop] = default[prop:upper()] * 255
      end
   end

   for i, container in pairs(tab.Container.Inputs:GetChildren()) do -- i know what you are about to say, so shut up
      if container:IsA("ImageLabel") then
         local textbox = container.Textbox
         local focused

         textbox.Focused:Connect(function()
            focused = true
         end)

         textbox.FocusLost:Connect(function()
            focused = false

            if not tonumber(textbox.Text) then
               textbox.Text = math.floor(rgb[container.Name:lower()])
            end
         end)

         textbox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = textbox.Text

            if not allowed[text] and not tonumber(text) then
               textbox.Text = text:sub(1, #text - 1)
            elseif focused and not allowed[text] then
               rgb[container.Name:lower()] = math.clamp(tonumber(textbox.Text), 0, 255)

               local color3 = Color3.fromRGB(rgb.r, rgb.g, rgb.b)
               hue, sat, brightness = Color3.toHSV(color3)

               self:updateColorPicker(colorpicker, nil, color3)
               callback(color3)
            end
         end)
      end
   end

   canvas.MouseButton1Down:Connect(function()
      draggingCanvas = true

      while draggingCanvas do

         local x, y = mouse.X, mouse.Y

         sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
         brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)

         color3 = Color3.fromHSV(hue, sat, brightness)

         for i, prop in pairs({"r", "g", "b"}) do
            rgb[prop] = color3[prop:upper()] * 255
         end

         self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
         utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1) -- overwrite

         callback(color3)
         utility:Wait()
      end
   end)

   color.MouseButton1Down:Connect(function()
      draggingColor = true

      while draggingColor do

         hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
         color3 = Color3.fromHSV(hue, sat, brightness)

         for i, prop in pairs({"r", "g", "b"}) do
            rgb[prop] = color3[prop:upper()] * 255
         end

         local x = hue -- hue is updated
         self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
         utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1) -- overwrite

         callback(color3)
         utility:Wait()
      end
   end)

   -- click events
   local button = colorpicker.Button
   local toggle, debounce, animate

   lastColor = Color3.fromHSV(hue, sat, brightness)
   animate = function(visible, overwrite)

      if overwrite then

         if not toggle then
            return
         end

         if debounce then
            while debounce do
               utility:Wait()
            end
         end
      elseif not overwrite then
         if debounce then 
            return 
         end

         if button.ImageTransparency == 0 then
            utility:Pop(button, 10)
         end
      end

      toggle = visible
      debounce = true

      if visible then

         if self.page.library.activePicker and self.page.library.activePicker ~= animate then
            self.page.library.activePicker(nil, true)
         end

         self.page.library.activePicker = animate
         lastColor = Color3.fromHSV(hue, sat, brightness)

         local x1, x2 = button.AbsoluteSize.X / 2, 162--tab.AbsoluteSize.X
         local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y

         tab.ClipsDescendants = true
         tab.Visible = true
         tab.Size = UDim2.new(0, 0, 0, 0)

         tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
         utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0.2)

         -- update size and position
         wait(0.2)
         tab.ClipsDescendants = false

         canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
         colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
      else
         utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
         tab.ClipsDescendants = true

         wait(0.2)
         tab.Visible = false
      end

      debounce = false
   end

   local toggleTab = function()
      animate(not toggle)
   end

   button.MouseButton1Click:Connect(toggleTab)
   colorpicker.MouseButton1Click:Connect(toggleTab)

   tab.Container.Button.MouseButton1Click:Connect(function()
      animate()
   end)

   tab.Close.MouseButton1Click:Connect(function()
      self:updateColorPicker(colorpicker, nil, lastColor)
      animate()
   end)

   return colorpicker
end

function section:addSlider(title, default, min, max, callback)
   local slider = utility:Create("ImageButton", {
      Name = "Slider",
      Parent = self.container,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
      Size = UDim2.new(1, 0, 0, 50),
      ZIndex = 2,
      Image = "rbxassetid://5028857472",
      ImageColor3 = themes.DarkContrast,
      ScaleType = Enum.ScaleType.Slice,
      SliceCenter = Rect.new(2, 2, 298, 298)
   }, {
      utility:Create("TextLabel", {
         Name = "Title",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0, 6),
         Size = UDim2.new(0.5, 0, 0, 16),
         ZIndex = 3,
         Font = Enum.Font.Gotham,
         Text = title,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextTransparency = 0.10000000149012,
         TextXAlignment = Enum.TextXAlignment.Left
      }),
      utility:Create("TextBox", {
         Name = "TextBox",
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Position = UDim2.new(1, -30, 0, 6),
         Size = UDim2.new(0, 20, 0, 16),
         ZIndex = 3,
         Font = Enum.Font.GothamSemibold,
         Text = default or min,
         TextColor3 = themes.TextColor,
         TextSize = 12,
         TextXAlignment = Enum.TextXAlignment.Right
      }),
      utility:Create("TextLabel", {
         Name = "Slider",
         BackgroundTransparency = 1,
         Position = UDim2.new(0, 10, 0, 28),
         Size = UDim2.new(1, -20, 0, 16),
         ZIndex = 3,
         Text = "",
      }, {
         utility:Create("ImageLabel", {
            Name = "Bar",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 4),
            ZIndex = 3,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.LightContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
         }, {
            utility:Create("ImageLabel", {
               Name = "Fill",
               BackgroundTransparency = 1,
               Size = UDim2.new(0.8, 0, 1, 0),
               ZIndex = 3,
               Image = "rbxassetid://5028857472",
               ImageColor3 = themes.TextColor,
               ScaleType = Enum.ScaleType.Slice,
               SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
               utility:Create("ImageLabel", {
                  Name = "Circle",
                  AnchorPoint = Vector2.new(0.5, 0.5),
                  BackgroundTransparency = 1,
                  ImageTransparency = 1.000,
                  ImageColor3 = themes.TextColor,
                  Position = UDim2.new(1, 0, 0.5, 0),
                  Size = UDim2.new(0, 10, 0, 10),
                  ZIndex = 3,
                  Image = "rbxassetid://4608020054"
               })
            })
         })
      })
   })

   table.insert(self.modules, slider)
   --self:Resize()

   local allowed = {
      [""] = true,
      ["-"] = true
   }

   local textbox = slider.TextBox
   local circle = slider.Slider.Bar.Fill.Circle

   local value = default or min
   local dragging, last

   local callback = function(value)
      if callback then
         callback(value, function(...)
            self:updateSlider(slider, ...)
         end)
      end
   end

   self:updateSlider(slider, nil, value, min, max)

   utility:DraggingEnded(function()
      dragging = false
   end)

   slider.MouseButton1Down:Connect(function(input)
      dragging = true

      while dragging do
         utility:Tween(circle, {ImageTransparency = 0}, 0.1)

         value = self:updateSlider(slider, nil, nil, min, max, value)
         callback(value)

         utility:Wait()
      end

      wait(0.5)
      utility:Tween(circle, {ImageTransparency = 1}, 0.2)
   end)

   textbox.FocusLost:Connect(function()
      if not tonumber(textbox.Text) then
         value = self:updateSlider(slider, nil, default or min, min, max)
         callback(value)
      end
   end)

   textbox:GetPropertyChangedSignal("Text"):Connect(function()
      local text = textbox.Text

      if not allowed[text] and not tonumber(text) then
         textbox.Text = text:sub(1, #text - 1)
      elseif not allowed[text] then	
         value = self:updateSlider(slider, nil, tonumber(text) or value, min, max)
         callback(value)
      end
   end)

   return slider
end

function section:addDropdown(title, list, callback)
   local dropdown = utility:Create("Frame", {
      Name = "Dropdown",
      Parent = self.container,
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 30),
      ClipsDescendants = true
   }, {
      utility:Create("UIListLayout", {
         SortOrder = Enum.SortOrder.LayoutOrder,
         Padding = UDim.new(0, 4)
      }),
      utility:Create("ImageLabel", {
         Name = "Search",
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Size = UDim2.new(1, 0, 0, 30),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = themes.DarkContrast,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      }, {
         utility:Create("TextBox", {
            Name = "TextBox",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.new(0, 10, 0.5, 1),
            Size = UDim2.new(1, -42, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = themes.TextColor,
            TextSize = 12,
            TextTransparency = 0.10000000149012,
            TextXAlignment = Enum.TextXAlignment.Left
         }),
         utility:Create("ImageButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -28, 0.5, -9),
            Size = UDim2.new(0, 18, 0, 18),
            ZIndex = 3,
            Image = "rbxassetid://5012539403",
            ImageColor3 = themes.TextColor,
            SliceCenter = Rect.new(2, 2, 298, 298)
         })
      }),
      utility:Create("ImageLabel", {
         Name = "List",
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Size = UDim2.new(1, 0, 1, -34),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = themes.Background,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      }, {
         utility:Create("ScrollingFrame", {
            Name = "Frame",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(1, -8, 1, -8),
            CanvasPosition = Vector2.new(0, 28),
            CanvasSize = UDim2.new(0, 0, 0, 120),
            ZIndex = 2,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = themes.DarkContrast
         }, {
            utility:Create("UIListLayout", {
               SortOrder = Enum.SortOrder.LayoutOrder,
               Padding = UDim.new(0, 4)
            })
         })
      })
   })

   table.insert(self.modules, dropdown)
   --self:Resize()

   local search = dropdown.Search
   local focused

   list = list or {}

   search.Button.MouseButton1Click:Connect(function()
      if search.Button.Rotation == 0 then
         self:updateDropdown(dropdown, nil, list, callback)
      else
         self:updateDropdown(dropdown, nil, nil, callback)
      end
   end)

   search.TextBox.Focused:Connect(function()
      if search.Button.Rotation == 0 then
         self:updateDropdown(dropdown, nil, list, callback)
      end

      focused = true
   end)

   search.TextBox.FocusLost:Connect(function()
      focused = false
   end)

   search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
      if focused then
         local list = utility:Sort(search.TextBox.Text, list)
         list = #list ~= 0 and list 

         self:updateDropdown(dropdown, nil, list, callback)
      end
   end)

   dropdown:GetPropertyChangedSignal("Size"):Connect(function()
      self:Resize()
   end)

   return dropdown
end

-- class functions

function library:SelectPage(page, toggle)

   if toggle and self.focusedPage == page then -- already selected
      return
   end

   local button = page.button

   if toggle then
      -- page button
      button.Title.TextTransparency = 0
      button.Title.Font = Enum.Font.GothamSemibold

      if button:FindFirstChild("Icon") then
         button.Icon.ImageTransparency = 0
      end

      -- update selected page
      local focusedPage = self.focusedPage
      self.focusedPage = page

      if focusedPage then
         self:SelectPage(focusedPage)
      end

      -- sections
      local existingSections = focusedPage and #focusedPage.sections or 0
      local sectionsRequired = #page.sections - existingSections

      page:Resize()

      for i, section in pairs(page.sections) do
         section.container.Parent.ImageTransparency = 0
      end

      if sectionsRequired < 0 then -- "hides" some sections
         for i = existingSections, #page.sections + 1, -1 do
            local section = focusedPage.sections[i].container.Parent

            utility:Tween(section, {ImageTransparency = 1}, 0.1)
         end
      end

      wait(0.1)
      page.container.Visible = true

      if focusedPage then
         focusedPage.container.Visible = false
      end

      if sectionsRequired > 0 then -- "creates" more section
         for i = existingSections + 1, #page.sections do
            local section = page.sections[i].container.Parent

            section.ImageTransparency = 1
            utility:Tween(section, {ImageTransparency = 0}, 0.05)
         end
      end

      wait(0.05)

      for i, section in pairs(page.sections) do

         utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
         section:Resize(true)

         wait(0.05)
      end

      wait(0.05)
      page:Resize(true)
   else
      -- page button
      button.Title.Font = Enum.Font.Gotham
      button.Title.TextTransparency = 0.65

      if button:FindFirstChild("Icon") then
         button.Icon.ImageTransparency = 0.65
      end

      -- sections
      for i, section in pairs(page.sections) do	
         utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, 28)}, 0.1)
         utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
      end

      wait(0.1)

      page.lastPosition = page.container.CanvasPosition.Y
      page:Resize()
   end
end

function page:Resize(scroll)
   local padding = 10
   local size = 0

   for i, section in pairs(self.sections) do
      size = size + section.container.Parent.AbsoluteSize.Y + padding
   end

   self.container.CanvasSize = UDim2.new(0, 0, 0, size)
   self.container.ScrollBarImageTransparency = size > self.container.AbsoluteSize.Y

   if scroll then
      utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
   end
end

function section:Resize(smooth)

   if self.page.library.focusedPage ~= self.page then
      return
   end

   local padding = 4
   local size = (4 * padding) + self.container.Title.AbsoluteSize.Y -- offset

   for i, module in pairs(self.modules) do
      size = size + module.AbsoluteSize.Y + padding
   end

   if smooth then
      utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
   else
      self.container.Parent.Size = UDim2.new(1, -10, 0, size)
      self.page:Resize()
   end
end

function section:getModule(info)

   if table.find(self.modules, info) then
      return info
   end

   for i, module in pairs(self.modules) do
      if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
         return module
      end
   end

   error("No module found under "..tostring(info))
end

-- updates

function section:updateButton(button, title)
   button = self:getModule(button)

   button.Title.Text = title
end

function section:updateToggle(toggle, title, value)
   toggle = self:getModule(toggle)

   local position = {
      In = UDim2.new(0, 2, 0.5, -6),
      Out = UDim2.new(0, 20, 0.5, -6)
   }

   local frame = toggle.Button.Frame
   value = value and "Out" or "In"

   if title then
      toggle.Title.Text = title
   end

   utility:Tween(frame, {
      Size = UDim2.new(1, -22, 1, -9),
      Position = position[value] + UDim2.new(0, 0, 0, 2.5)
   }, 0.2)

   wait(0.1)
   utility:Tween(frame, {
      Size = UDim2.new(1, -22, 1, -4),
      Position = position[value]
   }, 0.1)
end

function section:updateTextbox(textbox, title, value)
   textbox = self:getModule(textbox)

   if title then
      textbox.Title.Text = title
   end

   if value then
      textbox.Button.Textbox.Text = value
   end

end

function section:updateKeybind(keybind, title, key)
   keybind = self:getModule(keybind)

   local text = keybind.Button.Text
   local bind = self.binds[keybind]

   if title then
      keybind.Title.Text = title
   end

   if bind.connection then
      bind.connection = bind.connection:UnBind()
   end

   if key then
      self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
      text.Text = key.Name
   else
      text.Text = "None"
   end
end

function section:updateColorPicker(colorpicker, title, color)
   colorpicker = self:getModule(colorpicker)

   local picker = self.colorpickers[colorpicker]
   local tab = picker.tab
   local callback = picker.callback

   if title then
      colorpicker.Title.Text = title
      tab.Title.Text = title
   end

   local color3
   local hue, sat, brightness

   if type(color) == "table" then -- roblox is literally retarded x2
      hue, sat, brightness = unpack(color)
      color3 = Color3.fromHSV(hue, sat, brightness)
   else
      color3 = color
      hue, sat, brightness = Color3.toHSV(color3)
   end

   utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
   utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)

   utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
   utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)

   for i, container in pairs(tab.Container.Inputs:GetChildren()) do
      if container:IsA("ImageLabel") then
         local value = math.clamp(color3[container.Name], 0, 1) * 255

         container.Textbox.Text = math.floor(value)
         --callback(container.Name:lower(), value)
      end
   end
end

function section:updateSlider(slider, title, value, min, max, lvalue)
   slider = self:getModule(slider)

   if title then
      slider.Title.Text = title
   end

   local bar = slider.Slider.Bar
   local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

   if value then -- support negative ranges
      percent = (value - min) / (max - min)
   end

   percent = math.clamp(percent, 0, 1)
   value = value or math.floor(min + (max - min) * percent)

   slider.TextBox.Text = value
   utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)

   if value ~= lvalue and slider.ImageTransparency == 0 then
      utility:Pop(slider, 10)
   end

   return value
end

function section:updateDropdown(dropdown, title, list, callback)
   dropdown = self:getModule(dropdown)

   if title then
      dropdown.Search.TextBox.Text = title
   end

   local entries = 0

   utility:Pop(dropdown.Search, 10)

   for i, button in pairs(dropdown.List.Frame:GetChildren()) do
      if button:IsA("ImageButton") then
         button:Destroy()
      end
   end

   for i, value in pairs(list or {}) do
      local button = utility:Create("ImageButton", {
         Parent = dropdown.List.Frame,
         BackgroundTransparency = 1,
         BorderSizePixel = 0,
         Size = UDim2.new(1, 0, 0, 30),
         ZIndex = 2,
         Image = "rbxassetid://5028857472",
         ImageColor3 = themes.DarkContrast,
         ScaleType = Enum.ScaleType.Slice,
         SliceCenter = Rect.new(2, 2, 298, 298)
      }, {
         utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = value,
            TextColor3 = themes.TextColor,
            TextSize = 12,
            TextXAlignment = "Left",
            TextTransparency = 0.10000000149012
         })
      })

      button.MouseButton1Click:Connect(function()
         if callback then
            callback(value, function(...)
               self:updateDropdown(dropdown, ...)
            end)	
         end

         self:updateDropdown(dropdown, value, nil, callback)
      end)

      entries = entries + 1
   end

   local frame = dropdown.List.Frame

   utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
   utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)

   if entries > 3 then

      for i, button in pairs(dropdown.List.Frame:GetChildren()) do
         if button:IsA("ImageButton") then
            button.Size = UDim2.new(1, -6, 0, 30)
         end
      end

      frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
      frame.ScrollBarImageTransparency = 0
   else
      frame.CanvasSize = UDim2.new(0, 0, 0, 0)
      frame.ScrollBarImageTransparency = 1
   end
end
end
local lib = library.new("Island| Blox Fruit (Released)")
lib:Notify("Island","Ui Made by Denosaur")
wait(1)
lib:Notify("Island","Loading Functions + Data")
getgenv().AutoFarmQuest = true
getgenv().AFDistance = 350
getgenv().AF2Distance = 350 
getgenv().AutoFarmBring = true
getgenv().AutoBuso = true
getgenv().HealthMastery = 25
TweenSpeed = 200
--Check PlaceId
if game.PlaceId == 2753915549 then
   FirstSea = true
elseif game.PlaceId == 4442272183 then
   SecondSea = true
elseif game.PlaceId == 7449423635 then
   ThirdSea = true
end
Weapon = ""
PLrWeapons = {}

for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do  
    if v:IsA("Tool") then
        table.insert(PLrWeapons ,v.Name)
    end
end

for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do  
   if v:IsA("Tool") then
      table.insert(PLrWeapons ,v.Name)
   end
end

--Check player stats--
local MyLevel = game.Players.localPlayer.Data.Level.Value
local MyFragment = game.Players.localPlayer.Data.Fragments.Value
local placeId = game.PlaceId
local MyBeli = game.Players.localPlayer.Data.Beli.Value
local MyDevilFruit = game.Players.localPlayer.Data.DevilFruit.Value
getgenv().SkillZHold = 0
getgenv().SkillXHold = 0
getgenv().SkillCHold = 0
getgenv().SkillVHold = 0
getgenv().SkillFHold = 0
getgenv().SkillZ = true
getgenv().SkillX = true
getgenv().SkillC = true
getgenv().SkillV = true
getgenv().SkillF = true
-- I do some pascal
HighestLvToFarm =  0
BossTable =  {
    55;750;
    850;925;
    1000;1150;
    1325;1400;
    1475;200;
    25;110;
    120;130;
    175;225;
    350;425;
    500;575;
    675;1550;
    1675;1750;
    1875;1950;
    1400;5000;
    2100;
}
TableMobSea1 = {
   "Bandit [Lv. 5]";
   "Monkey [Lv. 14]";
   "Gorilla [Lv. 20]";
   "Pirate [Lv. 35]";
   "Brute [Lv. 45]";
   "Desert Bandit [Lv. 60]";
   "Desert Officer [Lv. 70]";
   "Snow Bandit [Lv. 90]";
   "Snowman [Lv. 100]";
   "Chief Petty Officer [Lv. 120]";
   "Sky Bandit [Lv. 150]";
   "Dark Master [Lv. 175]";
   "Toga Warrior [Lv. 225]";
   "Gladiator [Lv. 275]";
   "Military Soldier [Lv. 300]";
   "Military Spy [Lv. 330]";
   "Fishman Warrior [Lv. 375]";
   "Fishman Commando [Lv. 400]";
   "God's Guard [Lv. 450]";
   "Shanda [Lv. 475]";
   "Royal Squad [Lv. 525]";
   "Royal Soldier [Lv. 550]";
   "Galley Pirate [Lv. 625]";
   "Galley Captain [Lv. 650]";
}
Igr = {}
function zeroGrav(part)
   if part:FindFirstChild("BodyForce") then return end
   local temp = Instance.new("BodyForce")
   temp.Force = part:GetMass() * Vector3.new(0,workspace.Gravity,0)
   temp.Parent = part
end

for i, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
   table.insert(Igr , v)
end
for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
   if v:IsA("Tool") then
      for i2,v2 in pairs(v:GetDescendants()) do
         table.insert(Igr , v2)
      end
   end
end
MaxLevelSea = 0
if SecondSea then
   MaxLevelSea = 1450
elseif ThirdSea then
   MaxLevelSea = 2050
end

function refreshWeapon1()

   table.clear(PLrWeapons)
   for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do  
      if not table.find(PLrWeapons, v.name) then
         if v:IsA("Tool") then
            table.insert(PLrWeapons ,v.Name)
         end
      end
  end

   for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do  
      if not table.find(PLrWeapons, v.name) then
         if v:IsA("Tool") then
            table.insert(PLrWeapons ,v.Name)
         end
      end
   end

end

function Click()
   pcall(function()
   ClickMod = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
   ClickMod.activeController:attack()
   end)
end
function Equip(Tool)
   local ToolEquip =  game.Players.LocalPlayer.Backpack:FindFirstChild(Tool)
   game.Players.LocalPlayer.Character.Humanoid:EquipTool(ToolEquip)
end
function CheckLv()
   local MyLevel = game.Players.localPlayer.Data.Level.Value
    if SecondSea or ThirdSea then
      local MyLevel = game.Players.localPlayer.Data.Level.Value
        for i,v in pairs(require(game:GetService("ReplicatedStorage").Quests)) do
            CheckingQuest = true
            for i2,v2 in pairs(v) do
                for i3,v3 in pairs(v2) do
                    if typeof(v3) ~= "table" and typeof(v3) ~= "function" then
                        if typeof(v3) == "number"   then
                            for i4,v4 in pairs(BossTable) do
                                if v3 == v4 then SpotBoss = true end
                            end
                            
                            if MyLevel >= v3 and v3 > HighestLvToFarm and v3 <= MaxLevelSea and not SpotBoss then
                                HighestLvToFarm = v3
                            end
                            SpotBoss = false
                        end
                    end
                end
            end
            CheckingQuest = false
        end
    elseif FirstSea and not getgenv().AutoFarm2 then
        if MyLevel == 1 or MyLevel <= 9 then
            NameMob = "Bandit [Lv. 5]"
        elseif MyLevel == 10 or MyLevel <= 14 then
            NameMob = "Monkey [Lv. 14]"
        elseif MyLevel == 15 or MyLevel <= 29 then
            NameMob = "Gorilla [Lv. 20]"
        elseif MyLevel == 30 or MyLevel <= 39 then
            NameMob = "Pirate [Lv. 35]"
        elseif MyLevel == 40 or MyLevel <= 59 then
            NameMob = "Brute [Lv. 45]"
        elseif MyLevel == 60 or MyLevel <= 74 then
            NameMob = "Desert Bandit [Lv. 60]"
        elseif MyLevel == 75 or MyLevel <= 89 then
            NameMob = "Desert Officer [Lv. 70]"
        elseif MyLevel == 90 or MyLevel <= 99 then
            NameMob = "Snow Bandit [Lv. 90]"
        elseif MyLevel == 100 or MyLevel <= 119 then
            NameMob = "Snowman [Lv. 100]"
        elseif MyLevel == 120 or MyLevel <= 149 then
            NameMob = "Chief Petty Officer [Lv. 120]"
        elseif MyLevel == 150 or MyLevel <= 174 then
            NameMob = "Sky Bandit [Lv. 150]"
        elseif MyLevel == 175 or MyLevel <= 224 then 
            NameMob = "Dark Master [Lv. 175]"
        elseif MyLevel == 225 or MyLevel <= 274 then
            NameMob = "Toga Warrior [Lv. 225]"
        elseif MyLevel == 275 or MyLevel <= 299 then
            NameMob = "Gladiator [Lv. 275]"
        elseif MyLevel == 300 or MyLevel <= 329 then
            NameMob = "Military Soldier [Lv. 300]"
        elseif MyLevel == 300 or MyLevel <= 374 then
            NameMob = "Military Spy [Lv. 330]"
        elseif MyLevel == 375 or MyLevel <= 399 then
            NameMob = "Fishman Warrior [Lv. 375]"
        elseif MyLevel == 400 or MyLevel <= 449 then
            NameMob = "Fishman Commando [Lv. 400]"
        elseif MyLevel == 450 or MyLevel <= 474 then
            NameMob = "God's Guard [Lv. 450]"
        elseif MyLevel == 475 or MyLevel <= 524 then
            NameMob = "Shanda [Lv. 475]"
        elseif MyLevel == 525 or MyLevel <= 549 then
            NameMob = "Royal Squad [Lv. 525]"
        elseif MyLevel == 550 or MyLevel <= 624 then
            NameMob = "Royal Soldier [Lv. 550]"
        elseif MyLevel == 625 or MyLevel <= 649 then
            NameMob = "Galley Pirate [Lv. 625]"
        elseif MyLevel >= 650 then
            NameMob = "Galley Captain [Lv. 650]"
        end
    end
end
function CheckQuestMob()
   local MyLevel = game.Players.localPlayer.Data.Level.Value
   if FirstSea then
      if MyLevel == 1 or MyLevel <= 9 then
         QuestNameMob = "BanditQuest1"
         StringFindMob = "Bandit"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(1061.66699, 16.5166187, 1544.52905, -0.942978859, -3.33851502e-09, 0.332852632, 7.04340497e-09, 1, 2.99841325e-08, -0.332852632, 3.06188177e-08, -0.942978859)
         SpawnPoint = "Default"
         SpawnCFrame = CFrame.new(977.038269, 16.5166149, 1420.94336, 0.97796452, 0, -0.208771184, -0, 1, -0, 0.208771184, 0, 0.97796452)
      elseif MyLevel == 10 or MyLevel <= 14 then
         SpawnPoint = "Jungle"
         SpawnCFrame = CFrame.new(-1332.1394, 11.8529119, 492.35907, -0.774900496, -1.23768311e-08, 0.632082939, 1.77851245e-08, 1, 4.13846735e-08, -0.632082939, 4.33106848e-08, -0.774900496)
         QuestNameMob = "JungleQuest"
         StringFindMob = "Monkey"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-1604.12012, 36.8521118, 154.23732, 0.0648873374, -4.70858913e-06, -0.997892559, 1.41431883e-07, 1, -4.70933674e-06, 0.997892559, 1.64442184e-07, 0.0648873374)
      elseif MyLevel == 15 or MyLevel <= 29 then
         SpawnCFrame = CFrame.new(-1332.1394, 11.8529119, 492.35907, -0.774900496, -1.23768311e-08, 0.632082939, 1.77851245e-08, 1, 4.13846735e-08, -0.632082939, 4.33106848e-08, -0.774900496)
         SpawnPoint = "Jungle"
         QuestNameMob = "JungleQuest"
         StringFindMob = "Gorilla"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-1604.12012, 36.8521118, 154.23732, 0.0648873374, -4.70858913e-06, -0.997892559, 1.41431883e-07, 1, -4.70933674e-06, 0.997892559, 1.64442184e-07, 0.0648873374)
      elseif MyLevel == 30 or MyLevel <= 39 then
         SpawnCFrame = CFrame.new(-1186.37769, 4.75154591, 3810.49243, 0.508615494, 0, -0.860993803, -0, 1, -0, 0.860993803, 0, 0.508615494)
         SpawnPoint = "Pirate"
         QuestNameMob = "BuggyQuest1"
         StringFindMob = "Pirate"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-1139.59717, 4.75205183, 3825.16211, -0.959730506, -7.5857054e-09, 0.280922383, -4.06310328e-08, 1, -1.11807175e-07, -0.280922383, -1.18718916e-07, -0.959730506)
      elseif MyLevel == 40 or MyLevel <= 59 then
         SpawnCFrame = CFrame.new(-1186.37769, 4.75154591, 3810.49243, 0.508615494, 0, -0.860993803, -0, 1, -0, 0.860993803, 0, 0.508615494)
         SpawnPoint = "Pirate"
         QuestNameMob = "BuggyQuest1"
         StringFindMob = "Brute"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-1139.59717, 4.75205183, 3825.16211, -0.959730506, -7.5857054e-09, 0.280922383, -4.06310328e-08, 1, -1.11807175e-07, -0.280922383, -1.18718916e-07, -0.959730506)
      elseif MyLevel == 60 or MyLevel <= 74 then
         SpawnPoint = "Desert"
         SpawnCFrame = CFrame.new(917.85199, 3.37914562, 4114.66895, 0.203889921, -7.29310585e-08, 0.978993833, -8.66312355e-09, 1, 7.63001538e-08, -0.978993833, -2.40379769e-08, 0.203889921)
         QuestNameMob = "DesertQuest"
         StringFindMob = "Desert Bandit"

         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(897.031128, 6.43846416, 4388.97168, -0.804044724, 3.68233266e-08, 0.594568789, 6.97835176e-08, 1, 3.24365246e-08, -0.594568789, 6.75715199e-08, -0.804044724)
      elseif MyLevel == 75 or MyLevel <= 89 then
         SpawnPoint = "Desert"
         SpawnCFrame = CFrame.new(917.85199, 3.37914562, 4114.66895, 0.203889921, -7.29310585e-08, 0.978993833, -8.66312355e-09, 1, 7.63001538e-08, -0.978993833, -2.40379769e-08, 0.203889921)
         QuestNameMob = "DesertQuest"
         StringFindMob = "Desert Officer"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(897.031128, 6.43846416, 4388.97168, -0.804044724, 3.68233266e-08, 0.594568789, 6.97835176e-08, 1, 3.24365246e-08, -0.594568789, 6.75715199e-08, -0.804044724)
      elseif MyLevel == 90 or MyLevel <= 99 then
         SpawnPoint = "Ice"
         SpawnCFrame = CFrame.new(1107.42444, 7.3035593, -1164.79614, 0.548184574, -8.23326758e-08, 0.836357415, 4.65359591e-08, 1, 6.79403129e-08, -0.836357415, 1.67686287e-09, 0.548184574)
         QuestNameMob = "SnowQuest"
         StringFindMob = "Snow Bandits"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(1384.14001, 87.272789, -1297.06482, 0.348555952, -2.53947841e-09, -0.937287986, 1.49860568e-08, 1, 2.86358204e-09, 0.937287986, -1.50443711e-08, 0.348555952)
      elseif MyLevel == 100 or MyLevel <= 119 then
         SpawnPoint = "Ice"
         SpawnCFrame = CFrame.new(1107.42444, 7.3035593, -1164.79614, 0.548184574, -8.23326758e-08, 0.836357415, 4.65359591e-08, 1, 6.79403129e-08, -0.836357415, 1.67686287e-09, 0.548184574)
         QuestNameMob = "SnowQuest"
         StringFindMob = "Snowman"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(1384.14001, 87.272789, -1297.06482, 0.348555952, -2.53947841e-09, -0.937287986, 1.49860568e-08, 1, 2.86358204e-09, 0.937287986, -1.50443711e-08, 0.348555952)
      elseif MyLevel == 120 or MyLevel <= 149 then
         SpawnPoint = "MarineBase"
         SpawnCFrame = CFrame.new(-4922.20264, 41.2520523, 4424.44434, -0.488673091, -2.20081375e-08, 0.872467041, 1.13403127e-08, 1, 3.15769455e-08, -0.872467041, 2.53248498e-08, -0.488673091)
         QuestNameMob = "MarineQuest2"
         StringFindMob = "Chief Petty Officer"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-5035.0835, 28.6520386, 4325.29443, 0.0243340395, -7.08064647e-08, 0.999703884, -6.36926814e-08, 1, 7.23777944e-08, -0.999703884, -6.54350671e-08, 0.0243340395)
      elseif MyLevel == 150 or MyLevel <= 174 then
         SpawnPoint = "Sky"
         SpawnCFrame = CFrame.new(-4916.79346, 717.671265, -2637.03589, 0.808458745, 2.83643207e-08, 0.588552833, -4.5316173e-09, 1, -4.19685264e-08, -0.588552833, 3.12627257e-08, 0.808458745)
         QuestNameMob = "SkyQuest"
         StringFindMob = "Sky Bandit"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-4841.83447, 717.669617, -2623.96436, -0.875942111, 5.59710216e-08, -0.482416272, 3.04023082e-08, 1, 6.08195947e-08, 0.482416272, 3.86078725e-08, -0.875942111)
      elseif MyLevel == 175 or MyLevel <= 224 then
         SpawnPoint = "Sky"
         SpawnCFrame = CFrame.new(-4916.79346, 717.671265, -2637.03589, 0.808458745, 2.83643207e-08, 0.588552833, -4.5316173e-09, 1, -4.19685264e-08, -0.588552833, 3.12627257e-08, 0.808458745)
         QuestNameMob = "SkyQuest"
         StringFindMob = "Dark Master"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-4841.83447, 717.669617, -2623.96436, -0.875942111, 5.59710216e-08, -0.482416272, 3.04023082e-08, 1, 6.08195947e-08, 0.482416272, 3.86078725e-08, -0.875942111)
      elseif MyLevel == 225 or MyLevel <= 274 then
         SpawnPoint = "Colosseum"
         StringFindMob = "Toga Warrior"
         SpawnCFrame = CFrame.new(-1393.48926, 7.28934002, -2842.57324, -0.998255789, 6.55446408e-09, 0.0590373725, 6.72640565e-09, 1, 2.7136855e-09, -0.0590373725, 3.10606163e-09, -0.998255789)
         QuestNameMob = "ColosseumQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-1576.11743, 7.38933945, -2983.30762, 0.576966345, 1.22114863e-09, 0.816767931, -3.58496594e-10, 1, -1.24185606e-09, -0.816767931, 4.2370063e-10, 0.576966345)
      elseif MyLevel == 275 or MyLevel <= 299 then
         SpawnPoint = "Colosseum"
         StringFindMob = "Gladiato"
         SpawnCFrame = CFrame.new(-1393.48926, 7.28934002, -2842.57324, -0.998255789, 6.55446408e-09, 0.0590373725, 6.72640565e-09, 1, 2.7136855e-09, -0.0590373725, 3.10606163e-09, -0.998255789)
         QuestNameMob = "ColosseumQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-1576.11743, 7.38933945, -2983.30762, 0.576966345, 1.22114863e-09, 0.816767931, -3.58496594e-10, 1, -1.24185606e-09, -0.816767931, 4.2370063e-10, 0.576966345)
      elseif MyLevel == 300 or MyLevel <= 329 then
         SpawnPoint = "Magma"
         SpawnCFrame = CFrame.new(-5226.26416, 8.59022045, 8472.14844, 0.506667018, 0, -0.862141788, -0, 1, -0, 0.862141907, 0, 0.506666958)
         QuestNameMob = "MagmaQuest"
         StringFindMob = "Military Soldier"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-5316.55859, 12.2370615, 8517.2998, 0.588437557, -1.37880001e-08, -0.808542669, -2.10116209e-08, 1, -3.23446478e-08, 0.808542669, 3.60215964e-08, 0.588437557)
      elseif MyLevel == 300 or MyLevel <= 374 then
         QuestNameMob = "MagmaQuest"
         SpawnCFrame = CFrame.new(-5226.26416, 8.59022045, 8472.14844, 0.506667018, 0, -0.862141788, -0, 1, -0, 0.862141907, 0, 0.506666958)
         QuestNameMob = "MagmaQuest"
         StringFindMob = "Military Spy"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-5316.55859, 12.2370615, 8517.2998, 0.588437557, -1.37880001e-08, -0.808542669, -2.10116209e-08, 1, -3.23446478e-08, 0.808542669, 3.60215964e-08, 0.588437557)
      elseif MyLevel == 375 or MyLevel <= 399 then
         QuestNameMob = "FishmanQuest"
         StringFindMob = "Fishman Warrior"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(61122.5625, 18.4716396, 1568.16504, 0.893533468, 3.95251609e-09, 0.448996574, -2.34327455e-08, 1, 3.78297464e-08, -0.448996574, -4.43233645e-08, 0.893533468)
      elseif MyLevel == 400 or MyLevel <= 449 then
         QuestNameMob = "FishmanQuest"
         StringFindMob = "Fishman Commando"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(61122.5625, 18.4716396, 1568.16504, 0.893533468, 3.95251609e-09, 0.448996574, -2.34327455e-08, 1, 3.78297464e-08, -0.448996574, -4.43233645e-08, 0.893533468)
      elseif MyLevel == 450 or MyLevel <= 474 then
         SpawnPoint = "Sky"
         StringFindMob = "God's Guards"
         SpawnCFrame = CFrame.new(-4916.79346, 717.671265, -2637.03589, 0.808458745, 2.83643207e-08, 0.588552833, -4.5316173e-09, 1, -4.19685264e-08, -0.588552833, 3.12627257e-08, 0.808458745)
         QuestNameMob = "SkyExp1Quest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-4721.71436, 845.277161, -1954.20105, -0.999277651, -5.56969759e-09, 0.0380011722, -4.14751478e-09, 1, 3.75035256e-08, -0.0380011722, 3.73188307e-08, -0.999277651)
      elseif MyLevel == 475 or MyLevel <= 524 then
         SpawnPoint = "Sky2"
         SpawnCFrame = CFrame.new(-7873.7959, 5545.49316, -335.85321, -0.8423931, 4.59006095e-08, -0.53886348, 3.20399991e-08, 1, 3.50930023e-08, 0.53886348, 1.22969173e-08, -0.8423931)
         QuestNameMob = "SkyExp1Quest"
         StringFindMob = "Shandas"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-7863.63672, 5545.49316, -379.826324, 0.362120807, -1.98046344e-08, -0.93213129, 4.05822291e-08, 1, -5.48095125e-09, 0.93213129, -3.58431969e-08, 0.362120807)
      elseif MyLevel == 525 or MyLevel <= 549 then
         SpawnPoint = "Sky2"
         SpawnCFrame = CFrame.new(-7873.7959, 5545.49316, -335.85321, -0.8423931, 4.59006095e-08, -0.53886348, 3.20399991e-08, 1, 3.50930023e-08, 0.53886348, 1.22969173e-08, -0.8423931)
         QuestNameMob = "SkyExp2Quest"
         StringFindMob = "Royal Squad"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-7902.66895, 5635.96387, -1411.71802, 0.0504222959, 2.5710392e-08, 0.998727977, 1.12541557e-07, 1, -3.14249675e-08, -0.998727977, 1.13982921e-07, 0.0504222959)
      elseif MyLevel == 550 or MyLevel <= 624 then
         SpawnPoint = "Sky2"
         SpawnCFrame = CFrame.new(-7873.7959, 5545.49316, -335.85321, -0.8423931, 4.59006095e-08, -0.53886348, 3.20399991e-08, 1, 3.50930023e-08, 0.53886348, 1.22969173e-08, -0.8423931)
         QuestNameMob = "SkyExp2Quest"
         StringFindMob = "Royal Soldier"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-7902.66895, 5635.96387, -1411.71802, 0.0504222959, 2.5710392e-08, 0.998727977, 1.12541557e-07, 1, -3.14249675e-08, -0.998727977, 1.13982921e-07, 0.0504222959)
      elseif MyLevel == 625 or MyLevel <= 649 then
         SpawnPoint = "Fountain"
         SpawnCFrame = CFrame.new(5187.77197, 38.5011406, 4141.60791, 0.779290736, 0, 0.626662672, -0, 1.00000012, -0, -0.626662731, 0, 0.779290617)
         QuestNameMob = "FountainQuest"
         StringFindMob = "Galley Pirate"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(5254.60156, 38.5011406, 4049.69678, -0.0504891425, -3.62066501e-08, -0.998724639, -9.87921389e-09, 1, -3.57534553e-08, 0.998724639, 8.06145284e-09, -0.0504891425)
      elseif MyLevel >= 650 then
         SpawnPoint = "Fountain"
         SpawnCFrame = CFrame.new(5187.77197, 38.5011406, 4141.60791, 0.779290736, 0, 0.626662672, -0, 1.00000012, -0, -0.626662731, 0, 0.779290617)
         QuestNameMob = "FountainQuest"
         StringFindMob = "Galley Captain"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(5254.60156, 38.5011406, 4049.69678, -0.0504891425, -3.62066501e-08, -0.998724639, -9.87921389e-09, 1, -3.57534553e-08, 0.998724639, 8.06145284e-09, -0.0504891425)
      end
   elseif SecondSea then
      if HighestLvToFarm == 700  then
         StringFindMob = "Raider"
         SpawnCFrame = CFrame.new(-32.1582031, 29.2783928, 2766.5874, 0.999908745, 4.07748502e-08, 0.013477576, -4.06100966e-08, 1, -1.24986625e-08, -0.013477576, 1.19501982e-08, 0.999908745)
         SpawnPoint = "Default"
         QuestNameMob = "Area1Quest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-424.080078, 73.0055847, 1836.91589, 0.253544956, -1.42165932e-08, 0.967323601, -6.00147771e-08, 1, 3.04272909e-08, -0.967323601, -6.5768397e-08, 0.253544956)
      elseif HighestLvToFarm == 725 then
         SpawnCFrame = CFrame.new(-32.1582031, 29.2783928, 2766.5874, 0.999908745, 4.07748502e-08, 0.013477576, -4.06100966e-08, 1, -1.24986625e-08, -0.013477576, 1.19501982e-08, 0.999908745)
         SpawnPoint = "Default"
         StringFindMob = "Mercenary"
         QuestNameMob = "Area1Quest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-424.080078, 73.0055847, 1836.91589, 0.253544956, -1.42165932e-08, 0.967323601, -6.00147771e-08, 1, 3.04272909e-08, -0.967323601, -6.5768397e-08, 0.253544956)
      elseif HighestLvToFarm == 775 then
         StringFindMob = "Swan Pirate"
         SpawnCFrame = CFrame.new(-389.968658, 72.9961472, 1148.09241, 0.973822653, -2.55817412e-09, -0.227309078, 5.14786969e-09, 1, 1.07999991e-08, 0.227309078, -1.16874412e-08, 0.973822653)
         SpawnPoint = "DressTown"
         QuestNameMob = "Area2Quest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.07732087e-10, -0.0319722369)
      elseif HighestLvToFarm == 800 then 
         SpawnCFrame = CFrame.new(-389.968658, 72.9961472, 1148.09241, 0.973822653, -2.55817412e-09, -0.227309078, 5.14786969e-09, 1, 1.07999991e-08, 0.227309078, -1.16874412e-08, 0.973822653)
         SpawnPoint = "DressTown"
         StringFindMob = "Factory Staff"
         QuestNameMob = "Area2Quest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.07732087e-10, -0.0319722369)
      elseif HighestLvToFarm == 875 then
         SpawnPoint = "Greenb"
         StringFindMob = "Marine Lieutenant"
         SpawnCFrame = CFrame.new(-2220.05884, 72.967804, -2709.98462, 0.751716256, 2.54505395e-08, -0.659486711, -3.65784025e-08, 1, -3.10247139e-09, 0.659486711, 2.64551492e-08, 0.751716256)
         QuestNameMob = "MarineQuest3"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-2442.65015, 73.0511475, -3219.11523, -0.873540044, 4.2329841e-08, -0.486752301, 5.64383384e-08, 1, -1.43220786e-08, 0.486752301, -3.99823996e-08, -0.873540044)
      elseif HighestLvToFarm == 900 then
         SpawnPoint = "Greenb"
         StringFindMob = "Marine Captain"
         SpawnCFrame = CFrame.new(-2220.05884, 72.967804, -2709.98462, 0.751716256, 2.54505395e-08, -0.659486711, -3.65784025e-08, 1, -3.10247139e-09, 0.659486711, 2.64551492e-08, 0.751716256)
         QuestNameMob = "MarineQuest3"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-2442.65015, 73.0511475, -3219.11523, -0.873540044, 4.2329841e-08, -0.486752301, 5.64383384e-08, 1, -1.43220786e-08, 0.486752301, -3.99823996e-08, -0.873540044)
      elseif HighestLvToFarm == 950 then 
         SpawnPoint = "Graveyard"
         QuestNameMob = "ZombieQuest"
         StringFindMob = "Zombie"
         SpawnCFrame = CFrame.new(-5386.68799, 8.97076797, -713.903381, -0.681161046, -0, -0.732133687, -0, 1.00000012, -0, 0.732133627, 0, -0.681161106)
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-5492.79395, 48.5151672, -793.710571, 0.321800292, -6.24695815e-08, 0.946807742, 4.05616092e-08, 1, 5.21931227e-08, -0.946807742, 2.16082796e-08, 0.321800292)
      elseif HighestLvToFarm == 975 then 
         SpawnPoint = "Graveyard"
         SpawnCFrame = CFrame.new(-5386.68799, 8.97076797, -713.903381, -0.681161046, -0, -0.732133687, -0, 1.00000012, -0, 0.732133627, 0, -0.681161106)
         QuestNameMob = "ZombieQuest"
         LvQuestMob = 2
         StringFindMob = "Vampire"
         QuestCFrameMob = CFrame.new(-5492.79395, 48.5151672, -793.710571, 0.321800292, -6.24695815e-08, 0.946807742, 4.05616092e-08, 1, 5.21931227e-08, -0.946807742, 2.16082796e-08, 0.321800292)
      elseif HighestLvToFarm == 1000 then 
         StringFindMob = "Snow Trooper"
         SpawnPoint = "Snowy"
         SpawnCFrame = CFrame.new(394.089142, 401.423676, -5313.98486, 0.858188987, 0, -0.513334036, -0, 1.00000012, -0, 0.513334095, 0, 0.858188868)
         QuestNameMob = "SnowMountainQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(604.964966, 401.457062, -5371.69287, 0.353063971, 1.89520435e-08, -0.935599446, -5.81846002e-08, 1, -1.70033754e-09, 0.935599446, 5.50377841e-08, 0.353063971)
      elseif HighestLvToFarm == 1050 then 
         StringFindMob = "Winter Warrior"
         SpawnCFrame = CFrame.new(394.089142, 401.423676, -5313.98486, 0.858188987, 0, -0.513334036, -0, 1.00000012, -0, 0.513334095, 0, 0.858188868)
         SpawnPoint = "Snowy"
         QuestNameMob = "SnowMountainQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(604.964966, 401.457062, -5371.69287, 0.353063971, 1.89520435e-08, -0.935599446, -5.81846002e-08, 1, -1.70033754e-09, 0.935599446, 5.50377841e-08, 0.353063971)
      elseif HighestLvToFarm == 1100 then
         SpawnCFrame = CFrame.new(-5852.72803, 18.316433, -5030.0752, -0.0697377697, -1.76218595e-08, 0.997565329, -4.9068543e-08, 1, 1.42345851e-08, -0.997565329, -4.79563909e-08, -0.0697377697)
         SpawnPoint = "CircleIslandIce"
         StringFindMob = "Lab Subordinate"
         QuestNameMob = "IceSideQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-6060.10693, 15.9868021, -4904.7876, -0.411000341, -5.06538868e-07, 0.91163528, 1.26306062e-07, 1, 6.12581289e-07, -0.91163528, 3.66916197e-07, -0.411000341)
      elseif HighestLvToFarm == 1125  then
         SpawnCFrame = CFrame.new(-5852.72803, 18.316433, -5030.0752, -0.0697377697, -1.76218595e-08, 0.997565329, -4.9068543e-08, 1, 1.42345851e-08, -0.997565329, -4.79563909e-08, -0.0697377697)
         SpawnPoint = "CircleIslandIce"
         StringFindMob = "Horned Warrior"
         QuestNameMob = "IceSideQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-6060.10693, 15.9868021, -4904.7876, -0.411000341, -5.06538868e-07, 0.91163528, 1.26306062e-07, 1, 6.12581289e-07, -0.91163528, 3.66916197e-07, -0.411000341)
      elseif HighestLvToFarm == 1175  then
         SpawnCFrame = CFrame.new(-5852.72803, 18.316433, -5030.0752, -0.0697377697, -1.76218595e-08, 0.997565329, -4.9068543e-08, 1, 1.42345851e-08, -0.997565329, -4.79563909e-08, -0.0697377697)
         SpawnPoint = "CircleIslandIce"
         StringFindMob = "Magma Ninja"
         QuestNameMob = "FireSideQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-5431.09473, 15.9868021, -5296.53223, 0.831796765, 1.15322464e-07, -0.555080295, -1.10814341e-07, 1, 4.17010995e-08, 0.555080295, 2.68240168e-08, 0.831796765)
      elseif HighestLvToFarm == 1200  then 
         SpawnCFrame = CFrame.new(-5852.72803, 18.316433, -5030.0752, -0.0697377697, -1.76218595e-08, 0.997565329, -4.9068543e-08, 1, 1.42345851e-08, -0.997565329, -4.79563909e-08, -0.0697377697)
         SpawnPoint = "CircleIslandIce"
         StringFindMob = "Lava Pirate"
         QuestNameMob = "FireSideQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-5431.09473, 15.9868021, -5296.53223, 0.831796765, 1.15322464e-07, -0.555080295, -1.10814341e-07, 1, 4.17010995e-08, 0.555080295, 2.68240168e-08, 0.831796765)
      elseif HighestLvToFarm == 1250  then
         QuestNameMob = "ShipQuest1"
         LvQuestMob = 1
         StringFindMob = "Ship Deckhand"
         QuestCFrameMob = CFrame.new(1037.80127, 125.092171, 32911.6016, -0.244533166, -0, -0.969640911, -0, 1.00000012, -0, 0.96964103, 0, -0.244533136)
      elseif HighestLvToFarm == 1275 then
         QuestNameMob = "ShipQuest1"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(1037.80127, 125.092171, 32911.6016, -0.244533166, -0, -0.969640911, -0, 1.00000012, -0, 0.96964103, 0, -0.244533136)
      elseif HighestLvToFarm == 1300 then 
         QuestNameMob = "ShipQuest2"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(968.80957, 125.092171, 33244.125, -0.869560242, 1.51905191e-08, -0.493826836, 1.44108379e-08, 1, 5.38534195e-09, 0.493826836, -2.43357912e-09, -0.869560242)
      elseif HighestLvToFarm == 1325 then 
         QuestNameMob = "ShipQuest2"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(968.80957, 125.092171, 33244.125, -0.869560242, 1.51905191e-08, -0.493826836, 1.44108379e-08, 1, 5.38534195e-09, 0.493826836, -2.43357912e-09, -0.869560242)
      elseif HighestLvToFarm == 1350 then
         SpawnCFrame = CFrame.new(5573.96826, 28.1925011, -6111.41455, 0.63015002, 2.24445866e-08, -0.776473403, 1.18417554e-09, 1, 2.98668255e-08, 0.776473403, -1.97400603e-08, 0.63015002)
         SpawnPoint = "IceCastle"
         StringFindMob = "Arctic Warrior"
         QuestNameMob = "FrostQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(5669.43506, 28.2117786, -6482.60107, 0.888092756, 1.02705066e-07, 0.459664226, -6.20391774e-08, 1, -1.03572376e-07, -0.459664226, 6.34646895e-08, 0.888092756)
      elseif HighestLvToFarm == 1375 then 
         SpawnCFrame = CFrame.new(5573.96826, 28.1925011, -6111.41455, 0.63015002, 2.24445866e-08, -0.776473403, 1.18417554e-09, 1, 2.98668255e-08, 0.776473403, -1.97400603e-08, 0.63015002)
         SpawnPoint = "IceCastle"
         StringFindMob = "Snow Lurker"
         QuestNameMob = "FrostQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(5669.43506, 28.2117786, -6482.60107, 0.888092756, 1.02705066e-07, 0.459664226, -6.20391774e-08, 1, -1.03572376e-07, -0.459664226, 6.34646895e-08, 0.888092756)
      elseif HighestLvToFarm == 1425 then
         SpawnCFrame = CFrame.new(-3066.82715, 236.847992, -10159.6846, -0.0472635701, 9.39435338e-08, 0.998882413, -1.03863584e-08, 1, -9.45400771e-08, -0.998882413, -1.4843053e-08, -0.0472635701)
         SpawnPoint = "ForgottenIsland"
         StringFindMob = "Sea Soldier"
         QuestNameMob = "ForgottenQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-3052.99097, 236.881363, -10148.1943, -0.997911751, 4.42321983e-08, 0.064591676, 4.90968759e-08, 1, 7.37270085e-08, -0.064591676, 7.67442998e-08, -0.997911751)
      elseif HighestLvToFarm >= 1450 then 
         StringFindMob = "Water Fighter"
         SpawnPoint = "ForgottenIsland"
         SpawnCFrame = CFrame.new(-3066.82715, 236.847992, -10159.6846, -0.0472635701, 9.39435338e-08, 0.998882413, -1.03863584e-08, 1, -9.45400771e-08, -0.998882413, -1.4843053e-08, -0.0472635701)
         QuestNameMob = "ForgottenQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-3052.99097, 236.881363, -10148.1943, -0.997911751, 4.42321983e-08, 0.064591676, 4.90968759e-08, 1, 7.37270085e-08, -0.064591676, 7.67442998e-08, -0.997911751)
      end
   elseif ThirdSea then
      if HighestLvToFarm == 1500 then
         StringFindMob = "Pirate Millionaire"
         QuestNameMob = "PiratePortQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-288.95349121094, 43.789222717285, 5578.7622070313)
      elseif HighestLvToFarm == 1525 then
         StringFindMob = "Pistol Billionaire"

         QuestNameMob = "PiratePortQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-288.95349121094, 43.789222717285, 5578.7622070313)

      elseif HighestLvToFarm == 1575 then
         StringFindMob = "Dragon Crew Warrior"
         SpawnPoint = "Hydra3"
         SpawnCFrame = CFrame.new(4727.12988, 51.453064, -1401.72839, -0.0406560153, -8.94791299e-08, -0.999172926, -1.4819995e-08, 1, -8.89501877e-08, 0.999172926, 1.11913803e-08, -0.0406560153)
         QuestNameMob = "AmazonQuest"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(5833.5776367188, 51.575191497803, -1102.7550048828)
      elseif HighestLvToFarm == 1600  then
         SpawnPoint = "Hydra3"
         StringFindMob = "Dragon Crew Archer"

         SpawnCFrame = CFrame.new(4727.12988, 51.453064, -1401.72839, -0.0406560153, -8.94791299e-08, -0.999172926, -1.4819995e-08, 1, -8.89501877e-08, 0.999172926, 1.11913803e-08, -0.0406560153)
         QuestNameMob = "AmazonQuest"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(5833.5776367188, 51.575191497803, -1102.7550048828)
      elseif HighestLvToFarm == 1625  then
         SpawnPoint = "Hydra1"
         StringFindMob = "Female Islander"

         SpawnCFrame = CFrame.new(5264.06396, 602.526245, 353.749878, 0.279151142, -7.57343912e-08, 0.960247159, -6.40085602e-08, 1, 9.74774537e-08, -0.960247159, -8.86749874e-08, 0.279151142)
         QuestNameMob = "AmazonQuest2"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(5447.388671875, 601.74407958984, 751.86462402344)

      elseif HighestLvToFarm == 1650  then
         
         SpawnPoint = "Hydra1"
         StringFindMob = "Giant Islander"
         SpawnCFrame = CFrame.new(5264.06396, 602.526245, 353.749878, 0.279151142, -7.57343912e-08, 0.960247159, -6.40085602e-08, 1, 9.74774537e-08, -0.960247159, -8.86749874e-08, 0.279151142)
         QuestNameMob = "AmazonQuest2"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(5447.388671875, 601.74407958984, 751.86462402344)

      elseif HighestLvToFarm == 1700  then
         StringFindMob = "Marine Commodore"

         SpawnPoint = "GreatTree"
         SpawnCFrame = CFrame.new(2260.66162, 25.852705, -6416.6084, -0.626811504, 1.25838984e-08, -0.77917093, 6.058122e-09, 1, 1.1276855e-08, 0.77917093, 2.34815012e-09, -0.626811504)
         QuestNameMob = "MarineTreeIsland"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(2179.2548828125, 28.701448440552, -6739.7299804688)

      elseif HighestLvToFarm == 1725 then
         SpawnPoint = "GreatTree"
         StringFindMob = "Marine Rear Admiral"

         SpawnCFrame = CFrame.new(2260.66162, 25.852705, -6416.6084, -0.626811504, 1.25838984e-08, -0.77917093, 6.058122e-09, 1, 1.1276855e-08, 0.77917093, 2.34815012e-09, -0.626811504)
         QuestNameMob = "MarineTreeIsland"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(2179.2548828125, 28.701448440552, -6739.7299804688)
         
      elseif HighestLvToFarm == 1775  then
         SpawnPoint = "BigMansion"
         StringFindMob = "Fishman Raider"

         SpawnCFrame = CFrame.new(-12550.4844, 337.168365, -7425.26855, -0.999161005, -4.15654711e-09, 0.0409527794, -5.47581491e-09, 1, -3.21021858e-08, -0.0409527794, -3.22995035e-08, -0.999161005)
         QuestNameMob = "DeepForestIsland3"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-10580.998046875, 331.75863647461, -8758.193359375)
      elseif HighestLvToFarm == 1800 then
         SpawnPoint = "BigMansion"
         StringFindMob = "Fishman Captain"

         SpawnCFrame = CFrame.new(-12550.4844, 337.168365, -7425.26855, -0.999161005, -4.15654711e-09, 0.0409527794, -5.47581491e-09, 1, -3.21021858e-08, -0.0409527794, -3.22995035e-08, -0.999161005)
         QuestNameMob = "DeepForestIsland3"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-10580.998046875, 331.75863647461, -8758.193359375)

      elseif HighestLvToFarm == 1825 then
         SpawnPoint = "BigMansion"
         StringFindMob = "Forest Pirate"
         SpawnCFrame = CFrame.new(-12550.4844, 337.168365, -7425.26855, -0.999161005, -4.15654711e-09, 0.0409527794, -5.47581491e-09, 1, -3.21021858e-08, -0.0409527794, -3.22995035e-08, -0.999161005)
         QuestNameMob = "DeepForestIsland"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-13231.467773438, 332.37414550781, -7626.6860351563)

      elseif HighestLvToFarm == 1850 then
         SpawnPoint = "BigMansion"
         StringFindMob = "Mythological Pirate"
         SpawnCFrame = CFrame.new(-12550.4844, 337.168365, -7425.26855, -0.999161005, -4.15654711e-09, 0.0409527794, -5.47581491e-09, 1, -3.21021858e-08, -0.0409527794, -3.22995035e-08, -0.999161005)
         QuestNameMob = "DeepForestIsland"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-13231.467773438, 332.37414550781, -7626.6860351563)
      elseif HighestLvToFarm == 1900 then
         SpawnCFrame = (CFrame.new(-11374.4658, 331.723297, -10390.6523, 0.0812454298, -6.60837287e-08, 0.996694148, -2.83417223e-09, 1, 6.65339499e-08, -0.996694148, -8.23038171e-09, 0.0812454298))
         SpawnPoint = "PineappleTown"
         StringFindMob = "Jungle Pirate"
         QuestNameMob = "DeepForestIsland2"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-12683.189453125, 390.85668945313, -9902.15625)

      elseif HighestLvToFarm == 1925  then
         SpawnCFrame = (CFrame.new(-11374.4658, 331.723297, -10390.6523, 0.0812454298, -6.60837287e-08, 0.996694148, -2.83417223e-09, 1, 6.65339499e-08, -0.996694148, -8.23038171e-09, 0.0812454298))
         SpawnPoint = "PineappleTown"
         QuestNameMob = "DeepForestIsland2"
         LvQuestMob = 2
         StringFindMob = "Musketeer Pirate"
         QuestCFrameMob = CFrame.new(-12683.189453125, 390.85668945313, -9902.15625)
      elseif HighestLvToFarm == 1975 then
         SpawnCFrame = (CFrame.new(-9540.20898, 142.104858, 5537.26318, -0.0597328693, -5.60282345e-08, 0.998214364, -3.90994126e-09, 1, 5.5894489e-08, -0.998214364, -5.6422117e-10, -0.0597328693))
         SpawnPoint = "HauntedCastle"
         QuestNameMob = "HauntedQuest1"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-9490.2793, 142.104858, 5565.8501)
         StringFindMob = "Reborn Skeleton"
      elseif HighestLvToFarm == 2000  then
         SpawnCFrame = (CFrame.new(-9540.20898, 142.104858, 5537.26318, -0.0597328693, -5.60282345e-08, 0.998214364, -3.90994126e-09, 1, 5.5894489e-08, -0.998214364, -5.6422117e-10, -0.0597328693))
         SpawnPoint = "HauntedCastle"
         QuestNameMob = "HauntedQuest1"
         StringFindMob = "Living Zombie"
         LvQuestMob = 2
         QuestCFrameMob = CFrame.new(-9490.2793, 142.104858, 5565.8501)

      elseif HighestLvToFarm == 2025  then
         SpawnPoint = "HauntedCastle"
         SpawnCFrame = (CFrame.new(-9540.20898, 142.104858, 5537.26318, -0.0597328693, -5.60282345e-08, 0.998214364, -3.90994126e-09, 1, 5.5894489e-08, -0.998214364, -5.6422117e-10, -0.0597328693))
         QuestNameMob = "HauntedQuest2"
         StringFindMob = "Demonic Soul"
         LvQuestMob = 1
         QuestCFrameMob = CFrame.new(-9506.95313, 172.104858, 6074.63086)

      elseif HighestLvToFarm >= 2050 then
         SpawnPoint = "HauntedCastle"
         SpawnCFrame = (CFrame.new(-9540.20898, 142.104858, 5537.26318, -0.0597328693, -5.60282345e-08, 0.998214364, -3.90994126e-09, 1, 5.5894489e-08, -0.998214364, -5.6422117e-10, -0.0597328693))
         LvQuestMob = 2
         StringFindMob = "Posessed Mummy"
         QuestNameMob = "HauntedQuest2"
         QuestCFrameMob = CFrame.new(-9506.95313, 172.104858, 6074.63086)
      end
   end
end
function CheckMobPickSea1()
   if FirstSea and getgenv().AutoFarm2 and SelectedMobSea1 ~= nil then
      if SelectedMobSea1 == "Bandit [Lv. 5]" then
         NameMob = "Bandit [Lv. 5]"
         SpawnPoint = "Default"
         SpawnCFrame = CFrame.new(977.038269, 16.5166149, 1420.94336, 0.97796452, 0, -0.208771184, -0, 1, -0, 0.208771184, 0, 0.97796452)
         QuestNameMob = "BanditQuest1"
         LvQuestMob= 1
         StringFindMob = "Bandit"
         QuestCFrameMob = CFrame.new(1061.66699, 16.5166187, 1544.52905, -0.942978859, -3.33851502e-09, 0.332852632, 7.04340497e-09, 1, 2.99841325e-08, -0.332852632, 3.06188177e-08, -0.942978859)
      elseif SelectedMobSea1 == "Monkey [Lv. 14]" then
         NameMob = "Monkey [Lv. 14]"
         SpawnPoint = "Jungle"
         SpawnCFrame = CFrame.new(-1332.1394, 11.8529119, 492.35907, -0.774900496, -1.23768311e-08, 0.632082939, 1.77851245e-08, 1, 4.13846735e-08, -0.632082939, 4.33106848e-08, -0.774900496)
         QuestNameMob = "JungleQuest"
         LvQuestMob= 1
         StringFindMob = "Monkey"
         QuestCFrameMob = CFrame.new(-1604.12012, 36.8521118, 154.23732, 0.0648873374, -4.70858913e-06, -0.997892559, 1.41431883e-07, 1, -4.70933674e-06, 0.997892559, 1.64442184e-07, 0.0648873374)
      elseif SelectedMobSea1 == "Gorilla [Lv. 20]" then
         NameMob = "Gorilla [Lv. 20]"
         SpawnPoint = "Jungle"
         SpawnCFrame = CFrame.new(-1332.1394, 11.8529119, 492.35907, -0.774900496, -1.23768311e-08, 0.632082939, 1.77851245e-08, 1, 4.13846735e-08, -0.632082939, 4.33106848e-08, -0.774900496)
         QuestNameMob = "JungleQuest"
         LvQuestMob= 2
         StringFindMob = "Gorilla"
         QuestCFrameMob = CFrame.new(-1604.12012, 36.8521118, 154.23732, 0.0648873374, -4.70858913e-06, -0.997892559, 1.41431883e-07, 1, -4.70933674e-06, 0.997892559, 1.64442184e-07, 0.0648873374)
      elseif SelectedMobSea1 == "Pirate [Lv. 35]" then
         NameMob = "Pirate [Lv. 35]"
         SpawnCFrame = CFrame.new(-1186.37769, 4.75154591, 3810.49243, 0.508615494, 0, -0.860993803, -0, 1, -0, 0.860993803, 0, 0.508615494)
         SpawnPoint = "Pirate"
         QuestNameMob = "BuggyQuest1"
         LvQuestMob= 1
         StringFindMob = "Pirate"
         QuestCFrameMob = CFrame.new(-1139.59717, 4.75205183, 3825.16211, -0.959730506, -7.5857054e-09, 0.280922383, -4.06310328e-08, 1, -1.11807175e-07, -0.280922383, -1.18718916e-07, -0.959730506)
      elseif SelectedMobSea1 == "Brute [Lv. 45]"  then
         NameMob = "Brute [Lv. 45]"
         SpawnCFrame = CFrame.new(-1186.37769, 4.75154591, 3810.49243, 0.508615494, 0, -0.860993803, -0, 1, -0, 0.860993803, 0, 0.508615494)
         SpawnPoint = "Pirate"
         QuestNameMob = "BuggyQuest1"
         LvQuestMob= 2
         StringFindMob = "Brute"
         QuestCFrameMob = CFrame.new(-1139.59717, 4.75205183, 3825.16211, -0.959730506, -7.5857054e-09, 0.280922383, -4.06310328e-08, 1, -1.11807175e-07, -0.280922383, -1.18718916e-07, -0.959730506)
      elseif SelectedMobSea1 == "Desert Bandit [Lv. 60]" then
         NameMob = "Desert Bandit [Lv. 60]"
         SpawnPoint = "Desert"
         SpawnCFrame = CFrame.new(917.85199, 3.37914562, 4114.66895, 0.203889921, -7.29310585e-08, 0.978993833, -8.66312355e-09, 1, 7.63001538e-08, -0.978993833, -2.40379769e-08, 0.203889921)
         QuestNameMob = "DesertQuest"
         LvQuestMob= 1
         StringFindMob = "Desert Bandit"
         QuestCFrameMob = CFrame.new(897.031128, 6.43846416, 4388.97168, -0.804044724, 3.68233266e-08, 0.594568789, 6.97835176e-08, 1, 3.24365246e-08, -0.594568789, 6.75715199e-08, -0.804044724)
      elseif SelectedMobSea1 == "Desert Officer [Lv. 70]" then
         NameMob = "Desert Officer [Lv. 70]"
         SpawnPoint = "Desert"
         SpawnCFrame = CFrame.new(917.85199, 3.37914562, 4114.66895, 0.203889921, -7.29310585e-08, 0.978993833, -8.66312355e-09, 1, 7.63001538e-08, -0.978993833, -2.40379769e-08, 0.203889921)
         QuestNameMob = "DesertQuest"
         LvQuestMob= 2
         StringFindMob = "Desert Officer"
         QuestCFrameMob = CFrame.new(897.031128, 6.43846416, 4388.97168, -0.804044724, 3.68233266e-08, 0.594568789, 6.97835176e-08, 1, 3.24365246e-08, -0.594568789, 6.75715199e-08, -0.804044724)
      elseif SelectedMobSea1 == "Snow Bandit [Lv. 90]" then
         NameMob = "Snow Bandit [Lv. 90]"
         SpawnPoint = "Ice"
         SpawnCFrame = CFrame.new(1107.42444, 7.3035593, -1164.79614, 0.548184574, -8.23326758e-08, 0.836357415, 4.65359591e-08, 1, 6.79403129e-08, -0.836357415, 1.67686287e-09, 0.548184574)
         QuestNameMob = "SnowQuest"
         LvQuestMob= 1
         StringFindMob = "Snow Bandits"
         QuestCFrameMob = CFrame.new(1384.14001, 87.272789, -1297.06482, 0.348555952, -2.53947841e-09, -0.937287986, 1.49860568e-08, 1, 2.86358204e-09, 0.937287986, -1.50443711e-08, 0.348555952)
      elseif SelectedMobSea1 == "Snowman [Lv. 100]" then
         NameMob = "Snowman [Lv. 100]"
         SpawnPoint = "Ice"
         SpawnCFrame = CFrame.new(1107.42444, 7.3035593, -1164.79614, 0.548184574, -8.23326758e-08, 0.836357415, 4.65359591e-08, 1, 6.79403129e-08, -0.836357415, 1.67686287e-09, 0.548184574)
         QuestNameMob = "SnowQuest"
         LvQuestMob= 2
         StringFindMob = "Snowman"
         QuestCFrameMob = CFrame.new(1384.14001, 87.272789, -1297.06482, 0.348555952, -2.53947841e-09, -0.937287986, 1.49860568e-08, 1, 2.86358204e-09, 0.937287986, -1.50443711e-08, 0.348555952)
      elseif SelectedMobSea1 == "Chief Petty Officer [Lv. 120]" then
         NameMob = "Chief Petty Officer [Lv. 120]"
         SpawnPoint = "MarineBase"
         SpawnCFrame = CFrame.new(-4922.20264, 41.2520523, 4424.44434, -0.488673091, -2.20081375e-08, 0.872467041, 1.13403127e-08, 1, 3.15769455e-08, -0.872467041, 2.53248498e-08, -0.488673091)
         QuestNameMob = "MarineQuest2"
         LvQuestMob= 1
         StringFindMob = "Chief Petty Officer"
         QuestCFrameMob = CFrame.new(-5035.0835, 28.6520386, 4325.29443, 0.0243340395, -7.08064647e-08, 0.999703884, -6.36926814e-08, 1, 7.23777944e-08, -0.999703884, -6.54350671e-08, 0.0243340395)
      elseif SelectedMobSea1 == "Sky Bandit [Lv. 150]" then
         NameMob = "Sky Bandit [Lv. 150]"
         SpawnPoint = "Sky"
         SpawnCFrame = CFrame.new(-4916.79346, 717.671265, -2637.03589, 0.808458745, 2.83643207e-08, 0.588552833, -4.5316173e-09, 1, -4.19685264e-08, -0.588552833, 3.12627257e-08, 0.808458745)
         QuestNameMob = "SkyQuest"
         LvQuestMob= 1
         StringFindMob = "Sky Bandit"
         QuestCFrameMob = CFrame.new(-4841.83447, 717.669617, -2623.96436, -0.875942111, 5.59710216e-08, -0.482416272, 3.04023082e-08, 1, 6.08195947e-08, 0.482416272, 3.86078725e-08, -0.875942111)
      elseif SelectedMobSea1 ==  "Dark Master [Lv. 175]" then
         NameMob = "Dark Master [Lv. 175]"
         SpawnPoint = "Sky"
         SpawnCFrame = CFrame.new(-4916.79346, 717.671265, -2637.03589, 0.808458745, 2.83643207e-08, 0.588552833, -4.5316173e-09, 1, -4.19685264e-08, -0.588552833, 3.12627257e-08, 0.808458745)
         QuestNameMob = "SkyQuest"
         LvQuestMob= 2
         StringFindMob = "Dark Master"
         QuestCFrameMob = CFrame.new(-4841.83447, 717.669617, -2623.96436, -0.875942111, 5.59710216e-08, -0.482416272, 3.04023082e-08, 1, 6.08195947e-08, 0.482416272, 3.86078725e-08, -0.875942111)
      elseif SelectedMobSea1 == "Toga Warrior [Lv. 225]"  then
         NameMob = "Toga Warrior [Lv. 225]"
         SpawnPoint = "Colosseum"
         SpawnCFrame = CFrame.new(-1393.48926, 7.28934002, -2842.57324, -0.998255789, 6.55446408e-09, 0.0590373725, 6.72640565e-09, 1, 2.7136855e-09, -0.0590373725, 3.10606163e-09, -0.998255789)
         QuestNameMob = "ColosseumQuest"
         LvQuestMob= 1
         StringFindMob = "Toga Warrior"
         QuestCFrameMob = CFrame.new(-1576.11743, 7.38933945, -2983.30762, 0.576966345, 1.22114863e-09, 0.816767931, -3.58496594e-10, 1, -1.24185606e-09, -0.816767931, 4.2370063e-10, 0.576966345)
      elseif SelectedMobSea1 == "Gladiator [Lv. 275]" then
         NameMob = "Gladiator [Lv. 275]"
         SpawnPoint = "Colosseum"
         SpawnCFrame = CFrame.new(-1393.48926, 7.28934002, -2842.57324, -0.998255789, 6.55446408e-09, 0.0590373725, 6.72640565e-09, 1, 2.7136855e-09, -0.0590373725, 3.10606163e-09, -0.998255789)
         QuestNameMob = "ColosseumQuest"
         LvQuestMob= 2
         StringFindMob = "Gladiato"
         QuestCFrameMob = CFrame.new(-1576.11743, 7.38933945, -2983.30762, 0.576966345, 1.22114863e-09, 0.816767931, -3.58496594e-10, 1, -1.24185606e-09, -0.816767931, 4.2370063e-10, 0.576966345)
      elseif SelectedMobSea1 == "Military Soldier [Lv. 300]" then
         NameMob = "Military Soldier [Lv. 300]"
         SpawnPoint = "Magma"
         SpawnCFrame = CFrame.new(-5226.26416, 8.59022045, 8472.14844, 0.506667018, 0, -0.862141788, -0, 1, -0, 0.862141907, 0, 0.506666958)
         QuestNameMob = "MagmaQuest"
         LvQuestMob= 1
         StringFindMob = "Military Soldier"
         QuestCFrameMob = CFrame.new(-5316.55859, 12.2370615, 8517.2998, 0.588437557, -1.37880001e-08, -0.808542669, -2.10116209e-08, 1, -3.23446478e-08, 0.808542669, 3.60215964e-08, 0.588437557)
      elseif SelectedMobSea1 == "Military Spy [Lv. 330]"  then
         NameMob = "Military Spy [Lv. 330]"
         SpawnPoint = "Magma"
         SpawnCFrame = CFrame.new(-5226.26416, 8.59022045, 8472.14844, 0.506667018, 0, -0.862141788, -0, 1, -0, 0.862141907, 0, 0.506666958)
         QuestNameMob = "MagmaQuest"
         LvQuestMob= 2
         StringFindMob = "Military Spy"
         QuestCFrameMob = CFrame.new(-5316.55859, 12.2370615, 8517.2998, 0.588437557, -1.37880001e-08, -0.808542669, -2.10116209e-08, 1, -3.23446478e-08, 0.808542669, 3.60215964e-08, 0.588437557)
      elseif SelectedMobSea1 == "Fishman Warrior [Lv. 375]" then 
         NameMob = "Fishman Warrior [Lv. 375]"
         QuestNameMob = "FishmanQuest"
         LvQuestMob= 1
         StringFindMob = "Fishman Warrior"
         QuestCFrameMob = CFrame.new(61122.5625, 18.4716396, 1568.16504, 0.893533468, 3.95251609e-09, 0.448996574, -2.34327455e-08, 1, 3.78297464e-08, -0.448996574, -4.43233645e-08, 0.893533468)
      elseif SelectedMobSea1 == "Fishman Commando [Lv. 400]" then
         NameMob = "Fishman Commando [Lv. 400]"
         QuestNameMob = "FishmanQuest"
         LvQuestMob= 2
         StringFindMob = "Fishman Commando"
         QuestCFrameMob = CFrame.new(61122.5625, 18.4716396, 1568.16504, 0.893533468, 3.95251609e-09, 0.448996574, -2.34327455e-08, 1, 3.78297464e-08, -0.448996574, -4.43233645e-08, 0.893533468)
      elseif SelectedMobSea1 == "God's Guard [Lv. 450]" then
         NameMob = "God's Guard [Lv. 450]"
         QuestNameMob = "SkyExp1Quest"
         LvQuestMob= 1
         StringFindMob = "God's Guards"
         QuestCFrameMob = CFrame.new(-4721.71436, 845.277161, -1954.20105, -0.999277651, -5.56969759e-09, 0.0380011722, -4.14751478e-09, 1, 3.75035256e-08, -0.0380011722, 3.73188307e-08, -0.999277651)
      elseif SelectedMobSea1 == "Shanda [Lv. 475]" then
         NameMob = "Shanda [Lv. 475]"
         QuestNameMob = "SkyExp1Quest"
         LvQuestMob= 2
         StringFindMob = "Shandas"
         QuestCFrameMob = CFrame.new(-7863.63672, 5545.49316, -379.826324, 0.362120807, -1.98046344e-08, -0.93213129, 4.05822291e-08, 1, -5.48095125e-09, 0.93213129, -3.58431969e-08, 0.362120807)
      elseif SelectedMobSea1 == "Royal Squad [Lv. 525]" then
         NameMob = "Royal Squad [Lv. 525]"
         QuestNameMob = "SkyExp2Quest"
         LvQuestMob= 1
         StringFindMob = "Royal Squad"
         QuestCFrameMob = CFrame.new(-7902.66895, 5635.96387, -1411.71802, 0.0504222959, 2.5710392e-08, 0.998727977, 1.12541557e-07, 1, -3.14249675e-08, -0.998727977, 1.13982921e-07, 0.0504222959)
      elseif SelectedMobSea1 == "Royal Soldier [Lv. 550]" then
         NameMob = "Royal Soldier [Lv. 550]"
         QuestNameMob = "SkyExp2Quest"
         LvQuestMob= 2
         StringFindMob = "Royal Soldier"
         QuestCFrameMob = CFrame.new(-7902.66895, 5635.96387, -1411.71802, 0.0504222959, 2.5710392e-08, 0.998727977, 1.12541557e-07, 1, -3.14249675e-08, -0.998727977, 1.13982921e-07, 0.0504222959)
      elseif SelectedMobSea1 == "Galley Pirate [Lv. 625]" then 
         NameMob = "Galley Pirate [Lv. 625]"
         QuestNameMob = "FountainQuest"
         LvQuestMob= 1
         StringFindMob = "Galley Pirate"
         QuestCFrameMob = CFrame.new(5254.60156, 38.5011406, 4049.69678, -0.0504891425, -3.62066501e-08, -0.998724639, -9.87921389e-09, 1, -3.57534553e-08, 0.998724639, 8.06145284e-09, -0.0504891425)
      elseif SelectedMobSea1 == "Galley Captain [Lv. 650]" then
         NameMob = "Galley Captain [Lv. 650]"
         QuestNameMob = "FountainQuest"
         LvQuestMob= 2
         StringFindMob = "Galley Captain"
         QuestCFrameMob = CFrame.new(5254.60156, 38.5011406, 4049.69678, -0.0504891425, -3.62066501e-08, -0.998724639, -9.87921389e-09, 1, -3.57534553e-08, 0.998724639, 8.06145284e-09, -0.0504891425)
      end
   end
end
CanTween = true
function DoTween(dist, Speed)
   local char = game.Players.LocalPlayer.Character
   local hm = char:FindFirstChild("HumanoidRootPart")
   local info = TweenInfo.new((hm.Position - dist.Position).magnitude / Speed,Enum.EasingStyle.Linear)
   local tween =  game:service"TweenService":Create(hm, info, {CFrame = dist})
   if CanTween and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0  then
      tween:Play()
      tween.Completed:wait()
   else
      tween:Cancel()
   end
end
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(function()
   Tweening = true
   
   pcall(function()
   local char = game.Players.LocalPlayer.Character
   local hm = char:FindFirstChild("HumanoidRootPart")
   local info = TweenInfo.new((hm.Position - dist.Position).magnitude / Speed,Enum.EasingStyle.Linear)
   local tween =  game:service"TweenService":Create(hm, info, {CFrame = dist})
   tween(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame,TweenSpeed)
   wait(0.1)
   tween:Cancel()
   end)
   CanTween = false
   wait(4)
   Tweening = false
   CanTween = true
end)
function FastAttack()
    Fast = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
    pcall(function()
      if getgenv().FastAttack then
       Fast.activeController.attacking = false 
       Fast.activeController.active = false
       Fast.activeController.timeToNextAttack = 0
      end
    end)
end
function Simulation()
   if setsimulationradius then
      sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 10000)
  end
   if setsimulationradius then
      sethiddenproperty(game.Players.LocalPlayer, "MaxSimulationRadius", math.huge)
   end
   if setsimulationradius then
       sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
   end
end
function BringMob()
   if getgenv().AutoFarmBring and DoMagnet then
       if SecondSea or ThirdSea then
           for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
               if v.Parent and v:FindFirstChild("HumanoidRootPart") ~= nil and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0  then
                   if  v.Parent and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and not Tweening and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <=  300 and string.find(v.Name,HighestLvToFarm)  then 
                       Simulation()
                       zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                     --  spawn(function()
                          --pcall(function()
                           --  wait()
                           --  zeroGrav(v.HumanoidRootPart)
                        --  end)
                      -- end)
                       v.Humanoid.Sit = true
                       v.HumanoidRootPart.Transparency = 1
                       v.HumanoidRootPart.CanCollide = false
                       v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                       if BringCFrame~= nil and BringPos ~= nil  and  (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                          Simulation()
                          v.HumanoidRootPart.CFrame = BringCFrame
                          v.HumanoidRootPart.Position = BringPos
                       else 
                          BringCFrame = v.HumanoidRootPart.CFrame
                          BringPos = v.HumanoidRootPart.Position
                       end
                   end
                 else                            
                    pcall(function()
                       zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                    end)
               end
           end
       elseif FirstSea then
           for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
               if v.Parent and v:FindFirstChild("HumanoidRootPart") ~= nil then
                   if v.Name == NameMob and v.Parent and not Tweening and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <=  300 then
                       Simulation()
                       zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                      -- spawn(function()
                      --    wait()
                      --    pcall(function()
                      --       zeroGrav(v.HumanoidRootPart)
                         -- end)
                       --end)
                       v.HumanoidRootPart.Transparency = 1
                       v.HumanoidRootPart.CanCollide = false
                       v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                       if BringCFrame~= nil and BringPos ~= nil and  (v.HumanoidRootPart.Position-BringPos).magnitude <= 300 then
                          Simulation()
                           v.HumanoidRootPart.CFrame = BringCFrame
                           v.HumanoidRootPart.Position = BringPos
                       else 
                           BringCFrame = v.HumanoidRootPart.CFrame
                           BringPos = v.HumanoidRootPart.Position
                       end
                   end
               end
           end
       end
   end
end
function BringMobBone()
    if getgenv().AutoFarmBring and DoMagnet then
        if ThirdSea then
            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if v.Parent and v:FindFirstChild("HumanoidRootPart") ~= nil and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0  then
                    if  v.Parent and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and not Tweening and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <=  1500 then -- and string.find(v.Name,HighestLvToFarm) 
                        Simulation()
                        zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                        --spawn(function()
                        --   pcall(function()
                        --      wait()
                       --       zeroGrav(v.HumanoidRootPart)
                       --    end)
                      --  end)
                        v.Humanoid.Sit = true
                        v.HumanoidRootPart.Transparency = 1
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        if BringCFrame~= nil and BringPos ~= nil  and  (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                           Simulation()
                           v.HumanoidRootPart.CFrame = BringCFrame
                           v.HumanoidRootPart.Position = BringPos
                        else 
                         --  BringCFrame = v.HumanoidRootPart.CFrame
                        --   BringPos = v.HumanoidRootPart.Position
                        end
                    end
                  else                            
                     pcall(function()
                        zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                     end)
                end
            end
        elseif FirstSea then
            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if v.Parent and v:FindFirstChild("HumanoidRootPart") ~= nil then
                    if v.Name == NameMob and v.Parent and not Tweening and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <=  300 then
                        Simulation()
                        zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                        --spawn(function()
                         --  wait()
                          -- pcall(function()
                           --   zeroGrav(v.HumanoidRootPart)
                          -- end)
                       --end)
                        v.HumanoidRootPart.Transparency = 1
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        if BringCFrame~= nil and BringPos ~= nil and  (v.HumanoidRootPart.Position-BringPos).magnitude <= 300 then
                           Simulation()
                            v.HumanoidRootPart.CFrame = BringCFrame
                            v.HumanoidRootPart.Position = BringPos
                        else 
                            BringCFrame = v.HumanoidRootPart.CFrame
                            BringPos = v.HumanoidRootPart.Position
                        end
                    end
                end
            end
        end
    end
end
spawn(function()
    while game:GetService("RunService").RenderStepped:wait() do
        pcall(function()
            for i, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                if v:FindFirstChild("Humanoid") ~= nil  and v:FindFirstChild("HumanoidRootPart") ~= nil and v:IsA("Model") then
                    v.Parent = game:GetService("Workspace").Enemies
                end
            end
            for i, v in pairs(game:GetService("Workspace").Boats:GetChildren()) do
                if v:FindFirstChild("Humanoid") ~= nil  and v:FindFirstChild("HumanoidRootPart") ~= nil and v:IsA("Model") then
                    v.Parent = game:GetService("Workspace").Enemies
                end
            end
        end)
    end
end)
local AutoFarmPage = lib:addPage("Auto Farm", 6035145364)
local AutoFarm = AutoFarmPage:addSection("Auto Farm")
AutoFarm:addToggle("Auto Farm",getgenv().AutoFarm,function(boolen)
    getgenv().AutoFarm  = boolen
    
    if not getgenv().AutoFarm2 then
      CheckLv()
      CheckQuestMob()
    else
      CheckMobPickSea1()
    end
    if getgenv().AutoFarm and getgenv().AutoQuest then game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest") end
    spawn(function()
      while getgenv().AutoFarm do
         wait()
         pcall(function()
            zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
         end)
      end
    end)
    while getgenv().AutoFarm do
        game:GetService("RunService").RenderStepped:wait()
        pcall(function()
        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
        if SecondSea or ThirdSea then
            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if string.find(v.Name,HighestLvToFarm) and not Tweening and not string.find(v.Name,"Boss") and getgenv().AutoFarm and string.find(v.Name,StringFindMob) then
                  if getgenv().AutoSetSpawn then
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().AutoFarm and game:GetService("Players").LocalPlayer.Data.SpawnPoint.Value ~= SpawnPoint and CanTween then
                        DoTween(SpawnCFrame,TweenSpeed)
                        local args = {
                           [1] = "SetSpawnPoint"
                        }
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                        wait(0.1)

                     end
                  end
                  if getgenv().AutoFarmQuest then
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().AutoFarm and  game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false or not string.find(game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,StringFindMob) and CanTween then
                        DoTween(QuestCFrameMob,TweenSpeed)
                        wait(0.1)
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position- Vector3.new(QuestCFrameMob)).magnitude < 50 then
                           game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestNameMob, LvQuestMob)
                        elseif getgenv().AutoFarmQuest and getgenv().AutoFarm then Tweening = true DoTween(QuestCFrameMob,TweenSpeed) Tweening = false
                           game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestNameMob, LvQuestMob)
                        end
                     end
                  end
                  DoMagnet = false
                  if  getgenv().FastAttack then
                     FastAttack()
                     end
                  Simulation()
                  if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and getgenv().AutoFarm then
                     Tweening = true
                     DoTween(v.HumanoidRootPart.CFrame * CFrame.new(0,20,0),TweenSpeed)
                  end
                  Tweening = false
               if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.Health > 0 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Parent and v:FindFirstChild("HumanoidRootPart") then
                  BringCFrame = v.HumanoidRootPart.CFrame
                  BringPos = v.HumanoidRootPart.Position
               end

                  repeat 
                     game:GetService("RunService").RenderStepped:wait()
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0  then
                        spawn(function()
                           Equip(Weapon)
                           Click()
                        end)
                        Simulation()
                        if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                           if  getgenv().FastAttack then
                              FastAttack()
                           end
                           spawn(function()
                              wait(0.3)
                              BringMob()
                           end)
                           v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                           if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                              game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                           end
                        elseif not Tweening and v:FindFirstChild("HumanoidRootPart") ~= nil and v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then  DoTween(v.HumanoidRootPart.CFrame,TweenSpeed)
                        end
                        DoMagnet = true
                        Tweening = false
                     end
                  until not v.Parent or v:FindFirstChild("Humanoid") == nil and v.Humanoid.Health <= 0 or v:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 or getgenv().AutoFarm == false
               if not getgenv().AutoFarm2 then
                  CheckLv()
                  CheckQuestMob()
                else
                  CheckMobPickSea1()
                end
               end
         end
      elseif FirstSea then
         if game:GetService("Workspace").Enemies:FindFirstChild(NameMob) then
               for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                  if v.Name == NameMob and not string.find(v.Name,"Boss") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and getgenv().AutoFarm then
                     if getgenv().AutoSetSpawn then
                        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().AutoFarm and game:GetService("Players").LocalPlayer.Data.SpawnPoint.Value ~= SpawnPoint and CanTween then
                           Tweening = true
                           DoTween(SpawnCFrame,TweenSpeed)
                           Tweening = false
                           local args = {
                              [1] = "SetSpawnPoint"
                           }
                           game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                        end
                     end
                     if getgenv().AutoFarmQuest then
                        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().AutoFarm  and game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false or not string.find(game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,StringFindMob) and CanTween then
                           Tweening = true
                           DoTween(QuestCFrameMob,TweenSpeed)
                           Tweening = false
                           if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position- Vector3.new(QuestCFrameMob)).magnitude < 50 then
                              game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestNameMob, LvQuestMob)
                           elseif getgenv().AutoFarmQuest and getgenv().AutoFarm then Tweening = true DoTween(QuestCFrameMob,TweenSpeed) Tweening = false
                              game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestNameMob, LvQuestMob)
                           end
                        end
                     end
                     DoMagnet = false
                     if  getgenv().FastAttack then
                        FastAttack()
                        end
                     Simulation()
                     if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0  and getgenv().AutoFarm then
                        Tweening = true
                        DoTween(v.HumanoidRootPart.CFrame * CFrame.new(0,20,0),TweenSpeed)
                     end
                     Tweening = false
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.Health > 0 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Parent and v:FindFirstChild("HumanoidRootPart") then
                           BringCFrame = v.HumanoidRootPart.CFrame
                           BringPos = v.HumanoidRootPart.Position
                     end
                     repeat 
                        game:GetService("RunService").RenderStepped:wait()
                        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0  then
                           spawn(function()
                              Equip(Weapon)
                              Click()
                           end)
                           Simulation()
                           if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and not Tweening and v:FindFirstChild("HumanoidRootPart") ~= nil and v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                              FastAttack()
                              spawn(function()
                                 wait(0.3)
                                 BringMob()
                              end)
                              v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                              if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                              game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                              end
                           elseif not Tweening and v:FindFirstChild("HumanoidRootPart") ~= nil and v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then  DoTween(v.HumanoidRootPart.CFrame,TweenSpeed)
                           end
                           DoMagnet = true
                           Tweening = false
                        end
                     until  not v.Parent or v:FindFirstChild("Humanoid") == nil and v.Humanoid.Health <= 0 or v:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 or getgenv().AutoFarm == false
                     if not getgenv().AutoFarm2 then
                        CheckLv()
                        CheckQuestMob()
                      else
                        CheckMobPickSea1()
                      end
                  end
               end
            end
         end
         else wait(2)
         end
      end)
   end
end)
AutoFarm:addToggle("Auto Farm Bone",getgenv().AutoFarmBone,function(boolen)
   getgenv().AutoFarmBone  = boolen
   spawn(function()
      while getgenv().AutoFarmBone do
         wait()
         pcall(function()
            zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
         end)
      end
   end)
   while getgenv().AutoFarmBone do
      game:GetService("RunService").RenderStepped:wait()
      pcall(function()
         if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
            if ThirdSea then
               for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                  if (string.find(v.Name,2050) or string.find(v.Name,2025) or string.find(v.Name,2000) or string.find(v.Name,1975)) and not Tweening and not string.find(v.Name,"Boss") and getgenv().AutoFarmBone then
                     DoMagnet = false
                     if  getgenv().FastAttack then
                        FastAttack()
                     end
                     Simulation()
                     if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and getgenv().AutoFarmBone then
                        Tweening = true
                        DoTween(v.HumanoidRootPart.CFrame * CFrame.new(0,20,0),TweenSpeed)
                     end
                     Tweening = false
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.Health > 0 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Parent and v:FindFirstChild("HumanoidRootPart") then
                        BringCFrame = v.HumanoidRootPart.CFrame
                        BringPos = v.HumanoidRootPart.Position
                     end

                     repeat 
                        game:GetService("RunService").RenderStepped:wait()
                        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0  then
                           spawn(function()
                              Equip(Weapon)
                              Click()
                           end)
                           Simulation()
                           if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                              if  getgenv().FastAttack then
                                 FastAttack()
                              end
                              spawn(function()
                                 wait(0.3)
                                 BringMobBone()
                              end)
                              v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                              if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                                 game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                              end
                           elseif not Tweening and v:FindFirstChild("HumanoidRootPart") ~= nil and v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then  DoTween(v.HumanoidRootPart.CFrame,TweenSpeed)
                           end
                           DoMagnet = true
                           Tweening = false
                        end
                     until not v.Parent or v:FindFirstChild("Humanoid") == nil and v.Humanoid.Health <= 0 or v:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 or getgenv().AutoFarmBone == false
                  end
               end
            end
         end
      end)
   end
end)
AutoFarm:addToggle("Auto Farm Fruit Mastery(Current Support Sea 2,3)",getgenv().AutoFarmFruitMastery,function(boolen)
   getgenv().AutoFarmFruitMastery = boolen
   if not getgenv().AutoFarm2 then
      CheckLv()
      CheckQuestMob()
   else
      CheckMobPickSea1()
   end
   if getgenv().AutoFarm and getgenv().AutoQuest then game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest") end
   spawn(function()
     while getgenv().AutoFarm do
        wait()
        pcall(function()
         zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
        end)
     end
   end)
   while getgenv().AutoFarmFruitMastery do
      game:GetService("RunService").RenderStepped:wait()
      --pcall(function()
      if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then
         if SecondSea or ThirdSea then
            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
               if string.find(v.Name,HighestLvToFarm) and not Tweening and not string.find(v.Name,"Boss") and getgenv().AutoFarmFruitMastery then
                  if getgenv().AutoSetSpawn then
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().AutoFarmFruitMastery and game:GetService("Players").LocalPlayer.Data.SpawnPoint.Value ~= SpawnPoint and CanTween then
                     DoTween(SpawnCFrame,TweenSpeed)
                     local args = {
                        [1] = "SetSpawnPoint"
                     }
                     game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                     wait(0.1)
                     end
                  end
                  if getgenv().AutoFarmQuest then
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and getgenv().AutoFarmFruitMastery and  game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false or not string.find(game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text,StringFindMob) and CanTween then
                        DoTween(QuestCFrameMob,TweenSpeed)
                        wait(0.1)
                        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position- Vector3.new(QuestCFrameMob)).magnitude < 50 then
                           game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestNameMob, LvQuestMob)
                        elseif getgenv().AutoFarmQuest and getgenv().AutoFarm then Tweening = true DoTween(QuestCFrameMob,TweenSpeed) Tweening = false
                           game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", QuestNameMob, LvQuestMob)
                        end
                     end
                  end
                  DoMagnet = false
                  if  getgenv().FastAttack then
                     FastAttack()
                     end
                  Simulation()
                  if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and getgenv().AutoFarmFruitMastery then
                     Tweening = true
                     DoTween(v.HumanoidRootPart.CFrame * CFrame.new(0,20,0),TweenSpeed)
                  end
                  Tweening = false
                  if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.Health > 0 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Parent and v:FindFirstChild("HumanoidRootPart") then
                     BringCFrame = v.HumanoidRootPart.CFrame
                     BringPos = v.HumanoidRootPart.Position
                  end

                  repeat 
                     game:GetService("RunService").RenderStepped:wait()
                     if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0  then
                        spawn(function()
                           Click()
                        end)
                        Simulation()
                        if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                           if  getgenv().FastAttack then
                           FastAttack()
                           end
                           spawn(function()
                              wait(0.3)
                              BringMob()
                           end)
                        
                           v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                           
                           Simulation()
                          -- zeroGrav(v.HumanoidRootPart)
                           v.Humanoid.Sit = true
                           if v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                              if v:FindFirstChild("Humanoid").Health > (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 then
                                 Equip(Weapon)
                                 game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                              else
                                 v.HumanoidRootPart.Size = Vector3.new(2, 1, 2)
                                 getgenv().UsingFruitMas = true
                                 spawn(function()
                                    while getgenv().UsingFruitMas == true and getgenv().AutoFarmFruitMastery and  v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and  v:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 and v:FindFirstChild("Humanoid").Health > 0 and (v.HumanoidRootPart.Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 do
                                       wait()
                                       pcall(function()
                                          zeroGrav(game.Players.LocalPlayer.Character.HumanoidRootPart)
                                          game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0)
                                       end)
                                    end
                                 end)
                                 pcall(function()
                                 local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value)
                                 game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                                 end)
                                 
                                 if game.Players.LocalPlayer.Data.DevilFruit.Value == "Control-Control" then
                                    pcall(function()
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillZ then
                                       if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value).TextureId ~= "rbxassetid://4900750433" then
                                          workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                          local VIM =game:GetService("VirtualInputManager")
                                          VIM:SendKeyEvent(true,"Z",false,game)
                                          wait(getgenv().SkillZHold/10)
                                          VIM:SendKeyEvent(false,"Z",false,game)
                                          workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                       end

                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillX and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].X.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"X",false,game)
                                       wait(getgenv().SkillXHold/10)
                                       VIM:SendKeyEvent(false,"X",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillC and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].C.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"C",false,game)
                                       wait(getgenv().SkillCHold/10)
                                       VIM:SendKeyEvent(false,"C",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillV and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].V.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"V",false,game)
                                       wait(getgenv().SkillVHold/10)
                                       VIM:SendKeyEvent(false,"V",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillF and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].F.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"F",false,game)
                                       wait(getgenv().SkillFHold/10)
                                       VIM:SendKeyEvent(false,"F",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                    end
                                 end)
                                 
                                 elseif game.Players.LocalPlayer.Data.DevilFruit.Value ~= "Control-Control" then
                                    pcall(function()
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillZ and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].Z.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"Z",false,game)
                                       wait(getgenv().SkillZHold/10)
                                       VIM:SendKeyEvent(false,"Z",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillX and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].X.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                      
                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"X",false,game)
                                       wait(getgenv().SkillXHold/10)
                                       VIM:SendKeyEvent(false,"X",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillC and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].C.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                       
                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"C",false,game)
                                       wait(getgenv().SkillCHold/10)
                                       
                                       VIM:SendKeyEvent(false,"C",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillV and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].V.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                      
                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"V",false,game)
                                       wait(getgenv().SkillVHold/10)
                                       VIM:SendKeyEvent(false,"V",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                    end
                                    if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) and getgenv().SkillF and v.Humanoid.Health <= (v:FindFirstChild("Humanoid").MaxHealth*HealthMastery)/100 and game:GetService("Players").LocalPlayer.PlayerGui.Main.Skills[game.Players.LocalPlayer.Data.DevilFruit.Value].F.Cooldown.AbsoluteSize.X == 0 then
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)
                                      
                                       local args = {
                                          [1] = v.HumanoidRootPart.Position
                                          }
                                       game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].RemoteEvent:FireServer(unpack(args))
                                       local VIM =game:GetService("VirtualInputManager")
                                       VIM:SendKeyEvent(true,"F",false,game)
                                       wait(getgenv().SkillFHold/10)
                                       VIM:SendKeyEvent(false,"F",false,game)
                                       workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,v.Head.Position)

                                    end
                                 end)
                                 end
                              end
                           end
                        elseif not Tweening and v:FindFirstChild("HumanoidRootPart") ~= nil and v.Parent and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health > 0 then  DoTween(v.HumanoidRootPart.CFrame,TweenSpeed)
                        end

                        
                        DoMagnet = true
                        Tweening = false
                     end
                  until not v.Parent or v:FindFirstChild("Humanoid") == nil and v.Humanoid.Health <= 0 or v:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") == nil or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") == nil or game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health <= 0 or getgenv().AutoFarmFruitMastery == false
                  if getgenv().UsingFruitMas and game.Players.LocalPlayer.Data.DevilFruit.Value == "Control-Control" then
                     if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
                        if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value).TextureId == "rbxassetid://4900750433"  then
                           local VIM =game:GetService("VirtualInputManager")
                           VIM:SendKeyEvent(true,"Z",false,game)
                           wait()
                           VIM:SendKeyEvent(false,"Z",false,game)
                        end
                     end
                  end
                  getgenv().UsingFruitMas = false
                  if not getgenv().AutoFarm2 then
                  CheckLv()
                  CheckQuestMob()
                  else
                  CheckMobPickSea1()
                  end
               end
            end
         end
      end
   end
end)
AutoFarm:addSlider("Health Mastery (%) ",getgenv().HealthMastery,0,100,function(Value)
   getgenv().HealthMastery = Value
end)

if SecondSea or ThirdSea then
   AutoFarm:addTextbox("MaxLevelMob",MaxLevelSea,function(Value)
      CheckLv()
      if Value ~= nil then
         Value = tonumber(Value)
         if typeof(Value) == nil or typeof(Value) == "nil" then
            if not NotifyBoolen then
               NotifyBoolen = true
               lib:Notify("MaxLevelMob","Please Enter Number")
               wait(1)
               NotifyBoolen = false
            end
         elseif ThirdSea then
            if Value > 1499 then
            MaxLevelSea = Value
            HighestLvToFarm = 0
            CheckLv()
            elseif not NotifyBoolen then 
               NotifyBoolen = true 
               lib:Notify("MaxLevelMob","Please enter number over 1499")                       
               wait(1)
               NotifyBoolen = false        
            end
         elseif SecondSea then
            if Value > 699 and Value < 1500 then
               MaxLevelSea = Value
               HighestLvToFarm = 0
               CheckLv()
            elseif not NotifyBoolen then 
               NotifyBoolen = true 
               lib:Notify("MaxLevelMob","Pls enter number Between 700 and 1499")
               wait(1)
               NotifyBoolen = false     
            end
         end
      end
   end)
end
if FirstSea then
   AutoFarm:addToggle("Selected Mob(Choose Mob)",getgenv().AutoFarm2,function(Value)
      getgenv().AutoFarm2 = Value
      CheckMobPickSea1()
   end)
   AutoFarm:addDropdown("Choose Mob",TableMobSea1,function(Value)
      SelectedMobSea1 = Value
   end)
end
local WeaponDropdown = AutoFarm:addDropdown("Select A Weapon",PLrWeapons,function(Value)
   Weapon = Value
end)
AutoFarm:addButton("Refresh Weapon Dropdown",function()
   AutoFarm:updateDropdown(WeaponDropdown,"Refresh Weapon",refreshWeapon1(),function()
   end)
end)
local Setting = lib:addPage("Setting", 6034509993)
local AutofarmSetting = Setting:addSection("AutoFarm Setting")
AutofarmSetting:addToggle("Auto Farm Quest",getgenv().AutoFarmQuest,function(boolen)
    getgenv().AutoFarmQuest = tonumber(boolen)
end)
AutofarmSetting:addToggle("Auto Farm Bring Mob",getgenv().AutoFarmBring,function(boolen)
   getgenv().AutoFarmBring = boolen
end)
AutofarmSetting:addToggle("Auto Farm Set Spawn",getgenv().AutoSetSpawn,function(boolen)
   getgenv().AutoSetSpawn = boolen
end)
AutofarmSetting:addToggle("Auto Farm Set Spawn",getgenv().AutoSetSpawn,function(boolen)
   getgenv().FastAttack = boolen
end)
AutofarmSetting:addButton("Auto Farm Mastery Info",function()
   lib:Notify("Auto Farm Mastery","10 in Slider = 1s Hold Time")
end)
AutofarmSetting:addToggle("Skill Z",getgenv().SkillZ,function(Value)
   getgenv().SkillZ = Value
end)
AutofarmSetting:addSlider("Skill Z Hold Time ",getgenv().SkillZHold,0,40,function(Value)
   getgenv().SkillZHold = Value
end)
AutofarmSetting:addToggle("Skill X",getgenv().SkillX,function(Value)
   getgenv().SkillX = Value
end)
AutofarmSetting:addSlider("Skill X Hold Time",getgenv().SkillXHold,0,40,function(Value)
   getgenv().SkillXHold = Value
end)
AutofarmSetting:addToggle("Skill C",getgenv().SkillC,function(Value)
   getgenv().SkillC = Value
end)
AutofarmSetting:addSlider("Skill C Hold Time",getgenv().SkillCHold,0,40,function(Value)
   getgenv().SkillCHold = Value
end)
AutofarmSetting:addToggle("Skill V",getgenv().SkillV,function(Value)
   getgenv().SkillV = Value
end)
AutofarmSetting:addSlider("Skill V Hold Time",getgenv().SkillVHold,0,40,function(Value)
   getgenv().SkillVHold = Value
end)
AutofarmSetting:addToggle("Skill F",getgenv().SkillF,function(Value)
   getgenv().SkillF = Value
end)
AutofarmSetting:addSlider("Skill F Hold Time",getgenv().SkillFHold,0,40,function(Value)
   getgenv().SkillFHold = Value
end)
local AbilitySetting = Setting:addSection("Ability Setting")
--Simple Check 
spawn(function()
   while getgenv().AutoBuso do
      wait()
      if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
         local args = {
            [1] = "Buso"
         }
         game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
      end
   end
end)

AbilitySetting:addToggle("Auto Buso",getgenv().AutoBuso,function(boolen)
   getgenv().AutoBuso = boolen
   while getgenv().AutoBuso do
      wait()
      if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
         local args = {
            [1] = "Buso"
         }
         game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
      end
   end
end)
