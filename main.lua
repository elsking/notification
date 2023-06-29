local Notification = {}

local interface = game:GetObjects('rbxassetid://')[1]

if (gethui) then
    interface.Parent = gethui()
elseif (syn.protect_gui) then
    interface.Parent = game:GetService("CoreGui")
    syn.protect_gui(interface)
else
    interface.Parent = game:GetService("CoreGui")
end

local ts = game:GetService("TweenService")

local container = interface.NotificationContainer
local templates = interface.Templates
local notificationHeight = 80
local notificationOffset = 0
local notificationCount = 0

function Notification:PostNotification(Options) 
    if (notificationCount >= 7) then
		return
	end
    
	notificationCount += 1

    local Options = Options or {
        Title = Options.Title or "Title",
        Message = Options.Message or "Message",
        Duration = Options.Duration or 5,
        OnClose = Options.OnClose or nil
    }
    
	local Notification = templates.Notification:Clone()
	Notification.Visible = true
	Notification.Parent = container
	Notification.Position = UDim2.new(1, -10, 1, -90 - notificationOffset)
    
	Notification.Title.Text = Options.Title
	Notification.Message.Text = Options.Message
    
	notificationOffset = notificationOffset + notificationHeight + 10
    
	ts:Create(Notification.Duration.Time, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		Size = Notification.Duration.Size
	}):Play()
    
	local isFirstNotification = false
    
	Notification.Return.ReturnButton.MouseButton1Click:Connect(function() 
		--[[
			Allow the functionality to maunally tween out and remove the notification,
			in the process of this move down the notifications above this notification, not the ones below it.
		--]]
        
		local tweenOut = ts:Create(Notification, TweenInfo.new(.3), {
			Position = Notification.Position + UDim2.new(0, 400, 0, 0)
		})
        
		tweenOut:Play()
        
		for _, notification in pairs(container:GetChildren()) do 
			if not (notification:IsA("Frame")) then
				continue
			end
            
			if (notification.Position.Y.Offset > Notification.Position.Y.Offset) then
				continue
			end
            
			local tweenIn = ts:Create(notification, TweenInfo.new(.3), {
				Position = notification.Position - UDim2.new(0, 0, 0, -notificationHeight - 10)
			})
            
			tweenIn:Play()
            
			task.wait(.3)
		end

        if (Options.OnClose) then
            local s, r = pcall(Options.OnClose)
            assert(s, r)
        end
	end)

    Notification.Return.MouseEnter:Connect(function()
        ts:Create(Notification.Return, TweenInfo.new(duration), {
            BackgroundTransparency = 0
        }):Play()
    end)

    Notification.Return.MouseLeave:Connect(function()
        ts:Create(Notification.Return, TweenInfo.new(duration), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
	ts:Create(Notification.Duration.Time, TweenInfo.new(duration), {
        Size = Notification.Duration.Size
	}):Play()
    
	Notification:GetPropertyChangedSignal("Parent"):Connect(function() 
		if not (Notification.Parent) then
			notificationCount -= 1
		end
	end)
    
	task.spawn(function()
		task.wait(Options.Duration)
        
		local tweenOut = ts:Create(Notification, TweenInfo.new(.3), {
			Position = Notification.Position + UDim2.new(0, 400, 0, 0)
		})
        
		--[[
			Create a stackable notification system, if this is the first notification, don't set it's new position,
			leave it as it is, else tween each position to their new position when a notification is finished or
			removed.
		--]]
        
		if isFirstNotification then
			isFirstNotification = false
		else 
			tweenOut:Play()
            
			task.wait(.3)
            
			for _, notification in pairs(container:GetChildren()) do 
				if not (notification:IsA("Frame")) then
					continue
				end
                
				local tweenIn = ts:Create(notification, TweenInfo.new(.3), {
					Position = notification.Position - UDim2.new(0, 0, 0, -notificationHeight - 10)
				})
                
				tweenIn:Play()
			end
            
			return
		end
        
		local tweenIn = ts:Create(Notification, TweenInfo.new(.3), {
			Size = Notification.Size + UDim2.new(0, 400, 0, 0)
		}):Play()
                
		tweenOut.Completed:Connect(function()
			Notification:Destroy()
		end)
        
		tweenOut:Play()
	end)
end

return Notification
