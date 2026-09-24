--[[
                          Neverlose.cc UI Library
    Author: 4lpaca
	License: MIT
    Discord: https://arceney.win/discord
    Other-Projects: https://4lpaca.win
]]

do
	local Constant = 'L'..'P'..'H'..'_NO_VIRTUALIZE';
	getfenv()[Constant] = getfenv()[Constant] or function(f) return f end;
end;

cloneref = cloneref or function(i) return i end;
gethui = gethui or get_hidden_gui;
getcustomasset = getcustomasset or getsynasset;
getgenv = getgenv or getfenv;

local LOAD_ENV = LPH_NO_VIRTUALIZE(function()
	if game:GetService('RunService'):IsStudio() then
		local BaseWorkspace = game:GetService("ReplicatedFirst"):FindFirstChild('PRI_WORKSPACE') or Instance.new('Folder',game:GetService("ReplicatedFirst"));

		BaseWorkspace.Name = 'PRI\0.'..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)));

		local __get_path_c = function(path)
			return (string.find(path,'/',1,true) and string.split(path,'/')) or (string.find(path,'\\',1,true) and string.split(path,'\\')) or {path};
		end;

		local __get_path = function(path)
			local main = __get_path_c(path);

			local block = BaseWorkspace;

			for i,v in next , main do
				block = block[v];
			end;

			return block;
		end;

		getgenv().readfile = function(path)
			local path : StringValue = __get_path(path);

			return path.Value;
		end;

		getgenv().isfile = function(path)
			local success , message = pcall(function()
				return __get_path(path);
			end);

			if success and not message:IsA("Folder") then
				return true;
			end;

			return false;
		end;

		getgenv().isfolder = function(path)
			local success , message = pcall(function()
				return __get_path(path);
			end);

			if success and message:IsA("Folder") then
				return true;
			end;

			return false;
		end;

		getgenv().writefile = function(path,content)
			local main = __get_path_c(path);

			local block = BaseWorkspace;

			for i,v in next , main do
				local item = block:FindFirstChild(v);
				if not item then
					local c = Instance.new('StringValue',block);

					c.Name = tostring(v);
					c.Value = content;
				else
					if item:IsA('StringValue') and tostring(item) == v then
						item.Name = tostring(v);
						item.Value = content;
					end;

					block = item;
				end;
			end;
		end;

		getgenv().listfiles = function(path)
			local fold = __get_path(path);
			local pa = {};

			for i,v in next , fold:GetChildren() do
				if v:IsA('StringValue') then
					table.insert(pa,path..'/'..tostring(v));
				end;
			end;

			return pa;
		end;

		getgenv().makefolder = function(path)
			local main = __get_path_c(path);

			local block = BaseWorkspace;

			for i,v in next , main do
				local item = block:FindFirstChild(v);
				if not item then
					local c = Instance.new('Folder',block);

					c.Name = tostring(v);
				else
					block = item;
				end;
			end;
		end;

		getgenv().delfile = function(path)
			local main = __get_path_c(path);

			local block = BaseWorkspace;

			for i,v in next , main do
				local item = block:FindFirstChild(v);
				if item and item:IsA('StringValue') then
					item:Destroy();
				else
					block = item;
				end;
			end;
		end;
	end;
end)

LOAD_ENV();

writefile = writefile or getgenv().writefile;
makefolder = makefolder or getgenv().makefolder;
readfile = readfile or getgenv().readfile;
delfolder = delfolder or getgenv().delfolder;
delfile = delfile or getgenv().delfile;
listfiles = listfiles or getgenv().listfiles;
isfolder = isfolder or getgenv().isfolder;
isfile = isfile or getgenv().isfile;

local NeverLose = {};

NeverLose.BuiltInRegular = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json',Enum.FontWeight.Regular,Enum.FontStyle.Normal);
NeverLose.BuiltInBold = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json',Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NeverLose.GlobalSignals = {};
NeverLose.UnloadEnabled = true;

NeverLose.AccentListeners = {};
NeverLose.ActiveToggleCallbacks = {};

function NeverLose:RegisterAccent(instance, propertyName)
	propertyName = propertyName or "BackgroundColor3";
	table.insert(NeverLose.AccentListeners, {Instance = instance, Property = propertyName});
	if instance and instance.Parent then
		pcall(function()
			instance[propertyName] = NeverLose.AccentColor;
		end);
	end;
	return instance;
end;

function NeverLose:RegisterToggleAccent(callback)
	table.insert(NeverLose.ActiveToggleCallbacks, callback);
end;

function NeverLose:SetAccentColor(newColor)
	if typeof(newColor) == "Color3" then
		NeverLose.AccentColor = newColor;
		for i = #NeverLose.AccentListeners, 1, -1 do
			local entry = NeverLose.AccentListeners[i];
			if entry.Instance and entry.Instance.Parent then
				pcall(function()
					entry.Instance[entry.Property] = newColor;
				end);
			else
				table.remove(NeverLose.AccentListeners, i);
			end;
		end;
		for i = #NeverLose.ActiveToggleCallbacks, 1, -1 do
			local cb = NeverLose.ActiveToggleCallbacks[i];
			local ok = pcall(cb, newColor);
			if not ok then
				table.remove(NeverLose.ActiveToggleCallbacks, i);
			end;
		end;
		if NeverLose.UpdateHotkeysHUD then
			pcall(function() NeverLose:UpdateHotkeysHUD() end);
		end;
	end;
end;

NeverLose.CurrentFont = Enum.Font.GothamMedium;

function NeverLose:SetFont(fontEnum)
	if typeof(fontEnum) == "EnumItem" then
		NeverLose.CurrentFont = fontEnum;
		if NeverLose.ScreenGui then
			for _, d in ipairs(NeverLose.ScreenGui:GetDescendants()) do
				if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) then
					if d.FontFace ~= NeverLose.BuiltInBold and d.Font ~= Enum.Font.Code then
						pcall(function()
							d.Font = fontEnum;
						end);
					end;
				end;
			end;
		end;
	end;
end;

local cloneref: cloneref = cloneref or function(f) return f end;
local TweenService: TweenService = cloneref(game:GetService('TweenService'));
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'));
local TextService: TextService = cloneref(game:GetService('TextService'));
local RunService: RunService = cloneref(game:GetService('RunService'));
local Players: Players = cloneref(game:GetService('Players'));
local HttpService: HttpService = cloneref(game:GetService('HttpService'));
local LocalPlayer: Player = Players.LocalPlayer;
local CoreGui: PlayerGui = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or cloneref(game:FindFirstChild('CoreGui')) or cloneref(LocalPlayer.PlayerGui);
local Mouse: Mouse = LocalPlayer:GetMouse();
local CurrentCamera: Camera = cloneref(workspace.CurrentCamera);
local ProtectGui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s; end;
local GlobalWindow = Instance.new('ScreenGui');
local ManualTween = TweenInfo.new(0.1);
local SlowyTween = TweenInfo.new(0.175);
local FastTween = TweenInfo.new(0.05);
local VSlowTween = TweenInfo.new(0.5,Enum.EasingStyle.Quint);
local Encryption = {};

NeverLose.UserProfile = Players:GetUserThumbnailAsync(LocalPlayer.UserId , Enum.ThumbnailType.HeadShot , Enum.ThumbnailSize.Size150x150)
NeverLose.RandomString = LPH_NO_VIRTUALIZE(function()
	return string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4));
end);

ProtectGui(GlobalWindow);

GlobalWindow.Name = "NeverLose_ScreenGui";
GlobalWindow.IgnoreGuiInset = true;
GlobalWindow.ZIndexBehavior = Enum.ZIndexBehavior.Global;
GlobalWindow.ResetOnSpawn = false;
GlobalWindow.Parent = CoreGui;

NeverLose.Scales = {
	Small = UDim2.fromOffset(540,380),
	Mobile = UDim2.fromOffset(640,385),
	Default = UDim2.fromOffset(640 , 480),
	Large = UDim2.fromOffset(800 , 600)
};

NeverLose.IconColor = Color3.fromRGB(255, 255, 255);
NeverLose.ScreenGui = GlobalWindow;
NeverLose.Flags = {};
NeverLose.AccentColor = Color3.fromRGB(78, 127, 252);
NeverLose.MainColor = Color3.fromRGB(8, 8, 13);
NeverLose.RegisiteryColor = {};
NeverLose.NameRegisitry = {};
NeverLose.IsMosueOverOtherFrame = false;
NeverLose.GlobalLogo = "rbxassetid://120358385035996";
NeverLose.ImageColorMapping = "rbxassetid://4155801252";

if getcustomasset then
	local link = "https://github.com/4lpaca-pin/NeverLose/blob/main/assets/%s?raw=true";
	local dir = 'NLAssets';

	if not isfolder(dir) then
		makefolder(dir);
	end;

	pcall(function()
		if not isfile(dir..'/'..'logo.png') then
			local byte = game:HttpGet(string.format(link,'logo.png'));

			writefile(dir..'/'..'logo.png' , byte);
			task.wait();
		end;

		if isfile(dir..'/'..'logo.png') then
			NeverLose.GlobalLogo = getcustomasset(dir..'/'..'logo.png')
		end;
	end);

	pcall(function()
		if not isfile(dir..'/'..'saturation_value_gradient.png') then
			local byte = game:HttpGet(string.format(link,'saturation_value_gradient.png'));

			writefile(dir..'/'..'saturation_value_gradient.png' , byte);
			task.wait();
		end;

		if isfile(dir..'/'..'saturation_value_gradient.png') then
			NeverLose.ImageColorMapping = getcustomasset(dir..'/'..'saturation_value_gradient.png')
		end;
	end);
end;

function NeverLose:AddSignal(RBXSignal)
	if NeverLose.UnloadEnabled then
		table.insert(NeverLose.GlobalSignals,RBXSignal);
	end;

	return RBXSignal;
end;

function NeverLose:AddQuery(ItemRoot: Frame , Name : string, TabInfo: table)
	local tabName = (TabInfo and TabInfo.TabName) or "GENERAL";
	local secName = (TabInfo and TabInfo.SectionName) or "SETTINGS";
	local breadcrumb = string.upper(tabName) .. " > " .. string.upper(secName);

	table.insert(NeverLose.NameRegisitry , {
		Root = ItemRoot,
		Idx = Name,
		Tab = TabInfo and TabInfo.Tab,
		TabName = tabName,
		SectionName = secName,
		Path = breadcrumb,
		OriginalParent = ItemRoot.Parent,
		OriginalLayoutOrder = ItemRoot.LayoutOrder,
	});
end;

function Encryption.new(data: string)
	local bytes = {};
	local encrypt_seed = ((#data + 3782) % 111) + 1;

	string.gsub(data , '.', LPH_NO_VIRTUALIZE(function(dt)
		table.insert(bytes , tostring(dt:byte() + encrypt_seed));
	end));

	local concatbyte = table.concat(bytes,'?');

	table.clear(bytes);

	return "{"..tostring(encrypt_seed + 72667).."}?"..concatbyte;
end;

function Encryption.reverse(data: string)
	local main_data = string.split(data,'?');
	local seed_str = main_data[1]:gsub('{',''):gsub('}','');
	local seed = tonumber(seed_str);

	local ks = {};
	local real_seed = seed - 72667;

	for i,v in next , main_data do
		if i > 1 then
			local fake_byte = tonumber(v);
			table.insert(ks , string.char(fake_byte - real_seed))	
		end;
	end;

	local data = table.concat(ks);

	table.clear(ks);

	return data;
end;

do
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

	NeverLose.Base64Encode = LPH_NO_VIRTUALIZE(function(data)
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end);

	NeverLose.Base64Decode = LPH_NO_VIRTUALIZE(function(data)
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end);
end;

NeverLose.LoadIcon = LPH_NO_VIRTUALIZE(function()
	NeverLose.RobloxIcon = {
		["3d-cube-arrow-left"] = "3d-cube-arrow-left",
		["amazon"] = "amazon",
		["arm-left"] = "arm-left",
		["arm-right"] = "arm-right",
		["arrow-curl-to-left"] = "arrow-curl-to-left",
		["arrow-curl-to-right"] = "arrow-curl-to-right",
		["arrow-down-to-line"] = "arrow-down-to-line",
		["arrow-large-down"] = "arrow-large-down",
		["arrow-large-left"] = "arrow-large-left",
		["arrow-large-right"] = "arrow-large-right",
		["arrow-large-up"] = "arrow-large-up",
		["arrow-right-from-portrait-rectangle"] = "arrow-right-from-portrait-rectangle",
		["arrow-right-to-portrait-rectangle"] = "arrow-right-to-portrait-rectangle",
		["arrow-rotate-down-dashed"] = "arrow-rotate-down-dashed",
		["arrow-rotate-right"] = "arrow-rotate-right",
		["arrow-rotate-right-dashed"] = "arrow-rotate-right-dashed",
		["arrow-small-down"] = "arrow-small-down",
		["arrow-small-left"] = "arrow-small-left",
		["arrow-small-right"] = "arrow-small-right",
		["arrow-small-up"] = "arrow-small-up",
		["arrow-spin-clockwise"] = "arrow-spin-clockwise",
		["arrow-spin-clockwise-10"] = "arrow-spin-clockwise-10",
		["arrow-spin-clockwise-15"] = "arrow-spin-clockwise-15",
		["arrow-spin-clockwise-30"] = "arrow-spin-clockwise-30",
		["arrow-spin-counter-clockwise-10"] = "arrow-spin-counter-clockwise-10",
		["arrow-spin-counter-clockwise-15"] = "arrow-spin-counter-clockwise-15",
		["arrow-spin-counter-clockwise-30"] = "arrow-spin-counter-clockwise-30",
		["arrow-thick-to-left"] = "arrow-thick-to-left",
		["arrow-thick-to-right"] = "arrow-thick-to-right",
		["arrow-up-from-landscape-rectangle"] = "arrow-up-from-landscape-rectangle",
		["arrow-up-right-from-square"] = "arrow-up-right-from-square",
		["arrow-wide-short-down"] = "arrow-wide-short-down",
		["arrow-wide-short-left"] = "arrow-wide-short-left",
		["arrow-wide-short-right"] = "arrow-wide-short-right",
		["arrow-wide-short-up"] = "arrow-wide-short-up",
		["arrows-small-directional"] = "arrows-small-directional",
		["audio-wave-dotted-line"] = "audio-wave-dotted-line",
		["backpack"] = "backpack",
		["beard"] = "beard",
		["bell"] = "bell",
		["bell-clock"] = "bell-clock",
		["bell-plus"] = "bell-plus",
		["bell-slash"] = "bell-slash",
		["belt"] = "belt",
		["binoculars"] = "binoculars",
		["book-closed"] = "book-closed",
		["bookmark"] = "bookmark",
		["bow-tie"] = "bow-tie",
		["building-store"] = "building-store",
		["bullet-flying"] = "bullet-flying",
		["butterfly-wings"] = "butterfly-wings",
		["calendar"] = "calendar",
		["calendar-plus"] = "calendar-plus",
		["calendar-star"] = "calendar-star",
		["camera-small"] = "camera-small",
		["caret-small-down"] = "caret-small-down",
		["caret-small-left"] = "caret-small-left",
		["caret-small-right"] = "caret-small-right",
		["caret-small-up"] = "caret-small-up",
		["chain-link"] = "chain-link",
		["chart-four-vertical-bars"] = "chart-four-vertical-bars",
		["chart-line"] = "chart-line",
		["chart-pie"] = "chart-pie",
		["chart-scatter-plot"] = "chart-scatter-plot",
		["chart-three-vertical-bars"] = "chart-three-vertical-bars",
		["check"] = "check",
		["check-large"] = "check-large",
		["check-small"] = "check-small",
		["chevron-large-down"] = "chevron-large-down",
		["chevron-large-down-to-line"] = "chevron-large-down-to-line",
		["chevron-large-left"] = "chevron-large-left",
		["chevron-large-left-to-line"] = "chevron-large-left-to-line",
		["chevron-large-right"] = "chevron-large-right",
		["chevron-large-right-to-line"] = "chevron-large-right-to-line",
		["chevron-large-up"] = "chevron-large-up",
		["chevron-large-up-to-line"] = "chevron-large-up-to-line",
		["chevron-small-down"] = "chevron-small-down",
		["chevron-small-down-to-line"] = "chevron-small-down-to-line",
		["chevron-small-left"] = "chevron-small-left",
		["chevron-small-left-to-line"] = "chevron-small-left-to-line",
		["chevron-small-right"] = "chevron-small-right",
		["chevron-small-right-to-line"] = "chevron-small-right-to-line",
		["chevron-small-up"] = "chevron-small-up",
		["chevron-small-up-to-line"] = "chevron-small-up-to-line",
		["circle-check"] = "circle-check",
		["circle-i"] = "circle-i",
		["circle-minus"] = "circle-minus",
		["circle-person"] = "circle-person",
		["circle-person-three-horizontal-bars-wrapping-right"] = "circle-person-three-horizontal-bars-wrapping-right",
		["circle-play"] = "circle-play",
		["circle-plus"] = "circle-plus",
		["circle-question"] = "circle-question",
		["circle-slash"] = "circle-slash",
		["circle-star"] = "circle-star",
		["circle-three-dots-horizontal"] = "circle-three-dots-horizontal",
		["circle-three-dots-vertical"] = "circle-three-dots-vertical",
		["circle-x"] = "circle-x",
		["clock"] = "clock",
		["clock-dashed"] = "clock-dashed",
		["clock-spin-reverse"] = "clock-spin-reverse",
		["clock-spin-reverse-dashed"] = "clock-spin-reverse-dashed",
		["clothes-hanger"] = "clothes-hanger",
		["cloud"] = "cloud",
		["cloud-arrow-down"] = "cloud-arrow-down",
		["code"] = "code",
		["compact-makeup-brush"] = "compact-makeup-brush",
		["compass"] = "compass",
		["controller-with-cog"] = "controller-with-cog",
		["crop"] = "crop",
		["crosshairs"] = "crosshairs",
		["crosshairs-slash"] = "crosshairs-slash",
		["cube-vertexes"] = "cube-vertexes",
		["curved-rectangle-megaphone"] = "curved-rectangle-megaphone",
		["diagonal-line-pattern"] = "diagonal-line-pattern",
		["diagonal-line-pattern-sticker"] = "diagonal-line-pattern-sticker",
		["diamond-simplified"] = "diamond-simplified",
		["discord"] = "discord",
		["disguise-nose-glasses"] = "disguise-nose-glasses",
		["document-circle-slash"] = "document-circle-slash",
		["document-list-heart"] = "document-list-heart",
		["door-open-arrow-to-bottom-right"] = "door-open-arrow-to-bottom-right",
		["dress"] = "dress",
		["dual-arrows-horizontal"] = "dual-arrows-horizontal",
		["dual-arrows-to-corners"] = "dual-arrows-to-corners",
		["dual-arrows-vertical"] = "dual-arrows-vertical",
		["envelope"] = "envelope",
		["eraser"] = "eraser",
		["eye"] = "eye",
		["eye-slash"] = "eye-slash",
		["eye-with-eyeliner"] = "eye-with-eyeliner",
		["eyebrows"] = "eyebrows",
		["eyelashes"] = "eyelashes",
		["face-winking"] = "face-winking",
		["facebook"] = "facebook",
		["file-box"] = "file-box",
		["fingerprint"] = "fingerprint",
		["flag"] = "flag",
		["flame"] = "flame",
		["folder"] = "folder",
		["fountain-pen-nib"] = "fountain-pen-nib",
		["four-bars-horizontal-center-aligned"] = "four-bars-horizontal-center-aligned",
		["four-bars-horizontal-chevron-left"] = "four-bars-horizontal-chevron-left",
		["four-bars-horizontal-chevron-right"] = "four-bars-horizontal-chevron-right",
		["four-bars-horizontal-justified-aligned"] = "four-bars-horizontal-justified-aligned",
		["four-bars-horizontal-left-aligned"] = "four-bars-horizontal-left-aligned",
		["four-bars-horizontal-right-aligned"] = "four-bars-horizontal-right-aligned",
		["frame-bubble-slash"] = "frame-bubble-slash",
		["frame-bubble-soundwave"] = "frame-bubble-soundwave",
		["frame-camera"] = "frame-camera",
		["frame-camera-center"] = "frame-camera-center",
		["frame-collapsed"] = "frame-collapsed",
		["frame-corners"] = "frame-corners",
		["frame-expanded"] = "frame-expanded",
		["frame-face"] = "frame-face",
		["frame-person-torso"] = "frame-person-torso",
		["frame-record"] = "frame-record",
		["frame-single-bar-horizontal"] = "frame-single-bar-horizontal",
		["frame-soundwave"] = "frame-soundwave",
		["frame-video-camera"] = "frame-video-camera",
		["gear"] = "gear",
		["generic-dpad"] = "generic-dpad",
		["gift-box"] = "gift-box",
		["gift-card"] = "gift-card",
		["glasses"] = "glasses",
		["globe-detailed"] = "globe-detailed",
		["globe-simplified"] = "globe-simplified",
		["globe-simplipfied-speech-bubble"] = "globe-simplipfied-speech-bubble",
		["grid"] = "grid",
		["guilded"] = "guilded",
		["hack-week"] = "hack-week",
		["hammer-code"] = "hammer-code",
		["hand-curved-arrow-left"] = "hand-curved-arrow-left",
		["hand-dual-arrows"] = "hand-dual-arrows",
		["hand-ellipse"] = "hand-ellipse",
		["hand-half-ellipse"] = "hand-half-ellipse",
		["hand-two-arrows-horizontal"] = "hand-two-arrows-horizontal",
		["hashtag"] = "hashtag",
		["hat-fedora"] = "hat-fedora",
		["hat-toque"] = "hat-toque",
		["head-blank"] = "head-blank",
		["head-blush"] = "head-blush",
		["head-female"] = "head-female",
		["head-freckles"] = "head-freckles",
		["head-lips"] = "head-lips",
		["head-male"] = "head-male",
		["headphones"] = "headphones",
		["headphones-arrow-up"] = "headphones-arrow-up",
		["headphones-arrow-up-lock"] = "headphones-arrow-up-lock",
		["headphones-slash"] = "headphones-slash",
		["headphones-x"] = "headphones-x",
		["headphones-x-lock"] = "headphones-x-lock",
		["heart"] = "heart",
		["house"] = "house",
		["image"] = "image",
		["image-stacked"] = "image-stacked",
		["instagram"] = "instagram",
		["jacket"] = "jacket",
		["key"] = "key",
		["key-alt"] = "key-alt",
		["key-apostrophe"] = "key-apostrophe",
		["key-arrow-down"] = "key-arrow-down",
		["key-arrow-right"] = "key-arrow-right",
		["key-arrow-up"] = "key-arrow-up",
		["key-asterisk"] = "key-asterisk",
		["key-backspace"] = "key-backspace",
		["key-caps-lock"] = "key-caps-lock",
		["key-caret"] = "key-caret",
		["key-comma"] = "key-comma",
		["key-command"] = "key-command",
		["key-control"] = "key-control",
		["key-grave-accent"] = "key-grave-accent",
		["key-period"] = "key-period",
		["key-return"] = "key-return",
		["key-shift"] = "key-shift",
		["key-space"] = "key-space",
		["key-tab"] = "key-tab",
		["language-characters"] = "language-characters",
		["leg-left"] = "leg-left",
		["leg-right"] = "leg-right",
		["lightning-bolt"] = "lightning-bolt",
		["linkedin"] = "linkedin",
		["lips"] = "lips",
		["lipstick"] = "lipstick",
		["list-bulleted"] = "list-bulleted",
		["location-pin"] = "location-pin",
		["location-pin-map"] = "location-pin-map",
		["lock-closed"] = "lock-closed",
		["lollipop"] = "lollipop",
		["magnifying-glass"] = "magnifying-glass",
		["magnifying-glass-minus"] = "magnifying-glass-minus",
		["magnifying-glass-plus"] = "magnifying-glass-plus",
		["mascara"] = "mascara",
		["megaphone"] = "megaphone",
		["memory-card"] = "memory-card",
		["messenger"] = "messenger",
		["microphone"] = "microphone",
		["microphone-slash"] = "microphone-slash",
		["microphone-text-box"] = "microphone-text-box",
		["microphone-triangle-exclamation"] = "microphone-triangle-exclamation",
		["minus"] = "minus",
		["minus-small"] = "minus-small",
		["mirror-standing"] = "mirror-standing",
		["moments"] = "moments",
		["moon"] = "moon",
		["mouse-button-left"] = "mouse-button-left",
		["mouse-button-right"] = "mouse-button-right",
		["mouse-scrollwheel"] = "mouse-scrollwheel",
		["music-note"] = "music-note",
		["nebula"] = "nebula",
		["necklace"] = "necklace",
		["nine-dots-grid"] = "nine-dots-grid",
		["ninja"] = "ninja",
		["nose"] = "nose",
		["page"] = "page",
		["paint-brush"] = "paint-brush",
		["paint-bucket"] = "paint-bucket",
		["pants"] = "pants",
		["pants-2d-text"] = "pants-2d-text",
		["paper-airplane"] = "paper-airplane",
		["parrot"] = "parrot",
		["pause-large"] = "pause-large",
		["pause-small"] = "pause-small",
		["pencil"] = "pencil",
		["pencil-square"] = "pencil-square",
		["person"] = "person",
		["person-arrow-from-bottom-right"] = "person-arrow-from-bottom-right",
		["person-check"] = "person-check",
		["person-circle-slash"] = "person-circle-slash",
		["person-climbing"] = "person-climbing",
		["person-clock"] = "person-clock",
		["person-falling"] = "person-falling",
		["person-graduate"] = "person-graduate",
		["person-jumping"] = "person-jumping",
		["person-magnifying-glass"] = "person-magnifying-glass",
		["person-photo-camera"] = "person-photo-camera",
		["person-play"] = "person-play",
		["person-play-clock"] = "person-play-clock",
		["person-plus"] = "person-plus",
		["person-racing"] = "person-racing",
		["person-running"] = "person-running",
		["person-standing"] = "person-standing",
		["person-standing-arrow-reverse"] = "person-standing-arrow-reverse",
		["person-standing-dual-arrows-vertical"] = "person-standing-dual-arrows-vertical",
		["person-standing-gear"] = "person-standing-gear",
		["person-swimming"] = "person-swimming",
		["person-teleport"] = "person-teleport",
		["person-trash-can"] = "person-trash-can",
		["person-walking"] = "person-walking",
		["person-with-smaller-person"] = "person-with-smaller-person",
		["phone"] = "phone",
		["phone-down"] = "phone-down",
		["phone-plus"] = "phone-plus",
		["phone-volume"] = "phone-volume",
		["phone-x"] = "phone-x",
		["photo-camera"] = "photo-camera",
		["photo-camera-face"] = "photo-camera-face",
		["photo-camera-slash"] = "photo-camera-slash",
		["picture-in-picture"] = "picture-in-picture",
		["pig"] = "pig",
		["pin"] = "pin",
		["pin-slash"] = "pin-slash",
		["play-large"] = "play-large",
		["play-small"] = "play-small",
		["plus-large"] = "plus-large",
		["plus-small"] = "plus-small",
		["premium"] = "premium",
		["ps-circle"] = "ps-circle",
		["ps-dpad-down"] = "ps-dpad-down",
		["ps-dpad-left"] = "ps-dpad-left",
		["ps-dpad-right"] = "ps-dpad-right",
		["ps-dpad-up"] = "ps-dpad-up",
		["ps-l1"] = "ps-l1",
		["ps-l2"] = "ps-l2",
		["ps-l3"] = "ps-l3",
		["ps-r1"] = "ps-r1",
		["ps-r2"] = "ps-r2",
		["ps-r3"] = "ps-r3",
		["ps-square"] = "ps-square",
		["ps-stick-left"] = "ps-stick-left",
		["ps-stick-right"] = "ps-stick-right",
		["ps-triagle"] = "ps-triagle",
		["ps-x"] = "ps-x",
		["ps4-options"] = "ps4-options",
		["ps4-share"] = "ps4-share",
		["ps4-touchpad"] = "ps4-touchpad",
		["ps5-options"] = "ps5-options",
		["ps5-share"] = "ps5-share",
		["ps5-touchpad"] = "ps5-touchpad",
		["pumpkin"] = "pumpkin",
		["purse"] = "purse",
		["rectangle-list"] = "rectangle-list",
		["rectangle-numbers-counting"] = "rectangle-numbers-counting",
		["rectangle-person-with-three-horizontal-lines"] = "rectangle-person-with-three-horizontal-lines",
		["robux"] = "robux",
		["rosette-seven-point"] = "rosette-seven-point",
		["rosette-ten-point"] = "rosette-ten-point",
		["seven-point-rosette"] = "seven-point-rosette",
		["shield-check"] = "shield-check",
		["shield-lock"] = "shield-lock",
		["shirt"] = "shirt",
		["shirt-2d-text"] = "shirt-2d-text",
		["shirt-pants"] = "shirt-pants",
		["shoe-left"] = "shoe-left",
		["shoe-right"] = "shoe-right",
		["shopping-basket"] = "shopping-basket",
		["shopping-basket-check"] = "shopping-basket-check",
		["shopping-cart"] = "shopping-cart",
		["shorts"] = "shorts",
		["sidebar"] = "sidebar",
		["signal-exclamation"] = "signal-exclamation",
		["six-dots-two-column-grid"] = "six-dots-two-column-grid",
		["skip-end-large"] = "skip-end-large",
		["skip-end-small"] = "skip-end-small",
		["skip-next-large"] = "skip-next-large",
		["skip-next-small"] = "skip-next-small",
		["skip-previous-large"] = "skip-previous-large",
		["skip-previous-small"] = "skip-previous-small",
		["skip-start-large"] = "skip-start-large",
		["skip-start-small"] = "skip-start-small",
		["smartphone-portrait"] = "smartphone-portrait",
		["speaker"] = "speaker",
		["speaker-slash"] = "speaker-slash",
		["speaker-triangle-exclamation"] = "speaker-triangle-exclamation",
		["speaker-x"] = "speaker-x",
		["speech-bubble-align-center"] = "speech-bubble-align-center",
		["speech-bubble-align-left"] = "speech-bubble-align-left",
		["speech-bubble-exclamation"] = "speech-bubble-exclamation",
		["speech-bubble-round"] = "speech-bubble-round",
		["square-bone"] = "square-bone",
		["square-books"] = "square-books",
		["square-check"] = "square-check",
		["square-code"] = "square-code",
		["square-dashed-person-standing"] = "square-dashed-person-standing",
		["square-dual-arrows-horizontal"] = "square-dual-arrows-horizontal",
		["square-dual-arrows-to-corner"] = "square-dual-arrows-to-corner",
		["square-face-sound"] = "square-face-sound",
		["square-face-waving-hand"] = "square-face-waving-hand",
		["square-face-winking"] = "square-face-winking",
		["square-minus"] = "square-minus",
		["square-person"] = "square-person",
		["squares-grid-plus"] = "squares-grid-plus",
		["squares-grid-qr"] = "squares-grid-qr",
		["stacked-squares-arrow-down-left"] = "stacked-squares-arrow-down-left",
		["stacked-squares-arrow-up-right"] = "stacked-squares-arrow-up-right",
		["stacked-squares-plus"] = "stacked-squares-plus",
		["star"] = "star",
		["stop-large"] = "stop-large",
		["stop-small"] = "stop-small",
		["studio"] = "studio",
		["sun"] = "sun",
		["sweater"] = "sweater",
		["sword"] = "sword",
		["tag-sparkle"] = "tag-sparkle",
		["teletype"] = "teletype",
		["tencent-qq"] = "tencent-qq",
		["text-b-bold"] = "text-b-bold",
		["text-box-microphone"] = "text-box-microphone",
		["text-h-subscript-1"] = "text-h-subscript-1",
		["text-h-subscript-2"] = "text-h-subscript-2",
		["text-h-subscript-3"] = "text-h-subscript-3",
		["text-i-italic"] = "text-i-italic",
		["text-s-strikethrough"] = "text-s-strikethrough",
		["text-u-underline"] = "text-u-underline",
		["text-uppercase-a-lowercase-a"] = "text-uppercase-a-lowercase-a",
		["text-x-subscript-2"] = "text-x-subscript-2",
		["text-x-superscript-2"] = "text-x-superscript-2",
		["three-bars-horizontal"] = "three-bars-horizontal",
		["three-bars-horizontal-chevron-left"] = "three-bars-horizontal-chevron-left",
		["three-bars-horizontal-narrowing"] = "three-bars-horizontal-narrowing",
		["three-bars-horizontal-triangles-vertical"] = "three-bars-horizontal-triangles-vertical",
		["three-bars-vertical-triangles-horizontal"] = "three-bars-vertical-triangles-horizontal",
		["three-chevrons-enlarging-down"] = "three-chevrons-enlarging-down",
		["three-chevrons-enlarging-up"] = "three-chevrons-enlarging-up",
		["three-dots-horizontal"] = "three-dots-horizontal",
		["three-dots-vertical"] = "three-dots-vertical",
		["three-horizontal-bars-wrapping-right"] = "three-horizontal-bars-wrapping-right",
		["three-people"] = "three-people",
		["three-ring-note"] = "three-ring-note",
		["three-sliders-horizontal"] = "three-sliders-horizontal",
		["three-stacked-squares-tilted"] = "three-stacked-squares-tilted",
		["thumb-down"] = "thumb-down",
		["thumb-up"] = "thumb-up",
		["tik-tok"] = "tik-tok",
		["tilt"] = "tilt",
		["torso"] = "torso",
		["trash-can"] = "trash-can",
		["triangle-exclamation"] = "triangle-exclamation",
		["trophy"] = "trophy",
		["tshirt"] = "tshirt",
		["tshirt-2d-text"] = "tshirt-2d-text",
		["tshirt-dual-arrows"] = "tshirt-dual-arrows",
		["twitch"] = "twitch",
		["twitter"] = "twitter",
		["two-arrows-down-and-up"] = "two-arrows-down-and-up",
		["two-arrows-from-center"] = "two-arrows-from-center",
		["two-arrows-left-right"] = "two-arrows-left-right",
		["two-arrows-loop-clockwise"] = "two-arrows-loop-clockwise",
		["two-arrows-loop-clockwise-1"] = "two-arrows-loop-clockwise-1",
		["two-arrows-loop-clockwise-infinity"] = "two-arrows-loop-clockwise-infinity",
		["two-arrows-spin-clockwise"] = "two-arrows-spin-clockwise",
		["two-arrows-spin-clockwise-plus"] = "two-arrows-spin-clockwise-plus",
		["two-arrows-switch-right"] = "two-arrows-switch-right",
		["two-arrows-to-center"] = "two-arrows-to-center",
		["two-folders"] = "two-folders",
		["two-location-pins-connecting-arrow"] = "two-location-pins-connecting-arrow",
		["two-makeup-brushes"] = "two-makeup-brushes",
		["two-people"] = "two-people",
		["two-people-speech-bubble"] = "two-people-speech-bubble",
		["two-stacked-squares"] = "two-stacked-squares",
		["two-switches-horizontal"] = "two-switches-horizontal",
		["verified-backplate"] = "verified-backplate",
		["verified-check"] = "verified-check",
		["verified-mono"] = "verified-mono",
		["video-camera"] = "video-camera",
		["video-camera-arrow-to-bottom-left"] = "video-camera-arrow-to-bottom-left",
		["video-camera-arrow-to-top-right"] = "video-camera-arrow-to-top-right",
		["video-camera-slash"] = "video-camera-slash",
		["video-camera-triangle-exclamation"] = "video-camera-triangle-exclamation",
		["video-camera-x"] = "video-camera-x",
		["wallet"] = "wallet",
		["we-chat"] = "we-chat",
		["whatsapp"] = "whatsapp",
		["x"] = "x",
		["x-small"] = "x-small",
		["xbox-a"] = "xbox-a",
		["xbox-a-pressed"] = "xbox-a-pressed",
		["xbox-a-unpressed"] = "xbox-a-unpressed",
		["xbox-b"] = "xbox-b",
		["xbox-dpad"] = "xbox-dpad",
		["xbox-dpad-down"] = "xbox-dpad-down",
		["xbox-dpad-left"] = "xbox-dpad-left",
		["xbox-dpad-right"] = "xbox-dpad-right",
		["xbox-dpad-up"] = "xbox-dpad-up",
		["xbox-lb"] = "xbox-lb",
		["xbox-lt"] = "xbox-lt",
		["xbox-menu"] = "xbox-menu",
		["xbox-rb"] = "xbox-rb",
		["xbox-rt"] = "xbox-rt",
		["xbox-stick-left"] = "xbox-stick-left",
		["xbox-stick-left-directional"] = "xbox-stick-left-directional",
		["xbox-stick-left-horizontal"] = "xbox-stick-left-horizontal",
		["xbox-stick-left-vertical"] = "xbox-stick-left-vertical",
		["xbox-stick-right"] = "xbox-stick-right",
		["xbox-stick-right-directional"] = "xbox-stick-right-directional",
		["xbox-stick-right-horizontal"] = "xbox-stick-right-horizontal",
		["xbox-stick-right-vertical"] = "xbox-stick-right-vertical",
		["xbox-view"] = "xbox-view",
		["xbox-x"] = "xbox-x",
		["xbox-y"] = "xbox-y",
		["xr-headset"] = "xr-headset",
		["youtube"] = "youtube"
	};
end);

NeverLose.IsMouseOverFrame = LPH_NO_VIRTUALIZE(function(self , Frame)
	if not Frame then
		return;
	end;

	if NeverLose.Global3DRenderMode then
		if Frame.GuiState == Enum.GuiState.Hover or Frame.GuiState == Enum.GuiState.Press then
			return true;
		end;

		return false;
	end;

	local AbsPos: Vector2, AbsSize: Vector2 = Frame.AbsolutePosition, Frame.AbsoluteSize;

	if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
		return true;
	end;
end);

NeverLose.CreateSignal = LPH_NO_VIRTUALIZE(function(self , DefaultValue)
	local __cache = Instance.new('BindableEvent');
	local bind = {
		Value = DefaultValue,
		__event = __cache
	};

	function bind:GetValue()
		return bind.Value;
	end;

	function bind:SetValue(f)
		bind.Value = f;

		return __cache:Fire(f);
	end;

	function bind:Connect(f)
		local signal = __cache.Event:Connect(f);

		NeverLose:AddSignal(signal);

		return signal;
	end;

	return bind;
end);

NeverLose.SetIconMode = LPH_NO_VIRTUALIZE(function(self , Label: TextLabel , Icon: string)
	local useBold = string.lower(string.sub(Icon , -5)) == '-bold';

	if useBold then
		Label.Text = Icon:sub(1,-6);
		Label.FontFace = NeverLose.BuiltInBold;
	else
		Label.Text = Icon;
		Label.FontFace = NeverLose.BuiltInRegular;
	end;
end);

function NeverLose:GetIconFont(icon: string)
	local useBold = string.lower(string.sub(icon , -5)) == '-bold';

	if useBold then
		return NeverLose.BuiltInBold;
	end;

	return NeverLose.BuiltInRegular;
end;

function NeverLose:MoreThanHalfY(Value: number)
	return (NeverLose.ScreenGui.AbsoluteSize.Y / 2) < Value
end;

function NeverLose:ToScreenOffset(absX: number, absY: number)
	local sg = NeverLose.ScreenGui;
	local sgPos = (sg and sg.AbsolutePosition) or Vector2.zero;
	return UDim2.fromOffset(math.floor(absX - sgPos.X), math.floor(absY - sgPos.Y));
end;

NeverLose.IsStudio = RunService:IsStudio();
NeverLose.IsMobile = UserInputService.TouchEnabled;

NeverLose.CreateInput = LPH_NO_VIRTUALIZE(function(self , Frame , Callback, RightClickCallback)
	local Button = Instance.new('ImageButton',Frame);

	Button.ZIndex = Frame.ZIndex + 10;
	Button.Size = UDim2.fromScale(1,1);
	Button.BackgroundTransparency = 1;
	Button.ImageTransparency = 1;
	Button.Image = "rbxasset://textuers/translateIcon.png";

	if Callback then
		Button.MouseButton1Click:Connect(Callback);
	end;

	if RightClickCallback then
		Button.MouseButton2Click:Connect(RightClickCallback);
	end;

	return Button;
end);

NeverLose.PlayAnimate = LPH_NO_VIRTUALIZE(function(Self , Info , Property)
	local Tween = TweenService:Create(Self , Info or TweenInfo.new(0.25) , Property);

	Tween:Play();

	return Tween;
end);

NeverLose.Drag = LPH_NO_VIRTUALIZE(function(InputFrame: Frame, MoveFrame: Frame, Speed : number)
	local dragToggle: boolean = false;
	local dragStart: Vector3 = nil;
	local startPos: UDim2 = nil;
	local Tween = TweenInfo.new(Speed);

	local updateInput = function(input)
		local delta = input.Position - dragStart;
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y);

		if NeverLose.Global3DRenderMode then
			NeverLose.PlayAnimate(MoveFrame,Tween,{
				Position = UDim2.fromScale(0.5,0.5)
			});
		else
			NeverLose.PlayAnimate(MoveFrame,Tween,{
				Position = position
			});
		end;
	end;

	NeverLose:AddSignal(InputFrame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true;
			dragStart = input.Position;
			startPos = MoveFrame.Position;

			local input_end;
			input_end = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false;

					input_end:Disconnect();
				end
			end)
		end
	end));

	NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input)
			end
		end
	end));
end);

NeverLose.Rounding = LPH_NO_VIRTUALIZE(function(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0);
	return math.floor(num * mult + 0.5) / mult;
end);

NeverLose.ProcessParams = LPH_NO_VIRTUALIZE(function(self , Params , Fixed)
	Params = Params or {};

	local k = Params or {};

	for i,v in next , Fixed do
		k[i] = Params[i] or v;
	end;

	table.clear(Fixed);

	return k;
end);

NeverLose.EnabledBlur = true;
NeverLose.BlurModuleParent = workspace.CurrentCamera;

NeverLose.GetCalculatePosition = LPH_NO_VIRTUALIZE(function(planePos, planeNormal, rayOrigin, rayDirection)
	local n = planeNormal;
	local d = rayDirection;
	local v = rayOrigin - planePos;

	local num = (n.x * v.x) + (n.y * v.y) + (n.z * v.z);
	local den = (n.x * d.x) + (n.y * d.y) + (n.z * d.z);
	local a = -num / den;

	return rayOrigin + (a * rayDirection);
end);

NeverLose.CreateBlurModule = LPH_NO_VIRTUALIZE(function(self , Frame , Signal)
	if not NeverLose.EnabledBlur then
		return NeverLose:AddSignal(Instance.new('BindableEvent').Event:Connect(function() return "nl"; end));	
	end;

	local cam = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera");
	local Part = Instance.new('Part');
	local DepthOfField = Instance.new('DepthOfFieldEffect');
	local BlockMesh = Instance.new("BlockMesh");

	BlockMesh.Parent = Part;

	Part.Material = Enum.Material.Glass;
	Part.Transparency = 0.98;
	Part.Reflectance = 0;
	Part.CastShadow = false;
	Part.Anchored = true;
	Part.CanCollide = false;
	Part.CanQuery = false;
	Part.CollisionGroup = NeverLose.RandomString();
	Part.Size = Vector3.new(1, 1, 1) * 0.01;
	Part.Color = Color3.fromRGB(0,0,0);
	Part.Name = NeverLose.RandomString();

	DepthOfField.Enabled = false;
	DepthOfField.FarIntensity = 0;
	DepthOfField.FocusDistance = 0.2;
	DepthOfField.InFocusRadius = 0;
	DepthOfField.NearIntensity = 1;
	DepthOfField.Name = NeverLose.RandomString();
	DepthOfField.Parent = cloneref(game:GetService('Lighting'));

	local disconnect;

	local UpdateFunction = function()
		if not Frame or not Frame.Parent then return end;
		local curCam = workspace.CurrentCamera;
		if not curCam then return end;

		local IsWindowActive = Signal:GetValue();

		if IsWindowActive and not NeverLose.Global3DRenderMode then
			DepthOfField.Enabled = true;
			DepthOfField.NearIntensity = 1;
			Part.Transparency = 0.98;
			Part.Size = Vector3.new(1, 1, 1) * 0.01;
			Part.Parent = curCam;
		else
			DepthOfField.Enabled = false;
			DepthOfField.NearIntensity = 0;
			Part.Transparency = 1;
			Part.Size = Vector3.zero;
			Part.Parent = nil;
			return false;
		end;

		if IsWindowActive then
			local corner0 = Frame.AbsolutePosition;
			local corner1 = corner0 + Frame.AbsoluteSize;

			local ray0 = curCam:ScreenPointToRay(corner0.X, corner0.Y, 1);
			local ray1 = curCam:ScreenPointToRay(corner1.X, corner1.Y, 1);

			local planeOrigin = curCam.CFrame.Position + curCam.CFrame.LookVector * (0.05 - curCam.NearPlaneZ);
			local planeNormal = curCam.CFrame.LookVector;

			local pos0 = NeverLose.GetCalculatePosition(planeOrigin, planeNormal, ray0.Origin, ray0.Direction);
			local pos1 = NeverLose.GetCalculatePosition(planeOrigin, planeNormal, ray1.Origin, ray1.Direction);

			pos0 = curCam.CFrame:PointToObjectSpace(pos0);
			pos1 = curCam.CFrame:PointToObjectSpace(pos1);

			local size   = pos1 - pos0;
			local center = (pos0 + pos1) / 2;

			BlockMesh.Offset = center;
			BlockMesh.Scale  = size / 0.0101;
			Part.CFrame = curCam.CFrame;
		end;
	end;

	local renderConnection = RunService.RenderStepped:Connect(function()
		pcall(UpdateFunction);
	end);

	disconnect = function()
		if renderConnection then renderConnection:Disconnect(); renderConnection = nil; end;
		pcall(function() Part:Destroy() end);
		pcall(function() DepthOfField:Destroy() end);
	end;

	Frame.Destroying:Connect(disconnect);

	return renderConnection;
end);

local EmptyFunction = function() end;

function NeverLose:RollingEffect(parent)
	local UIGradient = Instance.new("UIGradient")

	UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.4), NumberSequenceKeypoint.new(1.00, 0.00)}
	UIGradient.Parent = parent

	return UIGradient;
end;

function NeverLose:CreateShadow(parent , RollingEffect)
	local Shadow = {};

	local UIShadowSafe85 = Instance.new("UIStroke")
	local UIShadowSafe65 = Instance.new("UIStroke")
	local UIShadowSafe50 = Instance.new("UIStroke")
	local UIShadowSafe45 = Instance.new("UIStroke")

	UIShadowSafe85.Thickness = 6.000
	UIShadowSafe85.Transparency = 1
	UIShadowSafe85.Parent = parent

	UIShadowSafe65.Thickness = 5.000
	UIShadowSafe65.Transparency = 1
	UIShadowSafe65.Parent = parent

	UIShadowSafe50.Thickness = 4.000
	UIShadowSafe50.Transparency = 1
	UIShadowSafe50.Parent = parent

	UIShadowSafe45.Thickness = 3.000
	UIShadowSafe45.Transparency = 1
	UIShadowSafe45.Parent = parent

	local RollingEffectThread;
	local r1,r2,r3,r4;

	if RollingEffect then
		r1 = NeverLose:RollingEffect(UIShadowSafe85);
		r2 = NeverLose:RollingEffect(UIShadowSafe65);
		r3 = NeverLose:RollingEffect(UIShadowSafe50);
		r4 = NeverLose:RollingEffect(UIShadowSafe45);
	end;

	Shadow.Render = LPH_NO_VIRTUALIZE(function(self , value)
		if RollingEffectThread then
			task.cancel(RollingEffectThread);
			RollingEffectThread = nil;
		end;

		if value then
			NeverLose.PlayAnimate(UIShadowSafe85 , SlowyTween , {
				Transparency = 0.900
			})

			NeverLose.PlayAnimate(UIShadowSafe65 , SlowyTween , {
				Transparency = 0.900
			})

			NeverLose.PlayAnimate(UIShadowSafe50 , SlowyTween , {
				Transparency = 0.900
			})

			NeverLose.PlayAnimate(UIShadowSafe45 , SlowyTween , {
				Transparency = 0.900
			})

			if RollingEffect then
				RollingEffectThread = task.spawn(function()
					local level = 20;
					while true do task.wait(0.025)
						NeverLose.PlayAnimate(r1 , SlowyTween , {
							Rotation = r1.Rotation + level
						});

						NeverLose.PlayAnimate(r2 , SlowyTween , {
							Rotation = r2.Rotation + level
						});

						NeverLose.PlayAnimate(r3 , SlowyTween , {
							Rotation = r3.Rotation + level
						});

						NeverLose.PlayAnimate(r4 , SlowyTween , {
							Rotation = r4.Rotation + level
						});
					end;
				end);
			end;
		else
			NeverLose.PlayAnimate(UIShadowSafe85 , SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(UIShadowSafe65 , SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(UIShadowSafe50 , SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(UIShadowSafe45 , SlowyTween , {
				Transparency = 1
			})
		end;
	end);

	return Shadow;
end;

function NeverLose:CreateOptionWindow(Frame: Frame , Zindex, CustomWidth)
	Zindex = Zindex or 9;
	local WinWidth = CustomWidth or 220;

	local Window = {
		Signal = NeverLose:CreateSignal(false),
	};

	local OptionHandler = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")
	local UIStroke = Instance.new("UIStroke")
	local shadow = NeverLose:CreateShadow(OptionHandler);
	if NeverLose.EnabledBlur then
		NeverLose:CreateBlurModule(OptionHandler, Window.Signal);
	end;

	OptionHandler.Name = NeverLose.RandomString();
	OptionHandler.Parent = NeverLose.ScreenGui
	OptionHandler.AnchorPoint = Vector2.new(0, 0)
	OptionHandler.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
	OptionHandler.BackgroundTransparency = 0.035
	OptionHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
	OptionHandler.BorderSizePixel = 0
	OptionHandler.ClipsDescendants = true
	OptionHandler.Position = UDim2.new(255,255,255,255)
	OptionHandler.Size = UDim2.new(0, WinWidth, 0, 75)
	OptionHandler.ZIndex = Zindex + 9

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = OptionHandler

	UIListLayout.Parent = OptionHandler
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	UIStroke.Transparency = 0.650
	UIStroke.Color = Color3.fromRGB(45, 48, 58)
	UIStroke.Parent = OptionHandler

	NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
		if Window.Signal:GetValue() then
			local contentH = UIListLayout.AbsoluteContentSize.Y;
			if contentH > 30 then
				NeverLose.PlayAnimate(OptionHandler , SlowyTween , {
					Size = UDim2.new(0, WinWidth, 0, contentH + 8)
				})
			end;
		end;
	end)));

	NeverLose:AddSignal(OptionHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
		if OptionHandler.BackgroundTransparency > 0.9 then
			OptionHandler.Visible = false;
		else
			OptionHandler.Visible = true;
			if NeverLose.Global3DRenderMode then
				OptionHandler.Parent = NeverLose.GlobalSurfaceGui;
			else
				OptionHandler.Parent = NeverLose.ScreenGui;
			end;
		end;
	end)));

	local FollowingThread;
	local SetPosition = LPH_NO_VIRTUALIZE(function()
		if not Frame or not Frame.Parent then return end;
		if CustomWidth and CustomWidth > 250 then
			-- UserSettings popup: anchor at bottom-left, place to the right of sidebar, bottom-aligned with BottomFrame
			OptionHandler.AnchorPoint = Vector2.new(0, 1);
			local targetX = Frame.AbsolutePosition.X + Frame.AbsoluteSize.X + 8;
			local targetY = Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y;
			OptionHandler.Position = NeverLose:ToScreenOffset(targetX, targetY);
		else
			if NeverLose:MoreThanHalfY(Frame.AbsolutePosition.Y + 30) then
				OptionHandler.AnchorPoint = Vector2.new(0, 1);
				local targetX = Frame.AbsolutePosition.X + 8;
				local targetY = Frame.AbsolutePosition.Y - 6;
				OptionHandler.Position = NeverLose:ToScreenOffset(targetX, targetY);
			else
				OptionHandler.AnchorPoint = Vector2.new(0, 0);
				local targetX = Frame.AbsolutePosition.X + 8;
				local targetY = Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y + 6;
				OptionHandler.Position = NeverLose:ToScreenOffset(targetX, targetY);
			end;
		end;
	end);

	Window.SetRender = LPH_NO_VIRTUALIZE(function(value)
		if FollowingThread then
			task.cancel(FollowingThread);
			FollowingThread = nil;
		end;

		if value then
			SetPosition();
			OptionHandler.Visible = true;

			local contentH = UIListLayout.AbsoluteContentSize.Y;
			if contentH < 50 then contentH = (CustomWidth and CustomWidth > 250) and 225 or 295 end;
			OptionHandler.Size = UDim2.new(0, WinWidth, 0, contentH + 8);

			NeverLose.PlayAnimate(OptionHandler , SlowyTween , {
				BackgroundTransparency = 0.035
			})

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 0.650
			})

			shadow:Render(true);

			if NeverLose.Global3DRenderMode then
				OptionHandler.Parent = NeverLose.GlobalSurfaceGui;
			else
				OptionHandler.Parent = NeverLose.ScreenGui;
			end;

			FollowingThread = task.spawn(function()
				while true do task.wait()
					SetPosition();
				end
			end)
		else
			NeverLose.PlayAnimate(OptionHandler , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 1
			})

			shadow:Render(false);
		end;
	end);

	Window.SetRender(false);
	Window.Signal:Connect(Window.SetRender)

	local Payback = NeverLose:RegisiterItem(OptionHandler , Window.Signal);

	Payback.Winbdow = Window;
	Payback.Root = OptionHandler;
	Payback.Signal = Window.Signal;

	return Payback;
end;

function NeverLose:CreateColorPicker(HandleFrame: Frame)
	local ZIndex = HandleFrame.ZIndex;

	local ColorPickerLib = {};

	local ColorPickerHandler = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local SaViMap = Instance.new("ImageLabel")
	local UICorner_2 = Instance.new("UICorner")
	local ColorZoneSelection = Instance.new("Frame")
	local UICorner_3 = Instance.new("UICorner")
	local UIStroke_2 = Instance.new("UIStroke")
	local ColorMap = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local UICorner_4 = Instance.new("UICorner")
	local ColorMapSelection = Instance.new("Frame")
	local UIStroke_3 = Instance.new("UIStroke")
	local UICorner_5 = Instance.new("UICorner")
	local RGBLabel = Instance.new("TextLabel")
	local UICorner_6 = Instance.new("UICorner")
	local Shadow = NeverLose:CreateShadow(ColorPickerHandler);

	ColorPickerHandler.Name = NeverLose.RandomString();
	ColorPickerHandler.Parent = NeverLose.ScreenGui
	ColorPickerHandler.AnchorPoint = Vector2.new(0, 0)
	ColorPickerHandler.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
	ColorPickerHandler.BackgroundTransparency = 0.035
	ColorPickerHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorPickerHandler.BorderSizePixel = 0
	ColorPickerHandler.ClipsDescendants = true
	ColorPickerHandler.Position = UDim2.new(255, 0, 255, 20)
	ColorPickerHandler.Size = UDim2.new(0, 200, 0, 240)
	ColorPickerHandler.ZIndex = ZIndex + 125

	NeverLose:AddSignal(ColorPickerHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
		if ColorPickerHandler.BackgroundTransparency > 0.9 then
			ColorPickerHandler.Visible = false;
			ColorPickerHandler.Parent = nil
		else
			ColorPickerHandler.Visible = true;

			if NeverLose.Global3DRenderMode then
				ColorPickerHandler.Parent = NeverLose.GlobalSurfaceGui;
			else
				ColorPickerHandler.Parent = NeverLose.ScreenGui;
			end;
		end;
	end)));

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = ColorPickerHandler

	UIStroke.Transparency = 0.650
	UIStroke.Color = Color3.fromRGB(45, 48, 58)
	UIStroke.Parent = ColorPickerHandler

	SaViMap.Name = NeverLose.RandomString();
	SaViMap.Parent = ColorPickerHandler
	SaViMap.AnchorPoint = Vector2.new(0.5, 0)
	SaViMap.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
	SaViMap.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SaViMap.BorderSizePixel = 0
	SaViMap.Position = UDim2.new(0.5, 0, 0, 5)
	SaViMap.Size = UDim2.new(0, 185, 0, 185)
	SaViMap.ZIndex = ZIndex + 126
	SaViMap.Image = NeverLose.ImageColorMapping -- UNSAFE IMAGE

	UICorner_2.CornerRadius = UDim.new(0, 5)
	UICorner_2.Parent = SaViMap

	ColorZoneSelection.Name = NeverLose.RandomString();
	ColorZoneSelection.Parent = SaViMap
	ColorZoneSelection.AnchorPoint = Vector2.new(0.5, 0.5)
	ColorZoneSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorZoneSelection.BackgroundTransparency = 1.000
	ColorZoneSelection.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorZoneSelection.BorderSizePixel = 0
	ColorZoneSelection.Position = UDim2.new(0.5, 0, 0.5, 0)
	ColorZoneSelection.Size = UDim2.new(0, 10, 0, 10)
	ColorZoneSelection.ZIndex = ZIndex + 127

	UICorner_3.CornerRadius = UDim.new(1, 0)
	UICorner_3.Parent = ColorZoneSelection

	UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
	UIStroke_2.Parent = ColorZoneSelection

	ColorMap.Name = NeverLose.RandomString();
	ColorMap.Parent = ColorPickerHandler
	ColorMap.AnchorPoint = Vector2.new(0.5, 0)
	ColorMap.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorMap.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorMap.BorderSizePixel = 0
	ColorMap.Position = UDim2.new(0.5, 0, 0, 200)
	ColorMap.Size = UDim2.new(1, -15, 0, 10)
	ColorMap.ZIndex = ZIndex + 126

	UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 153, 0)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(203, 255, 0)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(50, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 102)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 101, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(50, 0, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(204, 0, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 153)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))}
	UIGradient.Parent = ColorMap

	UICorner_4.CornerRadius = UDim.new(0, 3)
	UICorner_4.Parent = ColorMap

	ColorMapSelection.Name = NeverLose.RandomString();
	ColorMapSelection.Parent = ColorMap
	ColorMapSelection.AnchorPoint = Vector2.new(0.5, 0.5)
	ColorMapSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ColorMapSelection.BackgroundTransparency = 1.000
	ColorMapSelection.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ColorMapSelection.BorderSizePixel = 0
	ColorMapSelection.Position = UDim2.new(0, 0, 0.5, 0)
	ColorMapSelection.Size = UDim2.new(0, 5, 1, 0)
	ColorMapSelection.ZIndex = ZIndex + 126

	UIStroke_3.Thickness = 2.000
	UIStroke_3.Color = Color3.fromRGB(255, 255, 255)
	UIStroke_3.Parent = ColorMapSelection

	UICorner_5.CornerRadius = UDim.new(0, 3)
	UICorner_5.Parent = ColorMapSelection

	RGBLabel.Name = NeverLose.RandomString();
	RGBLabel.Parent = ColorPickerHandler
	RGBLabel.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
	RGBLabel.BackgroundTransparency = 0.750
	RGBLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	RGBLabel.BorderSizePixel = 0
	RGBLabel.Position = UDim2.new(0, 10, 0, 217)
	RGBLabel.Size = UDim2.new(1, -20, 0, 15)
	RGBLabel.ZIndex = ZIndex + 127
	RGBLabel.Font = Enum.Font.GothamBold
	RGBLabel.Text = "#FFFFFF"
	RGBLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	RGBLabel.TextSize = 12.000
	RGBLabel.TextTransparency = 0.400
	RGBLabel.TextXAlignment = Enum.TextXAlignment.Left

	UICorner_6.CornerRadius = UDim.new(0, 4)
	UICorner_6.Parent = RGBLabel

	ColorPickerLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
		if value then
			ColorPickerHandler.Position = NeverLose:ToScreenOffset(HandleFrame.AbsolutePosition.X + 20, HandleFrame.AbsolutePosition.Y + 75);

			NeverLose.PlayAnimate(ColorPickerHandler,SlowyTween , {
				BackgroundTransparency = 0.035
			})

			NeverLose.PlayAnimate(UIStroke,SlowyTween , {
				Transparency = 0.650
			})

			NeverLose.PlayAnimate(SaViMap,SlowyTween , {
				BackgroundTransparency = 0,
				ImageTransparency = 0
			})

			NeverLose.PlayAnimate(UIStroke_2,SlowyTween , {
				Transparency = 0
			})

			NeverLose.PlayAnimate(ColorMap,SlowyTween , {
				BackgroundTransparency = 0
			})

			NeverLose.PlayAnimate(UIStroke_3,SlowyTween , {
				Transparency = 0
			})

			NeverLose.PlayAnimate(RGBLabel,SlowyTween , {
				BackgroundTransparency = 0.750,
				TextTransparency = 0.400
			})

			Shadow:Render(true)
		else
			NeverLose.PlayAnimate(ColorPickerHandler,SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke,SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(SaViMap,SlowyTween , {
				BackgroundTransparency = 1,
				ImageTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke_2,SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(ColorMap,SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke_3,SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(RGBLabel,SlowyTween , {
				BackgroundTransparency = 1,
				TextTransparency = 1
			})

			Shadow:Render(false)
		end;
	end);

	ColorPickerLib.SetRender(false);
	ColorPickerLib.Root = ColorPickerHandler;
	ColorPickerLib.H = 1;
	ColorPickerLib.S = 1;
	ColorPickerLib.V = 1;
	ColorPickerLib.Callback = EmptyFunction;

	function ColorPickerLib:Update()
		local RealColor = Color3.fromHSV(ColorPickerLib.H , ColorPickerLib.S , ColorPickerLib.V);

		NeverLose.PlayAnimate(ColorZoneSelection,ManualTween,{
			Position = UDim2.fromScale(ColorPickerLib.S , 1 - ColorPickerLib.V)
		});

		NeverLose.PlayAnimate(SaViMap,ManualTween,{
			BackgroundColor3 = Color3.fromHSV(ColorPickerLib.H , 1 , 1)
		});

		NeverLose.PlayAnimate(ColorMapSelection,ManualTween,{
			Position = UDim2.fromScale(ColorPickerLib.H,0.5)
		});

		RGBLabel.Text = "#"..RealColor:ToHex();

		ColorPickerLib.Callback(RealColor);
	end;

	function ColorPickerLib:SetValue(Color)
		if typeof(Color) == 'string' then
			Color = Color3.fromHex(Color);
		end;

		local H , S , V = Color:ToHSV();

		ColorPickerLib.H = H;
		ColorPickerLib.S = S;
		ColorPickerLib.V = V;

		ColorPickerLib:Update();
	end;

	ColorPickerLib.IsHold = false;

	NeverLose:AddSignal(ColorPickerHandler.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			ColorPickerLib.IsHold = true;
		end;
	end));

	NeverLose:AddSignal(ColorPickerHandler.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			ColorPickerLib.IsHold = false;
		end;
	end));

	NeverLose:AddSignal(ColorMap.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			ColorPickerLib.IsHold = true;

			while (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or ColorPickerLib.IsHold) do task.wait()
				local ColorY = ColorMap.AbsolutePosition.X
				local ColorYM = ColorY + ColorMap.AbsoluteSize.X;
				local Value = math.clamp(Mouse.X, ColorY, ColorYM)
				local Code = ((Value - ColorY) / (ColorYM - ColorY));

				ColorPickerLib.H = Code;
				ColorPickerLib:Update();
			end;
		end;
	end)));

	NeverLose:AddSignal(SaViMap.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			ColorPickerLib.IsHold = true;

			while (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or ColorPickerLib.IsHold) do task.wait();
				local PosX = SaViMap.AbsolutePosition.X;
				local ScaleX = PosX + SaViMap.AbsoluteSize.X;
				local Value, PosY = math.clamp(Mouse.X, PosX, ScaleX), SaViMap.AbsolutePosition.Y;
				local ScaleY = PosY + SaViMap.AbsoluteSize.Y;
				local Vals = math.clamp(Mouse.Y, PosY, ScaleY);

				ColorPickerLib.S = (Value - PosX) / (ScaleX - PosX);
				ColorPickerLib.V = (1 - ((Vals - PosY) / (ScaleY - PosY)));
				ColorPickerLib:Update();
			end
		end
	end)));

	return ColorPickerLib;
end;

NeverLose.KeyEnum = {
	One = '1',
	Two = '2',
	Three = '3',
	Four = '4',
	Five = '5',
	Six = '6',
	Seven = '7',
	Eight = '8',
	Nine = '9',
	Zero = '0',
	['Minus'] = "-",
	['Plus'] = "+",
	BackSlash = "\\",
	Slash = "/",
	Period = '.',
	Semicolon = ';',
	Colon = ":",
	LeftControl = "LCtrl",
	RightControl = "RCtrl",
	LeftShift = "LShift",
	RightShift = "RShift",
	Return = "Enter",
	LeftBracket = "[",
	RightBracket = "]",
	Quote = "'",
	Comma = ",",
	Equals = "=",
	LeftSuper = "Super",
	RightSuper = "Super",
	LeftAlt = "LAlt",
	RightAlt = "RAlt",
	Escape = "Esc",
};

NeverLose.EnumReverse = {};

for i,v in next , NeverLose.KeyEnum do
	NeverLose.EnumReverse[v] = i;
end;

function NeverLose:KeyCodeToStr(K: Enum.KeyCode)
	if typeof(K) == 'string' then
		if NeverLose.KeyEnum[K] then
			return NeverLose.KeyEnum[K];
		end;

		return K;
	end;

	return (NeverLose.KeyEnum[K.Name] or K.Name);
end;

function NeverLose:StrToKeyCode(str: string)
	if NeverLose.EnumReverse[str] then
		return Enum.KeyCode[NeverLose.EnumReverse[str]];
	end;

	return Enum.KeyCode[str];
end;


-- =========================================================================
NeverLose.RegisteredHotkeys = {}
NeverLose.HotkeysHUD = nil
NeverLose.MainWindow = nil
_G.NeverLose = NeverLose

function NeverLose:CreateHotkeysHUD()
	if NeverLose.HotkeysHUD and NeverLose.HotkeysHUD.Parent then return NeverLose.HotkeysHUD end

	local hud = Instance.new("Frame")
	hud.Name = "NeverLose_HotkeysHUD"
	hud.Parent = NeverLose.ScreenGui or (gethui and gethui()) or game:GetService("CoreGui")
	hud.BackgroundTransparency = 1
	hud.BorderSizePixel = 0
	hud.Position = UDim2.new(0, 20, 0.35, 0)
	hud.Size = UDim2.new(0, 120, 0, 30)
	hud.Visible = false
	hud.ZIndex = 250

	local hudLayout = Instance.new("UIListLayout", hud)
	hudLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hudLayout.Padding = UDim.new(0, 4)
	hudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

	-- Pill Header Badge (Neverlose Style: Dark rounded pill with Orange/Accent List Icon)
	local header = Instance.new("Frame", hud)
	header.Name = "Header"
	header.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
	header.BackgroundTransparency = 0.15
	header.BorderSizePixel = 0
	header.Size = UDim2.new(0, 86, 0, 24)
	header.ZIndex = 251

	local hCorner = Instance.new("UICorner", header)
	hCorner.CornerRadius = UDim.new(0, 8)

	local hStroke = Instance.new("UIStroke", header)
	hStroke.Color = Color3.fromRGB(42, 46, 58)
	hStroke.Transparency = 0.4
	hStroke.Thickness = 1

	local icon = Instance.new("TextLabel", header)
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.new(0, 8, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Size = UDim2.new(0, 14, 0, 14)
	icon.FontFace = NeverLose.BuiltInBold
	icon.Text = "list"
	icon.TextColor3 = Color3.fromRGB(235, 95, 60)
	icon.TextSize = 12
	icon.ZIndex = 252
	NeverLose:RegisterAccent(icon, "TextColor3")

	local title = Instance.new("TextLabel", header)
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 26, 0.5, 0)
	title.AnchorPoint = Vector2.new(0, 0.5)
	title.Size = UDim2.new(1, -30, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.Text = "Hotkeys"
	title.TextColor3 = Color3.fromRGB(240, 242, 250)
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 252

	local listFrame = Instance.new("Frame", hud)
	listFrame.Name = "List"
	listFrame.BackgroundTransparency = 1
	listFrame.Size = UDim2.new(0, 140, 0, 0)
	listFrame.ZIndex = 251

	local listLayout = Instance.new("UIListLayout", listFrame)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)

	NeverLose:AddSignal(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		listFrame.Size = UDim2.new(0, 140, 0, listLayout.AbsoluteContentSize.Y)
		hud.Size = UDim2.new(0, 140, 0, 30 + listLayout.AbsoluteContentSize.Y)
	end))

	-- Dragging: allowed only when GUI is open
	local isDragging = false
	local dragStart, startPos
	header.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			local isGuiOpen = NeverLose.MainWindow and NeverLose.MainWindow.Visible and NeverLose.MainWindow.BackgroundTransparency < 0.9
			if isGuiOpen then
				isDragging = true
				dragStart = input.Position
				startPos = hud.Position
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			hud.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	NeverLose.HotkeysHUD = hud
	return hud
end

function NeverLose:UpdateHotkeysHUD()
	local hud = NeverLose:CreateHotkeysHUD()
	local listFrame = hud:FindFirstChild("List")
	local header = hud:FindFirstChild("Header")
	if not listFrame then return end

	local isGuiOpen = NeverLose.MainWindow and NeverLose.MainWindow.Visible and NeverLose.MainWindow.BackgroundTransparency < 0.9

	-- Count active hotkeys
	local activeCount = 0
	local activeData = {}
	for name, data in pairs(NeverLose.RegisteredHotkeys) do
		if data.Key and data.Key ~= "None" and data.Key ~= "Not Bound" and not data.HiddenFromHUD then
			if data.Mode == "Always On" then
				data.Active = true
			end
			if data.Active then
				activeCount = activeCount + 1
				table.insert(activeData, data)
			end
		end
	end

	-- Build active map
	local activeMap = {}
	for _, data in ipairs(activeData) do
		activeMap[data.Name] = data
	end

	-- If GUI is closed and no active hotkeys: smooth fade out & hide HUD
	if not isGuiOpen and activeCount == 0 then
		local hasExiting = false
		for _, c in ipairs(listFrame:GetChildren()) do
			if c:IsA("Frame") and c.Name:sub(1, 4) == "Row_" then
				hasExiting = true
				break
			end
		end

		if not hasExiting then
			hud.Visible = false
			return
		end
	end

	hud.Visible = true
	if header then
		TweenService:Create(header, FastTween, { BackgroundTransparency = 0.15 }):Play()
		for _, desc in ipairs(header:GetDescendants()) do
			if desc:IsA("TextLabel") then
				TweenService:Create(desc, FastTween, { TextTransparency = 0 }):Play()
			elseif desc:IsA("UIStroke") then
				TweenService:Create(desc, FastTween, { Transparency = 0.4 }):Play()
			end
		end
	end

	-- Smooth Exit Animation for deactivated hotkeys
	for _, c in ipairs(listFrame:GetChildren()) do
		if c:IsA("Frame") and c.Name:sub(1, 4) == "Row_" then
			local feat = c.Name:sub(5)
			if not activeMap[feat] and not c:GetAttribute("Exiting") then
				c:SetAttribute("Exiting", true)
				local toggleBox = c:FindFirstChild("ToggleBox")
				local nameBox = c:FindFirstChild("NameBox")
				local toggleCapsule = toggleBox and toggleBox:FindFirstChild("Toggle")
				local knob = toggleCapsule and toggleCapsule:FindFirstChild("Knob")
				local nameLbl = nameBox and nameBox:FindFirstChild("FeatureName")

				-- Animate switch knob sliding left (turn OFF)
				if knob then
					TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, 2, 0.5, 0),
						BackgroundColor3 = Color3.fromRGB(150, 155, 170)
					}):Play()
				end
				if toggleCapsule then
					TweenService:Create(toggleCapsule, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(38, 42, 54)
					}):Play()
				end

				-- Animate boxes fading out and collapsing
				local currentW = c.Size.X.Offset
				TweenService:Create(c, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					Size = UDim2.new(0, currentW, 0, 0)
				}):Play()

				if toggleBox then
					TweenService:Create(toggleBox, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, toggleBox.Size.X.Offset, 0, 0)
					}):Play()
					local s = toggleBox:FindFirstChildOfClass("UIStroke")
					if s then TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Transparency = 1 }):Play() end
				end
				if nameBox then
					TweenService:Create(nameBox, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, nameBox.Size.X.Offset, 0, 0)
					}):Play()
					local s = nameBox:FindFirstChildOfClass("UIStroke")
					if s then TweenService:Create(s, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Transparency = 1 }):Play() end
				end
				if nameLbl then
					TweenService:Create(nameLbl, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()
				end

				task.delay(0.25, function()
					if c and c.Parent then
						c:Destroy()
						local remaining = 0
						for _, ch in ipairs(listFrame:GetChildren()) do
							if ch:IsA("Frame") and ch.Name:sub(1, 4) == "Row_" and not ch:GetAttribute("Exiting") then
								remaining = remaining + 1
							end
						end
						local isGuiOpenNow = NeverLose.MainWindow and NeverLose.MainWindow.Visible and NeverLose.MainWindow.BackgroundTransparency < 0.9
						if remaining == 0 and not isGuiOpenNow and header then
							TweenService:Create(header, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
								BackgroundTransparency = 1
							}):Play()
							for _, desc in ipairs(header:GetDescendants()) do
								if desc:IsA("TextLabel") then
									TweenService:Create(desc, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
										TextTransparency = 1
									}):Play()
								elseif desc:IsA("UIStroke") then
									TweenService:Create(desc, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
										Transparency = 1
									}):Play()
								end
							end
							task.delay(0.25, function()
								if remaining == 0 and not isGuiOpenNow then
									hud.Visible = false
								end
							end)
						end
					end
				end)
			end
		end
	end

	-- Add or maintain active rows: TWO SEPARATE ROUNDED BOXES (Rounded square for toggle + Rounded rectangle for name)
	for _, data in ipairs(activeData) do
		local existingRow = listFrame:FindFirstChild("Row_" .. data.Name)
		local txtSize = TextService:GetTextSize(data.Name, 11, Enum.Font.GothamMedium, Vector2.new(1000, 20))
		local toggleW = 30
		local nameW = txtSize.X + 16
		local totalRowW = toggleW + 4 + nameW

		if not existingRow or existingRow:GetAttribute("Exiting") then
			if existingRow and existingRow:GetAttribute("Exiting") then
				existingRow:Destroy()
			end

			local row = Instance.new("Frame", listFrame)
			row.Name = "Row_" .. data.Name
			row.BackgroundTransparency = 1
			row.BorderSizePixel = 0
			row.ClipsDescendants = true
			row.Size = UDim2.new(0, totalRowW, 0, 0)
			row.ZIndex = 252

			local rowLayout = Instance.new("UIListLayout", row)
			rowLayout.FillDirection = Enum.FillDirection.Horizontal
			rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
			rowLayout.Padding = UDim.new(0, 4)
			rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			-- 1. Rounded Square for Toggle Switch
			local toggleBox = Instance.new("Frame", row)
			toggleBox.Name = "ToggleBox"
			toggleBox.LayoutOrder = 1
			toggleBox.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
			toggleBox.BackgroundTransparency = 1
			toggleBox.BorderSizePixel = 0
			toggleBox.ClipsDescendants = true
			toggleBox.Size = UDim2.new(0, toggleW, 0, 0)
			toggleBox.ZIndex = 253

			local tbCorner = Instance.new("UICorner", toggleBox)
			tbCorner.CornerRadius = UDim.new(0, 8)

			local tbStroke = Instance.new("UIStroke", toggleBox)
			tbStroke.Color = Color3.fromRGB(42, 46, 58)
			tbStroke.Thickness = 1
			tbStroke.Transparency = 1

			local toggleCapsule = Instance.new("Frame", toggleBox)
			toggleCapsule.Name = "Toggle"
			toggleCapsule.Position = UDim2.new(0.5, 0, 0.5, 0)
			toggleCapsule.AnchorPoint = Vector2.new(0.5, 0.5)
			toggleCapsule.Size = UDim2.new(0, 20, 0, 12)
			toggleCapsule.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
			toggleCapsule.BackgroundTransparency = 1
			toggleCapsule.BorderSizePixel = 0
			toggleCapsule.ZIndex = 254

			local tCorner = Instance.new("UICorner", toggleCapsule)
			tCorner.CornerRadius = UDim.new(1, 0)

			local toggleKnob = Instance.new("Frame", toggleCapsule)
			toggleKnob.Name = "Knob"
			toggleKnob.Position = UDim2.new(0, 2, 0.5, 0)
			toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
			toggleKnob.Size = UDim2.new(0, 8, 0, 8)
			toggleKnob.BackgroundColor3 = Color3.fromRGB(150, 155, 170)
			toggleKnob.BackgroundTransparency = 1
			toggleKnob.BorderSizePixel = 0
			toggleKnob.ZIndex = 255

			local kCorner = Instance.new("UICorner", toggleKnob)
			kCorner.CornerRadius = UDim.new(1, 0)

			-- 2. Rounded Rectangle for Feature Name
			local nameBox = Instance.new("Frame", row)
			nameBox.Name = "NameBox"
			nameBox.LayoutOrder = 2
			nameBox.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
			nameBox.BackgroundTransparency = 1
			nameBox.BorderSizePixel = 0
			nameBox.ClipsDescendants = true
			nameBox.Size = UDim2.new(0, nameW, 0, 0)
			nameBox.ZIndex = 253

			local nbCorner = Instance.new("UICorner", nameBox)
			nbCorner.CornerRadius = UDim.new(0, 8)

			local nbStroke = Instance.new("UIStroke", nameBox)
			nbStroke.Color = Color3.fromRGB(42, 46, 58)
			nbStroke.Thickness = 1
			nbStroke.Transparency = 1

			local nameLbl = Instance.new("TextLabel", nameBox)
			nameLbl.Name = "FeatureName"
			nameLbl.BackgroundTransparency = 1
			nameLbl.Position = UDim2.new(0, 8, 0.5, 0)
			nameLbl.AnchorPoint = Vector2.new(0, 0.5)
			nameLbl.Size = UDim2.new(1, -16, 1, 0)
			nameLbl.Font = Enum.Font.GothamMedium
			nameLbl.Text = data.Name
			nameLbl.TextColor3 = Color3.fromRGB(240, 242, 250)
			nameLbl.TextSize = 11
			nameLbl.TextXAlignment = Enum.TextXAlignment.Center
			nameLbl.TextTransparency = 1
			nameLbl.ZIndex = 254

			-- Smooth Entrance Animation (both rounded boxes expand to height 24, fade in, switch flips ON)
			TweenService:Create(row, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, totalRowW, 0, 24)
			}):Play()

			TweenService:Create(toggleBox, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, toggleW, 0, 24),
				BackgroundTransparency = 0.15
			}):Play()
			TweenService:Create(tbStroke, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = 0.4
			}):Play()

			TweenService:Create(nameBox, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, nameW, 0, 24),
				BackgroundTransparency = 0.15
			}):Play()
			TweenService:Create(nbStroke, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Transparency = 0.4
			}):Play()

			TweenService:Create(nameLbl, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(toggleCapsule, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(245, 245, 250)
			}):Play()
			TweenService:Create(toggleKnob, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
				Position = UDim2.new(1, -9, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(20, 22, 28)
			}):Play()

			-- Right-click on row to hide from HUD
			row.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton2 then
					data.HiddenFromHUD = true
					NeverLose:UpdateHotkeysHUD()
				end
			end)
		else
			if not existingRow:GetAttribute("Exiting") then
				local toggleBox = existingRow:FindFirstChild("ToggleBox")
				local toggleCapsule = toggleBox and toggleBox:FindFirstChild("Toggle")
				local knob = toggleCapsule and toggleCapsule:FindFirstChild("Knob")
				if data.Active then
					if toggleCapsule then
						TweenService:Create(toggleCapsule, FastTween, { BackgroundColor3 = Color3.fromRGB(245, 245, 250) }):Play()
					end
					if knob then
						TweenService:Create(knob, FastTween, {
							Position = UDim2.new(1, -9, 0.5, 0),
							BackgroundColor3 = Color3.fromRGB(20, 22, 28)
						}):Play()
					end
				end
			end
		end
	end
end

-- Helper to map keyboard and mouse input to a human-readable key name
local function getReadableKey(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Unknown then return nil end
		return input.KeyCode.Name
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		return "M1"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		return "M2"
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		return "M3"
	end
	return nil
end

-- Global keybind listener for in-game execution (supports both Keyboard and Mouse inputs)
NeverLose:AddSignal(UserInputService.InputBegan:Connect(function(inp, isTyping)
	if isTyping or NeverLose.IsRebindingKey then return end
	local key = getReadableKey(inp)
	if not key then return end
	for id, data in pairs(NeverLose.RegisteredHotkeys) do
		if data.Key == key then
			if data.Mode == "Hold" then
				data.Active = true
				if data.Callback then pcall(data.Callback, true) end
				NeverLose:UpdateHotkeysHUD()
			elseif data.Mode == "Toggle" then
				data.Active = not data.Active
				if data.Callback then pcall(data.Callback, data.Active) end
				NeverLose:UpdateHotkeysHUD()
			elseif data.Mode == "Always On" then
				data.Active = true
				if data.Callback then pcall(data.Callback, true) end
				NeverLose:UpdateHotkeysHUD()
			end
		end
	end
end))

NeverLose:AddSignal(UserInputService.InputEnded:Connect(function(inp)
	if NeverLose.IsRebindingKey then return end
	local key = getReadableKey(inp)
	if not key then return end
	for id, data in pairs(NeverLose.RegisteredHotkeys) do
		if data.Key == key and data.Mode == "Hold" then
			data.Active = false
			if data.Callback then pcall(data.Callback, false) end
			NeverLose:UpdateHotkeysHUD()
		end
	end
end))

-- Universal Right-Click Keybind Context Menu (Neverlose Style: Left Panel + Right Sub-Panel)
function NeverLose:OpenElementBindMenu(targetFrame, Config, elementLib, elementType)
	Config = Config or {}
	elementType = elementType or "Toggle"

	if NeverLose.CurrentBindMenu then
		pcall(function() NeverLose.CurrentBindMenu:Destroy() end)
		NeverLose.CurrentBindMenu = nil
	end
	if NeverLose.CurrentBindSubmenu then
		pcall(function() NeverLose.CurrentBindSubmenu:Destroy() end)
		NeverLose.CurrentBindSubmenu = nil
	end

	elementLib.Binds = elementLib.Binds or {}

	-- Helper to sync a bind entry to RegisteredHotkeys
	local function syncBind(bind)
		if not bind.Key or bind.Key == "None" or bind.Key == "Not Bound" then
			NeverLose.RegisteredHotkeys[bind.Id] = nil
		else
			NeverLose.RegisteredHotkeys[bind.Id] = {
				Id = bind.Id,
				Name = Config.Name or "Feature",
				Key = bind.Key,
				Mode = bind.Mode or "Toggle",
				Visible = (bind.Visible ~= false),
				HiddenFromHUD = (bind.Visible == false),
				Active = bind.Active or false,
				ElementType = elementType,
				Callback = function(active)
					bind.Active = active
					if elementType == "Toggle" then
						elementLib:SetValue(active)
					elseif elementType == "Slider" then
						if active then
							bind.PreviousNormalValue = elementLib:GetValue()
							local target = bind.TargetValue or math.clamp(math.floor(((Config.Min or 0) + (Config.Max or 100)) / 2), Config.Min or 0, Config.Max or 100)
							elementLib:SetValue(target)
						else
							elementLib:SetValue(bind.PreviousNormalValue or Config.Default or Config.Min or 0)
						end
					elseif elementType == "Keybind" then
						if Config.Callback then pcall(Config.Callback, active) end
					end
				end
			}
		end
		NeverLose:UpdateHotkeysHUD()
	end

	local parentGui = NeverLose.ScreenGui or (gethui and gethui()) or game:GetService("CoreGui")
	local scrSize = (NeverLose.ScreenGui and NeverLose.ScreenGui.AbsoluteSize) or workspace.CurrentCamera.ViewportSize

	local absPos = targetFrame.AbsolutePosition
	local absSize = targetFrame.AbsoluteSize
	local menuX = absPos.X + absSize.X + 6
	local menuY = absPos.Y
	if menuX + 140 + 175 > scrSize.X then
		menuX = math.max(10, absPos.X - 146)
	end

	-- 1. Left Panel Container
	local LeftPanel = Instance.new("Frame")
	LeftPanel.Name = "NeverLose_BindMenu"
	LeftPanel.Parent = parentGui
	LeftPanel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
	LeftPanel.BackgroundTransparency = 0.05
	LeftPanel.BorderSizePixel = 0
	LeftPanel.Position = UDim2.fromOffset(menuX, menuY)
	LeftPanel.Size = UDim2.new(0, 138, 0, 60)
	LeftPanel.ZIndex = 320

	local lpCorner = Instance.new("UICorner", LeftPanel)
	lpCorner.CornerRadius = UDim.new(0, 8)

	local lpStroke = Instance.new("UIStroke", LeftPanel)
	lpStroke.Color = Color3.fromRGB(42, 46, 58)
	lpStroke.Thickness = 1
	lpStroke.Transparency = 0.35

	local lpShadow = NeverLose:CreateShadow(LeftPanel)

	local lpLayout = Instance.new("UIListLayout", LeftPanel)
	lpLayout.SortOrder = Enum.SortOrder.LayoutOrder
	lpLayout.Padding = UDim.new(0, 2)
	lpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local lpPadding = Instance.new("UIPadding", LeftPanel)
	lpPadding.PaddingTop = UDim.new(0, 4)
	lpPadding.PaddingBottom = UDim.new(0, 4)
	lpPadding.PaddingLeft = UDim.new(0, 4)
	lpPadding.PaddingRight = UDim.new(0, 4)

	NeverLose.CurrentBindMenu = LeftPanel

	local activeSelectedBind = nil
	local selectedRowRef = nil

	-- 2. Right Sub-Panel Builder
	local function openSubPanel(bind, bindRow)
		if NeverLose.CurrentBindSubmenu then
			pcall(function() NeverLose.CurrentBindSubmenu:Destroy() end)
			NeverLose.CurrentBindSubmenu = nil
		end

		activeSelectedBind = bind
		selectedRowRef = bindRow

		for _, child in ipairs(LeftPanel:GetChildren()) do
			if child:IsA("TextButton") and string.sub(child.Name, 1, 5) == "Bind_" then
				child.BackgroundTransparency = (child == bindRow) and 0.3 or 1
			end
		end

		local SubPanel = Instance.new("Frame")
		SubPanel.Name = "NeverLose_BindSubmenu"
		SubPanel.Parent = parentGui
		SubPanel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
		SubPanel.BackgroundTransparency = 0.05
		SubPanel.BorderSizePixel = 0
		SubPanel.Size = UDim2.new(0, 168, 0, (elementType == "Slider") and 152 or 126)
		SubPanel.ZIndex = 325

		local spCorner = Instance.new("UICorner", SubPanel)
		spCorner.CornerRadius = UDim.new(0, 8)

		local spStroke = Instance.new("UIStroke", SubPanel)
		spStroke.Color = Color3.fromRGB(42, 46, 58)
		spStroke.Thickness = 1
		spStroke.Transparency = 0.35

		local spShadow = NeverLose:CreateShadow(SubPanel)

		local lpX = (LeftPanel.Position and LeftPanel.Position.X.Offset > 0) and LeftPanel.Position.X.Offset or LeftPanel.AbsolutePosition.X
		local lpY = (LeftPanel.Position and LeftPanel.Position.Y.Offset > 0) and LeftPanel.Position.Y.Offset or LeftPanel.AbsolutePosition.Y
		local subX = lpX + 138 + 6
		local subY = lpY
		if subX + 172 > scrSize.X then
			subX = lpX - 174
		end
		SubPanel.Position = UDim2.fromOffset(subX, subY)

		local spLayout = Instance.new("UIListLayout", SubPanel)
		spLayout.SortOrder = Enum.SortOrder.LayoutOrder
		spLayout.Padding = UDim.new(0, 3)
		spLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local spPadding = Instance.new("UIPadding", SubPanel)
		spPadding.PaddingTop = UDim.new(0, 5)
		spPadding.PaddingBottom = UDim.new(0, 5)
		spPadding.PaddingLeft = UDim.new(0, 6)
		spPadding.PaddingRight = UDim.new(0, 6)

		NeverLose.CurrentBindSubmenu = SubPanel

		-- Row 1: Key Row
		local keyRow = Instance.new("Frame", SubPanel)
		keyRow.Name = "KeyRow"
		keyRow.BackgroundTransparency = 1
		keyRow.Size = UDim2.new(1, 0, 0, 22)
		keyRow.ZIndex = 326

		local keyIcon = Instance.new("TextLabel", keyRow)
		keyIcon.BackgroundTransparency = 1
		keyIcon.Position = UDim2.new(0, 2, 0.5, 0)
		keyIcon.AnchorPoint = Vector2.new(0, 0.5)
		keyIcon.Size = UDim2.new(0, 14, 0, 14)
		keyIcon.FontFace = NeverLose.BuiltInBold
		keyIcon.Text = "key"
		keyIcon.TextColor3 = Color3.fromRGB(160, 165, 180)
		keyIcon.TextSize = 12
		keyIcon.ZIndex = 327

		local keyLbl = Instance.new("TextLabel", keyRow)
		keyLbl.BackgroundTransparency = 1
		keyLbl.Position = UDim2.new(0, 20, 0.5, 0)
		keyLbl.AnchorPoint = Vector2.new(0, 0.5)
		keyLbl.Size = UDim2.new(0, 60, 1, 0)
		keyLbl.Font = Enum.Font.GothamMedium
		keyLbl.Text = "Key"
		keyLbl.TextColor3 = Color3.fromRGB(220, 225, 235)
		keyLbl.TextSize = 11
		keyLbl.TextXAlignment = Enum.TextXAlignment.Left
		keyLbl.ZIndex = 327

		local keyBtn = Instance.new("TextButton", keyRow)
		keyBtn.Name = "KeyBtn"
		keyBtn.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
		keyBtn.Position = UDim2.new(1, 0, 0.5, 0)
		keyBtn.AnchorPoint = Vector2.new(1, 0.5)
		keyBtn.Size = UDim2.new(0, 58, 0, 18)
		keyBtn.Font = Enum.Font.GothamMedium
		keyBtn.Text = bind.Key or "None"
		keyBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
		keyBtn.TextSize = 11
		keyBtn.ZIndex = 327

		local kbCorner = Instance.new("UICorner", keyBtn)
		kbCorner.CornerRadius = UDim.new(0, 4)

		local kbStroke = Instance.new("UIStroke", keyBtn)
		kbStroke.Color = Color3.fromRGB(48, 54, 70)
		kbStroke.Thickness = 1
		kbStroke.Transparency = 0.4

		keyBtn.MouseButton1Click:Connect(function()
			if NeverLose.IsRebindingKey then return end
			NeverLose.IsRebindingKey = true
			keyBtn.Text = "..."
			keyBtn.TextColor3 = NeverLose.AccentColor

			local rebCon
			rebCon = UserInputService.InputBegan:Connect(function(inp)
				if inp.KeyCode == Enum.KeyCode.Escape or inp.KeyCode == Enum.KeyCode.Delete then
					rebCon:Disconnect()
					NeverLose.IsRebindingKey = false
					bind.Key = "None"
					keyBtn.Text = "None"
					keyBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
					syncBind(bind)
					if bindRow and bindRow:FindFirstChild("BindKeyLabel") then
						bindRow.BindKeyLabel.Text = "None"
					end
					return
				end

				local k = getReadableKey(inp)
				if k then
					rebCon:Disconnect()
					NeverLose.IsRebindingKey = false
					bind.Key = k
					keyBtn.Text = k
					keyBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
					syncBind(bind)
					if bindRow and bindRow:FindFirstChild("BindKeyLabel") then
						bindRow.BindKeyLabel.Text = k
					end
				end
			end)
		end)

		-- Row 2: Mode Row
		local modeRow = Instance.new("Frame", SubPanel)
		modeRow.Name = "ModeRow"
		modeRow.BackgroundTransparency = 1
		modeRow.Size = UDim2.new(1, 0, 0, 22)
		modeRow.ZIndex = 326

		local modeIcon = Instance.new("TextLabel", modeRow)
		modeIcon.BackgroundTransparency = 1
		modeIcon.Position = UDim2.new(0, 2, 0.5, 0)
		modeIcon.AnchorPoint = Vector2.new(0, 0.5)
		modeIcon.Size = UDim2.new(0, 14, 0, 14)
		modeIcon.FontFace = NeverLose.BuiltInBold
		modeIcon.Text = "gear"
		modeIcon.TextColor3 = Color3.fromRGB(160, 165, 180)
		modeIcon.TextSize = 12
		modeIcon.ZIndex = 327

		local modeLbl = Instance.new("TextLabel", modeRow)
		modeLbl.BackgroundTransparency = 1
		modeLbl.Position = UDim2.new(0, 20, 0.5, 0)
		modeLbl.AnchorPoint = Vector2.new(0, 0.5)
		modeLbl.Size = UDim2.new(0, 50, 1, 0)
		modeLbl.Font = Enum.Font.GothamMedium
		modeLbl.Text = "Mode"
		modeLbl.TextColor3 = Color3.fromRGB(220, 225, 235)
		modeLbl.TextSize = 11
		modeLbl.TextXAlignment = Enum.TextXAlignment.Left
		modeLbl.ZIndex = 327

		local modeBtn = Instance.new("TextButton", modeRow)
		modeBtn.Name = "ModeBtn"
		modeBtn.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
		modeBtn.Position = UDim2.new(1, 0, 0.5, 0)
		modeBtn.AnchorPoint = Vector2.new(1, 0.5)
		modeBtn.Size = UDim2.new(0, 68, 0, 18)
		modeBtn.Font = Enum.Font.GothamMedium
		modeBtn.Text = bind.Mode or "Toggle"
		modeBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
		modeBtn.TextSize = 11
		modeBtn.ZIndex = 327

		local mbCorner = Instance.new("UICorner", modeBtn)
		mbCorner.CornerRadius = UDim.new(0, 4)

		local mbStroke = Instance.new("UIStroke", modeBtn)
		mbStroke.Color = Color3.fromRGB(48, 54, 70)
		mbStroke.Thickness = 1
		mbStroke.Transparency = 0.4

		modeBtn.MouseButton1Click:Connect(function()
			local current = bind.Mode or (elementType == "Slider" and "Hold" or "Toggle")
			local nextMode = "Toggle"
			if elementType == "Slider" then
				if current == "Toggle" then
					nextMode = "Hold"
				else
					nextMode = "Toggle"
				end
			else
				if current == "Toggle" then
					nextMode = "Hold"
				elseif current == "Hold" then
					nextMode = "Always On"
				else
					nextMode = "Toggle"
				end
			end
			bind.Mode = nextMode
			modeBtn.Text = nextMode
			if nextMode == "Always On" then
				bind.Active = true
				if bind.Callback then pcall(bind.Callback, true) end
			end
			syncBind(bind)
		end)

		-- Row 2.5: Override Value Row for Sliders
		if elementType == "Slider" then
			bind.TargetValue = bind.TargetValue or math.clamp(math.floor(((Config.Min or 0) + (Config.Max or 100)) / 2), Config.Min or 0, Config.Max or 100)

			local valRow = Instance.new("Frame", SubPanel)
			valRow.Name = "ValueRow"
			valRow.BackgroundTransparency = 1
			valRow.Size = UDim2.new(1, 0, 0, 22)
			valRow.ZIndex = 326

			local valIcon = Instance.new("TextLabel", valRow)
			valIcon.BackgroundTransparency = 1
			valIcon.Position = UDim2.new(0, 2, 0.5, 0)
			valIcon.AnchorPoint = Vector2.new(0, 0.5)
			valIcon.Size = UDim2.new(0, 14, 0, 14)
			valIcon.FontFace = NeverLose.BuiltInBold
			valIcon.Text = "four-bars-horizontal-center-aligned"
			valIcon.TextColor3 = Color3.fromRGB(160, 165, 180)
			valIcon.TextSize = 12
			valIcon.ZIndex = 327

			local valLbl = Instance.new("TextLabel", valRow)
			valLbl.BackgroundTransparency = 1
			valLbl.Position = UDim2.new(0, 20, 0.5, 0)
			valLbl.AnchorPoint = Vector2.new(0, 0.5)
			valLbl.Size = UDim2.new(0, 50, 1, 0)
			valLbl.Font = Enum.Font.GothamMedium
			valLbl.Text = "Value"
			valLbl.TextColor3 = Color3.fromRGB(220, 225, 235)
			valLbl.TextSize = 11
			valLbl.TextXAlignment = Enum.TextXAlignment.Left
			valLbl.ZIndex = 327

			local valBox = Instance.new("TextBox", valRow)
			valBox.Name = "ValueBox"
			valBox.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
			valBox.Position = UDim2.new(1, 0, 0.5, 0)
			valBox.AnchorPoint = Vector2.new(1, 0.5)
			valBox.Size = UDim2.new(0, 68, 0, 18)
			valBox.Font = Enum.Font.GothamMedium
			valBox.Text = tostring(bind.TargetValue) .. tostring(Config.Type or "")
			valBox.TextColor3 = Color3.fromRGB(220, 225, 235)
			valBox.TextSize = 11
			valBox.ClearTextOnFocus = false
			valBox.ZIndex = 327

			local vbCorner = Instance.new("UICorner", valBox)
			vbCorner.CornerRadius = UDim.new(0, 4)

			local vbStroke = Instance.new("UIStroke", valBox)
			vbStroke.Color = Color3.fromRGB(48, 54, 70)
			vbStroke.Thickness = 1
			vbStroke.Transparency = 0.4

			valBox.FocusLost:Connect(function()
				local rawNum = tonumber(string.match(valBox.Text, "%-?%d+%.?%d*"))
				if rawNum then
					local clamped = math.clamp(rawNum, Config.Min or 0, Config.Max or 100)
					bind.TargetValue = clamped
					valBox.Text = tostring(clamped) .. tostring(Config.Type or "")
					if bind.Active then
						elementLib:SetValue(clamped)
					end
				else
					valBox.Text = tostring(bind.TargetValue) .. tostring(Config.Type or "")
				end
			end)
		end

		-- Row 3: Visible Row (Animated Mini Toggle Switch)
		local visRow = Instance.new("Frame", SubPanel)
		visRow.Name = "VisibleRow"
		visRow.BackgroundTransparency = 1
		visRow.Size = UDim2.new(1, 0, 0, 22)
		visRow.ZIndex = 326

		local visIcon = Instance.new("TextLabel", visRow)
		visIcon.BackgroundTransparency = 1
		visIcon.Position = UDim2.new(0, 2, 0.5, 0)
		visIcon.AnchorPoint = Vector2.new(0, 0.5)
		visIcon.Size = UDim2.new(0, 14, 0, 14)
		visIcon.FontFace = NeverLose.BuiltInBold
		visIcon.Text = "eye"
		visIcon.TextColor3 = Color3.fromRGB(160, 165, 180)
		visIcon.TextSize = 12
		visIcon.ZIndex = 327

		local visLbl = Instance.new("TextLabel", visRow)
		visLbl.BackgroundTransparency = 1
		visLbl.Position = UDim2.new(0, 20, 0.5, 0)
		visLbl.AnchorPoint = Vector2.new(0, 0.5)
		visLbl.Size = UDim2.new(0, 60, 1, 0)
		visLbl.Font = Enum.Font.GothamMedium
		visLbl.Text = "Visible"
		visLbl.TextColor3 = Color3.fromRGB(220, 225, 235)
		visLbl.TextSize = 11
		visLbl.TextXAlignment = Enum.TextXAlignment.Left
		visLbl.ZIndex = 327

		local visSwitch = Instance.new("Frame", visRow)
		visSwitch.Name = "VisSwitch"
		visSwitch.Position = UDim2.new(1, 0, 0.5, 0)
		visSwitch.AnchorPoint = Vector2.new(1, 0.5)
		visSwitch.Size = UDim2.new(0, 26, 0, 14)
		visSwitch.BackgroundColor3 = (bind.Visible ~= false) and NeverLose.AccentColor or Color3.fromRGB(38, 42, 54)
		visSwitch.ZIndex = 327

		local vsCorner = Instance.new("UICorner", visSwitch)
		vsCorner.CornerRadius = UDim.new(1, 0)

		local visKnob = Instance.new("Frame", visSwitch)
		visKnob.Name = "Knob"
		visKnob.Position = (bind.Visible ~= false) and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		visKnob.AnchorPoint = Vector2.new(0, 0.5)
		visKnob.Size = UDim2.new(0, 10, 0, 10)
		visKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		visKnob.ZIndex = 328

		local vkCorner = Instance.new("UICorner", visKnob)
		vkCorner.CornerRadius = UDim.new(1, 0)

		local visBtn = Instance.new("TextButton", visRow)
		visBtn.BackgroundTransparency = 1
		visBtn.Position = visSwitch.Position
		visBtn.AnchorPoint = visSwitch.AnchorPoint
		visBtn.Size = visSwitch.Size
		visBtn.Text = ""
		visBtn.ZIndex = 329

		visBtn.MouseButton1Click:Connect(function()
			bind.Visible = not (bind.Visible ~= false)
			if bind.Visible then
				TweenService:Create(visSwitch, FastTween, { BackgroundColor3 = NeverLose.AccentColor }):Play()
				TweenService:Create(visKnob, FastTween, { Position = UDim2.new(1, -12, 0.5, 0) }):Play()
			else
				TweenService:Create(visSwitch, FastTween, { BackgroundColor3 = Color3.fromRGB(38, 42, 54) }):Play()
				TweenService:Create(visKnob, FastTween, { Position = UDim2.new(0, 2, 0.5, 0) }):Play()
			end
			syncBind(bind)
		end)

		-- Row 4: Separator Divider
		local div = Instance.new("Frame", SubPanel)
		div.Name = "Divider"
		div.BackgroundColor3 = Color3.fromRGB(42, 46, 58)
		div.BackgroundTransparency = 0.5
		div.BorderSizePixel = 0
		div.Size = UDim2.new(1, 0, 0, 1)
		div.ZIndex = 326

		-- Row 5: Delete Row
		local delRow = Instance.new("TextButton", SubPanel)
		delRow.Name = "DeleteRow"
		delRow.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
		delRow.BackgroundTransparency = 1
		delRow.Size = UDim2.new(1, 0, 0, 22)
		delRow.Text = ""
		delRow.ZIndex = 326

		local drCorner = Instance.new("UICorner", delRow)
		drCorner.CornerRadius = UDim.new(0, 4)

		local delIcon = Instance.new("TextLabel", delRow)
		delIcon.BackgroundTransparency = 1
		delIcon.Position = UDim2.new(0, 2, 0.5, 0)
		delIcon.AnchorPoint = Vector2.new(0, 0.5)
		delIcon.Size = UDim2.new(0, 14, 0, 14)
		delIcon.FontFace = NeverLose.BuiltInBold
		delIcon.Text = "trash-can"
		delIcon.TextColor3 = Color3.fromRGB(240, 75, 75)
		delIcon.TextSize = 12
		delIcon.ZIndex = 327

		local delLbl = Instance.new("TextLabel", delRow)
		delLbl.BackgroundTransparency = 1
		delLbl.Position = UDim2.new(0, 20, 0.5, 0)
		delLbl.AnchorPoint = Vector2.new(0, 0.5)
		delLbl.Size = UDim2.new(1, -24, 1, 0)
		delLbl.Font = Enum.Font.GothamMedium
		delLbl.Text = "Delete"
		delLbl.TextColor3 = Color3.fromRGB(240, 75, 75)
		delLbl.TextSize = 11
		delLbl.TextXAlignment = Enum.TextXAlignment.Left
		delLbl.ZIndex = 327

		delRow.MouseEnter:Connect(function()
			delRow.BackgroundTransparency = 0.4
			delRow.BackgroundColor3 = Color3.fromRGB(38, 20, 26)
		end)
		delRow.MouseLeave:Connect(function()
			delRow.BackgroundTransparency = 1
		end)

		delRow.MouseButton1Click:Connect(function()
			if bind.Active and elementType == "Slider" then
				elementLib:SetValue(bind.PreviousNormalValue or Config.Default or Config.Min or 0)
			end
			-- Remove this bind
			for i, b in ipairs(elementLib.Binds) do
				if b == bind or b.Id == bind.Id then
					table.remove(elementLib.Binds, i)
					break
				end
			end
			NeverLose.RegisteredHotkeys[bind.Id] = nil
			if SubPanel and SubPanel.Parent then SubPanel:Destroy() end
			NeverLose.CurrentBindSubmenu = nil
			NeverLose:UpdateHotkeysHUD()
			rebuildLeftPanel()
		end)
	end

	-- 3. Left Panel Rebuilder
	function rebuildLeftPanel()
		for _, c in ipairs(LeftPanel:GetChildren()) do
			if c:IsA("TextButton") or c:IsA("Frame") then
				c:Destroy()
			end
		end

		-- Existing binds
		for _, b in ipairs(elementLib.Binds) do
			local bRow = Instance.new("TextButton", LeftPanel)
			bRow.Name = "Bind_" .. tostring(b.Id)
			bRow.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
			bRow.BackgroundTransparency = (activeSelectedBind == b) and 0.3 or 1
			bRow.Size = UDim2.new(1, 0, 0, 22)
			bRow.Text = ""
			bRow.ZIndex = 321

			local brCorner = Instance.new("UICorner", bRow)
			brCorner.CornerRadius = UDim.new(0, 4)

			local bIcon = Instance.new("TextLabel", bRow)
			bIcon.BackgroundTransparency = 1
			bIcon.Position = UDim2.new(0, 4, 0.5, 0)
			bIcon.AnchorPoint = Vector2.new(0, 0.5)
			bIcon.Size = UDim2.new(0, 14, 0, 14)
			bIcon.FontFace = NeverLose.BuiltInBold
			bIcon.Text = "key"
			bIcon.TextColor3 = Color3.fromRGB(160, 165, 180)
			bIcon.TextSize = 12
			bIcon.ZIndex = 322

			local bLbl = Instance.new("TextLabel", bRow)
			bLbl.Name = "BindKeyLabel"
			bLbl.BackgroundTransparency = 1
			bLbl.Position = UDim2.new(0, 22, 0.5, 0)
			bLbl.AnchorPoint = Vector2.new(0, 0.5)
			bLbl.Size = UDim2.new(1, -40, 1, 0)
			bLbl.Font = Enum.Font.GothamMedium
			bLbl.Text = b.Key or "None"
			bLbl.TextColor3 = Color3.fromRGB(220, 225, 235)
			bLbl.TextSize = 11
			bLbl.TextXAlignment = Enum.TextXAlignment.Left
			bLbl.ZIndex = 322

			local bChevron = Instance.new("TextLabel", bRow)
			bChevron.BackgroundTransparency = 1
			bChevron.Position = UDim2.new(1, -4, 0.5, 0)
			bChevron.AnchorPoint = Vector2.new(1, 0.5)
			bChevron.Size = UDim2.new(0, 12, 0, 12)
			bChevron.FontFace = NeverLose.BuiltInBold
			bChevron.Text = "chevron-small-right"
			bChevron.TextColor3 = Color3.fromRGB(140, 145, 160)
			bChevron.TextSize = 12
			bChevron.ZIndex = 322

			bRow.MouseEnter:Connect(function()
				bRow.BackgroundTransparency = 0.4
			end)
			bRow.MouseLeave:Connect(function()
				bRow.BackgroundTransparency = (activeSelectedBind == b) and 0.3 or 1
			end)

			bRow.MouseButton1Click:Connect(function()
				openSubPanel(b, bRow)
			end)
		end

		-- + New Bind Row (strictly at most 1 bind allowed per function)
		if #elementLib.Binds == 0 then
			local newRow = Instance.new("TextButton", LeftPanel)
			newRow.Name = "NewBindRow"
			newRow.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
			newRow.BackgroundTransparency = 1
			newRow.Size = UDim2.new(1, 0, 0, 22)
			newRow.Text = ""
			newRow.ZIndex = 321

			local nrCorner = Instance.new("UICorner", newRow)
			nrCorner.CornerRadius = UDim.new(0, 4)

			local plusIcon = Instance.new("TextLabel", newRow)
			plusIcon.BackgroundTransparency = 1
			plusIcon.Position = UDim2.new(0, 4, 0.5, 0)
			plusIcon.AnchorPoint = Vector2.new(0, 0.5)
			plusIcon.Size = UDim2.new(0, 14, 0, 14)
			plusIcon.FontFace = NeverLose.BuiltInBold
			plusIcon.Text = "plus-small"
			plusIcon.TextColor3 = NeverLose.AccentColor
			plusIcon.TextSize = 13
			plusIcon.ZIndex = 322

			local nrLbl = Instance.new("TextLabel", newRow)
			nrLbl.BackgroundTransparency = 1
			nrLbl.Position = UDim2.new(0, 22, 0.5, 0)
			nrLbl.AnchorPoint = Vector2.new(0, 0.5)
			nrLbl.Size = UDim2.new(1, -26, 1, 0)
			nrLbl.Font = Enum.Font.GothamMedium
			nrLbl.Text = "New Bind"
			nrLbl.TextColor3 = Color3.fromRGB(210, 215, 230)
			nrLbl.TextSize = 11
			nrLbl.TextXAlignment = Enum.TextXAlignment.Left
			nrLbl.ZIndex = 322

			newRow.MouseEnter:Connect(function()
				newRow.BackgroundTransparency = 0.4
				nrLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
			newRow.MouseLeave:Connect(function()
				newRow.BackgroundTransparency = 1
				nrLbl.TextColor3 = Color3.fromRGB(210, 215, 230)
			end)

			newRow.MouseButton1Click:Connect(function()
				local newBind = {
					Id = NeverLose.RandomString(),
					Key = "None",
					Mode = (elementType == "Slider") and "Hold" or "Toggle",
					Visible = true,
					Active = false,
					TargetValue = (elementType == "Slider") and math.clamp(math.floor(((Config.Min or 0) + (Config.Max or 100)) / 2), Config.Min or 0, Config.Max or 100) or nil,
					Name = Config.Name or "Feature"
				}
				table.insert(elementLib.Binds, newBind)
				syncBind(newBind)
				rebuildLeftPanel()
				-- Immediately open subpanel for this new bind
				local createdRow = LeftPanel:FindFirstChild("Bind_" .. tostring(newBind.Id))
				if createdRow then
					openSubPanel(newBind, createdRow)
				end
			end)
		end

		-- Reset Row
		local resetRow = Instance.new("TextButton", LeftPanel)
		resetRow.Name = "ResetRow"
		resetRow.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
		resetRow.BackgroundTransparency = 1
		resetRow.Size = UDim2.new(1, 0, 0, 22)
		resetRow.Text = ""
		resetRow.ZIndex = 321

		local rrCorner = Instance.new("UICorner", resetRow)
		rrCorner.CornerRadius = UDim.new(0, 4)

		local resetIcon = Instance.new("TextLabel", resetRow)
		resetIcon.BackgroundTransparency = 1
		resetIcon.Position = UDim2.new(0, 4, 0.5, 0)
		resetIcon.AnchorPoint = Vector2.new(0, 0.5)
		resetIcon.Size = UDim2.new(0, 14, 0, 14)
		resetIcon.FontFace = NeverLose.BuiltInBold
		resetIcon.Text = "clock-spin-reverse"
		resetIcon.TextColor3 = Color3.fromRGB(235, 95, 60)
		resetIcon.TextSize = 12
		resetIcon.ZIndex = 322

		local rrLbl = Instance.new("TextLabel", resetRow)
		rrLbl.BackgroundTransparency = 1
		rrLbl.Position = UDim2.new(0, 22, 0.5, 0)
		rrLbl.AnchorPoint = Vector2.new(0, 0.5)
		rrLbl.Size = UDim2.new(1, -26, 1, 0)
		rrLbl.Font = Enum.Font.GothamMedium
		rrLbl.Text = "Reset"
		rrLbl.TextColor3 = Color3.fromRGB(210, 215, 230)
		rrLbl.TextSize = 11
		rrLbl.TextXAlignment = Enum.TextXAlignment.Left
		rrLbl.ZIndex = 322

		resetRow.MouseEnter:Connect(function()
			resetRow.BackgroundTransparency = 0.4
			rrLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		resetRow.MouseLeave:Connect(function()
			resetRow.BackgroundTransparency = 1
			rrLbl.TextColor3 = Color3.fromRGB(210, 215, 230)
		end)

		resetRow.MouseButton1Click:Connect(function()
			if elementType == "Toggle" then
				elementLib:SetValue(Config.Default or false)
			elseif elementType == "Slider" then
				elementLib:SetValue(Config.Default or Config.Min or 0)
			end
			for _, b in ipairs(elementLib.Binds) do
				NeverLose.RegisteredHotkeys[b.Id] = nil
			end
			elementLib.Binds = {}
			if LeftPanel and LeftPanel.Parent then LeftPanel:Destroy() end
			if NeverLose.CurrentBindSubmenu and NeverLose.CurrentBindSubmenu.Parent then
				NeverLose.CurrentBindSubmenu:Destroy()
			end
			NeverLose.CurrentBindMenu = nil
			NeverLose.CurrentBindSubmenu = nil
			NeverLose:UpdateHotkeysHUD()
		end)

		-- Update size of left panel dynamically
		task.defer(function()
			if LeftPanel and LeftPanel.Parent then
				local totalY = 8
				for _, c in ipairs(LeftPanel:GetChildren()) do
					if c:IsA("TextButton") then
						totalY = totalY + c.AbsoluteSize.Y + 2
					end
				end
				LeftPanel.Size = UDim2.new(0, 138, 0, math.max(30, totalY))
			end
		end)
	end

	rebuildLeftPanel()

	if #elementLib.Binds > 0 then
		local firstBind = elementLib.Binds[1]
		local firstRow = LeftPanel:FindFirstChild("Bind_" .. tostring(firstBind.Id))
		if firstRow then
			openSubPanel(firstBind, firstRow)
		end
	end

	-- Auto-close when clicking outside both LeftPanel and SubPanel
	task.delay(0.12, function()
		local closeCon
		closeCon = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
				if NeverLose.IsRebindingKey then return end
				local mPos = input.Position
				local inLeft = false
				local inSub = false
				if LeftPanel and LeftPanel.Parent then
					local lx, ly = LeftPanel.AbsolutePosition.X, LeftPanel.AbsolutePosition.Y
					local lw, lh = LeftPanel.AbsoluteSize.X, LeftPanel.AbsoluteSize.Y
					if mPos.X >= lx and mPos.X <= lx + lw and mPos.Y >= ly and mPos.Y <= ly + lh then
						inLeft = true
					end
				end
				local sub = NeverLose.CurrentBindSubmenu
				if sub and sub.Parent then
					local sx, sy = sub.AbsolutePosition.X, sub.AbsolutePosition.Y
					local sw, sh = sub.AbsoluteSize.X, sub.AbsoluteSize.Y
					if mPos.X >= sx and mPos.X <= sx + sw and mPos.Y >= sy and mPos.Y <= sy + sh then
						inSub = true
					end
				end
				if not inLeft and not inSub then
					closeCon:Disconnect()
					if LeftPanel and LeftPanel.Parent then LeftPanel:Destroy() end
					if sub and sub.Parent then sub:Destroy() end
					NeverLose.CurrentBindMenu = nil
					NeverLose.CurrentBindSubmenu = nil
				end
			end
		end)
	end)
end

-- Backward compatible wrapper
function NeverLose:OpenKeybindMenu(KeybindFrame, Config, KeybindLib)
	NeverLose:OpenElementBindMenu(KeybindFrame, Config, KeybindLib, "Keybind")
end


function NeverLose:RegisiterHandler(Handler: Frame , Signal)
	local handle = {};
	local ZINdex = Handler.ZIndex;

	function handle:AddToggle(Config)
		Config = NeverLose:ProcessParams(Config , {
			Default = false,
			Flag = nil,
			Callback = EmptyFunction,
		});

		local Toggle = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local Circle = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")

		Toggle.Name = NeverLose.RandomString();
		Toggle.Parent = Handler
		Toggle.BackgroundColor3 = Color3.fromRGB(10, 13, 21)
		Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Toggle.BorderSizePixel = 0
		Toggle.ClipsDescendants = true
		Toggle.Size = UDim2.new(0, 30, 0, 18)
		Toggle.ZIndex = ZINdex + 13
		Toggle.LayoutOrder = -(#Handler:GetChildren() + 5);

		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = Toggle

		Circle.Name = NeverLose.RandomString();
		Circle.Parent = Toggle
		Circle.AnchorPoint = Vector2.new(0.5, 0.5)
		Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Circle.BackgroundTransparency = 0.500
		Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Circle.BorderSizePixel = 0
		Circle.Position = UDim2.new(0.300000012, 0, 0.5, 0)
		Circle.Size = UDim2.new(0, 16, 0, 16)
		Circle.ZIndex = ZINdex + 14

		UICorner_2.CornerRadius = UDim.new(1, 0)
		UICorner_2.Parent = Circle

		local ToggleLib = {
			Root = Toggle	
		};

		ToggleLib.SetUI = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(Toggle,SlowyTween,{
					BackgroundTransparency = 0,
					BackgroundColor3 = NeverLose.AccentColor
				})

				NeverLose.PlayAnimate(Circle,SlowyTween,{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0,
					Position = UDim2.new(0.7, 0, 0.5, 0)
				})
			else
				NeverLose.PlayAnimate(Toggle,SlowyTween,{
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.fromRGB(10, 13, 21)
				})

				NeverLose.PlayAnimate(Circle,SlowyTween,{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.500,
					Position = UDim2.new(0.300000012, 0, 0.5, 0)
				})
			end;
		end);

		ToggleLib.SetVisible = LPH_NO_VIRTUALIZE(function(value)
			if value then
				ToggleLib.SetUI(Config.Default);
			else
				NeverLose.PlayAnimate(Toggle,SlowyTween,{
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(10, 13, 21)
				})

				NeverLose.PlayAnimate(Circle,SlowyTween,{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.300000012, 0, 0.5, 0)
				})
			end;
		end);

		ToggleLib.SetUI(Config.Default);
		ToggleLib.SetVisible(Signal:GetValue());

		NeverLose:RegisterToggleAccent(function(col)
			if Config.Default and Toggle and Toggle.Parent then
				NeverLose.PlayAnimate(Toggle, SlowyTween, {
					BackgroundColor3 = col
				})
			end
		end);

		NeverLose:CreateInput(Toggle , LPH_NO_VIRTUALIZE(function()
			Config.Default = not Config.Default;

			ToggleLib.SetUI(Config.Default);

			if ToggleLib.Binds then
				for _, b in ipairs(ToggleLib.Binds) do
					b.Active = Config.Default;
					if NeverLose.RegisteredHotkeys[b.Id] then
						NeverLose.RegisteredHotkeys[b.Id].Active = Config.Default;
					end;
				end;
				NeverLose:UpdateHotkeysHUD();
			end;

			Config.Callback(Config.Default)
		end), function()
			NeverLose:OpenElementBindMenu(Toggle, Config, ToggleLib, "Toggle");
		end)

		Toggle.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton2 then
				NeverLose:OpenElementBindMenu(Toggle, Config, ToggleLib, "Toggle");
			end;
		end);

		ToggleLib.Signal = Signal:Connect(ToggleLib.SetVisible);

		function ToggleLib:GetValue()
			return Config.Default;
		end;

		function ToggleLib:SetValue(v)
			Config.Default = v;

			if Signal:GetValue() then
				ToggleLib.SetUI(Config.Default);
			end;

			if ToggleLib.Binds then
				for _, b in ipairs(ToggleLib.Binds) do
					b.Active = v;
					if NeverLose.RegisteredHotkeys[b.Id] then
						NeverLose.RegisteredHotkeys[b.Id].Active = v;
					end;
				end;
				NeverLose:UpdateHotkeysHUD();
			end;

			Config.Callback(Config.Default)
		end;

		if Config.Flag then
			NeverLose.Flags[Config.Flag] = ToggleLib;
		end;

		return ToggleLib;
	end;

	function handle:AddSlider(Config)
		Config = NeverLose:ProcessParams(Config , {
			Default = 50,
			Min = 0,
			Max = 10,
			Type = "",
			Rounding = 0,
			Nums = {},
			Flag = nil,
			Size = 125,
			Callback = EmptyFunction,
		});

		local SliderLib = {};

		SliderLib.GetSize = LPH_NO_VIRTUALIZE(function()
			return math.clamp((Config.Default - Config.Min) / (Config.Max - Config.Min), 0, 1);
		end);

		local FullNumSize = TextService:GetTextSize(string.rep("0",(Config.Rounding + #tostring(Config.Max))+1)..tostring(Config.Type),10,Enum.Font.GothamMedium,Vector2.new(math.huge,math.huge));

		SliderLib.MaximumSize = FullNumSize.X;

		if Config.Nums then
			local nszie = 0;

			for i,ns in next , Config.Nums do
				local size = TextService:GetTextSize(string.rep("m",string.len(tostring(ns))),10,Enum.Font.GothamMedium,Vector2.new(math.huge,math.huge));

				if nszie < size.X then
					nszie = size.X;
				end
			end;

			if SliderLib.MaximumSize < nszie then
				SliderLib.MaximumSize = nszie;
			end;
		end;

		local Slider = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local ValueFrame = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local ValueLabel = Instance.new("TextBox")
		local SlideMain = Instance.new("Frame")
		local SlideFrame = Instance.new("Frame")
		local UICorner_3 = Instance.new("UICorner")
		local SlideMoving = Instance.new("Frame")
		local UICorner_4 = Instance.new("UICorner")
		local Frame = Instance.new("Frame")
		local UICorner_5 = Instance.new("UICorner")
		local boxSize = 2;

		Slider.Name = NeverLose.RandomString();
		Slider.Parent = Handler
		Slider.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
		Slider.BackgroundTransparency = 1.000
		Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Slider.BorderSizePixel = 0
		Slider.ClipsDescendants = false
		Slider.Size = UDim2.new(0, Config.Size, 0, 18)
		Slider.ZIndex = ZINdex + 13
		Slider.LayoutOrder = -(#Handler:GetChildren() + 5);

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = Slider

		ValueFrame.Name = NeverLose.RandomString();
		ValueFrame.Parent = Slider
		ValueFrame.AnchorPoint = Vector2.new(1, 0)
		ValueFrame.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
		ValueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueFrame.BorderSizePixel = 0
		ValueFrame.ClipsDescendants = true
		ValueFrame.Position = UDim2.new(1, 0, 0, 0)
		ValueFrame.Size = UDim2.new(0, SliderLib.MaximumSize + boxSize, 0, 18)
		ValueFrame.ZIndex = ZINdex + 13

		UICorner_2.CornerRadius = UDim.new(0, 4)
		UICorner_2.Parent = ValueFrame

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = ValueFrame

		ValueLabel.Name = NeverLose.RandomString();
		ValueLabel.Parent = ValueFrame
		ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ValueLabel.BackgroundTransparency = 1.000
		ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueLabel.BorderSizePixel = 0
		ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		ValueLabel.Size = UDim2.new(1, 0, 1, 0)
		ValueLabel.ZIndex = ZINdex + 14
		ValueLabel.Font = Enum.Font.GothamMedium
		ValueLabel.Text = tostring(Config.Default)..tostring(Config.Type);
		ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ValueLabel.TextSize = 10.000
		ValueLabel.ClearTextOnFocus = false;
		ValueLabel.TextTransparency = 0.350

		SlideMain.Name = NeverLose.RandomString();
		SlideMain.Parent = Slider
		SlideMain.AnchorPoint = Vector2.new(0, 0.5)
		SlideMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SlideMain.BackgroundTransparency = 1.000
		SlideMain.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SlideMain.BorderSizePixel = 0
		SlideMain.Position = UDim2.new(0, 0, 0.5, 0)
		SlideMain.Size = UDim2.new(1, -((SliderLib.MaximumSize + 11)), 0, 18)
		SlideMain.ZIndex = ZINdex + 13

		SlideFrame.Name = NeverLose.RandomString();
		SlideFrame.Parent = SlideMain
		SlideFrame.AnchorPoint = Vector2.new(0, 0.5)
		SlideFrame.BackgroundColor3 = Color3.fromRGB(30, 29, 36)
		SlideFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SlideFrame.BorderSizePixel = 0
		SlideFrame.Position = UDim2.new(0, 0, 0.5, 0)
		SlideFrame.Size = UDim2.new(1, 0, 0, 5)
		SlideFrame.ZIndex = ZINdex + 13

		UICorner_3.CornerRadius = UDim.new(1, 0)
		UICorner_3.Parent = SlideFrame

		SlideMoving.Name = NeverLose.RandomString();
		SlideMoving.Parent = SlideFrame
		SlideMoving.BackgroundColor3 = NeverLose.AccentColor
		NeverLose:RegisterAccent(SlideMoving, "BackgroundColor3");
		SlideMoving.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SlideMoving.BorderSizePixel = 0
		SlideMoving.Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0)
		SlideMoving.ZIndex = ZINdex + 14

		UICorner_4.CornerRadius = UDim.new(1, 0)
		UICorner_4.Parent = SlideMoving

		Frame.Parent = SlideMoving
		Frame.AnchorPoint = Vector2.new(1, 0.5)
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(1, 5, 0.5, 0)
		Frame.Size = UDim2.new(0, 10, 0, 10)
		Frame.ZIndex = ZINdex + 15

		UICorner_5.CornerRadius = UDim.new(1, 0)
		UICorner_5.Parent = Frame

		local LoadText = LPH_NO_VIRTUALIZE(function()
			if Config.Nums[Config.Default] then
				ValueLabel.Text = Config.Nums[Config.Default]

			else
				ValueLabel.Text = tostring(Config.Default)..tostring(Config.Type);

			end;
		end);

		ValueLabel.FocusLost:Connect(LPH_NO_VIRTUALIZE(function()
			local numStr = string.gsub(ValueLabel.Text, "[^%d%.%-]", "")
			local OutVal = tonumber(numStr) or NeverLose:ParseInput(ValueLabel.Text , true);
			if OutVal then
				local rx = math.clamp(OutVal , Config.Min , Config.Max);
				local Value = (Config.Rounding and Config.Rounding > 0) and NeverLose.Rounding(rx, Config.Rounding) or math.round(rx);

				if Value then
					Config.Default = Value;

					TweenService:Create(SlideMoving , ManualTween ,{
						Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0)
					}):Play();

					LoadText();

					Config.Callback(Config.Default)
				else
					LoadText();
				end;
			else
				LoadText()
			end;
		end));

		SliderLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(ValueFrame,SlowyTween,{
					BackgroundTransparency = 0,
					Size = UDim2.new(0, SliderLib.MaximumSize + boxSize, 0, 18)
				});

				NeverLose.PlayAnimate(UIStroke,SlowyTween,{
					Transparency = 0.650
				});

				NeverLose.PlayAnimate(ValueLabel,SlowyTween,{
					TextTransparency = 0.350
				});

				NeverLose.PlayAnimate(SlideFrame,SlowyTween,{
					BackgroundTransparency = 0
				});

				NeverLose.PlayAnimate(SlideMoving,SlowyTween,{
					BackgroundTransparency = 0,
					Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0)
				});

				NeverLose.PlayAnimate(Frame,SlowyTween,{
					BackgroundTransparency = 0
				});
			else
				NeverLose.PlayAnimate(ValueFrame,SlowyTween,{
					BackgroundTransparency = 1,
				});

				NeverLose.PlayAnimate(UIStroke,SlowyTween,{
					Transparency = 1
				});

				NeverLose.PlayAnimate(ValueLabel,SlowyTween,{
					TextTransparency = 1
				});

				NeverLose.PlayAnimate(SlideFrame,SlowyTween,{
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(SlideMoving,SlowyTween,{
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0)
				});

				NeverLose.PlayAnimate(Frame,SlowyTween,{
					BackgroundTransparency = 1
				});
			end;
		end);

		SliderLib.SetRender(Signal:GetValue());
		SliderLib.Signal = Signal:Connect(SliderLib.SetRender);

		local Update = function(Input)
			local SizeScale = math.clamp((((Input.Position.X) - SlideMain.AbsolutePosition.X) / SlideMain.AbsoluteSize.X), 0, 1);
			local Main = ((Config.Max - Config.Min) * SizeScale) + Config.Min;
			local Value = NeverLose.Rounding(Main,Config.Rounding);
			local PositionX = UDim2.fromScale(SizeScale, 1);
			local Size = ((Value - Config.Min) / (Config.Max - Config.Min)) + 0.02;

			Config.Default = Value;

			TweenService:Create(SlideMoving , ManualTween ,{
				Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0)
			}):Play();

			LoadText()


			Config.Callback(Value)
		end;

		local IsHold = false;

		do
			SlideMain.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					IsHold = true
					Update(Input)
				end
			end))

			SlideMain.InputEnded:Connect(LPH_NO_VIRTUALIZE(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					if UserInputService.TouchEnabled then
						if not NeverLose:IsMouseOverFrame(SlideMain) then
							IsHold = false
						end;
					else
						IsHold = false
					end;
				end
			end))

			UserInputService.InputChanged:Connect(LPH_NO_VIRTUALIZE(function(Input)
				if IsHold then
					if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)  then
						if UserInputService.TouchEnabled then
							if not NeverLose:IsMouseOverFrame(SlideMain) then
								IsHold = false
							else
								Update(Input)
							end;
						else
							Update(Input)
						end;
					end;
				end;
			end));
		end;

		SliderLib.Root = Slider;

		Slider.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton2 then
				NeverLose:OpenElementBindMenu(Slider, Config, SliderLib, "Slider");
			end;
		end);

		function SliderLib:GetValue()
			return Config.Default;
		end;

		function SliderLib:SetValue(v)
			Config.Default = v;

			if Signal:GetValue() then
				NeverLose.PlayAnimate(SlideMoving,SlowyTween,{
					BackgroundTransparency = 0,
					Size = UDim2.new(SliderLib.GetSize(), 0, 1, 0)
				});
			end;

			LoadText()

			if SliderLib.Binds then
				for _, b in ipairs(SliderLib.Binds) do
					if not b.Active then
						b.PreviousNormalValue = v;
					end
				end;
			end;

			Config.Callback(Config.Default);
		end;

		if Config.Flag then
			NeverLose.Flags[Config.Flag] = SliderLib;
		end;

		return SliderLib;
	end;

	function handle:AddOption(GearIcon)
		local Option = Instance.new("Frame")
		local Icon = Instance.new("TextLabel")
		local UICorner = Instance.new("UICorner")

		Option.Name = NeverLose.RandomString();
		Option.Parent = Handler
		Option.BackgroundColor3 = Color3.fromRGB(39, 40, 49)
		Option.BackgroundTransparency = 1.000
		Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Option.BorderSizePixel = 0
		Option.ClipsDescendants = true
		Option.Size = UDim2.new(0, 20, 0, 18)
		Option.ZIndex = ZINdex + 13
		Option.LayoutOrder = -(#Handler:GetChildren() + 5);

		Icon.Name = NeverLose.RandomString();
		Icon.Parent = Option
		Icon.AnchorPoint = Vector2.new(0.5, 0.5)
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		Icon.Size = UDim2.new(1, 0, 1, 0)
		Icon.ZIndex = ZINdex + 14
		Icon.FontFace = NeverLose.BuiltInBold
		Icon.Text = (GearIcon == 1 and 'gear') or (GearIcon == 2 and 'chevron-large-right') or "three-dots-horizontal";
		Icon.TextColor3 = Color3.fromRGB(223, 223, 223)
		Icon.TextSize = 16.000
		Icon.TextTransparency = 0.400
		Icon.TextWrapped = true

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = Option

		local Window = NeverLose:CreateOptionWindow(Option , ZINdex + 13);
		local reciveSignal;

		Window.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(Icon , SlowyTween , {
					TextTransparency = 0.400
				})
			else
				NeverLose.PlayAnimate(Icon , SlowyTween , {
					TextTransparency = 1
				})
			end;
		end);

		Window.SetRender(Signal:GetValue());
		Signal:Connect(Window.SetRender);

		local bthg = NeverLose:CreateInput(Option , LPH_NO_VIRTUALIZE(function()
			if reciveSignal then
				reciveSignal:Disconnect();
				reciveSignal = nil;	
			end;

			Window.Signal:SetValue(true);

			reciveSignal = UserInputService.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					if not NeverLose:IsMouseOverFrame(Window.Root) and not NeverLose:IsMouseOverFrame(Option) then
						if reciveSignal then
							reciveSignal:Disconnect();
							reciveSignal = nil;	
						end;

						Window.Signal:SetValue(false);
					end
				end
			end)
		end));

		NeverLose:AddSignal(bthg.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(Option , SlowyTween , {
				BackgroundTransparency = 0.5
			})

			NeverLose.PlayAnimate(Icon , SlowyTween , {
				TextTransparency = 0.25
			})
		end)));

		NeverLose:AddSignal(bthg.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(Option , SlowyTween , {
				BackgroundTransparency = 1.000
			})

			NeverLose.PlayAnimate(Icon , SlowyTween , {
				TextTransparency = 0.400
			})
		end)));

		return Window;
	end;

	function handle:AddColorPicker(Config)
		Config = NeverLose:ProcessParams(Config , {
			Default = Color3.fromRGB(255, 255, 255),
			Callback  = EmptyFunction,
		});

		if typeof(Config.Default) == 'string' then
			Config.Default = Color3.fromHex(Config.Default:gsub('#',''));
		end;

		local ColorPickerLib = {};
		local ColorPicker = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local ImageLabel = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")

		ColorPicker.Name = NeverLose.RandomString();
		ColorPicker.Parent = Handler
		ColorPicker.BackgroundColor3 = Config.Default;
		ColorPicker.BackgroundTransparency = 0
		ColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ColorPicker.BorderSizePixel = 0
		ColorPicker.ClipsDescendants = true
		ColorPicker.Size = UDim2.new(0, 18, 0, 18)
		ColorPicker.ZIndex = ZINdex + 13
		ColorPicker.LayoutOrder = -(#Handler:GetChildren() + 5);

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = ColorPicker

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = ColorPicker

		ImageLabel.Parent = ColorPicker
		ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ImageLabel.BorderSizePixel = 0
		ImageLabel.Size = UDim2.new(1, 0, 1, 0)
		ImageLabel.ZIndex = ZINdex + 11
		ImageLabel.Image = "rbxasset://textures/meshPartFallback.png"
		ImageLabel.ImageTransparency = 0.9
		ImageLabel.BackgroundTransparency = 1;
		ImageLabel.ScaleType = Enum.ScaleType.Crop

		UICorner_2.CornerRadius = UDim.new(0, 4)
		UICorner_2.Parent = ImageLabel

		local BackendM = NeverLose:CreateColorPicker(ColorPicker);

		BackendM:SetValue(Config.Default)
		BackendM.Callback = function(color)
			ColorPicker.BackgroundColor3 = color;
			Config.Default = color;
			Config.Callback(Config.Default);
		end;

		local signal;
		NeverLose:CreateInput(ColorPicker , LPH_NO_VIRTUALIZE(function()
			if signal then
				signal:Disconnect();
				signal = nil;
			end;

			BackendM.SetRender(true);

			signal = UserInputService.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					if not NeverLose:IsMouseOverFrame(ColorPicker) and not NeverLose:IsMouseOverFrame(BackendM.Root) then
						if signal then
							signal:Disconnect();
							signal = nil;
						end;

						BackendM.SetRender(false);
					end;
				end;
			end)
		end));

		ColorPickerLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(ColorPicker , SlowyTween , {
					BackgroundTransparency = 0
				})

				NeverLose.PlayAnimate(UIStroke , SlowyTween , {
					Transparency = 0.650
				})

				NeverLose.PlayAnimate(ImageLabel , SlowyTween , {
					ImageTransparency = 0.9
				})
			else
				NeverLose.PlayAnimate(ColorPicker , SlowyTween , {
					BackgroundTransparency = 1
				})

				NeverLose.PlayAnimate(UIStroke , SlowyTween , {
					Transparency = 1
				})

				NeverLose.PlayAnimate(ImageLabel , SlowyTween , {
					ImageTransparency = 1
				})
			end;
		end);

		ColorPickerLib.SetRender(Signal:GetValue());
		Signal:Connect(ColorPickerLib.SetRender);

		function ColorPickerLib:GetValue()
			return Config.Default;
		end;

		function ColorPickerLib:SetValue(v)
			Config.Default = v;
			BackendM:SetValue(Config.Default)
		end;

		if Config.Flag then
			NeverLose.Flags[Config.Flag] = ColorPickerLib;
		end;

		return ColorPickerLib;
	end;

	function handle:AddKeybind(Config)
		Config = NeverLose:ProcessParams(Config,{
			Default = nil,
			Blacklist = {},
			Callback = EmptyFunction,
			Flag = nil,
			Mode = "Toggle",
			Name = "Keybind"
		});

		local KeybindLib = {
			Mode = Config.Mode or "Toggle"
		};

		local Keybind = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local ValueLabel = Instance.new("TextLabel")

		Keybind.Name = NeverLose.RandomString();
		Keybind.Parent = Handler
		Keybind.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
		Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Keybind.BorderSizePixel = 0
		Keybind.ClipsDescendants = true
		Keybind.Size = UDim2.new(0, 52, 0, 18)
		Keybind.ZIndex = ZINdex + 13
		Keybind.LayoutOrder = -(#Handler:GetChildren() + 5);

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = Keybind

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = Keybind

		ValueLabel.Name = NeverLose.RandomString();
		ValueLabel.Parent = Keybind
		ValueLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ValueLabel.BackgroundTransparency = 1.000
		ValueLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueLabel.BorderSizePixel = 0
		ValueLabel.ClipsDescendants = true
		ValueLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		ValueLabel.Size = UDim2.new(1, 0, 1, 0)
		ValueLabel.ZIndex = ZINdex + 14
		ValueLabel.Font = Enum.Font.GothamMedium
		ValueLabel.Text = Config.Default and NeverLose:KeyCodeToStr(Config.Default) or "Not Bound"
		ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ValueLabel.TextSize = 10.000
		ValueLabel.TextTransparency = 0.400

		KeybindLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(Keybind,SlowyTween, { BackgroundTransparency = 0 })
				NeverLose.PlayAnimate(UIStroke,SlowyTween, { Transparency = 0.650 })
				NeverLose.PlayAnimate(ValueLabel,SlowyTween, { TextTransparency = 0.400 })
			else
				NeverLose.PlayAnimate(Keybind,SlowyTween, { BackgroundTransparency = 1 })
				NeverLose.PlayAnimate(UIStroke,SlowyTween, { Transparency = 1 })
				NeverLose.PlayAnimate(ValueLabel,SlowyTween, { TextTransparency = 1 })
			end;
		end);

		function KeybindLib:Update()
			local size = TextService:GetTextSize(ValueLabel.Text, ValueLabel.TextSize, ValueLabel.Font, Vector2.new(math.huge, 18))
			NeverLose.PlayAnimate(Keybind, SlowyTween, {
				Size = UDim2.new(0, math.max(50, size.X + 12), 0, 18)
			})
		end;

		local IsBlacklist = LPH_NO_VIRTUALIZE(function(v)
			return Config.Blacklist and (Config.Blacklist[v] or table.find(Config.Blacklist,v))
		end);

		KeybindLib:Update()
		KeybindLib.SetRender(Signal:GetValue());
		Signal:Connect(KeybindLib.SetRender);

		-- Register in Hotkeys system
		if Config.Default then
			NeverLose.RegisteredHotkeys[Config.Name] = {
				Name = Config.Name,
				Key = tostring(Config.Default),
				Mode = KeybindLib.Mode,
				Callback = Config.Callback
			}
			NeverLose:UpdateHotkeysHUD()
		end

		local IsBinding = false;
		Keybind.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if IsBinding then return end
				IsBinding = true
				ValueLabel.Text = "..."
				KeybindLib:Update()

				local con
				con = UserInputService.InputBegan:Connect(function(Key)
					-- Escape or Delete to clear/reset bind!
					if Key.KeyCode == Enum.KeyCode.Escape or Key.KeyCode == Enum.KeyCode.Delete then
						con:Disconnect()
						IsBinding = false
						Config.Default = nil
						ValueLabel.Text = "Not Bound"
						KeybindLib:Update()
						if NeverLose.RegisteredHotkeys[Config.Name] then
							NeverLose.RegisteredHotkeys[Config.Name] = nil
							NeverLose:UpdateHotkeysHUD()
						end
						Config.Callback(nil)
						return
					end

					if Key.KeyCode ~= Enum.KeyCode.Unknown and not IsBlacklist(Key.KeyCode) and not IsBlacklist(Key.KeyCode.Name) then
						con:Disconnect()
						IsBinding = false
						local KeyName = Key.KeyCode.Name
						Config.Default = KeyName
						ValueLabel.Text = NeverLose:KeyCodeToStr(KeyName)
						KeybindLib:Update()
						NeverLose.RegisteredHotkeys[Config.Name] = {
							Name = Config.Name,
							Key = KeyName,
							Mode = KeybindLib.Mode,
							Callback = Config.Callback
						}
						NeverLose:UpdateHotkeysHUD()
						Config.Callback(KeyName)
					end
				end)
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				-- Right-click opens mode selection menu!
				NeverLose:OpenKeybindMenu(Keybind, Config, KeybindLib)
			end
		end)

		function KeybindLib:GetValue()
			return Config.Default;
		end;

		function KeybindLib:SetValue(v)
			Config.Default = v;
			ValueLabel.Text = v and NeverLose:KeyCodeToStr(v) or "Not Bound";
			KeybindLib:Update();
			if v then
				NeverLose.RegisteredHotkeys[Config.Name] = {
					Name = Config.Name,
					Key = tostring(v),
					Mode = KeybindLib.Mode,
					Callback = Config.Callback
				}
			else
				NeverLose.RegisteredHotkeys[Config.Name] = nil
			end
			NeverLose:UpdateHotkeysHUD()
			Config.Callback(Config.Default);
		end;

		if Config.Flag then
			NeverLose.Flags[Config.Flag] = KeybindLib;
		end;

		return KeybindLib;
	end;

	function handle:AddTextInput(Config)
		Config = NeverLose:ProcessParams(Config , {
			Default = "",
			Placeholder = "Placeholder",
			Callback = print,
			Flag = nil,
			Size = 100,
			Numeric = false,
		});

		local TextBoxLib = {};

		local TextInput = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local TextBox = Instance.new("TextBox")

		TextInput.Name = NeverLose.RandomString();
		TextInput.Parent = Handler
		TextInput.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
		TextInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextInput.BorderSizePixel = 0
		TextInput.ClipsDescendants = true
		TextInput.Size = UDim2.new(0, Config.Size, 0, 18)
		TextInput.ZIndex = ZINdex + 13
		TextInput.LayoutOrder = -(#Handler:GetChildren() + 5);

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = TextInput

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = TextInput

		TextBox.Parent = TextInput
		TextBox.AnchorPoint = Vector2.new(0, 0.5)
		TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.BackgroundTransparency = 1.000
		TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextBox.BorderSizePixel = 0
		TextBox.Position = UDim2.new(0, 5, 0.5, 0)
		TextBox.Size = UDim2.new(1, -5, 0, 17)
		TextBox.ZIndex = ZINdex + 14
		TextBox.ClearTextOnFocus = false
		TextBox.Font = Enum.Font.GothamMedium
		TextBox.PlaceholderText = Config.Placeholder
		TextBox.Text = tostring(Config.Default)
		TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.TextSize = 11.000
		TextBox.TextTransparency = 0.350
		TextBox.TextXAlignment = Enum.TextXAlignment.Left

		TextBoxLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(TextInput , SlowyTween ,{
					BackgroundTransparency = 0
				})	

				NeverLose.PlayAnimate(UIStroke , SlowyTween ,{
					Transparency = 0.650
				})	

				NeverLose.PlayAnimate(TextBox , SlowyTween ,{
					TextTransparency = 0.350
				})	
			else
				NeverLose.PlayAnimate(TextInput , SlowyTween ,{
					BackgroundTransparency = 1
				})	

				NeverLose.PlayAnimate(UIStroke , SlowyTween ,{
					Transparency = 1
				})	

				NeverLose.PlayAnimate(TextBox , SlowyTween ,{
					TextTransparency = 1
				})
			end;
		end);

		NeverLose:AddSignal(TextBox:GetPropertyChangedSignal('Text'):Connect(LPH_NO_VIRTUALIZE(function()
			local valout = NeverLose:ParseInput(TextBox.Text , Config.Numeric);

			if Config.Numeric then
				TextBox.Text = string.gsub(TextBox.Text , '[^0-9.]','')
			end;

			if valout then
				Config.Default = valout;
				Config.Callback(valout);
			end
		end)));

		TextBoxLib.SetRender(Signal:GetValue());
		Signal:Connect(TextBoxLib.SetRender);

		function TextBoxLib:GetValue()
			return Config.Default;
		end;

		function TextBoxLib:SetValue(v)
			Config.Default = v;
			TextBox.Text = tostring(v);
			Config.Callback(Config.Default);
		end;

		if Config.Flag then
			NeverLose.Flags[Config.Flag] = TextBoxLib;
		end;

		return TextBoxLib;
	end;

	function handle:AddDropdown(Config)
		Config = NeverLose:ProcessParams(Config , {
			Default = nil,
			Values = {},
			Multi = false,
			Callback = EmptyFunction,
			AutoUpdate = false,
			Flag = nil,
			Size = 100
		})

		Config.Default = NeverLose.ProcessDropdown(Config.Default);

		local Dropdown = Instance.new("Frame")
		local DropdownIcon = Instance.new("TextLabel")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local BasedLabel = Instance.new("TextLabel")

		Dropdown.Name = NeverLose.RandomString();
		Dropdown.Parent = Handler
		Dropdown.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
		Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Dropdown.BorderSizePixel = 0
		Dropdown.ClipsDescendants = true
		Dropdown.Size = UDim2.new(0, Config.Size, 0, 18)
		Dropdown.ZIndex = ZINdex + 13
		Dropdown.LayoutOrder = -(#Handler:GetChildren() + 5);

		DropdownIcon.Name = NeverLose.RandomString();
		DropdownIcon.Parent = Dropdown
		DropdownIcon.AnchorPoint = Vector2.new(1, 0.5)
		DropdownIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		DropdownIcon.BackgroundTransparency = 1.000
		DropdownIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		DropdownIcon.BorderSizePixel = 0
		DropdownIcon.Position = UDim2.new(1, -2, 0.5, 0)
		DropdownIcon.Size = UDim2.new(0, 18, 0, 18)
		DropdownIcon.ZIndex = ZINdex + 14
		DropdownIcon.FontFace = NeverLose.BuiltInBold
		DropdownIcon.Text = "chevron-small-down"
		DropdownIcon.TextColor3 = Color3.fromRGB(223, 223, 223)
		DropdownIcon.TextSize = 16.000
		DropdownIcon.TextTransparency = 0.250
		DropdownIcon.TextWrapped = true

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = Dropdown

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = Dropdown

		BasedLabel.Name = NeverLose.RandomString();
		BasedLabel.Parent = Dropdown
		BasedLabel.AnchorPoint = Vector2.new(0, 0.5)
		BasedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.BackgroundTransparency = 1.000
		BasedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedLabel.BorderSizePixel = 0
		BasedLabel.ClipsDescendants = true
		BasedLabel.Position = UDim2.new(0, 5, 0.5, 0)
		BasedLabel.Size = UDim2.new(1, -25, 0, 15)
		BasedLabel.ZIndex = ZINdex + 14
		BasedLabel.Font = Enum.Font.GothamMedium
		BasedLabel.Text = NeverLose.ParseDropdown(Config.Default);
		BasedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.TextSize = 12.000
		BasedLabel.TextTransparency = 0.5
		BasedLabel.TextXAlignment = Enum.TextXAlignment.Left

		do
			local UIGradient = Instance.new("UIGradient")

			UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.85, 0.23), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient.Parent = BasedLabel;
		end;

		NeverLose:AddSignal(Dropdown.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
				TextTransparency = 0.200
			})
		end)));

		NeverLose:AddSignal(Dropdown.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
				TextTransparency = 0.5
			})
		end)));

		local DropdownLib = {
			OpenSignal = NeverLose:CreateSignal(false),
			Signals = {},
			Refuse = {},
		};

		DropdownLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(Dropdown , SlowyTween , {
					BackgroundTransparency = 0
				});

				NeverLose.PlayAnimate(DropdownIcon , SlowyTween , {
					TextTransparency = 0.250
				});

				NeverLose.PlayAnimate(UIStroke , SlowyTween , {
					Transparency = 0.650
				});

				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 0.5
				});
			else
				NeverLose.PlayAnimate(Dropdown , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(DropdownIcon , SlowyTween , {
					TextTransparency = 1
				});

				NeverLose.PlayAnimate(UIStroke , SlowyTween , {
					Transparency = 1
				});

				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 1
				});
			end
		end);

		DropdownLib.SetRender(Signal:GetValue())
		Signal:Connect(DropdownLib.SetRender);
		DropdownLib.ExtentSize = 0;

		do
			local DropdownHandler = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local UIStroke = Instance.new("UIStroke")
			local DropdownScrollFrame = Instance.new("ScrollingFrame")
			local UIListLayout = Instance.new("UIListLayout")
			local Shadow = NeverLose:CreateShadow(DropdownHandler);

			DropdownHandler.Name = NeverLose.RandomString();
			DropdownHandler.Parent = NeverLose.ScreenGui;
			DropdownHandler.AnchorPoint = Vector2.new(0.5, 0)
			DropdownHandler.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
			DropdownHandler.BackgroundTransparency = 0.5
			DropdownHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
			DropdownHandler.BorderSizePixel = 0
			DropdownHandler.ClipsDescendants = true
			DropdownHandler.Position = UDim2.new(255,255,255,255)
			DropdownHandler.Size = UDim2.new(0, 125, 0, 50)
			DropdownHandler.ZIndex = ZINdex + 125
			DropdownLib.BlockRoot = DropdownHandler;

			NeverLose:AddSignal(DropdownHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(function()
				if DropdownHandler.BackgroundTransparency > 0.9 then
					DropdownHandler.Visible = false;
					DropdownHandler.Parent = nil;
				else
					DropdownHandler.Visible = true;

					if NeverLose.Global3DRenderMode then
						DropdownHandler.Parent = NeverLose.GlobalSurfaceGui;
					else
						DropdownHandler.Parent = NeverLose.ScreenGui;
					end;
				end;
			end));

			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = DropdownHandler

			UIStroke.Transparency = 0.650
			UIStroke.Color = Color3.fromRGB(45, 48, 58)
			UIStroke.Parent = DropdownHandler

			-- Search Bar for Dropdown
			local DropdownSearchFrame = Instance.new("Frame", DropdownHandler)
			DropdownSearchFrame.Name = "SearchFrame"
			DropdownSearchFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
			DropdownSearchFrame.BorderSizePixel = 0
			DropdownSearchFrame.Position = UDim2.new(0, 6, 0, 6)
			DropdownSearchFrame.Size = UDim2.new(1, -12, 0, 24)
			DropdownSearchFrame.ZIndex = ZINdex + 128

			local dsCorner = Instance.new("UICorner", DropdownSearchFrame)
			dsCorner.CornerRadius = UDim.new(0, 4)

			local dsStroke = Instance.new("UIStroke", DropdownSearchFrame)
			dsStroke.Color = Color3.fromRGB(45, 52, 68)
			dsStroke.Transparency = 0.5

			local DropdownSearchBox = Instance.new("TextBox", DropdownSearchFrame)
			DropdownSearchBox.Name = "SearchBox"
			DropdownSearchBox.BackgroundTransparency = 1
			DropdownSearchBox.Position = UDim2.new(0, 6, 0, 0)
			DropdownSearchBox.Size = UDim2.new(1, -12, 1, 0)
			DropdownSearchBox.Font = Enum.Font.GothamMedium
			DropdownSearchBox.PlaceholderText = "Search..."
			DropdownSearchBox.PlaceholderColor3 = Color3.fromRGB(130, 135, 150)
			DropdownSearchBox.Text = ""
			DropdownSearchBox.TextColor3 = Color3.fromRGB(240, 245, 255)
			DropdownSearchBox.TextSize = 11
			DropdownSearchBox.TextXAlignment = Enum.TextXAlignment.Left
			DropdownSearchBox.ClearTextOnFocus = false
			DropdownSearchBox.ZIndex = ZINdex + 129

			DropdownScrollFrame.Name = NeverLose.RandomString();
			DropdownScrollFrame.Parent = DropdownHandler
			DropdownScrollFrame.Active = true
			DropdownScrollFrame.AnchorPoint = Vector2.new(0.5, 0)
			DropdownScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			DropdownScrollFrame.BackgroundTransparency = 1.000
			DropdownScrollFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			DropdownScrollFrame.BorderSizePixel = 0
			DropdownScrollFrame.Position = UDim2.new(0.5, 0, 0, 34)
			DropdownScrollFrame.Size = UDim2.new(1, -8, 1, -38)
			DropdownScrollFrame.ZIndex = ZINdex + 127
			DropdownScrollFrame.ScrollBarThickness = 2
			DropdownScrollFrame.ScrollBarImageColor3 = NeverLose.AccentColor

			DropdownSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
				local filter = string.lower(DropdownSearchBox.Text)
				for _, item in ipairs(DropdownScrollFrame:GetChildren()) do
					if item:IsA("Frame") or item:IsA("TextButton") then
						local label = item:FindFirstChildWhichIsA("TextLabel")
						if label then
							local txt = string.lower(label.Text)
							local matches = (filter == "" or string.find(txt, filter, 1, true) ~= nil)
							item.Visible = matches
						end
					end
				end
				task.wait()
				DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y)
				NeverLose.PlayAnimate(DropdownHandler, SlowyTween, {
					Size = UDim2.new(0, (Dropdown.AbsoluteSize.X + 5) + DropdownLib.ExtentSize, 0, math.clamp(UIListLayout.AbsoluteContentSize.Y + 44, 70, 250))
				})
			end)

			DropdownLib.RootItem = DropdownScrollFrame;

			UIListLayout.Parent = DropdownScrollFrame
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
				DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y)
				if DropdownLib.OpenSignal:GetValue() then
					local targetWidth = (Dropdown.AbsoluteSize.X + 5) + DropdownLib.ExtentSize;
					local targetHeight = math.clamp(UIListLayout.AbsoluteContentSize.Y + 44, 70, 250);
					NeverLose.PlayAnimate(DropdownHandler , SlowyTween , {
						Size = UDim2.new(0, targetWidth, 0, targetHeight);
					})
				end;
			end)));

			local FollowingThread;
			local SetPosition = LPH_NO_VIRTUALIZE(function()
				if not Dropdown or not Dropdown.Parent then return end;
				DropdownHandler.AnchorPoint = Vector2.new(1, 0);
				local targetX = Dropdown.AbsolutePosition.X + Dropdown.AbsoluteSize.X;
				local targetY = Dropdown.AbsolutePosition.Y + Dropdown.AbsoluteSize.Y + 4;
				DropdownHandler.Position = NeverLose:ToScreenOffset(targetX, targetY);
			end);

			if NeverLose.EnabledBlur then
				NeverLose:CreateBlurModule(DropdownHandler, DropdownLib.OpenSignal);
			end;

			DropdownLib.SetFrameRender = LPH_NO_VIRTUALIZE(function(value)
				DropdownLib.OpenSignal:SetValue(value);

				if FollowingThread then
					task.cancel(FollowingThread);
					FollowingThread = nil;
				end;

				local targetWidth = (Dropdown.AbsoluteSize.X + 5) + DropdownLib.ExtentSize;
				local targetHeight = math.clamp(UIListLayout.AbsoluteContentSize.Y + 44, 70, 250);

				if value then
					SetPosition();
					DropdownHandler.Visible = true;
					DropdownHandler.Size = UDim2.new(0, targetWidth, 0, 0);
					DropdownHandler.BackgroundTransparency = 0.5;

					local rollTween = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);
					NeverLose.PlayAnimate(DropdownHandler, rollTween, {
						Size = UDim2.new(0, targetWidth, 0, targetHeight),
						BackgroundTransparency = 0.035
					});

					Shadow:Render(true);

					if Config.AutoUpdate then
						DropdownLib:Generate();
					end;

					FollowingThread = task.spawn(function()
						while DropdownLib.OpenSignal:GetValue() do
							task.wait();
							SetPosition();
						end;
					end);
				else
					local closeTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
					NeverLose.PlayAnimate(DropdownHandler, closeTween, {
						Size = UDim2.new(0, targetWidth, 0, 0),
						BackgroundTransparency = 1
					});

					Shadow:Render(false);
					task.delay(0.18, function()
						if not DropdownLib.OpenSignal:GetValue() then
							DropdownHandler.Visible = false;
						end;
					end);
				end;
			end);

			DropdownLib.SetFrameRender(false);
		end;

		local SecureSignal;
		NeverLose:CreateInput(Dropdown , LPH_NO_VIRTUALIZE(function()
			if DropdownLib.OpenSignal:GetValue() then
				if SecureSignal then
					SecureSignal:Disconnect();
					SecureSignal = nil;
				end;
				NeverLose.IsMosueOverOtherFrame = false;
				DropdownLib.SetFrameRender(false);
				return;
			end;

			if SecureSignal then
				SecureSignal:Disconnect();
				SecureSignal = nil;
			end;

			DropdownLib.SetFrameRender(true);
			NeverLose.IsMosueOverOtherFrame = true;

			SecureSignal = UserInputService.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					if not NeverLose:IsMouseOverFrame(DropdownLib.BlockRoot) and not NeverLose:IsMouseOverFrame(Dropdown) then
						if SecureSignal then
							SecureSignal:Disconnect();
							SecureSignal = nil;
						end;

						NeverLose.IsMosueOverOtherFrame = false;
						DropdownLib.SetFrameRender(false);
					end;
				end
			end)
		end))

		DropdownLib.IsMatch = LPH_NO_VIRTUALIZE(function(v1)
			if typeof(Config.Default) =='table' then
				if Config.Default[v1] or table.find(Config.Default , v1) then
					return true;
				end
			end

			if Config.Default == v1 then
				return true;
			end;
		end);

		function DropdownLib:Generate()
			for i,v in next , DropdownLib.RootItem:GetChildren() do
				if v:IsA('Frame') then
					v:Destroy();
				end;
			end;

			for i,v in next , DropdownLib.Signals do
				v:Disconnect();
			end;

			table.clear(DropdownLib.Signals);
			table.clear(DropdownLib.Refuse);

			local Lastone;
			for i,Value in next , Config.Values do
				local ItemFrame = Instance.new("Frame")
				local ItemLabel = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")

				ItemFrame.Name = NeverLose.RandomString();
				ItemFrame.Parent = DropdownLib.RootItem
				ItemFrame.BackgroundColor3 = Color3.fromRGB(29, 31, 38)
				ItemFrame.BackgroundTransparency = 1.000
				ItemFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ItemFrame.BorderSizePixel = 0
				ItemFrame.Size = UDim2.new(1, 0, 0, 25)
				ItemFrame.ZIndex = ZINdex + 1258

				ItemLabel.Name = NeverLose.RandomString();
				ItemLabel.Parent = ItemFrame
				ItemLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ItemLabel.BackgroundTransparency = 1.000
				ItemLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ItemLabel.BorderSizePixel = 0
				ItemLabel.Position = UDim2.new(0, 15, 0, 4)
				ItemLabel.Size = UDim2.new(0,1, 0, 15)
				ItemLabel.ZIndex = ZINdex + 1258
				ItemLabel.Font = Enum.Font.GothamMedium
				ItemLabel.Text = tostring(Value);
				ItemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				ItemLabel.TextSize = 13.000
				ItemLabel.TextTransparency = 0.200
				ItemLabel.TextXAlignment = Enum.TextXAlignment.Left

				UICorner.CornerRadius = UDim.new(0, 10)
				UICorner.Parent = ItemFrame
				local sizetext = TextService:GetTextSize(ItemLabel.Text , ItemLabel.TextSize,ItemLabel.Font,Vector2.new(math.huge,math.huge));

				DropdownLib.ExtentSize = math.max(DropdownLib.ExtentSize , sizetext.X);

				local MIcon , MarkItem = nil , nil;

				if Config.Multi then
					local Icon = Instance.new("TextLabel")

					Icon.Parent = ItemFrame;
					Icon.AnchorPoint = Vector2.new(0, 0.5)
					Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Icon.BackgroundTransparency = 1.000
					Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Icon.BorderSizePixel = 0
					Icon.Position = UDim2.new(0, 5, 0.5, 0)
					Icon.Size = UDim2.new(0, 20, 0, 20)
					Icon.ZIndex = ZINdex + 1259
					Icon.FontFace = NeverLose.BuiltInBold;
					Icon.Text = "check"
					Icon.TextColor3 = Color3.fromRGB(223, 223, 223)
					Icon.TextSize = 18.000
					Icon.TextTransparency = 1
					Icon.TextWrapped = true;

					local VisiblewOfMult = LPH_NO_VIRTUALIZE(function()
						if DropdownLib.IsMatch(Value) then
							NeverLose.PlayAnimate(ItemLabel , VSlowTween , {
								TextTransparency = 0.200,
								Position = UDim2.new(0, 30, 0, 4)
							})

							NeverLose.PlayAnimate(Icon , vs , {
								TextTransparency = 0.250
							})

							Lastone = ItemLabel;
						else

							NeverLose.PlayAnimate(Icon , SlowyTween , {
								TextTransparency = 1
							})

							NeverLose.PlayAnimate(ItemLabel , VSlowTween , {
								TextTransparency = 0.5,
								Position = UDim2.new(0, 15, 0, 4)
							})
						end;
					end);

					MIcon = Icon;
					MarkItem = VisiblewOfMult;
				else
					local DefaultVisible = LPH_NO_VIRTUALIZE(function()
						if DropdownLib.IsMatch(Value) then
							NeverLose.PlayAnimate(ItemLabel , SlowyTween , {
								TextTransparency = 0.200
							})

							Lastone = ItemLabel;
						else
							NeverLose.PlayAnimate(ItemLabel , SlowyTween , {
								TextTransparency = 0.5
							})
						end;
					end);

					MarkItem = DefaultVisible;
				end;

				MarkItem();

				table.insert(DropdownLib.Refuse , MarkItem)

				table.insert(DropdownLib.Signals,ItemFrame.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(ItemFrame , SlowyTween , {
						BackgroundTransparency = 0.1
					})
				end)));

				table.insert(DropdownLib.Signals,ItemFrame.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(ItemFrame , SlowyTween , {
						BackgroundTransparency = 1
					})
				end)));

				table.insert(DropdownLib.Signals , DropdownLib.OpenSignal:Connect(LPH_NO_VIRTUALIZE(function(val)
					if val then
						MarkItem();
					else
						NeverLose.PlayAnimate(ItemLabel , SlowyTween , {
							TextTransparency = 1
						})

						if MIcon then
							NeverLose.PlayAnimate(MIcon , SlowyTween , {
								TextTransparency = 1
							})
						end;
					end;
				end)));

				if Config.Multi then
					local _,bth_signal = NeverLose:CreateInput(ItemFrame , LPH_NO_VIRTUALIZE(function()
						Config.Default[Value] = not Config.Default[Value];

						MarkItem();

						BasedLabel.Text = NeverLose.ParseDropdown(Config.Default);

						Config.Callback(Config.Default);
					end));

					table.insert(DropdownLib.Signals , bth_signal);
				else
					local _,bth_signal = NeverLose:CreateInput(ItemFrame , LPH_NO_VIRTUALIZE(function()
						Config.Default = Value;

						for i,v in next , DropdownLib.Refuse do
							task.spawn(v);
						end;

						BasedLabel.Text = NeverLose.ParseDropdown(Config.Default);

						Config.Callback(Config.Default);
					end));

					table.insert(DropdownLib.Signals , bth_signal);
				end;
			end;
		end;

		DropdownLib:Generate();

		function DropdownLib:GetValue()
			return Config.Default;
		end;

		function DropdownLib:SetValue(v)
			Config.Default = v;

			BasedLabel.Text = NeverLose.ParseDropdown(Config.Default);

			for i,v in next , DropdownLib.Refuse do
				task.spawn(v);
			end;

			Config.Callback(Config.Default);
		end;

		function DropdownLib:SetValues(a)
			Config.Values = a;

			if not Config.AutoUpdate then
				DropdownLib:Generate();
			end;
		end;

		if Config.Flag then
			NeverLose.Flags[Config.Flag] = DropdownLib;
		end;

		return DropdownLib;
	end;

	return handle;
end;

NeverLose.ProcessDropdown = LPH_NO_VIRTUALIZE(function(value)
	if typeof(value) == 'table' then
		local data = {};

		for i,v in next , value do
			if typeof(v) == 'boolean' and typeof(i) ~= 'number' then
				data[i] = v;
			else
				data[v] = true;
			end;
		end;

		return data;
	else
		return value;
	end;
end);

NeverLose.ParseDropdown = LPH_NO_VIRTUALIZE(function(value)
	if not value then return 'Select'; end;

	local Out;

	if typeof(value) == 'table' then
		if #value > 0 then
			local x = {};

			for i,v in next , value do
				table.insert(x , tostring(v))
			end;

			Out = table.concat(x,' , ');

			table.clear(x);
		else
			local x = {};

			for i,v in next , value do
				if v == true then
					table.insert(x , tostring(i));
				end			
			end;

			Out = table.concat(x,' , ');

			table.clear(x)

			if not Out:byte() then
				Out = 'Select';
			end
		end;
	else
		Out = tostring(value or 'Select');
	end;

	return Out;
end);

function NeverLose:ParseInput(Value , Numeric)
	if not Value then
		return (Numeric and nil) or "";	
	end;

	if Numeric then
		local out = string.gsub(tostring(Value), '[^0-9.%-]', '')

		if tonumber(out) then
			return tonumber(out);
		end;

		return nil;
	end;

	return Value;
end;

function NeverLose:CreateToolTips(Container: Frame , Name: string , Content: string)
	local Tooltips = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIStroke = Instance.new("UIStroke")
	local TooltipName = Instance.new("TextLabel")
	local TooltipContent = Instance.new("TextLabel")
	local Shadow = NeverLose:CreateShadow(Tooltips)

	Tooltips.Name = NeverLose.RandomString()
	Tooltips.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
	Tooltips.BackgroundTransparency = 1
	Tooltips.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Tooltips.BorderSizePixel = 0
	Tooltips.ClipsDescendants = false
	Tooltips.Position = UDim2.new(0, -9999, 0, -9999)
	Tooltips.Size = UDim2.new(0, 240, 0, 60)
	Tooltips.ZIndex = 300
	Tooltips.Visible = false
	Tooltips.Parent = NeverLose.ScreenGui

	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = Tooltips

	UIStroke.Transparency = 1
	UIStroke.Color = Color3.fromRGB(45, 52, 68)
	UIStroke.Thickness = 1
	UIStroke.Parent = Tooltips

	TooltipName.Name = NeverLose.RandomString()
	TooltipName.Parent = Tooltips
	TooltipName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TooltipName.BackgroundTransparency = 1.000
	TooltipName.BorderSizePixel = 0
	TooltipName.Position = UDim2.new(0, 12, 0, 8)
	TooltipName.Size = UDim2.new(1, -24, 0, 16)
	TooltipName.ZIndex = 302
	TooltipName.Font = Enum.Font.GothamBold
	TooltipName.Text = Name or "Description"
	TooltipName.TextColor3 = Color3.fromRGB(255, 255, 255)
	TooltipName.TextSize = 13.000
	TooltipName.TextTransparency = 1
	TooltipName.TextXAlignment = Enum.TextXAlignment.Left

	TooltipContent.Name = NeverLose.RandomString()
	TooltipContent.Parent = Tooltips
	TooltipContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TooltipContent.BackgroundTransparency = 1.000
	TooltipContent.BorderSizePixel = 0
	TooltipContent.Position = UDim2.new(0, 12, 0, 26)
	TooltipContent.Size = UDim2.new(1, -24, 0, 30)
	TooltipContent.ZIndex = 302
	TooltipContent.Font = Enum.Font.GothamMedium
	TooltipContent.Text = Content or ""
	TooltipContent.TextColor3 = Color3.fromRGB(185, 190, 205)
	TooltipContent.TextSize = 11.000
	TooltipContent.TextTransparency = 1
	TooltipContent.TextWrapped = true
	TooltipContent.TextXAlignment = Enum.TextXAlignment.Left
	TooltipContent.TextYAlignment = Enum.TextYAlignment.Top

	local ToolTip = {}

	ToolTip.Update = LPH_NO_VIRTUALIZE(function()
		local maxTextWidth = 240
		local sizeContent = TextService:GetTextSize(TooltipContent.Text, TooltipContent.TextSize, TooltipContent.Font, Vector2.new(maxTextWidth - 24, 2000))
		local sizeName = TextService:GetTextSize(TooltipName.Text, TooltipName.TextSize, TooltipName.Font, Vector2.new(maxTextWidth - 24, 100))

		local finalWidth = math.clamp(math.max(sizeName.X, sizeContent.X) + 26, 160, 280)
		local finalHeight = sizeName.Y + sizeContent.Y + 22

		Tooltips.Size = UDim2.fromOffset(finalWidth, finalHeight)
		TooltipContent.Size = UDim2.new(1, -24, 0, sizeContent.Y)
	end)

	ToolTip.SetRender = LPH_NO_VIRTUALIZE(function(value)
		if value then
			if not Container or not Container.Parent or not Tooltips or not Tooltips.Parent then return end
			ToolTip.Update()
			pcall(function()
				Tooltips.Parent = NeverLose.ScreenGui or (gethui and gethui()) or game:GetService("CoreGui")
				Tooltips.Visible = true
			end)

			local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
			local tipW = Tooltips.AbsoluteSize.X > 0 and Tooltips.AbsoluteSize.X or 240
			local tipH = Tooltips.AbsoluteSize.Y > 0 and Tooltips.AbsoluteSize.Y or 60

			-- Intelligent positioning: right if fits, left if near right edge
			local posX = Container.AbsolutePosition.X + Container.AbsoluteSize.X + 10
			if posX + tipW > vp.X - 15 then
				posX = Container.AbsolutePosition.X - tipW - 10
			end
			local posY = math.clamp(Container.AbsolutePosition.Y, 15, vp.Y - tipH - 15)

			Tooltips.Position = UDim2.fromOffset(posX, posY)

			NeverLose.PlayAnimate(Tooltips, SlowyTween, { BackgroundTransparency = 0.08 })
			NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 0.45 })
			NeverLose.PlayAnimate(TooltipName, SlowyTween, { TextTransparency = 0 })
			NeverLose.PlayAnimate(TooltipContent, SlowyTween, { TextTransparency = 0.15 })
			Shadow:Render(true)
		else
			NeverLose.PlayAnimate(Tooltips, SlowyTween, { BackgroundTransparency = 1 })
			NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 1 })
			NeverLose.PlayAnimate(TooltipName, SlowyTween, { TextTransparency = 1 })
			NeverLose.PlayAnimate(TooltipContent, SlowyTween, { TextTransparency = 1 })
			Shadow:Render(false)
			task.delay(0.25, function()
				if Tooltips.BackgroundTransparency >= 0.95 then
					Tooltips.Visible = false
				end
			end)
		end
	end)

	local DelayThread = nil
	NeverLose:AddSignal(Container.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
		if DelayThread then
			task.cancel(DelayThread)
			DelayThread = nil
		end
		-- 0.45 second hover delay
		DelayThread = task.delay(0.45, function()
			if not Container or not Container.Parent or not Tooltips or not Tooltips.Parent then return end
			ToolTip.SetRender(true)
		end)
	end)))

	NeverLose:AddSignal(Container.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
		if DelayThread then
			task.cancel(DelayThread)
			DelayThread = nil
		end
		ToolTip.SetRender(false)
	end)))

	return ToolTip
end;

function NeverLose:CreateFlyoutSubmenu(parentRow, width)
	width = width or 120;
	local Flyout = Instance.new("Frame");
	local UICorner = Instance.new("UICorner");
	local UIStroke = Instance.new("UIStroke");
	local UIListLayout = Instance.new("UIListLayout");
	local UIPadding = Instance.new("UIPadding");
	local Shadow = NeverLose:CreateShadow(Flyout);

	Flyout.Name = NeverLose.RandomString();
	Flyout.Parent = NeverLose.ScreenGui;
	Flyout.BackgroundColor3 = Color3.fromRGB(18, 20, 26);
	Flyout.BackgroundTransparency = 1;
	Flyout.BorderSizePixel = 0;
	Flyout.ClipsDescendants = true;
	Flyout.Size = UDim2.new(0, width, 0, 30);
	Flyout.ZIndex = 45;
	Flyout.Visible = false;

	UICorner.CornerRadius = UDim.new(0, 10);
	UICorner.Parent = Flyout;

	UIStroke.Transparency = 1;
	UIStroke.Color = Color3.fromRGB(45, 48, 58);
	UIStroke.Parent = Flyout;

	UIListLayout.Parent = Flyout;
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	UIListLayout.Padding = UDim.new(0, 2);

	UIPadding.Parent = Flyout;
	UIPadding.PaddingTop = UDim.new(0, 4);
	UIPadding.PaddingBottom = UDim.new(0, 4);
	UIPadding.PaddingLeft = UDim.new(0, 4);
	UIPadding.PaddingRight = UDim.new(0, 4);

	NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Flyout.Size = UDim2.new(0, width, 0, UIListLayout.AbsoluteContentSize.Y + 10);
	end));

	NeverLose:AddSignal(Flyout.MouseEnter:Connect(function()
		NeverLose.IsMosueOverOtherFrame = true;
	end));

	NeverLose:AddSignal(Flyout.MouseLeave:Connect(function()
		NeverLose.IsMosueOverOtherFrame = false;
	end));

	local FlyoutLib = {
		Root = Flyout,
		IsOpen = false,
		Items = {},
	};

	function FlyoutLib:SetSelected(chosenName)
		for _, it in ipairs(FlyoutLib.Items) do
			if it.Name == chosenName then
				it.Label.TextColor3 = NeverLose.AccentColor;
				NeverLose:RegisterAccent(it.Label, "TextColor3");
			else
				it.Label.TextColor3 = Color3.fromRGB(220, 220, 225);
			end;
		end;
	end;

	function FlyoutLib:Open(customPos)
		FlyoutLib.IsOpen = true;
		NeverLose.IsMosueOverOtherFrame = true;
		if customPos then
			Flyout.Position = customPos;
		else
			Flyout.Position = NeverLose:ToScreenOffset(parentRow.AbsolutePosition.X + parentRow.AbsoluteSize.X + 8, parentRow.AbsolutePosition.Y - 6);
		end;
		Flyout.Visible = true;
		NeverLose.PlayAnimate(Flyout, SlowyTween, { BackgroundTransparency = 0.05 });
		NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 0.650 });
		Shadow:Render(true);
	end;

	function FlyoutLib:Close()
		FlyoutLib.IsOpen = false;
		NeverLose.IsMosueOverOtherFrame = false;
		NeverLose.PlayAnimate(Flyout, SlowyTween, { BackgroundTransparency = 1 });
		NeverLose.PlayAnimate(UIStroke, SlowyTween, { Transparency = 1 });
		Shadow:Render(false);
		task.delay(0.25, function()
			if not FlyoutLib.IsOpen then
				Flyout.Visible = false;
			end;
		end);
	end;

	function FlyoutLib:AddItem(name, isSelected, onClick)
		local Item = Instance.new("TextButton");
		local ItemCorner = Instance.new("UICorner");
		local ItemLabel = Instance.new("TextLabel");

		Item.Name = NeverLose.RandomString();
		Item.Parent = Flyout;
		Item.BackgroundColor3 = Color3.fromRGB(28, 31, 40);
		Item.BackgroundTransparency = 1;
		Item.BorderSizePixel = 0;
		Item.Size = UDim2.new(1, 0, 0, 24);
		Item.ZIndex = 46;
		Item.Text = "";
		Item.AutoButtonColor = false;

		ItemCorner.CornerRadius = UDim.new(0, 6);
		ItemCorner.Parent = Item;

		ItemLabel.Name = NeverLose.RandomString();
		ItemLabel.Parent = Item;
		ItemLabel.BackgroundTransparency = 1;
		ItemLabel.Position = UDim2.new(0, 8, 0.5, 0);
		ItemLabel.AnchorPoint = Vector2.new(0, 0.5);
		ItemLabel.Size = UDim2.new(1, -16, 1, 0);
		ItemLabel.Font = Enum.Font.GothamMedium;
		ItemLabel.TextSize = 12;
		ItemLabel.TextColor3 = isSelected and NeverLose.AccentColor or Color3.fromRGB(220, 220, 225);
		ItemLabel.TextXAlignment = Enum.TextXAlignment.Left;
		ItemLabel.Text = name;
		ItemLabel.ZIndex = 47;

		if isSelected then
			NeverLose:RegisterAccent(ItemLabel, "TextColor3");
		end;

		local itemData = { Name = name, Label = ItemLabel, Button = Item };
		table.insert(FlyoutLib.Items, itemData);

		NeverLose:AddSignal(Item.MouseEnter:Connect(function()
			NeverLose.PlayAnimate(Item, SlowyTween, { BackgroundTransparency = 0.4 });
		end));

		NeverLose:AddSignal(Item.MouseLeave:Connect(function()
			NeverLose.PlayAnimate(Item, SlowyTween, { BackgroundTransparency = 1 });
		end));

		NeverLose:AddSignal(Item.MouseButton1Click:Connect(function()
			FlyoutLib:SetSelected(name);
			if onClick then
				onClick(name);
			end;
			FlyoutLib:Close();
		end));

		return Item, ItemLabel;
	end;

	return FlyoutLib;
end;

function NeverLose:RegisiterItem(Frame: Frame , Signel, TabInfo: table)
	local idx = {};
	local LayerIndex = Frame.ZIndex;

	function idx:AddLabel(Name: string,Warp: boolean, Config: table)
		local BasedFrame = Instance.new("Frame")
		local BasedLabel = Instance.new("TextLabel")
		local LineFrame = Instance.new("Frame")
		local BasedHandler = Instance.new("Frame")
		local UIListLayout = Instance.new("UIListLayout")
		local UICorner = Instance.new("UICorner")

		BasedFrame.Name = NeverLose.RandomString();
		BasedFrame.Parent = Frame
		BasedFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
		BasedFrame.BackgroundTransparency = 1.000
		BasedFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedFrame.BorderSizePixel = 0
		BasedFrame.Size = UDim2.new(1, 0, 0, 30)
		BasedFrame.ZIndex = LayerIndex + 8
		BasedFrame.Active = true;

		NeverLose:AddQuery(BasedFrame , Name, TabInfo);

		BasedLabel.Name = NeverLose.RandomString();
		BasedLabel.Parent = BasedFrame
		BasedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.BackgroundTransparency = 1.000
		BasedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedLabel.BorderSizePixel = 0
		BasedLabel.Position = UDim2.new(0, 11, 0, 6)
		BasedLabel.Size = UDim2.new(0,1, 0, 15)
		BasedLabel.ZIndex = LayerIndex + 9
		BasedLabel.Font = Enum.Font.GothamMedium
		BasedLabel.Text = Name
		BasedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.TextSize = 13.000
		BasedLabel.TextTransparency = 0.35
		BasedLabel.TextXAlignment = Enum.TextXAlignment.Left

		LineFrame.Name = NeverLose.RandomString();
		LineFrame.Parent = BasedFrame
		LineFrame.AnchorPoint = Vector2.new(0.5, 1)
		LineFrame.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
		LineFrame.BackgroundTransparency = 0.650
		LineFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LineFrame.BorderSizePixel = 0
		LineFrame.Position = UDim2.new(0.5, 0, 1, 0)
		LineFrame.Size = UDim2.new(1, -20, 0, 1)
		LineFrame.ZIndex = LayerIndex + 11

		BasedHandler.Name = NeverLose.RandomString();
		BasedHandler.Parent = BasedFrame
		BasedHandler.AnchorPoint = Vector2.new(1, 0)
		BasedHandler.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BasedHandler.BackgroundTransparency = 1.000
		BasedHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedHandler.BorderSizePixel = 0
		BasedHandler.Position = UDim2.new(1, -11, 0, 2)
		BasedHandler.Size = UDim2.new(1, -20, 0, 25)
		BasedHandler.ZIndex = LayerIndex + 12

		UIListLayout.Parent = BasedHandler
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout.Padding = UDim.new(0, 5)

		UICorner.CornerRadius = UDim.new(0, 10)
		UICorner.Parent = BasedFrame

		local UpdateWarp = LPH_NO_VIRTUALIZE(function()
			local size = TextService:GetTextSize(BasedLabel.Text , BasedLabel.TextSize , BasedLabel.Font , Vector2.new(math.huge,math.huge));
			NeverLose.PlayAnimate(BasedFrame , SlowyTween , {
				Size = UDim2.new(1, 0, 0, size.Y + 13);
			})

			BasedLabel.Size = UDim2.new(1, -35, 1, 0)
			BasedLabel.TextYAlignment = Enum.TextYAlignment.Top;
		end);

		if Warp then
			UpdateWarp();
		end;

		local handle = NeverLose:RegisiterHandler(BasedHandler , Signel);

		handle.Root = BasedFrame;
		handle.BasedLabel = BasedLabel;

		handle.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(BasedFrame , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 0.35
				})

				NeverLose.PlayAnimate(LineFrame , SlowyTween , {
					BackgroundTransparency = 0.650
				})
			else
				NeverLose.PlayAnimate(BasedFrame , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 1
				})

				NeverLose.PlayAnimate(LineFrame , SlowyTween , {
					BackgroundTransparency = 1
				})
			end;
		end);

		function handle:SetVisible(val)
			BasedFrame.Visible = val;
		end;

		NeverLose:AddSignal(BasedFrame.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(BasedFrame , SlowyTween , {
				BackgroundTransparency = 0.35
			});

			NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
				TextTransparency = 0.25
			})

		end)))

		NeverLose:AddSignal(BasedFrame.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(BasedFrame , SlowyTween , {
				BackgroundTransparency = 1
			});

			NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
				TextTransparency = 0.35
			})
		end)))

		function handle:SetText(t)
			local oldtxt = BasedLabel.Text;

			BasedLabel.Text = t;

			if Warp and oldtxt ~= t then
				UpdateWarp();
			end;
		end;

		function handle:ToolTip(Content: string)
			handle.ToolTip = NeverLose:CreateToolTips(BasedFrame , Name , Content);
			return handle;
		end;

		if Config and (Config.ToolTip or Config.Description) then
			handle:ToolTip(Config.ToolTip or Config.Description);
		end;

		handle.SetRender(Signel:GetValue());
		Signel:Connect(handle.SetRender);

		return handle;
	end;

	function idx:AddButton(Config)
		Config = NeverLose:ProcessParams(Config , {
			Icon = 'chevron-large-left',
			Name = "Button",
			Callback = EmptyFunction,
			ToolTip = nil,
		});

		local Button = {};
		local ButtonFrame = Instance.new("Frame")
		local BasedLabel = Instance.new("TextLabel")
		local LineFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local Icon = Instance.new("TextLabel")

		NeverLose:AddQuery(ButtonFrame , Config.Name, TabInfo);

		ButtonFrame.Name = NeverLose.RandomString();
		ButtonFrame.Parent = Frame
		ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
		ButtonFrame.BackgroundTransparency = 1.000
		ButtonFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ButtonFrame.BorderSizePixel = 0
		ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
		ButtonFrame.ZIndex = LayerIndex + 8

		BasedLabel.Name = NeverLose.RandomString();
		BasedLabel.Parent = ButtonFrame
		BasedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.BackgroundTransparency = 1.000
		BasedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedLabel.BorderSizePixel = 0
		BasedLabel.Position = UDim2.new(0, 35, 0, 6)
		BasedLabel.Size = UDim2.new(0,1, 0, 15)
		BasedLabel.ZIndex = LayerIndex + 9
		BasedLabel.Font = Enum.Font.GothamMedium
		BasedLabel.Text = Config.Name;
		BasedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.TextSize = 13.000
		BasedLabel.TextTransparency = 0.200
		BasedLabel.TextXAlignment = Enum.TextXAlignment.Left

		LineFrame.Name = NeverLose.RandomString();
		LineFrame.Parent = ButtonFrame
		LineFrame.AnchorPoint = Vector2.new(0.5, 1)
		LineFrame.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
		LineFrame.BackgroundTransparency = 0.650
		LineFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LineFrame.BorderSizePixel = 0
		LineFrame.Position = UDim2.new(0.5, 0, 1, 0)
		LineFrame.Size = UDim2.new(1, -20, 0, 1)
		LineFrame.ZIndex = LayerIndex + 11

		UICorner.CornerRadius = UDim.new(0, 10)
		UICorner.Parent = ButtonFrame

		Icon.Name = NeverLose.RandomString();
		Icon.Parent = ButtonFrame
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0, 11, 0, 5)
		Icon.Size = UDim2.new(0, 18, 0, 18)
		Icon.ZIndex = LayerIndex + 9
		Icon.FontFace = NeverLose.BuiltInBold
		Icon.Text = Config.Icon
		Icon.TextColor3 = Color3.fromRGB(223, 223, 223)
		Icon.TextSize = 16.000
		Icon.TextTransparency = 0.250
		Icon.TextWrapped = true

		function Button:SetText(t)
			BasedLabel.Text = t;
		end;

		function Button:SetIcon(t)
			Icon.Text = t
		end;

		local bth = NeverLose:CreateInput(ButtonFrame , LPH_NO_VIRTUALIZE(function()
			Config.Callback();
		end));

		NeverLose:AddSignal(bth.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(ButtonFrame , SlowyTween , {
				BackgroundTransparency = 0.35
			});
		end)))

		NeverLose:AddSignal(bth.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(ButtonFrame , SlowyTween , {
				BackgroundTransparency = 1
			});
		end)))

		Button.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				NeverLose.PlayAnimate(ButtonFrame , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 0.200
				});

				NeverLose.PlayAnimate(LineFrame , SlowyTween , {
					BackgroundTransparency = 0.650
				});

				NeverLose.PlayAnimate(Icon , SlowyTween , {
					TextTransparency = 0.250
				});
			else
				NeverLose.PlayAnimate(ButtonFrame , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 1
				});

				NeverLose.PlayAnimate(LineFrame , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(Icon , SlowyTween , {
					TextTransparency = 1
				});
			end;
		end);

		if Config.ToolTip then
			Button.ToolTip = NeverLose:CreateToolTips(ButtonFrame , Config.Name , Config.ToolTip);
		end;

		Button.SetRender(Signel:GetValue())
		Signel:Connect(Button.SetRender);

		return Button;
	end;

	function idx:AddUserFrame(Name : string , Profile: string , Expires : string, WinRef: any)
		local UserFrameItem = {};
		local Submenus = {};

		local function closeAllSubmenus()
			for _, sm in ipairs(Submenus) do
				pcall(function() sm:Close() end);
			end;
		end;

		-- 1. Profile Header Card
		local UserHeader = Instance.new("Frame");
		local AvatarImage = Instance.new("ImageLabel");
		local AvatarCorner = Instance.new("UICorner");
		local UserLabel = Instance.new("TextLabel");
		local UserStatusLabel = Instance.new("TextLabel");
		local EditionLabel = Instance.new("TextLabel");
		local HeaderLine = Instance.new("Frame");

		UserHeader.Name = NeverLose.RandomString();
		UserHeader.Parent = Frame;
		UserHeader.BackgroundTransparency = 1;
		UserHeader.Size = UDim2.new(1, 0, 0, 56);
		UserHeader.ZIndex = LayerIndex + 8;
		UserHeader.LayoutOrder = 1;

		AvatarImage.Name = NeverLose.RandomString();
		AvatarImage.Parent = UserHeader;
		AvatarImage.Position = UDim2.new(0, 12, 0.5, 0);
		AvatarImage.AnchorPoint = Vector2.new(0, 0.5);
		AvatarImage.Size = UDim2.new(0, 36, 0, 36);
		AvatarImage.BackgroundTransparency = 1;
		AvatarImage.Image = Profile or "rbxasset://textures/ui/clb_robux_20@3x.png";
		AvatarImage.ZIndex = LayerIndex + 9;

		AvatarCorner.CornerRadius = UDim.new(1, 0);
		AvatarCorner.Parent = AvatarImage;

		UserLabel.Name = NeverLose.RandomString();
		UserLabel.Parent = UserHeader;
		UserLabel.Position = UDim2.new(0, 58, 0, 6);
		UserLabel.Size = UDim2.new(1, -66, 0, 16);
		UserLabel.BackgroundTransparency = 1;
		UserLabel.Font = Enum.Font.GothamBold;
		UserLabel.Text = Name or "User";
		UserLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
		UserLabel.TextSize = 13;
		UserLabel.TextTransparency = 0.1;
		UserLabel.TextXAlignment = Enum.TextXAlignment.Left;
		UserLabel.ZIndex = LayerIndex + 9;

		UserStatusLabel.Name = NeverLose.RandomString();
		UserStatusLabel.Parent = UserHeader;
		UserStatusLabel.Position = UDim2.new(0, 58, 0, 23);
		UserStatusLabel.Size = UDim2.new(1, -66, 0, 14);
		UserStatusLabel.BackgroundTransparency = 1;
		UserStatusLabel.Font = Enum.Font.GothamMedium;
		UserStatusLabel.Text = "Till: " .. (Expires or "lifetime");
		UserStatusLabel.TextColor3 = Color3.fromRGB(150, 155, 170);
		UserStatusLabel.TextSize = 11;
		UserStatusLabel.TextXAlignment = Enum.TextXAlignment.Left;
		UserStatusLabel.ZIndex = LayerIndex + 9;

		EditionLabel.Name = NeverLose.RandomString();
		EditionLabel.Parent = UserHeader;
		EditionLabel.Position = UDim2.new(0, 58, 0, 38);
		EditionLabel.Size = UDim2.new(1, -66, 0, 14);
		EditionLabel.BackgroundTransparency = 1;
		EditionLabel.Font = Enum.Font.GothamBold;
		EditionLabel.Text = "Renew";
		EditionLabel.TextColor3 = NeverLose.AccentColor;
		EditionLabel.TextSize = 11;
		EditionLabel.TextXAlignment = Enum.TextXAlignment.Left;
		EditionLabel.ZIndex = LayerIndex + 9;
		NeverLose:RegisterAccent(EditionLabel, "TextColor3");

		HeaderLine.Name = NeverLose.RandomString();
		HeaderLine.Parent = UserHeader;
		HeaderLine.Position = UDim2.new(0.5, 0, 1, -1);
		HeaderLine.AnchorPoint = Vector2.new(0.5, 1);
		HeaderLine.Size = UDim2.new(1, -16, 0, 1);
		HeaderLine.BackgroundColor3 = Color3.fromRGB(45, 48, 58);
		HeaderLine.BackgroundTransparency = 0.65;
		HeaderLine.BorderSizePixel = 0;
		HeaderLine.ZIndex = LayerIndex + 10;

		-- Row generator helper
		local function makeRow(layoutOrder, iconName, labelText)
			local RowFrame = Instance.new("Frame");
			local RowCorner = Instance.new("UICorner");
			local IconLabel = Instance.new("TextLabel");
			local NameLabel = Instance.new("TextLabel");
			local RightBox = Instance.new("Frame");

			RowFrame.Name = NeverLose.RandomString();
			RowFrame.Parent = Frame;
			RowFrame.BackgroundTransparency = 1;
			RowFrame.BackgroundColor3 = Color3.fromRGB(28, 31, 40);
			RowFrame.BorderSizePixel = 0;
			RowFrame.Size = UDim2.new(1, -10, 0, 32);
			RowFrame.ZIndex = LayerIndex + 8;
			RowFrame.LayoutOrder = layoutOrder;

			RowCorner.CornerRadius = UDim.new(0, 6);
			RowCorner.Parent = RowFrame;

			IconLabel.Name = NeverLose.RandomString();
			IconLabel.Parent = RowFrame;
			IconLabel.Position = UDim2.new(0, 8, 0.5, 0);
			IconLabel.AnchorPoint = Vector2.new(0, 0.5);
			IconLabel.Size = UDim2.new(0, 18, 0, 18);
			IconLabel.BackgroundTransparency = 1;
			IconLabel.FontFace = NeverLose.BuiltInBold;
			IconLabel.Text = iconName;
			IconLabel.TextColor3 = Color3.fromRGB(180, 185, 200);
			IconLabel.TextSize = 14;
			IconLabel.TextTransparency = 0.25;
			IconLabel.ZIndex = LayerIndex + 9;

			NameLabel.Name = NeverLose.RandomString();
			NameLabel.Parent = RowFrame;
			NameLabel.Position = UDim2.new(0, 34, 0.5, 0);
			NameLabel.AnchorPoint = Vector2.new(0, 0.5);
			NameLabel.Size = UDim2.new(1, -135, 0, 18);
			NameLabel.BackgroundTransparency = 1;
			NameLabel.Font = Enum.Font.GothamMedium;
			NameLabel.Text = labelText;
			NameLabel.TextColor3 = Color3.fromRGB(225, 225, 230);
			NameLabel.TextSize = 12;
			NameLabel.TextTransparency = 0.2;
			NameLabel.TextXAlignment = Enum.TextXAlignment.Left;
			NameLabel.ZIndex = LayerIndex + 9;

			RightBox.Name = NeverLose.RandomString();
			RightBox.Parent = RowFrame;
			RightBox.Position = UDim2.new(1, -8, 0.5, 0);
			RightBox.AnchorPoint = Vector2.new(1, 0.5);
			RightBox.Size = UDim2.new(0, 95, 0, 24);
			RightBox.BackgroundTransparency = 1;
			RightBox.ZIndex = LayerIndex + 9;

			NeverLose:AddSignal(RowFrame.MouseEnter:Connect(function()
				NeverLose.PlayAnimate(RowFrame, SlowyTween, { BackgroundTransparency = 0.45 });
			end));

			NeverLose:AddSignal(RowFrame.MouseLeave:Connect(function()
				NeverLose.PlayAnimate(RowFrame, SlowyTween, { BackgroundTransparency = 1 });
			end));

			return RowFrame, IconLabel, NameLabel, RightBox;
		end;

		-- 2. Menu Open Keybind Row (Top of user settings)
		local KeybindRow, KeybindIcon, KeybindTitle, KeybindRight = makeRow(2, "sliders-vertical", "Menu Keybind");
		local KeybindPill = Instance.new("Frame");
		local KeybindPillCorner = Instance.new("UICorner");
		local KeybindPillStroke = Instance.new("UIStroke");
		local KeybindVal = Instance.new("TextLabel");

		KeybindPill.Name = NeverLose.RandomString();
		KeybindPill.Parent = KeybindRight;
		KeybindPill.AnchorPoint = Vector2.new(1, 0.5);
		KeybindPill.Position = UDim2.new(1, 0, 0.5, 0);
		KeybindPill.Size = UDim2.new(0, 75, 0, 20);
		KeybindPill.BackgroundColor3 = Color3.fromRGB(22, 25, 33);
		KeybindPill.BorderSizePixel = 0;
		KeybindPill.ZIndex = LayerIndex + 10;

		KeybindPillCorner.CornerRadius = UDim.new(0, 4);
		KeybindPillCorner.Parent = KeybindPill;

		KeybindPillStroke.Color = Color3.fromRGB(55, 60, 75);
		KeybindPillStroke.Thickness = 1;
		KeybindPillStroke.Transparency = 0.3;
		KeybindPillStroke.Parent = KeybindPill;

		KeybindVal.Name = NeverLose.RandomString();
		KeybindVal.Parent = KeybindPill;
		KeybindVal.Size = UDim2.new(1, 0, 1, 0);
		KeybindVal.BackgroundTransparency = 1;
		KeybindVal.Font = Enum.Font.GothamMedium;
		local curKb = (WinRef and WinRef.Keybind) or "Insert";
		KeybindVal.Text = tostring(typeof(curKb) == "EnumItem" and curKb.Name or curKb);
		KeybindVal.TextColor3 = Color3.fromRGB(200, 205, 220);
		KeybindVal.TextSize = 11;
		KeybindVal.TextXAlignment = Enum.TextXAlignment.Center;
		KeybindVal.ZIndex = LayerIndex + 11;

		local isListeningKey = false;
		NeverLose:CreateInput(KeybindRow, function()
			if isListeningKey then return end;
			isListeningKey = true;
			KeybindVal.Text = "...";
			KeybindVal.TextColor3 = NeverLose.AccentColor;
			KeybindPillStroke.Color = NeverLose.AccentColor;
			closeAllSubmenus();

			local con;
			con = UserInputService.InputBegan:Connect(function(keyInp)
				if keyInp.KeyCode ~= Enum.KeyCode.Unknown then
					con:Disconnect();
					isListeningKey = false;
					KeybindPillStroke.Color = Color3.fromRGB(55, 60, 75);
					if keyInp.KeyCode == Enum.KeyCode.Escape then
						local k = (WinRef and WinRef.Keybind) or "Insert";
						KeybindVal.Text = tostring(typeof(k) == "EnumItem" and k.Name or k);
						KeybindVal.TextColor3 = Color3.fromRGB(200, 205, 220);
						return;
					end;
					local chosenName = keyInp.KeyCode.Name;
					NeverLose.IsRebindingKey = true;
					if WinRef then
						WinRef.Keybind = keyInp.KeyCode;
					end;
					KeybindVal.Text = chosenName;
					KeybindVal.TextColor3 = Color3.fromRGB(255, 255, 255);
					task.delay(0.25, function()
						NeverLose.IsRebindingKey = false;
					end);
				end;
			end);
		end);

		-- 3. Language Row
		local LangRow, LangIcon, LangTitle, LangRight = makeRow(3, "globe", "Language");
		local LangVal = Instance.new("TextLabel");
		LangVal.Name = NeverLose.RandomString();
		LangVal.Parent = LangRight;
		LangVal.Size = UDim2.new(1, 0, 1, 0);
		LangVal.BackgroundTransparency = 1;
		LangVal.Font = Enum.Font.GothamMedium;
		LangVal.Text = "English >";
		LangVal.TextColor3 = Color3.fromRGB(160, 165, 180);
		LangVal.TextSize = 12;
		LangVal.TextXAlignment = Enum.TextXAlignment.Right;
		LangVal.ZIndex = LayerIndex + 10;

		local LangFlyout = NeverLose:CreateFlyoutSubmenu(LangRow, 110);
		table.insert(Submenus, LangFlyout);

		local function updateLanguage(lang)
			closeAllSubmenus();
			LangFlyout:SetSelected(lang);
			if lang == "Russian" or lang == "Русский" then
				NeverLose.Language = "ru";
				LangVal.Text = "Русский >";
				LangTitle.Text = "Язык";
			else
				NeverLose.Language = "en";
				LangVal.Text = "English >";
				LangTitle.Text = "Language";
			end;
		end;

		LangFlyout:AddItem("English", true, updateLanguage);
		LangFlyout:AddItem("Русский", false, updateLanguage);

		NeverLose:CreateInput(LangRow, function()
			if LangFlyout.IsOpen then
				LangFlyout:Close();
			else
				closeAllSubmenus();
				LangFlyout:Open();
			end;
		end);

		-- 4. Menu Scale Row
		local ScaleRow, ScaleIcon, ScaleTitle, ScaleRight = makeRow(4, "arrow-up-down", "Menu Scale");
		local ScaleVal = Instance.new("TextLabel");
		ScaleVal.Name = NeverLose.RandomString();
		ScaleVal.Parent = ScaleRight;
		ScaleVal.Size = UDim2.new(1, 0, 1, 0);
		ScaleVal.BackgroundTransparency = 1;
		ScaleVal.Font = Enum.Font.GothamMedium;
		ScaleVal.Text = "100% >";
		ScaleVal.TextColor3 = Color3.fromRGB(160, 165, 180);
		ScaleVal.TextSize = 12;
		ScaleVal.TextXAlignment = Enum.TextXAlignment.Right;
		ScaleVal.ZIndex = LayerIndex + 10;

		local ScaleFlyout = NeverLose:CreateFlyoutSubmenu(ScaleRow, 115);
		table.insert(Submenus, ScaleFlyout);

		local scales = {
			{ label = "Auto", scale = 1.0 },
			{ label = "75%", scale = 0.75 },
			{ label = "100%", scale = 1.0 },
			{ label = "125%", scale = 1.25 },
			{ label = "150%", scale = 1.5 },
			{ label = "175%", scale = 1.75 },
			{ label = "200%", scale = 2.0 },
		};

		for _, item in ipairs(scales) do
			ScaleFlyout:AddItem(item.label, item.label == "100%", function(choice)
				closeAllSubmenus();
				ScaleFlyout:SetSelected(choice);
				ScaleVal.Text = choice .. " >";
				if WinRef and WinRef.SetSize then
					local baseW = 640;
					local baseH = 480;
					local newW = math.floor(baseW * item.scale);
					local newH = math.floor(baseH * item.scale);
					WinRef:SetSize(UDim2.new(0, newW, 0, newH));
				end;
			end);
		end;

		NeverLose:CreateInput(ScaleRow, function()
			if ScaleFlyout.IsOpen then
				ScaleFlyout:Close();
			else
				closeAllSubmenus();
				ScaleFlyout:Open();
			end;
		end);

		-- 5. Style Row (Color customizer + Settings gear flyout with Watermark toggle)
		local StyleRow, StyleIcon, StyleTitle, StyleRight = makeRow(5, "palette", "Style");

		local StyleGear = Instance.new("TextLabel");
		StyleGear.Name = NeverLose.RandomString();
		StyleGear.Parent = StyleRight;
		StyleGear.Position = UDim2.new(1, -26, 0.5, 0);
		StyleGear.AnchorPoint = Vector2.new(1, 0.5);
		StyleGear.Size = UDim2.new(0, 18, 0, 18);
		StyleGear.BackgroundTransparency = 1;
		StyleGear.FontFace = NeverLose.BuiltInBold;
		StyleGear.Text = "gear";
		StyleGear.TextSize = 13;
		StyleGear.TextColor3 = Color3.fromRGB(160, 165, 180);
		StyleGear.ZIndex = LayerIndex + 10;

		local StyleSwatch = Instance.new("Frame");
		local SwatchCorner = Instance.new("UICorner");
		local SwatchStroke = Instance.new("UIStroke");

		StyleSwatch.Name = NeverLose.RandomString();
		StyleSwatch.Parent = StyleRight;
		StyleSwatch.Position = UDim2.new(1, 0, 0.5, 0);
		StyleSwatch.AnchorPoint = Vector2.new(1, 0.5);
		StyleSwatch.Size = UDim2.new(0, 18, 0, 18);
		StyleSwatch.BackgroundColor3 = NeverLose.AccentColor;
		StyleSwatch.BorderSizePixel = 0;
		StyleSwatch.ZIndex = LayerIndex + 10;

		SwatchCorner.CornerRadius = UDim.new(0, 4);
		SwatchCorner.Parent = StyleSwatch;

		SwatchStroke.Color = Color3.fromRGB(60, 65, 80);
		SwatchStroke.Thickness = 1;
		SwatchStroke.Parent = StyleSwatch;

		NeverLose:RegisterAccent(StyleSwatch, "BackgroundColor3");

		local cpInstance = NeverLose:CreateColorPicker(StyleSwatch);
		cpInstance:SetValue(NeverLose.AccentColor);
		cpInstance.Callback = function(newCol)
			StyleSwatch.BackgroundColor3 = newCol;
			NeverLose:SetAccentColor(newCol);
		end;

		local cpOpen = false;
		local cpInputSig;
		NeverLose:CreateInput(StyleSwatch, function()
			closeAllSubmenus();
			cpOpen = not cpOpen;
			if cpOpen then
				cpInstance.SetRender(true);
				NeverLose.IsMosueOverOtherFrame = true;
				if cpInputSig then cpInputSig:Disconnect() end;
				cpInputSig = UserInputService.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						if not NeverLose:IsMouseOverFrame(cpInstance.Root) and not NeverLose:IsMouseOverFrame(StyleSwatch) then
							cpOpen = false;
							NeverLose.IsMosueOverOtherFrame = false;
							cpInstance.SetRender(false);
							if cpInputSig then cpInputSig:Disconnect(); cpInputSig = nil; end;
						end;
					end;
				end);
			else
				NeverLose.IsMosueOverOtherFrame = false;
				cpInstance.SetRender(false);
				if cpInputSig then cpInputSig:Disconnect(); cpInputSig = nil; end;
			end;
		end);

		-- Style Settings Flyout (Includes Watermark toggle & options)
		local StyleFlyout = NeverLose:CreateFlyoutSubmenu(StyleRow, 155);
		table.insert(Submenus, StyleFlyout);

		local function addStyleToggle(label, defaultVal, onToggle)
			local Item = Instance.new("Frame");
			local ItemLabel = Instance.new("TextLabel");
			local Sw = Instance.new("Frame");
			local SwCorner = Instance.new("UICorner");
			local Kn = Instance.new("Frame");
			local KnCorner = Instance.new("UICorner");

			Item.Name = NeverLose.RandomString();
			Item.Parent = StyleFlyout.Root;
			Item.BackgroundTransparency = 1;
			Item.Size = UDim2.new(1, 0, 0, 24);
			Item.ZIndex = 46;

			ItemLabel.Name = NeverLose.RandomString();
			ItemLabel.Parent = Item;
			ItemLabel.Position = UDim2.new(0, 6, 0.5, 0);
			ItemLabel.AnchorPoint = Vector2.new(0, 0.5);
			ItemLabel.Size = UDim2.new(1, -38, 1, 0);
			ItemLabel.BackgroundTransparency = 1;
			ItemLabel.Font = Enum.Font.GothamMedium;
			ItemLabel.TextSize = 12;
			ItemLabel.TextColor3 = Color3.fromRGB(220, 220, 225);
			ItemLabel.TextXAlignment = Enum.TextXAlignment.Left;
			ItemLabel.Text = label;
			ItemLabel.ZIndex = 47;

			Sw.Name = NeverLose.RandomString();
			Sw.Parent = Item;
			Sw.Position = UDim2.new(1, -2, 0.5, 0);
			Sw.AnchorPoint = Vector2.new(1, 0.5);
			Sw.Size = UDim2.new(0, 26, 0, 14);
			Sw.BackgroundColor3 = defaultVal and NeverLose.AccentColor or Color3.fromRGB(35, 38, 48);
			Sw.ZIndex = 47;

			SwCorner.CornerRadius = UDim.new(1, 0);
			SwCorner.Parent = Sw;

			Kn.Name = NeverLose.RandomString();
			Kn.Parent = Sw;
			Kn.Position = defaultVal and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0);
			Kn.AnchorPoint = Vector2.new(0, 0.5);
			Kn.Size = UDim2.new(0, 10, 0, 10);
			Kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Kn.ZIndex = 48;

			KnCorner.CornerRadius = UDim.new(1, 0);
			KnCorner.Parent = Kn;

			local state = defaultVal;
			NeverLose:CreateInput(Item, function()
				state = not state;
				if state then
					NeverLose.PlayAnimate(Sw, SlowyTween, { BackgroundColor3 = NeverLose.AccentColor });
					NeverLose.PlayAnimate(Kn, SlowyTween, { Position = UDim2.new(1, -12, 0.5, 0) });
				else
					NeverLose.PlayAnimate(Sw, SlowyTween, { BackgroundColor3 = Color3.fromRGB(35, 38, 48) });
					NeverLose.PlayAnimate(Kn, SlowyTween, { Position = UDim2.new(0, 2, 0.5, 0) });
				end;
				if onToggle then onToggle(state) end;
			end);
		end;

		-- Watermark toggle inside Style
		addStyleToggle("Watermark", true, function(val)
			if WinRef and WinRef.WatermarkObj then
				WinRef.WatermarkObj:SetRender(val);
			end;
		end);
		addStyleToggle("Show FPS", true, function(val)
			if WinRef and WinRef.WatermarkBlocks and WinRef.WatermarkBlocks.Fps then
				WinRef.WatermarkBlocks.Fps:SetVisible(val);
			end;
		end);
		addStyleToggle("Show Ping", true, function(val)
			if WinRef and WinRef.WatermarkBlocks and WinRef.WatermarkBlocks.Ping then
				WinRef.WatermarkBlocks.Ping:SetVisible(val);
			end;
		end);
		addStyleToggle("Show User", true, function(val)
			if WinRef and WinRef.WatermarkBlocks and WinRef.WatermarkBlocks.User then
				WinRef.WatermarkBlocks.User:SetVisible(val);
			end;
		end);
		addStyleToggle("Show Time", true, function(val)
			if WinRef and WinRef.WatermarkBlocks and WinRef.WatermarkBlocks.Time then
				WinRef.WatermarkBlocks.Time:SetVisible(val);
			end;
		end);

		NeverLose:CreateInput(StyleGear, function()
			if StyleFlyout.IsOpen then
				StyleFlyout:Close();
			else
				closeAllSubmenus();
				StyleFlyout:Open();
			end;
		end);

		-- 6. Divider Line
		local SepRow = Instance.new("Frame");
		local SepLine = Instance.new("Frame");
		SepRow.Name = NeverLose.RandomString();
		SepRow.Parent = Frame;
		SepRow.BackgroundTransparency = 1;
		SepRow.Size = UDim2.new(1, 0, 0, 7);
		SepRow.LayoutOrder = 6;
		SepRow.ZIndex = LayerIndex + 8;

		SepLine.Name = NeverLose.RandomString();
		SepLine.Parent = SepRow;
		SepLine.Position = UDim2.new(0.5, 0, 0.5, 0);
		SepLine.AnchorPoint = Vector2.new(0.5, 0.5);
		SepLine.Size = UDim2.new(1, -16, 0, 1);
		SepLine.BackgroundColor3 = Color3.fromRGB(45, 48, 58);
		SepLine.BackgroundTransparency = 0.65;
		SepLine.BorderSizePixel = 0;
		SepLine.ZIndex = LayerIndex + 9;

		-- 7. Unload UI Row
		local UnloadRow, UnloadIcon, UnloadTitle, UnloadRight = makeRow(7, "arrow-right-from-portrait-rectangle", "Unload UI");
		UnloadIcon.TextColor3 = Color3.fromRGB(255, 75, 75);
		UnloadTitle.TextColor3 = Color3.fromRGB(255, 75, 75);
		UnloadTitle.Font = Enum.Font.GothamBold;

		NeverLose:AddSignal(UnloadRow.MouseEnter:Connect(function()
			NeverLose.PlayAnimate(UnloadRow, SlowyTween, {
				BackgroundColor3 = Color3.fromRGB(255, 60, 60),
				BackgroundTransparency = 0.88
			});
		end));
		NeverLose:AddSignal(UnloadRow.MouseLeave:Connect(function()
			NeverLose.PlayAnimate(UnloadRow, SlowyTween, {
				BackgroundColor3 = Color3.fromRGB(28, 31, 40),
				BackgroundTransparency = 1
			});
		end));

		NeverLose:CreateInput(UnloadRow, function()
			closeAllSubmenus();
			NeverLose:Unload();
		end);

		-- Render binding
		UserFrameItem.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if not value then
				closeAllSubmenus();
				if cpOpen then
					cpOpen = false;
					cpInstance.SetRender(false);
				end;
			end;
		end);

		UserFrameItem.SetRender(Signel:GetValue());
		Signel:Connect(UserFrameItem.SetRender);

		function UserFrameItem:SetUsername(name)
			UserLabel.Text = name or "User";
		end;

		function UserFrameItem:SetProfile(p)
			AvatarImage.Image = p or "rbxasset://textures/ui/clb_robux_20@3x.png";
		end;

		function UserFrameItem:SetExpires(e)
			UserStatusLabel.Text = "Till: " .. (e or "Lifetime");
		end;

		function UserFrameItem:CloseSubmenus()
			closeAllSubmenus();
			if cpOpen then
				cpOpen = false;
				cpInstance.SetRender(false);
			end;
		end;

		return UserFrameItem;
	end;

	function idx:AddToggle(Config)
		Config = Config or {};
		local label = idx:AddLabel(Config.Name or "Toggle", false, Config);
		local tLib = label:AddToggle(Config);
		function tLib:ToolTip(c)
			label:ToolTip(c);
			return tLib;
		end;

		local function onRightClick(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton2 then
				NeverLose:OpenElementBindMenu(label.Root, Config, tLib, "Toggle");
			end;
		end;
		label.Root.InputBegan:Connect(onRightClick);
		if label.BasedLabel then
			label.BasedLabel.InputBegan:Connect(onRightClick);
		end;
		if tLib.Root then
			tLib.Root.InputBegan:Connect(onRightClick);
		end;

		return tLib;
	end;

	function idx:AddSlider(Config)
		Config = Config or {};
		local label = idx:AddLabel(Config.Name or "Slider", false, Config);
		local sLib = label:AddSlider(Config);
		function sLib:ToolTip(c)
			label:ToolTip(c);
			return sLib;
		end;

		local function onRightClick(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton2 then
				NeverLose:OpenElementBindMenu(label.Root, Config, sLib, "Slider");
			end;
		end;
		label.Root.InputBegan:Connect(onRightClick);
		if label.BasedLabel then
			label.BasedLabel.InputBegan:Connect(onRightClick);
		end;
		if sLib.Root then
			sLib.Root.InputBegan:Connect(onRightClick);
		end;

		return sLib;
	end;

	function idx:AddDropdown(Config)
		Config = Config or {};
		local label = idx:AddLabel(Config.Name or "Dropdown", false, Config);
		local dLib = label:AddDropdown(Config);
		function dLib:ToolTip(c)
			label:ToolTip(c);
			return dLib;
		end;
		return dLib;
	end;

	function idx:AddColorPicker(Config)
		Config = Config or {};
		local label = idx:AddLabel(Config.Name or "Color", false, Config);
		local cLib = label:AddColorPicker(Config);
		function cLib:ToolTip(c)
			label:ToolTip(c);
			return cLib;
		end;
		return cLib;
	end;

	function idx:AddKeybind(Config)
		Config = Config or {};
		local label = idx:AddLabel(Config.Name or "Keybind", false, Config);
		local kLib = label:AddKeybind(Config);
		function kLib:ToolTip(c)
			label:ToolTip(c);
			return kLib;
		end;
		return kLib;
	end;

	return idx;
end;

function NeverLose:CreateWindow(Config)
	Config = NeverLose:ProcessParams(Config , {
		Logo = NeverLose.GlobalLogo,
		Name = "Whispy",
		Content = "",
		Size = UDim2.new(0, 640, 0, 480),
		ConfigFolder = "NeverLoseConfigs",
		Enable3DRenderer = false,
		Keybind = "Insert"
	});

	local Window = {
		Logo = Config.Logo,
		Name = Config.Name,
		Content = Config.Content,
		Size = Config.Size,
		ConfigFolder = Config.ConfigFolder,
		Signal = NeverLose:CreateSignal(true),
		Tabs = {},
		CurrentTab = 1,
		Keybind = Config.Keybind,
		Enable3DRenderer = Config.Enable3DRenderer
	};

	NeverLose.ActiveWindow = Window;

	NeverLose.GlobalLogo = Window.Logo;

	local Logging = NeverLose:CreateLogger();
	if not isfolder(Window.ConfigFolder) then
		makefolder(Window.ConfigFolder);
	end;

	local WindowFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local LeftMenuFrame = Instance.new("Frame")
	local HeadFrame = Instance.new("Frame")
	local LogoImage = Instance.new("ImageLabel")
	local UICorner_2 = Instance.new("UICorner")
	local WindowName = Instance.new("TextLabel")
	local WindowContent = Instance.new("TextLabel")
	local LineFrame = Instance.new("Frame")
	local LeftScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local BottomFrame = Instance.new("Frame")
	local AccountProfile = Instance.new("ImageLabel")
	local UICorner_3 = Instance.new("UICorner")
	local AccountName = Instance.new("TextLabel")
	local ExpireLabel = Instance.new("TextLabel")
	local LineFrame_2 = Instance.new("Frame")
	local UserSettingButton = Instance.new("TextLabel")
	local RightMenuFrame = Instance.new("Frame")
	local UIStroke = Instance.new("UIStroke")
	local UICorner_4 = Instance.new("UICorner")
	local RightHeader = Instance.new("Frame")
	local LineFrame_3 = Instance.new("Frame")
	local ConfigFrame = Instance.new("Frame")
	local UIStroke_2 = Instance.new("UIStroke")
	local UICorner_5 = Instance.new("UICorner")
	local ConfigIcon = Instance.new("TextLabel")
	local LineFrame_4 = Instance.new("Frame")
	local ConfigName = Instance.new("TextLabel")
	local ConfigBthIcon = Instance.new("TextLabel")
	local SearchFrame = Instance.new("Frame")
	local SearchIcon = Instance.new("TextLabel")
	local SearchBox = Instance.new("TextBox")
	local TabContainer = Instance.new("Frame")

	WindowFrame.Name = NeverLose.RandomString();
	WindowFrame.Parent = NeverLose.ScreenGui;
	WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	WindowFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
	WindowFrame.BackgroundTransparency = 0.055
	WindowFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	WindowFrame.BorderSizePixel = 0
	WindowFrame.ClipsDescendants = true
	WindowFrame.Position = UDim2.new(255, 0, 255, 0)
	WindowFrame.Size = Window.Size
	NeverLose.MainWindow = WindowFrame
	WindowFrame.Active = true;

	if not NeverLose.EnabledBlur then
		WindowFrame.BackgroundTransparency = 0.0255
	end;

	local renderParentWindow = LPH_NO_VIRTUALIZE(function()
		if Window.__3DRender then
			if WindowFrame.BackgroundTransparency > 0.9 then
				WindowFrame.Visible = false;
				WindowFrame.Parent = nil
			else
				WindowFrame.Visible = true;

				NeverLose.PlayAnimate(WindowFrame,VSlowTween , {
					Position = UDim2.fromScale(0.5,0.5);
				});

				WindowFrame.Parent = Window.SurfaceGui;
			end;
		else
			if WindowFrame.BackgroundTransparency > 0.9 then
				WindowFrame.Visible = false;
				WindowFrame.Parent = nil
			else
				WindowFrame.Visible = true;
				WindowFrame.Parent = NeverLose.ScreenGui


			end;
		end;
	end);

	NeverLose:AddSignal(WindowFrame:GetPropertyChangedSignal('BackgroundTransparency'):Connect(renderParentWindow))

	Window.SetRender = LPH_NO_VIRTUALIZE(function(self , value)
		NeverLose.IsGuiOpen = value;
		if value then
			task.delay(0.05, function()
				if NeverLose.UpdateHotkeysHUD then NeverLose:UpdateHotkeysHUD() end
			end);
			NeverLose.PlayAnimate(WindowFrame , SlowyTween , {
				BackgroundTransparency = (NeverLose.EnabledBlur and 0.055) or 0.0255,
				Size = Window.Size
			})

			NeverLose.PlayAnimate(LogoImage , SlowyTween , {
				ImageTransparency = 0
			})

			NeverLose.PlayAnimate(WindowName , SlowyTween , {
				TextTransparency = 0
			})

			NeverLose.PlayAnimate(WindowContent , SlowyTween , {
				TextTransparency = 0.650
			})

			NeverLose.PlayAnimate(LineFrame , SlowyTween , {
				BackgroundTransparency = 0.650
			})

			NeverLose.PlayAnimate(AccountProfile , SlowyTween , {
				ImageTransparency = 0
			})

			NeverLose.PlayAnimate(AccountName , SlowyTween , {
				TextTransparency = 0
			})

			NeverLose.PlayAnimate(ExpireLabel , SlowyTween , {
				TextTransparency = 0.650
			})

			NeverLose.PlayAnimate(LineFrame_2 , SlowyTween , {
				BackgroundTransparency = 0.650
			})

			NeverLose.PlayAnimate(UserSettingButton , SlowyTween , {
				TextTransparency = 0.5
			})

			NeverLose.PlayAnimate(RightMenuFrame , SlowyTween , {
				BackgroundTransparency = 0.600
			})

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 0.650
			})

			NeverLose.PlayAnimate(LineFrame_3 , SlowyTween , {
				BackgroundTransparency = 0.650
			})

			NeverLose.PlayAnimate(ConfigFrame , SlowyTween , {
				BackgroundTransparency = 0.750
			})

			NeverLose.PlayAnimate(UIStroke_2 , SlowyTween , {
				Transparency = 0.650
			})

			NeverLose.PlayAnimate(ConfigIcon , SlowyTween , {
				TextTransparency = 0.250
			})

			NeverLose.PlayAnimate(LineFrame_4 , SlowyTween , {
				BackgroundTransparency = 0.650
			})

			NeverLose.PlayAnimate(ConfigName , SlowyTween , {
				TextTransparency = 0.350
			})

			NeverLose.PlayAnimate(ConfigBthIcon , SlowyTween , {
				TextTransparency = 0.250
			})

			NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
				TextTransparency = 0.250
			})

			NeverLose.PlayAnimate(SearchBox , SlowyTween , {
				TextTransparency = 0.350
			})

			Window.Shadow:Render(true);
		else

			NeverLose.PlayAnimate(WindowFrame , SlowyTween , {
				BackgroundTransparency = 1,
				Size = Window.Size + UDim2.fromOffset(-15,-15)
			})

			NeverLose.PlayAnimate(LogoImage , SlowyTween , {
				ImageTransparency = 1
			})

			NeverLose.PlayAnimate(WindowName , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(WindowContent , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(LineFrame , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(AccountProfile , SlowyTween , {
				ImageTransparency = 1
			})

			NeverLose.PlayAnimate(AccountName , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(ExpireLabel , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(LineFrame_2 , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UserSettingButton , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(RightMenuFrame , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(LineFrame_3 , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(ConfigFrame , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke_2 , SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(ConfigIcon , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(LineFrame_4 , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(ConfigName , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(ConfigBthIcon , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(SearchBox , SlowyTween , {
				TextTransparency = 1
			})

			Window.Shadow:Render(false);
			task.delay(0.2, function()
				if NeverLose.UpdateHotkeysHUD then NeverLose:UpdateHotkeysHUD() end
			end);
		end;
	end);

	Window.Shadow = NeverLose:CreateShadow(WindowFrame);
	Window.Shadow:Render(false);

	task.delay(0.25,function()
		WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		Window:SetRender(true);
		NeverLose:AddSignal(Window.Signal:Connect(LPH_NO_VIRTUALIZE(function(...)
			Window:SetRender(...);
			local isGuiOpen = Window.Signal:GetValue();
			NeverLose.IsGuiOpen = isGuiOpen;
			if not isGuiOpen then
				if Window.UserSettings then
					if Window.UserSettings.Signal then
						Window.UserSettings.Signal:SetValue(false);
					end;
					if Window.UserSettings.Root then
						Window.UserSettings.Root.Visible = false;
						Window.UserSettings.Root.Parent = nil;
					end;
					if Window.UserSettings.UserFrame and Window.UserSettings.UserFrame.CloseSubmenus then
						Window.UserSettings.UserFrame:CloseSubmenus();
					end;
				end;
				if Window.ClearGlobalSearch then
					Window.ClearGlobalSearch();
				end;
				if Window.SearchBox then
					Window.SearchBox.Text = "";
				end;
			end;
			task.delay(0.15, function()
				if NeverLose.UpdateHotkeysHUD then NeverLose:UpdateHotkeysHUD() end
			end);
		end)))
	end)

	if NeverLose.EnabledBlur then
		NeverLose:CreateBlurModule(WindowFrame,Window.Signal);
	end;

	do
		local Frame = Instance.new("Frame")

		Frame.Parent = WindowFrame
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Size = UDim2.new(1, 0, 0, 50)
		Frame.ZIndex = 7
		Frame.BackgroundTransparency = 1;

		NeverLose.Drag(Frame , WindowFrame , 0.15)
	end

	UICorner.Parent = WindowFrame

	LeftMenuFrame.Name = NeverLose.RandomString();
	LeftMenuFrame.Parent = WindowFrame
	LeftMenuFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LeftMenuFrame.BackgroundTransparency = 1.000
	LeftMenuFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LeftMenuFrame.BorderSizePixel = 0
	LeftMenuFrame.Size = UDim2.new(0, 175, 1, 0)

	HeadFrame.Name = NeverLose.RandomString();
	HeadFrame.Parent = LeftMenuFrame
	HeadFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HeadFrame.BackgroundTransparency = 1.000
	HeadFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HeadFrame.BorderSizePixel = 0
	HeadFrame.Size = UDim2.new(1, 0, 0, 50)
	HeadFrame.ZIndex = 7

	LogoImage.Name = NeverLose.RandomString();
	LogoImage.Parent = HeadFrame
	LogoImage.AnchorPoint = Vector2.new(0, 0.5)
	LogoImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LogoImage.BackgroundTransparency = 1.000
	LogoImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LogoImage.BorderSizePixel = 0
	LogoImage.Position = UDim2.new(0, 10, 0.5, 0)
	LogoImage.Size = UDim2.new(0, 35, 0, 35)
	LogoImage.ZIndex = 7
	if Window.Logo and Window.Logo ~= "" and Window.Logo ~= NeverLose.GlobalLogo then
		LogoImage.Image = Window.Logo
		LogoImage.ImageColor3 = NeverLose.AccentColor
		LogoImage.Visible = true
		WindowName.Position = UDim2.new(0, 55, 0, 12)
	else
		LogoImage.Visible = false
		WindowName.Position = UDim2.new(0, 16, 0, 12)
	end
	WindowContent.Visible = false

	UICorner_2.CornerRadius = UDim.new(0, 7)
	UICorner_2.Parent = LogoImage

	WindowName.Name = NeverLose.RandomString();
	WindowName.Parent = HeadFrame
	WindowName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WindowName.BackgroundTransparency = 1.000
	WindowName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	WindowName.BorderSizePixel = 0
	WindowName.Position = UDim2.new(0, 55, 0, 4)
	WindowName.Size = UDim2.new(0, 200, 0, 25)
	WindowName.ZIndex = 7
	WindowName.Font = Enum.Font.GothamBold
	WindowName.Text = Window.Name
	WindowName.TextColor3 = Color3.fromRGB(255, 255, 255)
	WindowName.TextSize = 18.000
	WindowName.TextXAlignment = Enum.TextXAlignment.Left

	WindowContent.Name = NeverLose.RandomString();
	WindowContent.Parent = HeadFrame
	WindowContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WindowContent.BackgroundTransparency = 1.000
	WindowContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
	WindowContent.BorderSizePixel = 0
	WindowContent.Position = UDim2.new(0, 55, 0, 25)
	WindowContent.Size = UDim2.new(0, 200, 0, 15)
	WindowContent.ZIndex = 7
	WindowContent.Font = Enum.Font.GothamBold
	WindowContent.Text = Window.Content
	WindowContent.TextColor3 = Color3.fromRGB(255, 255, 255)
	WindowContent.TextSize = 9.000
	WindowContent.TextTransparency = 0.650
	WindowContent.TextXAlignment = Enum.TextXAlignment.Left

	LineFrame.Name = NeverLose.RandomString();
	LineFrame.Parent = HeadFrame
	LineFrame.AnchorPoint = Vector2.new(0.5, 1)
	LineFrame.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
	LineFrame.BackgroundTransparency = 0.650
	LineFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LineFrame.BorderSizePixel = 0
	LineFrame.Position = UDim2.new(0.5, 0, 1, 0)
	LineFrame.Size = UDim2.new(1, -10, 0, 1)
	LineFrame.ZIndex = 5

	LeftScrollingFrame.Name = NeverLose.RandomString();
	LeftScrollingFrame.Parent = LeftMenuFrame
	LeftScrollingFrame.Active = true
	LeftScrollingFrame.AnchorPoint = Vector2.new(0.5, 0)
	LeftScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LeftScrollingFrame.BackgroundTransparency = 1.000
	LeftScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LeftScrollingFrame.BorderSizePixel = 0
	LeftScrollingFrame.Position = UDim2.new(0.5, 0, 0, 60)
	LeftScrollingFrame.Size = UDim2.new(1, -10, 1, -115)
	LeftScrollingFrame.ZIndex = 7
	LeftScrollingFrame.ScrollBarThickness = 0

	UIListLayout.Parent = LeftScrollingFrame
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
		LeftScrollingFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y + 1)
	end)))

	BottomFrame.Name = NeverLose.RandomString();
	BottomFrame.Parent = LeftMenuFrame
	BottomFrame.AnchorPoint = Vector2.new(0, 1)
	BottomFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BottomFrame.BackgroundTransparency = 1.000
	BottomFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BottomFrame.BorderSizePixel = 0
	BottomFrame.Position = UDim2.new(0, 0, 1, 0)
	BottomFrame.Size = UDim2.new(1, 0, 0, 50)
	BottomFrame.ZIndex = 7

	AccountProfile.Name = NeverLose.RandomString();
	AccountProfile.Parent = BottomFrame
	AccountProfile.AnchorPoint = Vector2.new(0, 0.5)
	AccountProfile.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	AccountProfile.BackgroundTransparency = 1.000
	AccountProfile.BorderColor3 = Color3.fromRGB(0, 0, 0)
	AccountProfile.BorderSizePixel = 0
	AccountProfile.Position = UDim2.new(0, 10, 0.5, 0)
	AccountProfile.Size = UDim2.new(0, 35, 0, 35)
	AccountProfile.ZIndex = 7
	AccountProfile.Image = NeverLose.UserProfile or ""

	UICorner_3.CornerRadius = UDim.new(1, 0)
	UICorner_3.Parent = AccountProfile

	AccountName.Name = NeverLose.RandomString();
	AccountName.Parent = BottomFrame
	AccountName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	AccountName.BackgroundTransparency = 1.000
	AccountName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	AccountName.BorderSizePixel = 0
	AccountName.Position = UDim2.new(0, 55, 0.5, 0)
	AccountName.AnchorPoint = Vector2.new(0, 0.5)
	AccountName.Size = UDim2.new(0, 105, 0, 25)
	AccountName.ZIndex = 7
	AccountName.Font = Enum.Font.GothamBold
	AccountName.Text = ""
	AccountName.TextColor3 = Color3.fromRGB(255, 255, 255)
	AccountName.TextSize = 14.000
	AccountName.TextXAlignment = Enum.TextXAlignment.Left
	AccountName.TextTruncate = Enum.TextTruncate.SplitWord;

	ExpireLabel.Name = NeverLose.RandomString();
	ExpireLabel.Parent = BottomFrame
	ExpireLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ExpireLabel.BackgroundTransparency = 1.000
	ExpireLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ExpireLabel.BorderSizePixel = 0
	ExpireLabel.Position = UDim2.new(0, 55, 0, 25)
	ExpireLabel.Size = UDim2.new(0, 200, 0, 15)
	ExpireLabel.ZIndex = 7
	ExpireLabel.Font = Enum.Font.GothamBold
	ExpireLabel.Text = ""
	ExpireLabel.Visible = false
	ExpireLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ExpireLabel.TextSize = 10.000
	ExpireLabel.TextTransparency = 0.650
	ExpireLabel.TextXAlignment = Enum.TextXAlignment.Left

	LineFrame_2.Name = NeverLose.RandomString();
	LineFrame_2.Parent = BottomFrame
	LineFrame_2.AnchorPoint = Vector2.new(0.5, 0)
	LineFrame_2.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
	LineFrame_2.BackgroundTransparency = 0.650
	LineFrame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LineFrame_2.BorderSizePixel = 0
	LineFrame_2.Position = UDim2.new(0.5, 0, 0, 0)
	LineFrame_2.Size = UDim2.new(1, -10, 0, 1)
	LineFrame_2.ZIndex = 5

	UserSettingButton.Name = NeverLose.RandomString();
	UserSettingButton.Parent = BottomFrame
	UserSettingButton.AnchorPoint = Vector2.new(1, 0.5)
	UserSettingButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	UserSettingButton.BackgroundTransparency = 1.000
	UserSettingButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	UserSettingButton.BorderSizePixel = 0
	UserSettingButton.Position = UDim2.new(1, -7, 0.5, 0)
	UserSettingButton.Size = UDim2.new(0, 25, 0, 25)
	UserSettingButton.ZIndex = 7
	UserSettingButton.FontFace = NeverLose.BuiltInBold
	UserSettingButton.Text = "chevron-large-right"
	UserSettingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	UserSettingButton.TextSize = 13.000
	UserSettingButton.TextTransparency = 0.5

	NeverLose:AddSignal(BottomFrame.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
		NeverLose.PlayAnimate(UserSettingButton,SlowyTween , {
			TextTransparency = 0.25
		})		
	end)))

	NeverLose:AddSignal(BottomFrame.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
		NeverLose.PlayAnimate(UserSettingButton,SlowyTween , {
			TextTransparency = 0.5
		})		
	end)))

	RightMenuFrame.Name = NeverLose.RandomString();
	RightMenuFrame.Parent = WindowFrame
	RightMenuFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
	RightMenuFrame.BackgroundTransparency = 0.600
	RightMenuFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	RightMenuFrame.BorderSizePixel = 0
	RightMenuFrame.ClipsDescendants = true
	RightMenuFrame.Position = UDim2.new(0, 176, 0, 0)
	RightMenuFrame.Size = UDim2.new(1, -176, 1, 0)
	RightMenuFrame.ZIndex = 8

	UIStroke.Transparency = 0.650
	UIStroke.Color = Color3.fromRGB(45, 48, 58)
	UIStroke.Parent = RightMenuFrame

	UICorner_4.CornerRadius = UDim.new(0, 13)
	UICorner_4.Parent = RightMenuFrame

	RightHeader.Name = NeverLose.RandomString();
	RightHeader.Parent = RightMenuFrame
	RightHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	RightHeader.BackgroundTransparency = 1.000
	RightHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
	RightHeader.BorderSizePixel = 0
	RightHeader.Size = UDim2.new(1, 0, 0, 50)
	RightHeader.ZIndex = 9

	LineFrame_3.Name = NeverLose.RandomString();
	LineFrame_3.Parent = RightHeader
	LineFrame_3.AnchorPoint = Vector2.new(0.5, 1)
	LineFrame_3.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
	LineFrame_3.BackgroundTransparency = 0.650
	LineFrame_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LineFrame_3.BorderSizePixel = 0
	LineFrame_3.Position = UDim2.new(0.5, 0, 1, 0)
	LineFrame_3.Size = UDim2.new(1, -10, 0, 1)
	LineFrame_3.ZIndex = 9

	ConfigFrame.Name = NeverLose.RandomString();
	ConfigFrame.Parent = RightHeader
	ConfigFrame.AnchorPoint = Vector2.new(0, 0.5)
	ConfigFrame.BackgroundColor3 = Color3.fromRGB(13, 17, 22)
	ConfigFrame.BackgroundTransparency = 0.750
	ConfigFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ConfigFrame.BorderSizePixel = 0
	ConfigFrame.Position = UDim2.new(0, 10, 0.5, 0)
	ConfigFrame.Size = UDim2.new(0, 115, 0, 30)
	ConfigFrame.ZIndex = 9

	UIStroke_2.Transparency = 0.650
	UIStroke_2.Color = Color3.fromRGB(45, 48, 58)
	UIStroke_2.Parent = ConfigFrame

	UICorner_5.CornerRadius = UDim.new(0, 4)
	UICorner_5.Parent = ConfigFrame

	ConfigIcon.Name = NeverLose.RandomString();
	ConfigIcon.Parent = ConfigFrame
	ConfigIcon.AnchorPoint = Vector2.new(0, 0.5)
	ConfigIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ConfigIcon.BackgroundTransparency = 1.000
	ConfigIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ConfigIcon.BorderSizePixel = 0
	ConfigIcon.Position = UDim2.new(0, 2, 0.5, 0)
	ConfigIcon.Size = UDim2.new(0, 25, 0, 25)
	ConfigIcon.ZIndex = 9
	ConfigIcon.FontFace = NeverLose.BuiltInBold
	ConfigIcon.Text = "floppy-disk"
	ConfigIcon.TextColor3 = Color3.fromRGB(223, 223, 223)
	ConfigIcon.TextSize = 16.000
	ConfigIcon.TextTransparency = 0.250
	ConfigIcon.TextWrapped = true

	LineFrame_4.Name = NeverLose.RandomString();
	LineFrame_4.Parent = ConfigFrame
	LineFrame_4.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
	LineFrame_4.BackgroundTransparency = 0.650
	LineFrame_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LineFrame_4.BorderSizePixel = 0
	LineFrame_4.Position = UDim2.new(0, 30, 0, 0)
	LineFrame_4.Size = UDim2.new(0, 1, 1, 0)

	ConfigName.Name = NeverLose.RandomString();
	ConfigName.Parent = ConfigFrame
	ConfigName.AnchorPoint = Vector2.new(0, 0.5)
	ConfigName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ConfigName.BackgroundTransparency = 1.000
	ConfigName.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ConfigName.BorderSizePixel = 0
	ConfigName.Position = UDim2.new(0, 40, 0.5, 0)
	ConfigName.Size = UDim2.new(1, -7, 0, 15)
	ConfigName.ZIndex = 9
	ConfigName.Font = Enum.Font.GothamMedium
	ConfigName.Text = "Default"
	ConfigName.TextColor3 = Color3.fromRGB(255, 255, 255)
	ConfigName.TextSize = 12.000
	ConfigName.TextTransparency = 0.350
	ConfigName.TextXAlignment = Enum.TextXAlignment.Left

	ConfigBthIcon.Name = NeverLose.RandomString();
	ConfigBthIcon.Parent = ConfigFrame
	ConfigBthIcon.AnchorPoint = Vector2.new(1, 0.5)
	ConfigBthIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ConfigBthIcon.BackgroundTransparency = 1.000
	ConfigBthIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ConfigBthIcon.BorderSizePixel = 0
	ConfigBthIcon.Position = UDim2.new(1, -2, 0.5, 0)
	ConfigBthIcon.Size = UDim2.new(0, 25, 0, 25)
	ConfigBthIcon.ZIndex = 9
	ConfigBthIcon.FontFace = NeverLose.BuiltInBold
	ConfigBthIcon.Text = "chevron-small-down"
	ConfigBthIcon.TextColor3 = Color3.fromRGB(223, 223, 223)
	ConfigBthIcon.TextSize = 16.000
	ConfigBthIcon.TextTransparency = 0.250
	ConfigBthIcon.TextWrapped = true

	SearchFrame.Name = NeverLose.RandomString();
	SearchFrame.Parent = RightHeader
	SearchFrame.AnchorPoint = Vector2.new(1, 0.5)
	SearchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SearchFrame.BackgroundTransparency = 1.000
	SearchFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SearchFrame.BorderSizePixel = 0
	SearchFrame.ClipsDescendants = true
	SearchFrame.Position = UDim2.new(1, -10, 0.5, 0)
	SearchFrame.Size = UDim2.new(0, 30, 0, 30)
	SearchFrame.ZIndex = 12

	SearchIcon.Name = NeverLose.RandomString();
	SearchIcon.Parent = SearchFrame
	SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
	SearchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SearchIcon.BackgroundTransparency = 1.000
	SearchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SearchIcon.BorderSizePixel = 0
	SearchIcon.Position = UDim2.new(0, 2, 0.5, 0)
	SearchIcon.Size = UDim2.new(0, 25, 0, 25)
	SearchIcon.ZIndex = 12
	SearchIcon.FontFace = NeverLose.BuiltInBold
	SearchIcon.Text = "magnifying-glass"
	SearchIcon.TextColor3 = Color3.fromRGB(223, 223, 223)
	SearchIcon.TextSize = 14.000
	SearchIcon.TextTransparency = 0.45
	SearchIcon.TextWrapped = true

	SearchBox.Name = NeverLose.RandomString();
	SearchBox.Parent = SearchFrame
	SearchBox.AnchorPoint = Vector2.new(0, 0.5)
	SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SearchBox.BackgroundTransparency = 1.000
	SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SearchBox.BorderSizePixel = 0
	SearchBox.Position = UDim2.new(0, 35, 0.5, 0)
	SearchBox.Size = UDim2.new(1, -35, 0, 25)
	SearchBox.ZIndex = 12
	SearchBox.ClearTextOnFocus = false
	SearchBox.Font = Enum.Font.GothamMedium
	SearchBox.PlaceholderText = "Search"
	SearchBox.Text = ""
	SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	SearchBox.TextSize = 13.000
	SearchBox.TextTransparency = 1
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left

	TabContainer.Name = NeverLose.RandomString();
	TabContainer.Parent = RightMenuFrame
	TabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabContainer.BackgroundTransparency = 1.000
	TabContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabContainer.BorderSizePixel = 0
	TabContainer.ClipsDescendants = true
	TabContainer.Position = UDim2.new(0, 0, 0, 50)
	TabContainer.Size = UDim2.new(1, 0, 1, -50)
	TabContainer.ZIndex = 5

	do
		Window.Searching = false;
		local Input = NeverLose:CreateInput(SearchIcon , LPH_NO_VIRTUALIZE(function()
			Window.Searching = not Window.Searching;

			if Window.Searching then
				NeverLose.PlayAnimate(SearchFrame , VSlowTween , {
					Size = UDim2.new(0, 220, 0, 30)
				})

				NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
					TextTransparency = 0.25
				})

				NeverLose.PlayAnimate(SearchBox , VSlowTween , {
					TextTransparency = 0.350
				})
			else
				NeverLose.PlayAnimate(SearchFrame , VSlowTween , {
					Size = UDim2.new(0, 30, 0, 30)
				})

				NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
					TextTransparency = 0.45
				})

				NeverLose.PlayAnimate(SearchBox , SlowyTween , {
					TextTransparency = 1
				})

				SearchBox.Text = "";
			end;
		end));	

		-- Global Search Scroll Container (cross-tab breadcrumb results matching NeverLose reference)
		local GlobalSearchScroll = Instance.new("ScrollingFrame");
		local SearchListLayout = Instance.new("UIListLayout");
		local SearchPadding = Instance.new("UIPadding");

		GlobalSearchScroll.Name = NeverLose.RandomString();
		GlobalSearchScroll.Parent = RightMenuFrame;
		GlobalSearchScroll.BackgroundTransparency = 1.000;
		GlobalSearchScroll.BorderSizePixel = 0;
		GlobalSearchScroll.ClipsDescendants = true;
		GlobalSearchScroll.Position = UDim2.new(0, 0, 0, 50);
		GlobalSearchScroll.Size = UDim2.new(1, 0, 1, -50);
		GlobalSearchScroll.ZIndex = 8;
		GlobalSearchScroll.ScrollBarThickness = 2;
		GlobalSearchScroll.ScrollBarImageColor3 = NeverLose.AccentColor;
		GlobalSearchScroll.Visible = false;

		SearchListLayout.Parent = GlobalSearchScroll;
		SearchListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		SearchListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		SearchListLayout.Padding = UDim.new(0, 4);

		SearchPadding.Parent = GlobalSearchScroll;
		SearchPadding.PaddingTop = UDim.new(0, 8);
		SearchPadding.PaddingBottom = UDim.new(0, 15);
		SearchPadding.PaddingLeft = UDim.new(0, 14);
		SearchPadding.PaddingRight = UDim.new(0, 14);

		NeverLose:AddSignal(SearchListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			GlobalSearchScroll.CanvasSize = UDim2.fromOffset(0, SearchListLayout.AbsoluteContentSize.Y + 30);
		end));

		Window.SearchBox = SearchBox;

		local isGlobalSearching = false;

		local function restoreAllItems()
			for _, item in ipairs(NeverLose.NameRegisitry) do
				if item.Root and item.OriginalParent then
					pcall(function()
						if item.Root.Parent ~= item.OriginalParent then
							item.Root.Parent = item.OriginalParent;
							item.Root.LayoutOrder = item.OriginalLayoutOrder or 0;
						end;
						for _, d in ipairs(item.Root:GetDescendants()) do
							if d:IsA("TextLabel") and d.Text ~= "" then
								d.TextTransparency = 0.35;
							end;
						end;
					end);
				end;
			end;
		end;

		local function clearSearchScrollHeaders()
			for _, c in ipairs(GlobalSearchScroll:GetChildren()) do
				if not c:IsA("UIListLayout") and not c:IsA("UIPadding") and (c.Name:sub(1, 7) == "Header_" or c:FindFirstChild("Path")) then
					c:Destroy();
				end;
			end;
		end;

		local function clearGlobalSearch()
			if not isGlobalSearching and SearchBox.Text == "" then return end;
			isGlobalSearching = false;
			restoreAllItems();
			clearSearchScrollHeaders();
			GlobalSearchScroll.Visible = false;
			TabContainer.Visible = true;
			local curTab = Window.Tabs[Window.CurrentTab];
			if curTab then
				curTab.SetValue(true);
			end;
		end;
		Window.ClearGlobalSearch = clearGlobalSearch;

		local function performGlobalSearch(query)
			query = string.lower(query);
			if query == "" then
				clearGlobalSearch();
				return;
			end;
			isGlobalSearching = true;
			TabContainer.Visible = false;
			GlobalSearchScroll.Visible = true;

			restoreAllItems();
			clearSearchScrollHeaders();

			local groups = {};
			local groupOrder = {};
			for _, item in ipairs(NeverLose.NameRegisitry) do
				local nameMatch = item.Idx and string.find(string.lower(item.Idx), query, 1, true);
				local pathMatch = item.Path and string.find(string.lower(item.Path), query, 1, true);
				if nameMatch or pathMatch then
					local p = item.Path or "GENERAL";
					if not groups[p] then
						groups[p] = {
							Tab = item.Tab,
							Items = {}
						};
						table.insert(groupOrder, p);
					end;
					table.insert(groups[p].Items, item);
				end;
			end;

			local orderCounter = 0;
			for _, pathStr in ipairs(groupOrder) do
				local gData = groups[pathStr];
				orderCounter = orderCounter + 1;

				local HeaderFrame = Instance.new("Frame");
				HeaderFrame.Name = "Header_" .. orderCounter;
				HeaderFrame.Parent = GlobalSearchScroll;
				HeaderFrame.BackgroundTransparency = 1;
				HeaderFrame.Size = UDim2.new(1, 0, 0, 24);
				HeaderFrame.LayoutOrder = orderCounter;
				HeaderFrame.ZIndex = 9;

				local PathLabel = Instance.new("TextLabel");
				PathLabel.Name = "Path";
				PathLabel.Parent = HeaderFrame;
				PathLabel.BackgroundTransparency = 1;
				PathLabel.Position = UDim2.new(0, 4, 0.5, 0);
				PathLabel.AnchorPoint = Vector2.new(0, 0.5);
				PathLabel.Size = UDim2.new(1, -34, 1, 0);
				PathLabel.Font = Enum.Font.GothamBold;
				PathLabel.Text = pathStr;
				PathLabel.TextColor3 = Color3.fromRGB(110, 118, 140);
				PathLabel.TextSize = 10;
				PathLabel.TextXAlignment = Enum.TextXAlignment.Left;
				PathLabel.ZIndex = 10;

				local LinkBtn = Instance.new("TextButton");
				LinkBtn.Name = "Link";
				LinkBtn.Parent = HeaderFrame;
				LinkBtn.BackgroundTransparency = 1;
				LinkBtn.Position = UDim2.new(1, -22, 0.5, 0);
				LinkBtn.AnchorPoint = Vector2.new(1, 0.5);
				LinkBtn.Size = UDim2.new(0, 18, 0, 18);
				LinkBtn.FontFace = NeverLose.BuiltInBold;
				LinkBtn.Text = "link";
				LinkBtn.TextColor3 = Color3.fromRGB(130, 138, 160);
				LinkBtn.TextSize = 12;
				LinkBtn.ZIndex = 10;

				local function navigate()
					SearchBox.Text = "";
					clearGlobalSearch();
					if gData.Tab then
						for i, v in ipairs(Window.Tabs) do
							if v == gData.Tab then
								Window.CurrentTab = i;
								v.SetValue(true);
							else
								v.SetValue(false);
							end;
						end;
					end;
				end;

				LinkBtn.MouseButton1Click:Connect(navigate);
				PathLabel.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						navigate();
					end;
				end);

				for _, item in ipairs(gData.Items) do
					orderCounter = orderCounter + 1;
					item.Root.Parent = GlobalSearchScroll;
					item.Root.LayoutOrder = orderCounter;
					item.Root.Visible = true;
					item.Root.Size = UDim2.new(1, 0, 0, 30);
					for _, d in ipairs(item.Root:GetDescendants()) do
						if d:IsA("TextLabel") and d.Text ~= "" and d.TextTransparency > 0.7 then
							d.TextTransparency = 0.25;
						end;
					end;
				end;
			end;
		end;

		local wati_for_finish = tick();
		local last_thread;
		local max_time = 0.15;

		NeverLose:AddSignal(SearchBox:GetPropertyChangedSignal('Text'):Connect(LPH_NO_VIRTUALIZE(function()
			local txt = SearchBox.Text;
			if not txt or txt == "" then
				clearGlobalSearch();
				return;
			end;

			wati_for_finish = tick();
			if last_thread then
				task.cancel(last_thread);
				last_thread = nil;
			end;

			last_thread = task.delay(max_time, function()
				if SearchBox.Text ~= "" and (tick() - wati_for_finish) >= max_time - 0.05 then
					performGlobalSearch(SearchBox.Text);
				end;
			end);
		end)));

		NeverLose:AddSignal(Input.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
				TextTransparency = 0.25
			})
		end)))

		NeverLose:AddSignal(Input.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			if Window.Searching then
				NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
					TextTransparency = 0.25
				})
			else
				NeverLose.PlayAnimate(SearchIcon , SlowyTween , {
					TextTransparency = 0.45
				})
			end;
		end)));
	end;

	if Window.Enable3DRenderer then
		local Part = Instance.new('Part');

		Part.Name = NeverLose.RandomString();
		Part.Anchored = true;
		Part.Transparency = 1;
		Part.CanCollide = false;
		Part.CanTouch = false;
		Part.AudioCanCollide = false;
		Part.CollisionGroup = NeverLose.RandomString();
		Part.CFrame = CFrame.new(0,0,0);
		Part.Size = Vector3.zero;

		local SurfaceGui = Instance.new("SurfaceGui")

		SurfaceGui.Parent = NeverLose.ScreenGui;
		SurfaceGui.Adornee = Part;
		SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		SurfaceGui.AlwaysOnTop = true
		SurfaceGui.LightInfluence = 1.000
		SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
		SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize;
		SurfaceGui.PixelsPerStud = 40;

		Window.SurfaceGui = SurfaceGui;
		NeverLose.GlobalSurfaceGui = SurfaceGui;

		local PerfectScale = Vector2.new(1920 , 1080 + 300)

		Window.Load3DBlock = LPH_NO_VIRTUALIZE(function()
			if not Window.Signal:GetValue() then
				local _,OnScreen = CurrentCamera:WorldToViewportPoint(Part.Position);

				if OnScreen then
					NeverLose.PlayAnimate(Part,VSlowTween , {
						CFrame = CurrentCamera.CFrame * CFrame.new(0,0,-15) * CFrame.Angles(0,math.rad(180),0);
					});
				end;

				return
			end;

			local Dimensions = 50;

			local XY_Incom = Vector2.new(PerfectScale.X + 5, PerfectScale.Y * 1.35) / (Dimensions / 2);
			local PerfectDistance = XY_Incom.Magnitude;
			local SizeIndicator = PerfectDistance / 1.35;

			Part.Parent = NeverLose.BlurModuleParent or workspace;

			NeverLose.PlayAnimate(Part,VSlowTween , {
				CFrame = (CurrentCamera.CFrame * CFrame.new(0,0,-25)) * CFrame.Angles(0,math.rad(180),0);
			});

			Part.Size = Vector3.new(PerfectScale.X / SizeIndicator,PerfectScale.Y / SizeIndicator,0);
		end);

		function Window:Set3DRender(val)
			Window.__3DRender = val;
			NeverLose.Global3DRenderMode = val;

			if val then
				Window.Load3DBlock();
			else


				Part.Parent = nil;
			end;

			renderParentWindow();
		end;
	end;

	function Window:AddTabLabel(Name: string)
		local TabLabel = Instance.new("TextLabel")

		TabLabel.Name = NeverLose.RandomString()
		TabLabel.Parent = LeftScrollingFrame
		TabLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabLabel.BackgroundTransparency = 1.000
		TabLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabLabel.BorderSizePixel = 0
		TabLabel.Size = UDim2.new(1, -7, 0, 15)
		TabLabel.ZIndex = 8
		TabLabel.Font = Enum.Font.GothamMedium
		TabLabel.Text = Name
		TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabLabel.TextSize = 11.000
		TabLabel.TextTransparency = 0.500
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		local SetRender = LPH_NO_VIRTUALIZE(function(val)
			if val then
				NeverLose.PlayAnimate(TabLabel , SlowyTween,{
					TextTransparency = 0.500
				})
			else
				NeverLose.PlayAnimate(TabLabel , SlowyTween,{
					TextTransparency = 1
				})
			end
		end)

		SetRender(Window.Signal:GetValue());

		return Window.Signal:Connect(SetRender);
	end;

	function Window:AddTab(Config)
		Config = NeverLose:ProcessParams(Config , {
			Icon = "crosshairs",
			Name = "Tab",
			Type = "Double"
		});

		local Tab = {
			Signal = NeverLose:CreateSignal(false);
		};

		local TabButton = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local TabIcon = Instance.new("TextLabel")
		local TabContentLabel = Instance.new("TextLabel")

		Tab.Idx = TabButton;
		Tab.Name = Config.Name or "Tab";

		TabButton.Name = NeverLose.RandomString();
		TabButton.Parent = Config.Parent or LeftScrollingFrame
		TabButton.BackgroundColor3 = Color3.fromRGB(41, 45, 49)
		TabButton.BackgroundTransparency = 0.500
		TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, -1, 0, 30)
		TabButton.ZIndex = 8

		UICorner.CornerRadius = UDim.new(0, 6)
		UICorner.Parent = TabButton

		TabIcon.Name = NeverLose.RandomString();
		TabIcon.Parent = TabButton
		TabIcon.AnchorPoint = Vector2.new(0, 0.5)
		TabIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabIcon.BackgroundTransparency = 1.000
		TabIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabIcon.BorderSizePixel = 0
		TabIcon.Position = UDim2.new(0, 2, 0.5, 0)
		TabIcon.Size = UDim2.new(0, 25, 0, 25)
		TabIcon.ZIndex = 9
		TabIcon.FontFace = NeverLose.BuiltInBold
		TabIcon.Text = Config.Icon;
		TabIcon.TextColor3 = NeverLose.AccentColor
		TabIcon.TextSize = 16.000
		TabIcon.TextWrapped = true

		TabContentLabel.Name = NeverLose.RandomString();
		TabContentLabel.Parent = TabButton
		TabContentLabel.AnchorPoint = Vector2.new(0, 0.5)
		TabContentLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabContentLabel.BackgroundTransparency = 1.000
		TabContentLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabContentLabel.BorderSizePixel = 0
		TabContentLabel.Position = Config.IsSub and UDim2.new(0, 44, 0.5, 0) or UDim2.new(0, 30, 0.5, 0)
		if Config.IsSub then
			TabIcon.Position = UDim2.new(0, 16, 0.5, 0)
			TabButton.Size = UDim2.new(1, -1, 0, 26)
		end
		TabContentLabel.Size = UDim2.new(1, -7, 0, 15)
		TabContentLabel.ZIndex = 9
		TabContentLabel.Font = Enum.Font.GothamMedium
		TabContentLabel.Text = Config.Name
		TabContentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabContentLabel.TextSize = 12.000
		TabContentLabel.TextXAlignment = Enum.TextXAlignment.Left

		local TabFrame = Instance.new("Frame")
		local LeftScroll = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")
		local RightScroll = Instance.new("ScrollingFrame")
		local UIListLayout_2 = Instance.new("UIListLayout")

		TabFrame.Name = NeverLose.RandomString();
		TabFrame.Parent = TabContainer
		TabFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabFrame.BackgroundTransparency = 1.000
		TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabFrame.BorderSizePixel = 0
		TabFrame.ClipsDescendants = true
		TabFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		TabFrame.Size = UDim2.new(1, 0, 1, 0)
		TabFrame.Visible = true;

		LeftScroll.Name = NeverLose.RandomString();
		LeftScroll.Parent = TabFrame
		LeftScroll.Active = true
		LeftScroll.AnchorPoint = Vector2.new(0.5, 0.5)
		LeftScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		LeftScroll.BackgroundTransparency = 1.000
		LeftScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LeftScroll.BorderSizePixel = 0
		LeftScroll.ClipsDescendants = false
		LeftScroll.Position = UDim2.new(0.25, 0, 0.5, 0)
		LeftScroll.Size = UDim2.new(0.5, 0, 1, -5)
		LeftScroll.ScrollBarThickness = 0

		UIListLayout.Parent = LeftScroll
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 5)

		NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
			LeftScroll.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y + 1)
		end)))

		RightScroll.Name = NeverLose.RandomString();
		RightScroll.Parent = TabFrame
		RightScroll.Active = true
		RightScroll.AnchorPoint = Vector2.new(0.5, 0.5)
		RightScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		RightScroll.BackgroundTransparency = 1.000
		RightScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RightScroll.BorderSizePixel = 0
		RightScroll.ClipsDescendants = false
		RightScroll.Position = UDim2.new(0.75, 0, 0.5, 0)
		RightScroll.Size = UDim2.new(0.5, 0, 1, -5)
		RightScroll.ScrollBarThickness = 0

		UIListLayout_2.Parent = RightScroll
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.Padding = UDim.new(0, 5)

		if Config.Type == "Single" then
			UIListLayout_2:Destroy();
			RightScroll:Destroy();
			RightScroll = LeftScroll;
			UIListLayout_2 = UIListLayout;
			LeftScroll.Size = UDim2.new(1, 0, 1, -5);
			LeftScroll.Position = UDim2.new(0.5, 0, 0.5, 0)
		else
			NeverLose:AddSignal(UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
				RightScroll.CanvasSize = UDim2.fromOffset(0,UIListLayout_2.AbsoluteContentSize.Y + 1)
			end)))
		end;

		NeverLose:AddSignal(TabIcon:GetPropertyChangedSignal('TextTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
			if TabIcon.TextTransparency > 0.4 then
				TabFrame.Visible = false;
				TabFrame.Parent = nil;
			else
				TabFrame.Visible = true;
				TabFrame.Parent = TabContainer;
				LeftScroll.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y + 10);
				if RightScroll and UIListLayout_2 and UIListLayout_2.Parent then
					RightScroll.CanvasSize = UDim2.fromOffset(0, UIListLayout_2.AbsoluteContentSize.Y + 10);
				end;
			end;
		end)));

		Tab.SetValue = LPH_NO_VIRTUALIZE(function(value, isGoingDown)
			Tab.Signal:SetValue(value);

			if value then
				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 0.500
				})

				NeverLose.PlayAnimate(TabIcon , SlowyTween , {
					TextTransparency = 0,
					TextColor3 = NeverLose.AccentColor
				})

				NeverLose.PlayAnimate(TabContentLabel , SlowyTween , {
					TextTransparency = 0
				})

				-- Directional Slide Animation
				pcall(function()
					TabFrame.Visible = true;
					TabFrame.Parent = TabContainer;
					LeftScroll.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y + 10);
					if RightScroll and UIListLayout_2 and UIListLayout_2.Parent then
						RightScroll.CanvasSize = UDim2.fromOffset(0, UIListLayout_2.AbsoluteContentSize.Y + 10);
					end;
				end);
				if isGoingDown ~= nil then
					local startY = isGoingDown and 0.55 or 0.45;
					TabFrame.Position = UDim2.new(0.5, 0, startY, 0);
					NeverLose.PlayAnimate(TabFrame, SlowyTween, {
						Position = UDim2.new(0.5, 0, 0.5, 0)
					});
				else
					TabFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
				end
			else
				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 1
				})

				NeverLose.PlayAnimate(TabIcon , SlowyTween , {
					TextTransparency = 0.5,
					TextColor3 = Color3.fromRGB(252, 252, 252)
				})

				NeverLose.PlayAnimate(TabContentLabel , SlowyTween , {
					TextTransparency = 0.5
				})
			end;
		end);

		table.insert(Window.Tabs,Tab);

		if Window.Tabs[Window.CurrentTab] == Tab then
			Tab.SetValue(true)
		else
			Tab.SetValue(false);
		end;

		local over = NeverLose:CreateInput(TabButton,LPH_NO_VIRTUALIZE(function()
			if Window.SearchBox and Window.SearchBox.Text ~= "" then
				Window.SearchBox.Text = "";
			end;
			if Window.ClearGlobalSearch then
				Window.ClearGlobalSearch();
			end;
			local prevTab = Window.CurrentTab or 1;
			for i,v in next , Window.Tabs do
				if v.Idx == TabButton then
					if Window.CurrentTab == i then return end;
					local isGoingDown = (i > prevTab);
					Window.CurrentTab = i;
					v.SetValue(true, isGoingDown);
				else
					v.SetValue(false);
				end;
			end;
		end));

		NeverLose:AddSignal(over.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			if Window.Tabs[Window.CurrentTab] == Tab then
				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 0.500
				})
			else
				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 0.8
				})
			end;
		end)))

		NeverLose:AddSignal(over.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			if Window.Tabs[Window.CurrentTab] == Tab then
				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 0.500
				})
			else
				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 1
				})
			end;
		end)))

		Window.Signal:Connect(LPH_NO_VIRTUALIZE(function(value)
			if value then
				if Window.Tabs[Window.CurrentTab] == Tab then
					Tab.SetValue(true)
				else
					Tab.SetValue(false);
				end;
			else
				Tab.SetValue(false);

				NeverLose.PlayAnimate(TabButton , SlowyTween , {
					BackgroundTransparency = 1
				})

				NeverLose.PlayAnimate(TabIcon , SlowyTween , {
					TextTransparency = 1,
				})

				NeverLose.PlayAnimate(TabContentLabel , SlowyTween , {
					TextTransparency = 1
				})
			end;
		end));

		function Tab:AddSection(Config)
			Config = NeverLose:ProcessParams(Config , {
				Name = "SECTION",
				Position = 'left'
			});

			local SectionFrame = Instance.new("Frame")
			local SectionLabel = Instance.new("TextLabel")
			local SectionHandler = Instance.new("Frame")
			local UIStroke = Instance.new("UIStroke")
			local UICorner = Instance.new("UICorner")
			local UIListLayout = Instance.new("UIListLayout")

			SectionFrame.Name = NeverLose.RandomString();
			SectionFrame.Parent = (string.lower(Config.Position) == 'left' and LeftScroll) or RightScroll
			SectionFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionFrame.BackgroundTransparency = 1.000
			SectionFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionFrame.BorderSizePixel = 0
			SectionFrame.ClipsDescendants = true
			SectionFrame.Size = UDim2.new(1, -5, 0, 0)
			SectionFrame.ZIndex = 9

			SectionLabel.Name = NeverLose.RandomString();
			SectionLabel.Parent = SectionFrame
			SectionLabel.AnchorPoint = Vector2.new(0.5, 0)
			SectionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SectionLabel.BackgroundTransparency = 1.000
			SectionLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionLabel.BorderSizePixel = 0
			SectionLabel.Position = UDim2.new(0.5, 0, 0, 0)
			SectionLabel.Size = UDim2.new(1, -35, 0, 15)
			SectionLabel.ZIndex = 9
			SectionLabel.Font = Enum.Font.GothamMedium
			SectionLabel.Text = Config.Name
			SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			SectionLabel.TextSize = 11.000
			SectionLabel.TextTransparency = 0.500
			SectionLabel.TextXAlignment = Enum.TextXAlignment.Left

			SectionHandler.Name = NeverLose.RandomString();
			SectionHandler.Parent = SectionFrame
			SectionHandler.AnchorPoint = Vector2.new(0.5, 0)
			SectionHandler.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
			SectionHandler.BackgroundTransparency = 0.500
			SectionHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SectionHandler.BorderSizePixel = 0
			SectionHandler.ClipsDescendants = true
			SectionHandler.Position = UDim2.new(0.5, 0, 0, 20)
			SectionHandler.Size = UDim2.new(1, -10, 1, -21)
			SectionHandler.ZIndex = 9

			UIStroke.Transparency = 0.650
			UIStroke.Color = Color3.fromRGB(45, 48, 58)
			UIStroke.Parent = SectionHandler

			UICorner.CornerRadius = UDim.new(0, 10)
			UICorner.Parent = SectionHandler

			UIListLayout.Parent = SectionHandler
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()


				if UIListLayout.AbsoluteContentSize.Y <= 1 then
					NeverLose.PlayAnimate(SectionFrame , VSlowTween , {
						Size = UDim2.new(1, -5, 0, 0)
					})
				else
					NeverLose.PlayAnimate(SectionFrame , VSlowTween , {
						Size = UDim2.new(1, -5, 0, UIListLayout.AbsoluteContentSize.Y + 19.5)
					})
				end;
			end));

			local Section = NeverLose:RegisiterItem(SectionHandler , Tab.Signal, { Tab = Tab, TabName = Tab.Name or "General", SectionName = Config.Name or "Section" });

			Section.SetRender = LPH_NO_VIRTUALIZE(function(value)
				if value then
					NeverLose.PlayAnimate(SectionLabel,SlowyTween,{
						TextTransparency = 0.500
					})

					NeverLose.PlayAnimate(SectionHandler,SlowyTween,{
						BackgroundTransparency = 0.500
					})

					NeverLose.PlayAnimate(UIStroke,SlowyTween,{
						Transparency = 0.650
					})
				else
					NeverLose.PlayAnimate(SectionLabel,SlowyTween,{
						TextTransparency = 1
					})

					NeverLose.PlayAnimate(SectionHandler,SlowyTween,{
						BackgroundTransparency = 1
					})

					NeverLose.PlayAnimate(UIStroke,SlowyTween,{
						Transparency = 1
					})
				end;
			end);

			Section.SetRender(Tab.Signal:GetValue());
			Tab.Signal:Connect(Section.SetRender);

			return Section;
		end;

		return Tab;
	end;

	function Window:AddAccordionTab(Config)
		Config = NeverLose:ProcessParams(Config , {
			Icon = "eye",
			Name = "Visuals",
			SubTabs = {}
		});

		local GroupButton = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local GroupIcon = Instance.new("TextLabel")
		local GroupContentLabel = Instance.new("TextLabel")
		local ArrowIcon = Instance.new("TextLabel")

		GroupButton.Name = NeverLose.RandomString()
		GroupButton.Parent = LeftScrollingFrame
		GroupButton.BackgroundColor3 = Color3.fromRGB(41, 45, 49)
		GroupButton.BackgroundTransparency = 1.000
		GroupButton.BorderSizePixel = 0
		GroupButton.Size = UDim2.new(1, -1, 0, 30)
		GroupButton.ZIndex = 8

		UICorner.CornerRadius = UDim.new(0, 6)
		UICorner.Parent = GroupButton

		GroupIcon.Name = NeverLose.RandomString()
		GroupIcon.Parent = GroupButton
		GroupIcon.AnchorPoint = Vector2.new(0, 0.5)
		GroupIcon.BackgroundTransparency = 1.000
		GroupIcon.Position = UDim2.new(0, 2, 0.5, 0)
		GroupIcon.Size = UDim2.new(0, 25, 0, 25)
		GroupIcon.ZIndex = 9
		GroupIcon.FontFace = NeverLose.BuiltInBold
		GroupIcon.Text = Config.Icon
		GroupIcon.TextColor3 = Color3.fromRGB(252, 252, 252)
		GroupIcon.TextTransparency = 0.5
		GroupIcon.TextSize = 16.000
		GroupIcon.TextWrapped = true

		GroupContentLabel.Name = NeverLose.RandomString()
		GroupContentLabel.Parent = GroupButton
		GroupContentLabel.AnchorPoint = Vector2.new(0, 0.5)
		GroupContentLabel.BackgroundTransparency = 1.000
		GroupContentLabel.Position = UDim2.new(0, 30, 0.5, 0)
		GroupContentLabel.Size = UDim2.new(1, -55, 0, 15)
		GroupContentLabel.ZIndex = 9
		GroupContentLabel.Font = Enum.Font.GothamMedium
		GroupContentLabel.Text = Config.Name
		GroupContentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		GroupContentLabel.TextTransparency = 0.5
		GroupContentLabel.TextSize = 12.000
		GroupContentLabel.TextXAlignment = Enum.TextXAlignment.Left

		ArrowIcon.Name = NeverLose.RandomString()
		ArrowIcon.Parent = GroupButton
		ArrowIcon.AnchorPoint = Vector2.new(1, 0.5)
		ArrowIcon.BackgroundTransparency = 1.000
		ArrowIcon.Position = UDim2.new(1, -8, 0.5, 0)
		ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
		ArrowIcon.ZIndex = 9
		ArrowIcon.FontFace = NeverLose.BuiltInBold
		ArrowIcon.Text = "chevron-large-down"
		ArrowIcon.TextColor3 = Color3.fromRGB(252, 252, 252)
		ArrowIcon.TextTransparency = 0.6
		ArrowIcon.TextSize = 12.000

		local SubContainer = Instance.new("Frame")
		local SubLayout = Instance.new("UIListLayout")

		SubContainer.Name = NeverLose.RandomString()
		SubContainer.Parent = LeftScrollingFrame
		SubContainer.BackgroundTransparency = 1.000
		SubContainer.BorderSizePixel = 0
		SubContainer.ClipsDescendants = true
		SubContainer.Size = UDim2.new(1, -1, 0, #Config.SubTabs * 28)
		SubContainer.ZIndex = 8

		SubLayout.Parent = SubContainer
		SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SubLayout.Padding = UDim.new(0, 2)

		local isExpanded = true
		local createdSubTabs = {}

		for _, sub in ipairs(Config.SubTabs) do
			local subTabObj = Window:AddTab({
				Name = sub.Name,
				Icon = sub.Icon or "user",
				Type = sub.Type or "Double",
				Parent = SubContainer,
				IsSub = true
			})
			createdSubTabs[sub.Name] = subTabObj
		end

		local function toggleAccordion()
			isExpanded = not isExpanded
			local targetH = isExpanded and (#Config.SubTabs * 30) or 0
			NeverLose.PlayAnimate(SubContainer, SlowyTween, {
				Size = UDim2.new(1, -1, 0, targetH)
			})
			NeverLose.PlayAnimate(ArrowIcon, SlowyTween, {
				Rotation = isExpanded and 0 or -90
			})
		end

		NeverLose:CreateInput(GroupButton, LPH_NO_VIRTUALIZE(function()
			toggleAccordion()
		end))

		return createdSubTabs
	end;

	function Window:_InitConfig()
		local ConfigSignal = NeverLose:CreateSignal(false);
		local ConfigLib = {
			Signals = {},
		};

		local ConfigMenu = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIListLayout = Instance.new("UIListLayout")
		local UIStroke = Instance.new("UIStroke")
		local InputFrame = Instance.new("Frame")
		local BasedLabel = Instance.new("TextLabel")
		local LineFrame = Instance.new("Frame")
		local BasedHandler = Instance.new("Frame")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local TextInput = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIStroke_2 = Instance.new("UIStroke")
		local TextBox = Instance.new("TextBox")
		local LoadConfig = Instance.new("Frame")
		local Icon = Instance.new("TextLabel")
		local UICorner_3 = Instance.new("UICorner")
		local UICorner_4 = Instance.new("UICorner")

		local shadow = NeverLose:CreateShadow(ConfigMenu);
	if NeverLose.EnabledBlur then
		NeverLose:CreateBlurModule(ConfigMenu, ConfigSignal);
	end;

		ConfigLib.SetRender = LPH_NO_VIRTUALIZE(function(value)
			if value then
				ConfigMenu.Position = UDim2.fromOffset(ConfigFrame.AbsolutePosition.X + 110 , ConfigFrame.AbsolutePosition.Y + 96)

				NeverLose.PlayAnimate(ConfigMenu , SlowyTween , {
					BackgroundTransparency = 0.035,
					Position = UDim2.fromOffset(ConfigFrame.AbsolutePosition.X + 110 , ConfigFrame.AbsolutePosition.Y + 95)
				})	

				NeverLose.PlayAnimate(UIStroke , SlowyTween , {
					Transparency = 0.650
				})
				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 0.200
				})	

				NeverLose.PlayAnimate(UIStroke_2 , SlowyTween , {
					Transparency = 0.65
				})	

				NeverLose.PlayAnimate(LineFrame , SlowyTween , {
					BackgroundTransparency = 0.650
				})	
				NeverLose.PlayAnimate(TextInput , SlowyTween , {
					BackgroundTransparency = 0
				})	
				NeverLose.PlayAnimate(TextBox , SlowyTween , {
					TextTransparency = 0.350
				})	
				NeverLose.PlayAnimate(Icon , SlowyTween , {
					TextTransparency = 0.350
				})	

				NeverLose.PlayAnimate(ConfigBthIcon , SlowyTween , {
					Rotation = 180
				})	

				shadow:Render(true)
			else
				NeverLose.PlayAnimate(ConfigBthIcon , SlowyTween , {
					Rotation = 0
				})

				NeverLose.PlayAnimate(ConfigMenu , SlowyTween , {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(ConfigFrame.AbsolutePosition.X + 110 , ConfigFrame.AbsolutePosition.Y + 96)
				})	

				NeverLose.PlayAnimate(UIStroke_2 , SlowyTween , {
					Transparency = 1
				})	

				NeverLose.PlayAnimate(UIStroke , SlowyTween , {
					Transparency = 1
				})
				NeverLose.PlayAnimate(BasedLabel , SlowyTween , {
					TextTransparency = 1
				})	
				NeverLose.PlayAnimate(LineFrame , SlowyTween , {
					BackgroundTransparency = 1
				})	
				NeverLose.PlayAnimate(TextInput , SlowyTween , {
					BackgroundTransparency = 1
				})	
				NeverLose.PlayAnimate(TextBox , SlowyTween , {
					TextTransparency = 1
				})	
				NeverLose.PlayAnimate(Icon , SlowyTween , {
					TextTransparency = 1
				})	

				shadow:Render(false)
			end;
		end);

		NeverLose:AddSignal(ConfigMenu:GetPropertyChangedSignal('BackgroundTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
			if ConfigMenu.BackgroundTransparency > 0.9 then
				ConfigMenu.Visible = false;
				UIListLayout.Parent = nil;
				ConfigMenu.Parent = nil;
			else

				ConfigMenu.Visible = true;
				UIListLayout.Parent = ConfigMenu

				if NeverLose.Global3DRenderMode then
					ConfigMenu.Parent = NeverLose.GlobalSurfaceGui;
				else
					ConfigMenu.Parent = NeverLose.ScreenGui;
				end;
			end
		end)))

		ConfigMenu.Name = NeverLose.RandomString();
		ConfigMenu.Parent = NeverLose.ScreenGui;
		ConfigMenu.AnchorPoint = Vector2.new(0.5, 0)
		ConfigMenu.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
		ConfigMenu.BackgroundTransparency = 0.035
		ConfigMenu.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ConfigMenu.BorderSizePixel = 0
		ConfigMenu.ClipsDescendants = true
		ConfigMenu.Position = UDim2.new(255,255,255,255)
		ConfigMenu.Size = UDim2.new(0, 220,0, 110)
		ConfigMenu.ZIndex = 151

		UICorner.CornerRadius = UDim.new(0, 10)
		UICorner.Parent = ConfigMenu

		UIListLayout.Parent = ConfigMenu
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 4)

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = ConfigMenu

		InputFrame.Name = NeverLose.RandomString();
		InputFrame.Parent = ConfigMenu
		InputFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
		InputFrame.BackgroundTransparency = 1.000
		InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		InputFrame.BorderSizePixel = 0
		InputFrame.Size = UDim2.new(1, 0, 0, 30)
		InputFrame.ZIndex = 154

		BasedLabel.Name = NeverLose.RandomString();
		BasedLabel.Parent = InputFrame
		BasedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.BackgroundTransparency = 1.000
		BasedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedLabel.BorderSizePixel = 0
		BasedLabel.Position = UDim2.new(0, 11, 0, 6)
		BasedLabel.Size = UDim2.new(0,1, 0, 15)
		BasedLabel.ZIndex = 154
		BasedLabel.Font = Enum.Font.GothamMedium
		BasedLabel.Text = "Config"
		BasedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		BasedLabel.TextSize = 13.000
		BasedLabel.TextTransparency = 0.200
		BasedLabel.TextXAlignment = Enum.TextXAlignment.Left

		LineFrame.Name = NeverLose.RandomString();
		LineFrame.Parent = InputFrame
		LineFrame.AnchorPoint = Vector2.new(0.5, 1)
		LineFrame.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
		LineFrame.BackgroundTransparency = 0.650
		LineFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LineFrame.BorderSizePixel = 0
		LineFrame.Position = UDim2.new(0.5, 0, 1, 0)
		LineFrame.Size = UDim2.new(1, -20, 0, 1)
		LineFrame.ZIndex = 154

		BasedHandler.Name = NeverLose.RandomString();
		BasedHandler.Parent = InputFrame
		BasedHandler.AnchorPoint = Vector2.new(1, 0)
		BasedHandler.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BasedHandler.BackgroundTransparency = 1.000
		BasedHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BasedHandler.BorderSizePixel = 0
		BasedHandler.Position = UDim2.new(1, -11, 0, 2)
		BasedHandler.Size = UDim2.new(1, -20, 0, 25)
		BasedHandler.ZIndex = 154

		UIListLayout_2.Parent = BasedHandler
		UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout_2.Padding = UDim.new(0, 5)

		NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
			if #ConfigLib.Signals <= 0 then
				NeverLose.PlayAnimate(ConfigMenu , SlowyTween , {
					Size = UDim2.new(0, 220,0, UIListLayout.AbsoluteContentSize.Y + 0);
				})
			else
				NeverLose.PlayAnimate(ConfigMenu , SlowyTween , {
					Size = UDim2.new(0, 220,0, UIListLayout.AbsoluteContentSize.Y + 5);
				})
			end;

		end)));

		TextInput.Name = NeverLose.RandomString();
		TextInput.Parent = BasedHandler
		TextInput.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
		TextInput.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextInput.BorderSizePixel = 0
		TextInput.ClipsDescendants = true
		TextInput.Size = UDim2.new(0, 100, 0, 18)
		TextInput.ZIndex = 154

		UICorner_2.CornerRadius = UDim.new(0, 4)
		UICorner_2.Parent = TextInput

		UIStroke_2.Transparency = 0.650
		UIStroke_2.Color = Color3.fromRGB(45, 48, 58)
		UIStroke_2.Parent = TextInput

		TextBox.Parent = TextInput
		TextBox.AnchorPoint = Vector2.new(0, 0.5)
		TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.BackgroundTransparency = 1.000
		TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextBox.BorderSizePixel = 0
		TextBox.Position = UDim2.new(0, 5, 0.5, 0)
		TextBox.Size = UDim2.new(1, -5, 0, 17)
		TextBox.ZIndex = 154
		TextBox.ClearTextOnFocus = false
		TextBox.Font = Enum.Font.GothamMedium
		TextBox.PlaceholderText = "Config Name ..."
		TextBox.Text = ""
		TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.TextSize = 11.000
		TextBox.TextTransparency = 0.350
		TextBox.TextXAlignment = Enum.TextXAlignment.Left

		LoadConfig.Name = NeverLose.RandomString();
		LoadConfig.Parent = BasedHandler
		LoadConfig.BackgroundColor3 = Color3.fromRGB(39, 40, 49)
		LoadConfig.BackgroundTransparency = 1.000
		LoadConfig.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LoadConfig.BorderSizePixel = 0
		LoadConfig.ClipsDescendants = true
		LoadConfig.Size = UDim2.new(0, 20, 0, 18)
		LoadConfig.ZIndex = 153

		Icon.Name = NeverLose.RandomString();
		Icon.Parent = LoadConfig
		Icon.AnchorPoint = Vector2.new(0.5, 0.5)
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		Icon.Size = UDim2.new(1, 0, 1, 0)
		Icon.ZIndex = 153
		Icon.FontFace = NeverLose.BuiltInBold
		Icon.Text = "plus-large"
		Icon.TextColor3 = Color3.fromRGB(223, 223, 223)
		Icon.TextSize = 16.000
		Icon.TextTransparency = 0.350
		Icon.TextWrapped = true

		UICorner_3.CornerRadius = UDim.new(0, 4)
		UICorner_3.Parent = LoadConfig

		UICorner_4.CornerRadius = UDim.new(0, 10)
		UICorner_4.Parent = InputFrame

		local OpenButton = Instance.new("TextButton")
		local UICorner = Instance.new("UICorner")

		OpenButton.Name = NeverLose.RandomString();
		OpenButton.Parent = ConfigFrame
		OpenButton.AnchorPoint = Vector2.new(0, 0.5)
		OpenButton.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
		OpenButton.BackgroundTransparency = 1.000
		OpenButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		OpenButton.BorderSizePixel = 0
		OpenButton.Position = UDim2.new(0, 31, 0.5, 0)
		OpenButton.Size = UDim2.new(1, -31, 1, 0)
		OpenButton.ZIndex = 10
		OpenButton.Font = Enum.Font.SourceSans
		OpenButton.Text = ""
		OpenButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		OpenButton.TextSize = 14.000

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = OpenButton

		ConfigLib.SetRender(false);
		ConfigSignal:Connect(ConfigLib.SetRender);
		ConfigLib.UnsafeThread = nil;
		ConfigLib.SelectedConfig = "Default";

		local UpdateSize = LPH_NO_VIRTUALIZE(function()
			local size = TextService:GetTextSize(ConfigName.Text , ConfigName.TextSize,ConfigName.Font,Vector2.new(math.huge,math.huge));

			NeverLose.PlayAnimate(ConfigFrame,SlowyTween , {
				Size = UDim2.fromOffset(size.X + 75, 30)
			});
		end);

		UpdateSize();

		function ConfigLib:GetData(performance)
			local ikc = {};
			
			local cd = 0;
			for Flag,v in next , NeverLose.Flags do
				if v and v.GetValue then
					local data = v:GetValue();

					if typeof(data) == 'Color3' then
						table.insert(ikc,{
							Idx = Flag,
							Value = data:ToHex(),
						});
					else
						table.insert(ikc,{
							Idx = Flag,
							Value = data
						});
					end;
				end;
				
				if performance then
					if cd % 35 == 1 then
						task.wait()
					end
				end;
				
				cd += 1;
			end;

			return NeverLose.Base64Encode(Encryption.new(HttpService:JSONEncode(ikc)));
		end;

		function ConfigLib:LoadData(data)
			local coded = HttpService:JSONDecode(Encryption.reverse(NeverLose.Base64Decode(data)));

			for i,v in next , coded do
				if v.Idx then
					if NeverLose.Flags[v.Idx] then
						task.spawn(function()
							NeverLose.Flags[v.Idx]:SetValue(v.Value)
						end)
					end;
				end;
			end;
		end;

		function ConfigLib:RefreshConfig()
			if not isfolder(Window.ConfigFolder) then
				makefolder(Window.ConfigFolder);
			end;
			
			if not isfile(Window.ConfigFolder..'/Default') then
				writefile(Window.ConfigFolder..'/Default',ConfigLib:GetData());
			end;
			
			for i,v in next,ConfigMenu:GetChildren() do
				if v:GetAttribute('ConfigItem') then
					v:Destroy();
				end;
			end;

			for i,v in next , ConfigLib.Signals do
				v:Disconnect();
			end

			table.clear(ConfigLib.Signals);

			local ConfigList = {};
			for i,v in next , listfiles(Window.ConfigFolder) do

				local name = string.sub(v , #Window.ConfigFolder + 2);

				table.insert(ConfigList , name)
			end;

			for i,ConfigNameStr in next , ConfigList do
				local ConfigItemFrame = Instance.new("Frame")
				local BasedHandler = Instance.new("Frame")
				local UIListLayout = Instance.new("UIListLayout")
				local DeleteConfig = Instance.new("Frame")
				local Icon = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")
				local LoadConfig = Instance.new("Frame")
				local Icon_2 = Instance.new("TextLabel")
				local UICorner_2 = Instance.new("UICorner")
				local UICorner_3 = Instance.new("UICorner")
				local BasedLabel = Instance.new("TextLabel")
				local UIStroke = Instance.new("UIStroke")

				ConfigItemFrame.Name = NeverLose.RandomString();
				ConfigItemFrame.Parent = ConfigMenu
				ConfigItemFrame.BackgroundColor3 = Color3.fromRGB(21, 20, 27)
				ConfigItemFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ConfigItemFrame.BorderSizePixel = 0
				ConfigItemFrame.Size = UDim2.new(1, -10, 0, 30)
				ConfigItemFrame.ZIndex = 153
				ConfigItemFrame:SetAttribute('ConfigItem',true);

				BasedHandler.Name = NeverLose.RandomString();
				BasedHandler.Parent = ConfigItemFrame
				BasedHandler.AnchorPoint = Vector2.new(1, 0)
				BasedHandler.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				BasedHandler.BackgroundTransparency = 1.000
				BasedHandler.BorderColor3 = Color3.fromRGB(0, 0, 0)
				BasedHandler.BorderSizePixel = 0
				BasedHandler.Position = UDim2.new(1, -11, 0, 2)
				BasedHandler.Size = UDim2.new(1, -20, 0, 25)
				BasedHandler.ZIndex = 153

				UIListLayout.Parent = BasedHandler
				UIListLayout.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				UIListLayout.Padding = UDim.new(0, 5)

				DeleteConfig.Name = NeverLose.RandomString();
				DeleteConfig.Parent = BasedHandler
				DeleteConfig.BackgroundColor3 = Color3.fromRGB(39, 40, 49)
				DeleteConfig.BackgroundTransparency = 1.000
				DeleteConfig.BorderColor3 = Color3.fromRGB(0, 0, 0)
				DeleteConfig.BorderSizePixel = 0
				DeleteConfig.ClipsDescendants = true
				DeleteConfig.Size = UDim2.new(0, 20, 0, 18)
				DeleteConfig.ZIndex = 153

				Icon.Name = NeverLose.RandomString();
				Icon.Parent = DeleteConfig
				Icon.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Icon.BackgroundTransparency = 1.000
				Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Icon.BorderSizePixel = 0
				Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
				Icon.Size = UDim2.new(1, 0, 1, 0)
				Icon.ZIndex = 153
				Icon.FontFace = NeverLose.BuiltInBold
				Icon.Text = "trash-can"
				Icon.TextColor3 = Color3.fromRGB(223, 223, 223)
				Icon.TextSize = 16.000
				Icon.TextTransparency = 0.400
				Icon.TextWrapped = true

				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = DeleteConfig

				LoadConfig.Name = NeverLose.RandomString();
				LoadConfig.Parent = BasedHandler
				LoadConfig.BackgroundColor3 = Color3.fromRGB(39, 40, 49)
				LoadConfig.BackgroundTransparency = 1.000
				LoadConfig.BorderColor3 = Color3.fromRGB(0, 0, 0)
				LoadConfig.BorderSizePixel = 0
				LoadConfig.ClipsDescendants = true
				LoadConfig.Size = UDim2.new(0, 20, 0, 18)
				LoadConfig.ZIndex = 153

				Icon_2.Name = NeverLose.RandomString();
				Icon_2.Parent = LoadConfig
				Icon_2.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Icon_2.BackgroundTransparency = 1.000
				Icon_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Icon_2.BorderSizePixel = 0
				Icon_2.Position = UDim2.new(0.5, 0, 0.5, 0)
				Icon_2.Size = UDim2.new(1, 0, 1, 0)
				Icon_2.ZIndex = 153
				Icon_2.FontFace = NeverLose.BuiltInBold
				Icon_2.Text = "arrow-right-from-portrait-rectangle"
				Icon_2.TextColor3 = Color3.fromRGB(223, 223, 223)
				Icon_2.TextSize = 16.000
				Icon_2.TextTransparency = 0.400
				Icon_2.TextWrapped = true

				UICorner_2.CornerRadius = UDim.new(0, 4)
				UICorner_2.Parent = LoadConfig

				UICorner_3.CornerRadius = UDim.new(0, 5)
				UICorner_3.Parent = ConfigItemFrame

				BasedLabel.Name = NeverLose.RandomString();
				BasedLabel.Parent = ConfigItemFrame
				BasedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				BasedLabel.BackgroundTransparency = 1.000
				BasedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
				BasedLabel.BorderSizePixel = 0
				BasedLabel.Position = UDim2.new(0, 11, 0, 7)
				BasedLabel.Size = UDim2.new(0, 1, 0, 15)
				BasedLabel.ZIndex = 153
				BasedLabel.Font = Enum.Font.GothamMedium
				BasedLabel.Text = ConfigNameStr
				BasedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				BasedLabel.TextSize = 13.000
				BasedLabel.TextTransparency = 0.200
				BasedLabel.TextXAlignment = Enum.TextXAlignment.Left

				UIStroke.Transparency = 0.500
				UIStroke.Color = Color3.fromRGB(45, 48, 58)
				UIStroke.Parent = ConfigItemFrame

				local Render = LPH_NO_VIRTUALIZE(function(rst)
					if rst then
						NeverLose.PlayAnimate(ConfigItemFrame,SlowyTween,{
							BackgroundTransparency = 0
						})

						NeverLose.PlayAnimate(Icon,SlowyTween,{
							TextTransparency = 0.400
						})

						NeverLose.PlayAnimate(Icon_2,SlowyTween,{
							TextTransparency = 0.400
						})

						NeverLose.PlayAnimate(BasedLabel,SlowyTween,{
							TextTransparency = 0.200
						})

						NeverLose.PlayAnimate(UIStroke,SlowyTween,{
							Transparency = 0.500
						})
					else
						NeverLose.PlayAnimate(ConfigItemFrame,SlowyTween,{
							BackgroundTransparency = 1
						})

						NeverLose.PlayAnimate(Icon,SlowyTween,{
							TextTransparency = 1
						})

						NeverLose.PlayAnimate(Icon_2,SlowyTween,{
							TextTransparency = 1
						})

						NeverLose.PlayAnimate(BasedLabel,SlowyTween,{
							TextTransparency = 1
						})

						NeverLose.PlayAnimate(UIStroke,SlowyTween,{
							Transparency = 1
						})
					end;
				end)

				Render(ConfigSignal:GetValue());
				table.insert(ConfigLib.Signals , ConfigSignal:Connect(Render));

				table.insert(ConfigLib.Signals , ConfigItemFrame.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(UIStroke,SlowyTween,{
						Transparency = 0.25
					})
				end)));

				table.insert(ConfigLib.Signals , ConfigItemFrame.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(UIStroke,SlowyTween,{
						Transparency = 0.500
					})
				end)));

				local deleter,signal = NeverLose:CreateInput(DeleteConfig,function()
					if ConfigNameStr == "Default" then
						Logging.new("trash-can","You can't delete default config!",3.5)
						return;
					end;
					
					delfile(Window.ConfigFolder..'/'..ConfigNameStr);

					UpdateSize();

					ConfigLib:RefreshConfig();

					Logging.new("trash-can",'Deleted '..tostring(ConfigNameStr),3.5)
				end);


				local _,load_signal = NeverLose:CreateInput(LoadConfig,function()
					local path = Window.ConfigFolder..'/'..ConfigNameStr;

					if isfile(path) then
						local data = readfile(path);

						ConfigLib:LoadData(data);

						ConfigLib.SelectedConfig = ConfigNameStr;
						ConfigName.Text = ConfigNameStr;

						UpdateSize();

						ConfigLib:RefreshConfig();

						Logging.new("folder",'Loaded '..tostring(ConfigNameStr),3.5)
					end
				end);

				table.insert(ConfigLib.Signals , signal);
				table.insert(ConfigLib.Signals , load_signal);

				table.insert(ConfigLib.Signals , deleter.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(Icon,SlowyTween,{
						TextTransparency = 0.2,
						TextColor3 = Color3.fromRGB(223, 125, 125)
					})
				end)))

				table.insert(ConfigLib.Signals , deleter.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(Icon,SlowyTween,{
						TextTransparency = 0.400,
						TextColor3 = Color3.fromRGB(223, 223, 223)
					})
				end)))

				table.insert(ConfigLib.Signals , LoadConfig.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(Icon_2,SlowyTween,{
						TextTransparency = 0.2,
						TextColor3 = NeverLose.AccentColor
					})
				end)))

				table.insert(ConfigLib.Signals , LoadConfig.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
					NeverLose.PlayAnimate(Icon_2,SlowyTween,{
						TextTransparency = 0.400,
						TextColor3 = Color3.fromRGB(223, 223, 223)
					})
				end)))
			end;

			table.clear(ConfigList);
		end;
		
		task.delay(1,function()
			if ConfigLib.SelectedConfig == "Default" then
				local path = Window.ConfigFolder..'/Default';
				local ConfigNameStr = "Default";
				
				if isfile(path) then
					local data = readfile(path);

					ConfigLib:LoadData(data);

					ConfigLib.SelectedConfig = ConfigNameStr;
					ConfigName.Text = ConfigNameStr;

					UpdateSize();

					ConfigLib:RefreshConfig();

					Logging.new("folder","Loaded Default Config",3.5);
					
					task.spawn(function()
						while true do task.wait(5.75);
							if isfile(path) and ConfigLib.SelectedConfig == "Default" then
								writefile(Window.ConfigFolder..'/Default',ConfigLib:GetData(true));
							end;
						end;
					end);
				end;
			end;
		end);

		local hover_write = NeverLose:CreateInput(ConfigIcon,function()
			local path = Window.ConfigFolder..'/'..(ConfigLib.SelectedConfig or "Default");

			if isfile(path) then
				writefile(Window.ConfigFolder..'/'..(ConfigLib.SelectedConfig or "Default"),ConfigLib:GetData());

				Logging.new("folder",'Saved '..tostring(ConfigLib.SelectedConfig),3.5)
			end;
		end);

		NeverLose:AddSignal(hover_write.MouseEnter:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(ConfigIcon,SlowyTween,{
				TextTransparency = 0.1
			})
		end)));

		NeverLose:AddSignal(hover_write.MouseLeave:Connect(LPH_NO_VIRTUALIZE(function()
			NeverLose.PlayAnimate(ConfigIcon,SlowyTween,{
				TextTransparency = 0.25
			})
		end)));


		local mv = NeverLose:CreateInput(LoadConfig , function()
			local cfg_name = TextBox.Text;

			if cfg_name and cfg_name:byte() and not cfg_name:find('/',1,true) and not cfg_name:find('\\',1,true) then
				cfg_name = string.sub(cfg_name , 1 , 24);

				writefile(Window.ConfigFolder..'/'..cfg_name,ConfigLib:GetData());
				ConfigLib.SelectedConfig = cfg_name;
				ConfigName.Text = cfg_name;

				Logging.new("folder",'Created '..tostring(cfg_name),3.5)

				TextBox.Text = "";

				UpdateSize();

				ConfigLib:RefreshConfig();
			end;
		end);

		NeverLose:AddSignal(mv.MouseEnter:Connect(function()
			NeverLose.PlayAnimate(Icon , SlowyTween , {
				TextTransparency = 0.1
			})
		end))

		NeverLose:AddSignal(mv.MouseLeave:Connect(function()
			NeverLose.PlayAnimate(Icon , SlowyTween , {
				TextTransparency = 0.35
			})
		end))

		ConfigLib:RefreshConfig();

		OpenButton.MouseButton1Click:Connect(LPH_NO_VIRTUALIZE(function()
			if ConfigSignal:GetValue() then
				if ConfigLib.UnsafeThread then
					ConfigLib.UnsafeThread:Disconnect();
					ConfigLib.UnsafeThread = nil;
				end;
				ConfigSignal:SetValue(false);
				return;
			end;

			if ConfigLib.UnsafeThread then
				ConfigLib.UnsafeThread:Disconnect();
				ConfigLib.UnsafeThread = nil;
			end;

			ConfigSignal:SetValue(true);

			task.delay(0.05, function()
				ConfigLib.UnsafeThread = UserInputService.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						if not NeverLose:IsMouseOverFrame(ConfigMenu) and not NeverLose:IsMouseOverFrame(ConfigFrame) then
							if ConfigLib.UnsafeThread then
								ConfigLib.UnsafeThread:Disconnect();
								ConfigLib.UnsafeThread = nil;
							end;

							ConfigSignal:SetValue(false);
						end;
					end;
				end);
			end);
		end));

		return ConfigLib;
	end;

	Window:_InitConfig();

	local UserSettings = NeverLose:CreateOptionWindow(BottomFrame , BottomFrame.ZIndex + 13, 285);
	local reciveSignal;
	NeverLose:CreateInput(BottomFrame , LPH_NO_VIRTUALIZE(function()
		if UserSettings.Signal:GetValue() then
			if reciveSignal then
				reciveSignal:Disconnect();
				reciveSignal = nil;
			end;
			UserSettings.Signal:SetValue(false);
			NeverLose.PlayAnimate(UserSettingButton, SlowyTween, { Rotation = 0 });
			return;
		end;

		if reciveSignal then
			reciveSignal:Disconnect();
			reciveSignal = nil;	
		end;

		UserSettings.Signal:SetValue(true);
		NeverLose.PlayAnimate(UserSettingButton, SlowyTween, { Rotation = 90 });

		reciveSignal = UserInputService.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				if not NeverLose:IsMouseOverFrame(UserSettings.Root) and not NeverLose:IsMouseOverFrame(BottomFrame) and not NeverLose.IsMosueOverOtherFrame then
					if reciveSignal then
						reciveSignal:Disconnect();
						reciveSignal = nil;	
					end;

					UserSettings.Signal:SetValue(false);
					NeverLose.PlayAnimate(UserSettingButton, SlowyTween, { Rotation = 0 });
				end
			end
		end);
	end))

	NeverLose:AddSignal(UserSettings.Signal:Connect(function(isOpen)
		if not isOpen then
			NeverLose.PlayAnimate(UserSettingButton, SlowyTween, { Rotation = 0 });
		end;
	end));

	Window.UserSettings = UserSettings;

	function Window:SetAccount(Config)
		Config = NeverLose:ProcessParams(Config , {
			Profile = NeverLose.UserProfile,
			Username = LocalPlayer.DisplayName,
			Expires = "Never",
		});

		AccountName.Text = Config.Username;
		AccountProfile.Image = Config.Profile;
		ExpireLabel.Text = Config.Expires;

		Window.Username = Config.Username or Window.Username;
		Window.Profile = Config.Profile or Window.Profile;
		Window.Expires = Config.Expires or Window.Expires;

		if Window.UserSettings.UserFrame then
			Window.UserSettings.UserFrame:SetUsername(Window.Username);
			Window.UserSettings.UserFrame:SetProfile(Window.Profile);
			Window.UserSettings.UserFrame:SetExpires(Window.Expires);
		else
			Window.UserSettings.UserFrame = UserSettings:AddUserFrame(Window.Username , Window.Profile , Window.Expires, Window);
		end;
	end;

	-- Auto-initialize default account profile popup
	Window:SetAccount({});

	function Window:SetSize(newsize)
		Window.Size = newsize;

		if Window.Signal:GetValue() then
			NeverLose.PlayAnimate(WindowFrame , VSlowTween , {
				Size = Window.Size
			})
		end
	end;


	function Window:Watermark()
		if NeverLose.__WatermarkCache then
			return NeverLose.__WatermarkCache;
		end;

		local Watermark_lb = {};
		local Watermark = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local Shadow = NeverLose:CreateShadow(Watermark);

		Watermark.Name = NeverLose.RandomString();
		Watermark.Parent = NeverLose.ScreenGui
		Watermark.AnchorPoint = Vector2.new(1, 0)
		Watermark.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
		Watermark.BackgroundTransparency = 0.200
		Watermark.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Watermark.BorderSizePixel = 0
		Watermark.ClipsDescendants = true
		Watermark.Position = UDim2.new(1, -10, 0, 10)
		Watermark.Size = UDim2.new(0, 120, 0, 30)
		Watermark.ZIndex = 16

		UICorner.CornerRadius = UDim.new(0, 25)
		UICorner.Parent = Watermark

		Watermark:GetPropertyChangedSignal('BackgroundTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
			if Watermark.BackgroundTransparency > 0.9 then
				Watermark.Visible = false;
				Watermark.Parent = nil;
			else
				Watermark.Parent = NeverLose.ScreenGui
				Watermark.Visible = true;
			end;
		end));

		-- Container Draggability (allowed when GUI is open)
		local wmDragging = false;
		local wmDragStart = nil;
		local wmStartPos = nil;
		local wmHasMoved = false;

		local function startWMDrag(input)
			local isGuiOpen = (NeverLose.IsGuiOpen == true) or (NeverLose.MainWindow and NeverLose.MainWindow.Visible and NeverLose.MainWindow.BackgroundTransparency < 0.9);
			if isGuiOpen then
				wmDragging = true;
				wmHasMoved = false;
				wmDragStart = input.Position;
				wmStartPos = Watermark.Position;
			end;
		end;

		Watermark.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				startWMDrag(input);
			end;
		end);

		UserInputService.InputChanged:Connect(function(input)
			if wmDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - wmDragStart;
				if delta.Magnitude > 3 then
					wmHasMoved = true;
				end;
				Watermark.Position = UDim2.new(wmStartPos.X.Scale, wmStartPos.X.Offset + delta.X, wmStartPos.Y.Scale, wmStartPos.Y.Offset + delta.Y);
			end;
		end);

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				wmDragging = false;
			end;
		end);

		NeverLose.__WatermarkCache = Watermark_lb;
		Shadow:Render(true);

		Watermark_lb.Renders = {};
		Watermark_lb.Blocks = {};
		Watermark_lb.BlockMap = {};
		Watermark_lb.Status = true;

		-- Smooth Animated Watermark Layout (Butter smooth sliding on reorder or text change)
		function Watermark_lb:UpdateLayout(animated)
			local curX = 12;
			for _, b in ipairs(Watermark_lb.Blocks) do
				if b.Visible then
					local textWidth = TextService:GetTextSize(b.Content.Text, b.Content.TextSize, b.Content.Font, Vector2.new(1000, 30)).X;
					local hasIcon = (b.Icon and b.Icon.Visible and b.Icon.Text ~= "") or (b.Frame:FindFirstChild("LogoImg") and b.Frame.LogoImg.Visible);
					local targetWidth = textWidth + (hasIcon and 30 or 14);
					local targetSize = UDim2.new(0, targetWidth, 0, 24);
					local targetPos = UDim2.new(0, curX, 0.5, 0);

					if animated then
						TweenService:Create(b.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Position = targetPos,
							Size = targetSize
						}):Play();
					else
						b.Frame.Position = targetPos;
						b.Frame.Size = targetSize;
					end;
					curX = curX + targetWidth + 6;
				else
					if animated then
						TweenService:Create(b.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Size = UDim2.new(0, 0, 0, 24),
							Position = UDim2.new(0, curX, 0.5, 0)
						}):Play();
					else
						b.Frame.Size = UDim2.new(0, 0, 0, 24);
						b.Frame.Position = UDim2.new(0, curX, 0.5, 0);
					end;
				end;
			end;

			local totalWidth = curX + 6;
			if animated then
				TweenService:Create(Watermark, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, totalWidth, 0, 30)
				}):Play();
			else
				Watermark.Size = UDim2.new(0, totalWidth, 0, 30);
			end;
		end;

		-- Smooth Reorder Function: blocks physically glide into new positions
		function Watermark_lb:MoveBlock(keyOrBlock, direction)
			local targetIdx = nil;
			for idx, b in ipairs(Watermark_lb.Blocks) do
				if b == keyOrBlock or b.Key == keyOrBlock or b.Name == keyOrBlock then
					targetIdx = idx;
					break;
				end;
			end;
			if not targetIdx then return end;

			local newIdx = targetIdx + direction;
			-- Keep Title/Logo pinned at index 1:
			if newIdx < 2 or newIdx > #Watermark_lb.Blocks then return end;
			if targetIdx == 1 then return end;

			Watermark_lb.Blocks[targetIdx], Watermark_lb.Blocks[newIdx] = Watermark_lb.Blocks[newIdx], Watermark_lb.Blocks[targetIdx];

			for idx, b in ipairs(Watermark_lb.Blocks) do
				b.Order = idx;
			end;

			Watermark_lb:UpdateLayout(true);
		end;

		function Watermark_lb:SetRender(value)
			Watermark_lb.Status = value;

			if value then
				NeverLose.PlayAnimate(Watermark,SlowyTween , {
					BackgroundTransparency = 0.200
				})

				Shadow:Render(true);

				for i,v in next , Watermark_lb.Renders do
					pcall(v,true);
				end;
			else
				NeverLose.PlayAnimate(Watermark,SlowyTween , {
					BackgroundTransparency = 1
				})

				Shadow:Render(false);

				for i,v in next , Watermark_lb.Renders do
					pcall(v,false);
				end;
			end
		end;

		function Watermark_lb:SetLogo(logoAssetOrText)
			local logoBlock = Watermark_lb.BlockMap["Logo"] or Watermark_lb.BlockMap["Title"];
			if logoBlock then
				if string.sub(tostring(logoAssetOrText), 1, 10) == "rbxassetid" or string.sub(tostring(logoAssetOrText), 1, 8) == "rbxasset" then
					local img = logoBlock.Frame:FindFirstChild("LogoImg") or Instance.new("ImageLabel", logoBlock.Frame);
					img.Name = "LogoImg";
					img.BackgroundTransparency = 1;
					img.Size = UDim2.new(0, 18, 0, 18);
					img.Position = UDim2.new(0, 4, 0.5, 0);
					img.AnchorPoint = Vector2.new(0, 0.5);
					img.ZIndex = 18;
					img.Image = logoAssetOrText;
					if logoBlock.Icon then logoBlock.Icon.Visible = false end;
				else
					if logoBlock.Content then logoBlock.Content.Text = tostring(logoAssetOrText) end;
				end;
				Watermark_lb:UpdateLayout(true);
			end;
		end;

		-- AddBlock with automatic deduplication: if key already exists, update and reuse it!
		function Watermark_lb:AddBlock(IconStr , Name, key)
			local checkKey = key or Name;
			local normalizedKey = checkKey;
			if checkKey == "Logo" and Watermark_lb.BlockMap["Title"] then
				normalizedKey = "Title";
			elseif checkKey == "Title" and Watermark_lb.BlockMap["Logo"] then
				normalizedKey = "Logo";
			end;

			local existing = Watermark_lb.BlockMap[normalizedKey] or Watermark_lb.BlockMap[checkKey];
			if existing then
				if IconStr ~= nil and existing.Icon then
					existing.Icon.Text = IconStr or "";
					existing.Icon.Visible = (IconStr ~= "");
				end;
				if Name ~= nil and existing.Content then
					existing.Content.Text = tostring(Name);
				end;
				existing.Update();
				return existing;
			end;

			local InnerBlock = {};

			local Frame = Instance.new("Frame")
			local Content = Instance.new("TextLabel")
			local Icon = Instance.new("TextLabel")

			Frame.Parent = Watermark
			Frame.AnchorPoint = Vector2.new(0, 0.5)
			Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Frame.BackgroundTransparency = 1.000
			Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Frame.BorderSizePixel = 0
			Frame.Size = UDim2.new(0, 50, 0, 24)

			local FrameCorner = Instance.new("UICorner");
			FrameCorner.CornerRadius = UDim.new(0, 6);
			FrameCorner.Parent = Frame;

			local FrameStroke = Instance.new("UIStroke");
			FrameStroke.Color = NeverLose.AccentColor;
			FrameStroke.Thickness = 1;
			FrameStroke.Transparency = 1;
			FrameStroke.Parent = Frame;

			local order = #Watermark_lb.Blocks + 1;

			Content.Name = NeverLose.RandomString();
			Content.Parent = Frame
			Content.AnchorPoint = Vector2.new(0, 0.5)
			Content.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
			Content.BackgroundTransparency = 1.000
			Content.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Content.BorderSizePixel = 0
			Content.Position = UDim2.new(0, (IconStr and IconStr ~= "" and 24 or 6), 0.5, 0)
			Content.Size = UDim2.new(0, 1, 0, 22)
			Content.ZIndex = 17
			Content.Font = Enum.Font.GothamBold
			Content.Text = tostring(Name or "")
			Content.TextColor3 = Color3.fromRGB(240, 242, 250)
			Content.TextSize = 12.000
			Content.TextTransparency = 0.05
			Content.TextXAlignment = Enum.TextXAlignment.Left

			Icon.Name = NeverLose.RandomString();
			Icon.Parent = Frame
			Icon.AnchorPoint = Vector2.new(0, 0.5)
			Icon.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
			Icon.BackgroundTransparency = 1.000
			Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Icon.BorderSizePixel = 0
			Icon.Position = UDim2.new(0, 6, 0.5, 0)
			Icon.Size = UDim2.new(0, 16, 0, 16)
			Icon.ZIndex = 17
			Icon.FontFace = NeverLose.BuiltInBold;
			Icon.Text = IconStr or ""
			Icon.TextColor3 = NeverLose.AccentColor
			Icon.TextSize = 13.000
			Icon.TextTransparency = 0.000
			Icon.TextWrapped = true
			Icon.Visible = (IconStr and IconStr ~= "") or false
			NeverLose:RegisterAccent(Icon, "TextColor3");

			InnerBlock.Key = checkKey;
			InnerBlock.Name = Name;
			InnerBlock.Frame = Frame;
			InnerBlock.Icon = Icon;
			InnerBlock.Content = Content;
			InnerBlock.Order = order;

			table.insert(Watermark_lb.Blocks, InnerBlock);
			Watermark_lb.BlockMap[checkKey] = InnerBlock;
			if checkKey == "Title" then Watermark_lb.BlockMap["Logo"] = InnerBlock end;
			if checkKey == "Logo" then Watermark_lb.BlockMap["Title"] = InnerBlock end;

			-- Dragging: LMB strictly drags watermark container; MMB strictly reorders blocks with subtle in-place highlight
			local isBlockDragging = false;

			local function startReorderDrag(input)
				local isGuiOpen = (NeverLose.IsGuiOpen == true) or (NeverLose.MainWindow and NeverLose.MainWindow.Visible and NeverLose.MainWindow.BackgroundTransparency < 0.9);
				if not isGuiOpen or InnerBlock.Key == "Title" or InnerBlock.Key == "Logo" then return end;
				isBlockDragging = true;

				-- Subtle in-place highlight directly inside the watermark
				TweenService:Create(Frame, FastTween, {
					BackgroundTransparency = 0.45,
					BackgroundColor3 = Color3.fromRGB(50, 62, 85)
				}):Play();
				TweenService:Create(FrameStroke, FastTween, {
					Transparency = 0.35,
					Color = NeverLose.AccentColor
				}):Play();
			end;

			local function stopReorderDrag()
				if isBlockDragging then
					isBlockDragging = false;
					TweenService:Create(Frame, FastTween, {
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					}):Play();
					TweenService:Create(FrameStroke, FastTween, {
						Transparency = 1
					}):Play();
				end;
			end;

			Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					-- LMB on any block drags the whole watermark
					startWMDrag(input);
				elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
					-- MMB strictly handles block reordering
					startReorderDrag(input);
				end;
			end);

			NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(input)
				if isBlockDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					local mouseX = input.Position.X;
					local myIdx = nil;
					for idx, b in ipairs(Watermark_lb.Blocks) do
						if b == InnerBlock then myIdx = idx; break; end;
					end;
					if myIdx then
						if myIdx > 2 then
							local leftBlock = Watermark_lb.Blocks[myIdx - 1];
							if leftBlock and leftBlock.Frame then
								local leftCenter = leftBlock.Frame.AbsolutePosition.X + (leftBlock.Frame.AbsoluteSize.X / 2);
								if mouseX < leftCenter then
									Watermark_lb:MoveBlock(InnerBlock, -1);
								end;
							end;
						end;
						if myIdx < #Watermark_lb.Blocks then
							local rightBlock = Watermark_lb.Blocks[myIdx + 1];
							if rightBlock and rightBlock.Frame then
								local rightCenter = rightBlock.Frame.AbsolutePosition.X + (rightBlock.Frame.AbsoluteSize.X / 2);
								if mouseX > rightCenter then
									Watermark_lb:MoveBlock(InnerBlock, 1);
								end;
							end;
						end;
					end;
				end;
			end));

			Frame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton3 then
					stopReorderDrag();
				end;
			end);

			NeverLose:AddSignal(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton3 then
					stopReorderDrag();
				end;
			end));

			InnerBlock.Update = LPH_NO_VIRTUALIZE(function(value)
				Watermark_lb:UpdateLayout(true);
			end);

			InnerBlock.Visible = true;
			Watermark_lb:UpdateLayout(false);

			function InnerBlock:SetVisible(v)
				InnerBlock.Visible = v;

				if Watermark_lb.Status then
					InnerBlock.SetRender(v);
				end;

				InnerBlock.Update();
			end;

			InnerBlock.SetRender = LPH_NO_VIRTUALIZE(function(value)
				if value and InnerBlock.Visible then
					NeverLose.PlayAnimate(Content,SlowyTween , {
						TextTransparency = 0.05
					})

					NeverLose.PlayAnimate(Icon,SlowyTween , {
						TextTransparency = 0.00
					})
				else
					NeverLose.PlayAnimate(Content,SlowyTween , {
						TextTransparency = 1
					})

					NeverLose.PlayAnimate(Icon,SlowyTween , {
						TextTransparency = 1
					})
				end;
			end);

			table.insert(Watermark_lb.Renders,InnerBlock.SetRender);

			function InnerBlock:SetText(t)
				Content.Text = tostring(t);
				InnerBlock.Update();
			end;

			function InnerBlock:Input(func)
				local c,s = NeverLose:CreateInput(Frame,func);
				return s;
			end;

			return InnerBlock;
		end;

		return Watermark_lb;
	end;

	-- Auto-initialize test Watermark badge (Only 1 set of default blocks!)
	local AutoWM = Window:Watermark();
	local WMTitle = AutoWM:AddBlock("sparkles", "whispy", "Title");
	local WMUser = AutoWM:AddBlock("user", Window.Username or LocalPlayer.DisplayName, "User");
	local WMFps = AutoWM:AddBlock("activity", "60 FPS", "Fps");
	local WMPing = AutoWM:AddBlock("globe", "45 MS", "Ping");
	local WMTime = AutoWM:AddBlock("floppy-disk", os.date("%H:%M"), "Time");

	NeverLose.WatermarkInstance = AutoWM;
	Window.WatermarkObj = AutoWM;
	Window.WatermarkBlocks = {
		Title = WMTitle,
		Logo = WMTitle,
		User = WMUser,
		Fps = WMFps,
		Ping = WMPing,
		Time = WMTime,
	};

	-- Live FPS, Ping, Time loop (High performance single loop)
	local lastWMUpdate = 0;
	local wmFrames = 0;
	NeverLose:AddSignal(RunService.RenderStepped:Connect(function(dt)
		wmFrames = wmFrames + 1;
		local now = tick();
		if now - lastWMUpdate >= 0.5 then
			local curFps = math.floor(wmFrames / (now - lastWMUpdate));
			wmFrames = 0;
			lastWMUpdate = now;

			if WMFps and WMFps.SetText then WMFps:SetText(curFps .. " FPS") end;
			if WMTime and WMTime.SetText then WMTime:SetText(os.date("%H:%M")) end;

			local pingVal = 0;
			local statsObj = game:GetService("Stats");
			if statsObj and statsObj:FindFirstChild("PerformanceStats") and statsObj.PerformanceStats:FindFirstChild("Ping") then
				pingVal = math.floor(statsObj.PerformanceStats.Ping:GetValue());
			end;
			if pingVal == 0 then
				pcall(function()
					pingVal = math.floor((LocalPlayer:GetNetworkPing() or 0.02) * 1000);
				end);
			end;
			if WMPing and WMPing.SetText then WMPing:SetText(pingVal .. " MS") end;
		end;
	end));

	AutoWM:SetRender(true);

	Window:SetAccount();

	NeverLose:AddSignal(UserInputService.InputBegan:Connect(LPH_NO_VIRTUALIZE(function(value,ISTYPING)
		if NeverLose.IsRebindingKey then return end;
		if value.KeyCode == Window.Keybind or value.KeyCode.Name == Window.Keybind then
			if not ISTYPING then
				Window:ToggleInterface()
			end
		end;
	end)));

	function Window:ToggleInterface()
		Window.Signal:SetValue(not Window.Signal:GetValue());

		if Window.__3DRender then
			Window.Load3DBlock();
		end;
	end;

	Window:SetRender(true);

	return Window;
end;

function NeverLose:CreateNotification()
	if NeverLose.__Notification_Cache then
		return NeverLose.__Notification_Cache;
	end;

	local Notifier = {};
	local Notification = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")

	Notification.Name = NeverLose.RandomString();
	Notification.Parent = NeverLose.ScreenGui;
	Notification.AnchorPoint = Vector2.new(1, 0)
	Notification.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Notification.BackgroundTransparency = 1.000
	Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(1, -25, 0, 25)
	Notification.Size = UDim2.new(0, 25, 0, 25)

	UIListLayout.Parent = Notification
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 0)

	NeverLose.__Notification_Cache = Notifier;

	function Notifier.new(Config)
		Config = NeverLose:ProcessParams(Config , {
			Title = "Notification",
			Content = "Hello World!",
			Logo = NeverLose.GlobalLogo or "rbxasset://textures/ui/VerifiedBadgeNameIcon.png",
			Duration = 5,
		});

		if NeverLose.__WatermarkCache then
			NeverLose.PlayAnimate(Notification,SlowyTween , {
				Position = UDim2.new(1, -25, 0, 55)
			});
		end;

		local ContainerFrame = Instance.new("Frame")
		local NotifyFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local LogoImage = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local NotifyName = Instance.new("TextLabel")
		local NotifyContent = Instance.new("TextLabel");
		local shadow = NeverLose:CreateShadow(NotifyFrame , true);

		ContainerFrame.Name = NeverLose.RandomString();
		ContainerFrame.Parent = Notification
		ContainerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ContainerFrame.BackgroundTransparency = 1.000
		ContainerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ContainerFrame.BorderSizePixel = 0
		ContainerFrame.Size = UDim2.new(0, 0, 0, 100)

		NotifyFrame.Name = NeverLose.RandomString();
		NotifyFrame.Parent = ContainerFrame
		NotifyFrame.AnchorPoint = Vector2.new(1, 0)
		NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
		NotifyFrame.BackgroundTransparency = 0.075
		NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		NotifyFrame.BorderSizePixel = 0
		NotifyFrame.ClipsDescendants = true
		NotifyFrame.Position = UDim2.new(0, 750, 0, 0)
		NotifyFrame.Size = UDim2.new(0, 220, 0, 55)
		NotifyFrame.ZIndex = 130

		UICorner.CornerRadius = UDim.new(0, 10)
		UICorner.Parent = NotifyFrame

		UIStroke.Transparency = 0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = NotifyFrame

		LogoImage.Name = NeverLose.RandomString();
		LogoImage.Parent = NotifyFrame
		LogoImage.AnchorPoint = Vector2.new(0, 0.5)
		LogoImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		LogoImage.BackgroundTransparency = 1.000
		LogoImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LogoImage.BorderSizePixel = 0
		LogoImage.Position = UDim2.new(0, 10, 0.5, 0)
		LogoImage.Size = UDim2.new(0, 35, 0, 35)
		LogoImage.ZIndex = 131
		LogoImage.Image = Config.Logo
		LogoImage.ImageColor3 = NeverLose.IconColor;

		UICorner_2.CornerRadius = UDim.new(0, 7)
		UICorner_2.Parent = LogoImage

		NotifyName.Name = NeverLose.RandomString();
		NotifyName.Parent = NotifyFrame
		NotifyName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NotifyName.BackgroundTransparency = 1.000
		NotifyName.BorderColor3 = Color3.fromRGB(0, 0, 0)
		NotifyName.BorderSizePixel = 0
		NotifyName.Position = UDim2.new(0, 50, 0, 7)
		NotifyName.Size = UDim2.new(0, 200, 0, 20)
		NotifyName.ZIndex = 132
		NotifyName.Font = Enum.Font.GothamBold
		NotifyName.Text = Config.Title
		NotifyName.TextColor3 = Color3.fromRGB(255, 255, 255)
		NotifyName.TextSize = 17.000
		NotifyName.TextXAlignment = Enum.TextXAlignment.Left

		NotifyContent.Name = NeverLose.RandomString();
		NotifyContent.Parent = NotifyFrame
		NotifyContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NotifyContent.BackgroundTransparency = 1.000
		NotifyContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
		NotifyContent.BorderSizePixel = 0
		NotifyContent.Position = UDim2.new(0, 50, 0, 28)
		NotifyContent.Size = UDim2.new(0, 200, 0, 15)
		NotifyContent.ZIndex = 132
		NotifyContent.Font = Enum.Font.GothamBold
		NotifyContent.Text = Config.Content
		NotifyContent.TextColor3 = Color3.fromRGB(255, 255, 255)
		NotifyContent.TextSize = 12.000
		NotifyContent.TextTransparency = 0.650
		NotifyContent.TextXAlignment = Enum.TextXAlignment.Left

		local Size1 = TextService:GetTextSize(NotifyName.Text,NotifyName.TextSize,NotifyName.Font,Vector2.new(math.huge,math.huge));
		local Size2 = TextService:GetTextSize(NotifyContent.Text,NotifyContent.TextSize,NotifyContent.Font,Vector2.new(math.huge,math.huge));

		local MainSize = math.max(Size1.X , Size2.X);

		NotifyFrame.Size = UDim2.new(0, MainSize + 65, 0, 55);

		shadow:Render(true)
		NeverLose.PlayAnimate(NotifyFrame , VSlowTween , {
			Position = UDim2.new(1, 0, 0, 0)
		})

		ContainerFrame.Size = UDim2.new(0, 0, 0, 65)

		task.delay(Config.Duration or 5 , LPH_NO_VIRTUALIZE(function()

			if NeverLose.__WatermarkCache then
				NeverLose.PlayAnimate(Notification,SlowyTween , {
					Position = UDim2.new(1, -25, 0, 55)
				});
			end;

			shadow:Render(false)

			NeverLose.PlayAnimate(NotifyFrame , SlowyTween , {
				BackgroundTransparency = 1
			})

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 1
			})

			NeverLose.PlayAnimate(LogoImage , SlowyTween , {
				ImageTransparency = 1
			})

			NeverLose.PlayAnimate(NotifyName , SlowyTween , {
				TextTransparency = 1
			})

			NeverLose.PlayAnimate(NotifyContent , SlowyTween , {
				TextTransparency = 1
			})

			task.wait(0.125);

			NeverLose.PlayAnimate(ContainerFrame , SlowyTween , {
				Size = UDim2.new(0, 0, 0, 0)
			})

			task.wait(0.125);

			ContainerFrame:Destroy();
		end))
	end;

	return Notifier;
end;

function NeverLose:CreateLogger()
	if NeverLose.__LogSystem then
		return 	NeverLose.__LogSystem;
	end;

	local Logging = {};
	local Log = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")

	Log.Name = NeverLose.RandomString();
	Log.Parent = NeverLose.ScreenGui
	Log.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Log.BackgroundTransparency = 1.000
	Log.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Log.BorderSizePixel = 0
	Log.Position = UDim2.new(0, 25, 0, 5 + math.abs(NeverLose.ScreenGui.AbsolutePosition.Y))
	Log.Size = UDim2.new(0, 25, 0, 25)

	UIListLayout.Parent = Log
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 12)

	NeverLose.__LogSystem = Logging;

	function Logging.new(IconStr: string , Message: string , Duration: number)
		Duration = Duration or 3;
		Message = Message or "Log";
		IconStr = IconStr or "crosshairs";

		local LogFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local LogContent = Instance.new("TextLabel")
		local Line = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local Icon = Instance.new("TextLabel")
		local Shadow = NeverLose:CreateShadow(LogFrame , true);

		LogFrame.Name = NeverLose.RandomString();
		LogFrame.Parent = Log
		LogFrame.AnchorPoint = Vector2.new(0.5, 0)
		LogFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
		LogFrame.BackgroundTransparency =  1--0.075
		LogFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LogFrame.BorderSizePixel = 0
		LogFrame.ClipsDescendants = true
		LogFrame.Position = UDim2.new(0,0,0,0)
		LogFrame.Size = UDim2.new(0, 0, 0, 20)
		LogFrame.ZIndex = 130

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = LogFrame

		UIStroke.Transparency = 1--0.650
		UIStroke.Color = Color3.fromRGB(45, 48, 58)
		UIStroke.Parent = LogFrame

		LogContent.Name = NeverLose.RandomString();
		LogContent.Parent = LogFrame
		LogContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		LogContent.BackgroundTransparency = 1.000
		LogContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LogContent.BorderSizePixel = 0
		LogContent.Position = UDim2.new(0, 25, 0, 2)
		LogContent.Size = UDim2.new(0, 200, 0, 15)
		LogContent.ZIndex = 132
		LogContent.Font = Enum.Font.GothamBold
		LogContent.Text = Message
		LogContent.TextColor3 = Color3.fromRGB(255, 255, 255)
		LogContent.TextSize = 12.000
		LogContent.TextTransparency = 1--0.250
		LogContent.TextXAlignment = Enum.TextXAlignment.Left

		Line.Name = NeverLose.RandomString();
		Line.Parent = LogFrame
		Line.AnchorPoint = Vector2.new(0, 0.5)
		Line.BackgroundColor3 = NeverLose.AccentColor
		Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Line.BackgroundTransparency = 1 --0
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0, -2, 0.5, 0)
		Line.Size = UDim2.new(0, 5, 1, 0)
		Line.ZIndex = 131

		UICorner_2.CornerRadius = UDim.new(0, 4)
		UICorner_2.Parent = Line

		Icon.Name = NeverLose.RandomString();
		Icon.Parent = LogFrame
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0, 7, 0, 3)
		Icon.Size = UDim2.new(0, 15, 0, 15)
		Icon.ZIndex = 133
		Icon.FontFace = NeverLose.BuiltInBold
		Icon.Text = IconStr
		Icon.TextColor3 = Color3.fromRGB(223, 223, 223)
		Icon.TextSize = 13.000
		Icon.TextTransparency = 1--0.250
		Icon.TextWrapped = true

		local size = TextService:GetTextSize(LogContent.Text,LogContent.TextSize,LogContent.Font,Vector2.new(math.huge,math.huge));

		NeverLose.PlayAnimate(LogFrame , SlowyTween , {
			Size = UDim2.new(0, size.X + 35, 0, 20),
			BackgroundTransparency =  0.075
		});

		task.delay(0.15,LPH_NO_VIRTUALIZE(function()
			Shadow:Render(true);

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 0.650
			});

			NeverLose.PlayAnimate(LogContent , SlowyTween , {
				TextTransparency = 0.25
			});

			NeverLose.PlayAnimate(Line , SlowyTween , {
				BackgroundTransparency = 0
			});

			NeverLose.PlayAnimate(Icon , SlowyTween , {
				TextTransparency = 0.25
			});

			task.wait(Duration + 0.1);

			Shadow:Render(false);

			NeverLose.PlayAnimate(LogFrame , SlowyTween , {
				BackgroundTransparency =  1
			});

			NeverLose.PlayAnimate(UIStroke , SlowyTween , {
				Transparency = 1
			});

			NeverLose.PlayAnimate(LogContent , SlowyTween , {
				TextTransparency = 1
			});

			NeverLose.PlayAnimate(Line , SlowyTween , {
				BackgroundTransparency = 1
			});

			NeverLose.PlayAnimate(Icon , SlowyTween , {
				TextTransparency = 1
			});

			task.wait(0.25);

			LogFrame:Destroy();
		end))
	end;

	return Logging
end;

function NeverLose:CreateIndicator()
	local IndicatorFrame = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")

	IndicatorFrame.Name = NeverLose.RandomString();
	IndicatorFrame.Parent = NeverLose.ScreenGui;
	IndicatorFrame.AnchorPoint = Vector2.new(0, 0.5)
	IndicatorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	IndicatorFrame.BackgroundTransparency = 1.000
	IndicatorFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	IndicatorFrame.BorderSizePixel = 0
	IndicatorFrame.Position = UDim2.new(0, 15, 0.5, 0)
	IndicatorFrame.Size = UDim2.new(0, 100, 0, 100)
	IndicatorFrame.ZIndex = 15

	UIListLayout.Parent = IndicatorFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 10)

	local Indicators = {};

	Indicators.Color = {
		Red = Color3.fromRGB(255, 102, 105),
		Green = Color3.fromRGB(135, 255, 143),
		White = Color3.fromRGB(186, 186, 186),
	};

	Indicators.Root = IndicatorFrame;

	function Indicators.new(Config)
		Config = NeverLose:ProcessParams(Config , {
			Name = "Indicator",
			Icon = 'crosshairs',
			Color = 'Red',
		});

		local Indicator = {
			CurrentColor = Config.Color,	
			Visible = false,
		};

		local IndicatorItem = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local Line = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIGradient = Instance.new("UIGradient")
		local Icon = Instance.new("TextLabel")
		local Content = Instance.new("TextLabel")
		local Shadow = NeverLose:CreateShadow(IndicatorItem);

		IndicatorItem.Name = NeverLose.RandomString();
		IndicatorItem.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
		IndicatorItem.BackgroundTransparency = 1
		IndicatorItem.BorderColor3 = Color3.fromRGB(0, 0, 0)
		IndicatorItem.BorderSizePixel = 0
		IndicatorItem.ClipsDescendants = true
		IndicatorItem.Size = UDim2.new(0, 85, 0, 40)
		IndicatorItem.ZIndex = 16
		IndicatorItem.Visible = false;

		IndicatorItem:GetPropertyChangedSignal('BackgroundTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
			if IndicatorItem.BackgroundTransparency > 0.9 then
				IndicatorItem.Parent = nil;
				IndicatorItem.Visible = false;
			else
				IndicatorItem.Parent = IndicatorFrame;
				IndicatorItem.Visible = true;
			end;
		end))

		UICorner.CornerRadius = UDim.new(0, 25)
		UICorner.Parent = IndicatorItem

		Line.Name = NeverLose.RandomString();
		Line.Parent = IndicatorItem
		Line.AnchorPoint = Vector2.new(0, 0.5)
		Line.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
		Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0, 2, 0.5, 0)
		Line.BackgroundTransparency = 1;
		Line.Size = UDim2.new(0, 3, 0.649999976, 0)
		Line.ZIndex = 17

		UICorner_2.CornerRadius = UDim.new(0, 25)
		UICorner_2.Parent = Line

		UIGradient.Rotation = 90
		UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
		UIGradient.Parent = Line

		Icon.Name = NeverLose.RandomString();
		Icon.Parent = IndicatorItem
		Icon.AnchorPoint = Vector2.new(0, 0.5)
		Icon.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0, 10, 0.5, 0)
		Icon.Size = UDim2.new(0, 25, 0, 25)
		Icon.ZIndex = 17
		Icon.FontFace = NeverLose.BuiltInBold;
		Icon.Text = Config.Icon
		Icon.TextColor3 = Color3.fromRGB(186, 186, 186)
		Icon.TextSize = 21.000
		Icon.TextTransparency = 1
		Icon.TextWrapped = true

		Content.Name = NeverLose.RandomString();
		Content.Parent = IndicatorItem
		Content.AnchorPoint = Vector2.new(0, 0.5)
		Content.BackgroundColor3 = Color3.fromRGB(186, 186, 186)
		Content.BackgroundTransparency = 1.000
		Content.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Content.BorderSizePixel = 0
		Content.Position = UDim2.new(0, 40, 0.5, 0)
		Content.Size = UDim2.new(1, -40, 0, 25)
		Content.ZIndex = 17
		Content.Font = Enum.Font.GothamBold
		Content.Text = Config.Name
		Content.TextColor3 = Color3.fromRGB(186, 186, 186)
		Content.TextSize = 20.000
		Content.TextTransparency = 1
		Content.TextXAlignment = Enum.TextXAlignment.Left

		Indicator.Update = LPH_NO_VIRTUALIZE(function()
			local text = TextService:GetTextSize(Content.Text,Content.TextSize , Content.Font , Vector2.new(math.huge,math.huge));

			NeverLose.PlayAnimate(IndicatorItem , SlowyTween , {
				Size = UDim2.new(0, text.X + 60, 0, 40);
			})
		end);

		Indicator.SetRender = LPH_NO_VIRTUALIZE(function(self , value)
			Indicator.Visible = value;

			if value then
				NeverLose.PlayAnimate(IndicatorItem , SlowyTween , {
					BackgroundTransparency = 0.200
				});

				NeverLose.PlayAnimate(Line , SlowyTween , {
					BackgroundTransparency = 0,
					BackgroundColor3 = Indicators.Color[Indicator.CurrentColor]
				});

				NeverLose.PlayAnimate(Icon , VSlowTween , {
					TextTransparency = 0.250,
					TextColor3 = Indicators.Color[Indicator.CurrentColor]
				});

				NeverLose.PlayAnimate(Content , VSlowTween , {
					TextTransparency = 0.2,
					TextColor3 = Indicators.Color[Indicator.CurrentColor]
				});

				Shadow:Render(true);
			else
				NeverLose.PlayAnimate(IndicatorItem , SlowyTween , {
					BackgroundTransparency = 1
				});

				NeverLose.PlayAnimate(Line , SlowyTween , {
					BackgroundTransparency = 1,
					BackgroundColor3 = Indicators.Color[Indicator.CurrentColor]
				});

				NeverLose.PlayAnimate(Icon , VSlowTween , {
					TextTransparency = 1,
					TextColor3 = Indicators.Color[Indicator.CurrentColor]
				});

				NeverLose.PlayAnimate(Content , VSlowTween , {
					TextTransparency = 1,
					TextColor3 = Indicators.Color[Indicator.CurrentColor]
				});

				Shadow:Render(false);
			end;

			Indicator.Update();
		end);

		Indicator.Update();
		Indicator:SetRender(false);

		function Indicator:SetColor(new_color)
			Indicator.CurrentColor = new_color;

			if Indicator.Visible then
				Indicator:SetRender(true);
			end;
		end;

		function Indicator:SetText(name)
			Config.Name = name;

			Content.Text = Config.Name;

			Indicator.Update();
		end;

		return Indicator;
	end;

	return Indicators;
end;

function NeverLose:Unload()
	for _, sig in ipairs(NeverLose.GlobalSignals) do
		pcall(function() sig:Disconnect() end);
	end;
	NeverLose.GlobalSignals = {};

	if NeverLose.HotkeysHUD and NeverLose.HotkeysHUD.Parent then
		pcall(function() NeverLose.HotkeysHUD:Destroy() end);
	end;

	if NeverLose.WatermarkInstance and typeof(NeverLose.WatermarkInstance) == "table" and NeverLose.WatermarkInstance.SetRender then
		pcall(function() NeverLose.WatermarkInstance:SetRender(false) end);
	end;

	if NeverLose.ScreenGui and NeverLose.ScreenGui.Parent then
		pcall(function() NeverLose.ScreenGui:Destroy() end);
	end;

	if NeverLose.GlobalSurfaceGui and NeverLose.GlobalSurfaceGui.Parent then
		pcall(function() NeverLose.GlobalSurfaceGui:Destroy() end);
	end;

	if getgenv().NeverLose then
		getgenv().NeverLose = nil;
	end;

	print("[Whispy] UI successfully unloaded.");
end;

return NeverLose;
