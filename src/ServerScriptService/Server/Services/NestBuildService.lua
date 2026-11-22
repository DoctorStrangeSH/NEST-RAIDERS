local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local NestBuildCatalog = require(ReplicatedStorage.Shared.Config.NestBuildCatalog)

local NestBuildService = {}
NestBuildService._lastRequest = {}
local REQUEST_COOLDOWN = 0.3
local MAX_BUILDINGS = 100
local MAX_PER_TYPE = 50
local GRID = 2
local LIMIT = 14

local function ensureNest(profile)
    profile.Nest = profile.Nest or { Level = 1 }
    profile.Nest.BuildInventory = type(profile.Nest.BuildInventory) == "table" and profile.Nest.BuildInventory or {}
    profile.Nest.PlacedBuildings = type(profile.Nest.PlacedBuildings) == "table" and profile.Nest.PlacedBuildings or {}
    return profile.Nest
end

local function snap(value)
    return math.clamp(math.floor(value / GRID + 0.5) * GRID, -LIMIT, LIMIT)
end

local function getSnapshot(profile)
    local nest = ensureNest(profile)
    local inventory, placed = {}, {}
    for id, count in pairs(nest.BuildInventory) do
        local def = NestBuildCatalog[id]
        count = math.max(0, math.floor(tonumber(count) or 0))
        if def and count > 0 then
            table.insert(inventory, { Id = id, Name = def.Name, Count = count })
        end
    end
    table.sort(inventory, function(a,b) return a.Name < b.Name end)
    for key, item in pairs(nest.PlacedBuildings) do
        local def = type(item) == "table" and NestBuildCatalog[item.Id] or nil
        if def then
            table.insert(placed, {
                Key = tostring(key), Id = item.Id, Name = def.Name,
                X = item.X, Z = item.Z, Rotation = item.Rotation or 0, Footprint = def.Footprint,
            })
        end
    end
    table.sort(placed, function(a,b) return a.Key < b.Key end)
    local catalog = {}
    for id, def in pairs(NestBuildCatalog) do
        table.insert(catalog, { Id=id, Name=def.Name, Description=def.Description, Cost=def.Cost, Footprint=def.Footprint })
    end
    table.sort(catalog, function(a,b) return a.Cost < b.Cost end)
    return { Coins=math.max(0, math.floor(tonumber(profile.Coins) or 0)), Inventory=inventory, Placed=placed, Catalog=catalog, Limit=LIMIT }
end

local function makePart(parent, name, size, cf, color, material, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cf
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    if shape then part.Shape = shape end
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function renderBuilding(parent, center, item, key)
    local def = NestBuildCatalog[item.Id]
    if not def then return end
    local model = Instance.new("Model")
    model.Name = "Build_" .. item.Id .. "_" .. tostring(key)
    model:SetAttribute("BuildId", item.Id)
    model:SetAttribute("BuildKey", tostring(key))
    model.Parent = parent
    local base = CFrame.new(center + Vector3.new(item.X, 1.75, item.Z)) * CFrame.Angles(0, math.rad(item.Rotation or 0), 0)
    local function p(name,size,offset,color,material,shape)
        return makePart(model,name,size,base*CFrame.new(offset),color,material,shape)
    end
    if def.Kind == "Path" then
        p("Stone",Vector3.new(1.9,0.18,1.9),Vector3.new(0,0,0),def.Color,Enum.Material.Slate)
        p("Inset",Vector3.new(0.12,0.04,1.55),Vector3.new(0,0.11,0),def.Accent,Enum.Material.Slate)
    elseif def.Kind == "Bush" then
        p("LeafA",Vector3.new(1.5,1.5,1.5),Vector3.new(0,0.65,0),def.Color,nil,Enum.PartType.Ball)
        p("LeafB",Vector3.new(0.95,1.0,0.95),Vector3.new(-0.45,1.05,0.1),def.Accent,nil,Enum.PartType.Ball)
        p("LeafC",Vector3.new(0.95,1.0,0.95),Vector3.new(0.45,1.05,-0.1),def.Color,nil,Enum.PartType.Ball)
    elseif def.Kind == "Tree" then
        p("Trunk",Vector3.new(0.7,3.0,0.7),Vector3.new(0,1.5,0),def.Accent,Enum.Material.Wood,Enum.PartType.Cylinder)
        p("Canopy",Vector3.new(3.3,3.0,3.3),Vector3.new(0,3.4,0),def.Color,nil,Enum.PartType.Ball)
        for i,off in ipairs({Vector3.new(-0.8,3.5,0.5),Vector3.new(0.9,3.2,-0.4),Vector3.new(0,4.0,0.2)}) do
            p("Apple"..i,Vector3.new(0.38,0.38,0.38),off,Color3.fromRGB(220,83,77),Enum.Material.Neon,Enum.PartType.Ball)
        end
    elseif def.Kind == "Fence" then
        p("RailTop",Vector3.new(2,0.18,0.18),Vector3.new(0,1.35,0),def.Accent,Enum.Material.Wood)
        p("RailBottom",Vector3.new(2,0.18,0.18),Vector3.new(0,0.55,0),def.Accent,Enum.Material.Wood)
        for _,x in ipairs({-0.85,0,0.85}) do
            p("Picket",Vector3.new(0.18,1.6,0.18),Vector3.new(x,0.95,0),def.Color,Enum.Material.Wood)
        end
    elseif def.Kind == "Cottage" then
        p("Walls",Vector3.new(5.5,3.4,5),Vector3.new(0,1.7,0),def.Color,Enum.Material.WoodPlanks)
        p("Roof",Vector3.new(6.2,1.1,5.8),Vector3.new(0,3.95,0),def.Accent,Enum.Material.Slate)
        p("Door",Vector3.new(1.1,2.2,0.12),Vector3.new(0,1.1,-2.56),Color3.fromRGB(103,72,57),Enum.Material.Wood)
        p("WindowL",Vector3.new(0.9,0.85,0.12),Vector3.new(-1.65,2.1,-2.56),Color3.fromRGB(137,211,229),Enum.Material.Glass)
        p("WindowR",Vector3.new(0.9,0.85,0.12),Vector3.new(1.65,2.1,-2.56),Color3.fromRGB(137,211,229),Enum.Material.Glass)
    end
end

function NestBuildService:RefreshPlayer(player)
    local profile = PlayerDataService:GetProfile(player)
    local plot = PlotService:GetPlayerPlot(player)
    if not profile or not plot or not plot.Model or not plot.Model.Parent then return end
    local nest = ensureNest(profile)
    local old = plot.Model:FindFirstChild("PlayerBuildings")
    if old then old:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "PlayerBuildings"
    folder.Parent = plot.Model
    for key,item in pairs(nest.PlacedBuildings) do
        if type(item) == "table" and NestBuildCatalog[item.Id] then
            renderBuilding(folder,plot.Center,item,key)
        end
    end
end

function NestBuildService:HandleRequest(player,payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then return {Ok=false,Message="Некорректный запрос."} end
    local now=os.clock()
    if now-(self._lastRequest[player] or 0)<REQUEST_COOLDOWN then return {Ok=false,Message="Подожди немного."} end
    self._lastRequest[player]=now
    local profile=PlayerDataService:GetProfile(player)
    local plot=PlotService:GetPlayerPlot(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then return {Ok=false,Message="Профиль ещё загружается."} end
    if not plot then return {Ok=false,Message="Личное гнездо ещё не назначено."} end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position-plot.Center).Magnitude>65 then return {Ok=false,Message="Подойди к своему острову."} end
    local nest=ensureNest(profile)
    if payload.Action=="Get" then self:RefreshPlayer(player); return {Ok=true,Data=getSnapshot(profile)} end
    if payload.Action=="Buy" then
        local id=payload.BuildId
        local def=type(id)=="string" and NestBuildCatalog[id] or nil
        if not def then return {Ok=false,Message="Такого объекта нет в каталоге."} end
        local count=math.max(0,math.floor(tonumber(nest.BuildInventory[id]) or 0))
        local placed=0
        for _,entry in pairs(nest.PlacedBuildings) do if type(entry)=="table" and entry.Id==id then placed+=1 end end
        if count+placed>=MAX_PER_TYPE then return {Ok=false,Message="Достигнут лимит этого объекта."} end
        if (tonumber(profile.Coins) or 0)<def.Cost then return {Ok=false,Message="Не хватает монет. Нужно "..def.Cost.."."} end
        profile.Coins-=def.Cost
        nest.BuildInventory[id]=count+1
        player:SetAttribute("Coins",profile.Coins)
        return {Ok=true,Data=getSnapshot(profile),Message="Куплено: "..def.Name}
    end
    if payload.Action=="Place" then
        local id=payload.BuildId
        local def=type(id)=="string" and NestBuildCatalog[id] or nil
        if not def then return {Ok=false,Message="Выбери объект из каталога."} end
        local count=math.max(0,math.floor(tonumber(nest.BuildInventory[id]) or 0))
        if count<1 then return {Ok=false,Message="Сначала купи этот объект."} end
        local buildingCount = 0
        for _ in pairs(nest.PlacedBuildings) do buildingCount += 1 end
        if buildingCount >= MAX_BUILDINGS then return {Ok=false,Message="На острове уже достаточно построек."} end
        local x,z=tonumber(payload.X),tonumber(payload.Z)
        local rotation=tonumber(payload.Rotation) or 0
        if not x or not z or x~=x or z~=z or math.abs(x)==math.huge or math.abs(z)==math.huge
            or math.abs(x)>LIMIT or math.abs(z)>LIMIT or rotation~=rotation or math.abs(rotation)>36000 then
            return {Ok=false,Message="Некорректное место размещения."}
        end
        x,z=snap(x),snap(z)
        local footprint=def.Footprint
        if math.abs(x) + footprint / 2 > 15 or math.abs(z) + footprint / 2 > 15 then
            return {Ok=false,Message="Эта постройка не помещается в границах острова."}
        end
        for _,entry in pairs(nest.PlacedBuildings) do
            local other=NestBuildCatalog[entry.Id]
            if other then
                local minGap=(footprint+other.Footprint)/2
                if math.abs(x-entry.X)<minGap and math.abs(z-entry.Z)<minGap then
                    return {Ok=false,Message="Здесь уже есть постройка. Выбери другое место."}
                end
            end
        end
        local key=tostring((nest.NextBuildingId or 0)+1)
        nest.NextBuildingId=(nest.NextBuildingId or 0)+1
        nest.BuildInventory[id]=count-1
        nest.PlacedBuildings[key]={Id=id,X=x,Z=z,Rotation=(math.floor(rotation/15+0.5)*15)%360}
        self:RefreshPlayer(player)
        return {Ok=true,Data=getSnapshot(profile),Message="Размещено: "..def.Name}
    elseif payload.Action=="Move" then
        local key=tostring(payload.Key or "")
        local entry=nest.PlacedBuildings[key]
        if type(entry)~="table" or not NestBuildCatalog[entry.Id] then return {Ok=false,Message="Постройка не найдена."} end
        local x,z=tonumber(payload.X),tonumber(payload.Z)
        local rotation=tonumber(payload.Rotation)
        if not x or not z or not rotation or x~=x or z~=z or math.abs(x)==math.huge or math.abs(z)==math.huge
            or math.abs(x)>LIMIT or math.abs(z)>LIMIT or rotation~=rotation or math.abs(rotation)>36000 then
            return {Ok=false,Message="Некорректное положение."}
        end
        x,z=snap(x),snap(z)
        local def=NestBuildCatalog[entry.Id]
        if math.abs(x) + def.Footprint / 2 > 15 or math.abs(z) + def.Footprint / 2 > 15 then
            return {Ok=false,Message="Эта постройка не помещается в границах острова."}
        end
        for otherKey,otherEntry in pairs(nest.PlacedBuildings) do
            if otherKey~=key then
                local other=NestBuildCatalog[otherEntry.Id]
                if other then
                    local gap=(def.Footprint+other.Footprint)/2
                    if math.abs(x-otherEntry.X)<gap and math.abs(z-otherEntry.Z)<gap then
                        return {Ok=false,Message="Это место занято другой постройкой."}
                    end
                end
            end
        end
        entry.X=x; entry.Z=z; entry.Rotation=(math.floor(rotation/15+0.5)*15)%360
        self:RefreshPlayer(player)
        return {Ok=true,Data=getSnapshot(profile),Message="Положение постройки обновлено."}
    elseif payload.Action=="Remove" then
        local key=tostring(payload.Key or "")
        local entry=nest.PlacedBuildings[key]
        if type(entry)~="table" or not NestBuildCatalog[entry.Id] then return {Ok=false,Message="Постройка не найдена."} end
        nest.BuildInventory[entry.Id]=(tonumber(nest.BuildInventory[entry.Id]) or 0)+1
        nest.PlacedBuildings[key]=nil
        self:RefreshPlayer(player)
        return {Ok=true,Data=getSnapshot(profile),Message="Постройка возвращена в инвентарь."}
    end
    return {Ok=false,Message="Неизвестное действие."}
end

function NestBuildService:Init()
    local remotes=ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then remotes=Instance.new("Folder"); remotes.Name="NestRaidersRemotes"; remotes.Parent=ReplicatedStorage end
    local remote=remotes:FindFirstChild("NestBuild")
    if not remote then remote=Instance.new("RemoteFunction"); remote.Name="NestBuild"; remote.Parent=remotes end
    remote.OnServerInvoke=function(player,payload) return self:HandleRequest(player,payload) end
    local function bind(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then task.defer(function() self:RefreshPlayer(player) end) end
        end)
        if player:GetAttribute("ProfileLoaded") then task.defer(function() self:RefreshPlayer(player) end) end
    end
    Players.PlayerAdded:Connect(bind)
    Players.PlayerRemoving:Connect(function(player) self._lastRequest[player]=nil end)
    for _,player in ipairs(Players:GetPlayers()) do bind(player) end
end

return NestBuildService
