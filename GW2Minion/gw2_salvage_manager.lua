gw2_salvage_manager = {}
gw2_salvage_manager.active = false
gw2_salvage_manager.salvageTick = 0
gw2_salvage_manager.toolTip = false
gw2_salvage_manager.filterList = {list = {}, nameList = {}, currID = 1,}
gw2_salvage_manager.singleItemList = {list = {}, nameList = {}, currID = 1,}
gw2_salvage_manager.inventoryItemList = {list = {}, nameList = {}, currID = 1,}
gw2_salvage_manager.salvageKitList = {
	list = {
		-- none kit
		{name = GetString("none"),				id = "none",			itemid = "none",	rarity = 0,},	-- No kit placeholder
		-- normal kits
		{name = GetString("crudeKit"),			id = "crudekit",		itemid = 23038,		rarity = 0,},	-- Crude Salvage Kit (rarity 1)
		{name = GetString("basicKit"),			id = "basickit",		itemid = 23040,		rarity = 1,},	-- Basic Salvage Kit (rarity 1)
		{name = GetString("fineKit"),			id = "finekit",			itemid = 23041,		rarity = 2,},	-- Fine (rarity 2)
		{name = GetString("journeymanKit"),		id = "journeymankit",	itemid = 23042,		rarity = 3,},	-- Journeyman (rarity 3)
		{name = GetString("masterKit"),			id = "masterkit",		itemid = 23043,		rarity = 4,},	-- Master (rarity 4)
		-- special kits
		-- {name = GetString("mysticKit"),			id = "mystickit",		itemid = 23045,		rarity = 4,},	-- Mystic Kit (rarity 4)
		{name = GetString("copperfedKit"),		id = "copperfedkit",	itemid = 44602,		rarity = 1,},	-- Copper-Fed Kit (rarity 1)
		{name = GetString("runecrafterkit"),	id = "runecrafterkit",	itemid = 89409,		rarity = 5,},	-- Runecrafter Kit (rarity 1)
		{name = GetString("silverfedKit"),		id = "silverfedkit",	itemid = 67027,		rarity = 4,},	-- Silver-Fed Kit (rarity 4)
		-- {name = GetString("blacklionKit"),		id = "blacklionkit",	itemid = 19986,		rarity = 5,},	-- Black Lion Kit (Rarity 5)
	},
	kitlist = {}, -- [itemID] = {name = stringid, rarity = rarity}
	nameList = {}, -- [key] = name
	savenameList = {}, -- [key] = stringid --> could acces list.id instead. 1 extra table makes more readable and no overhead.
	saveidList = {}, -- [stringid] = key
	currID = 1,
}
gw2_salvage_manager.tempFilter = {
	new = true,
	name = "",
	preferedKit = "None",
	rarity = {Common = false, Fine = false, Masterwork = false, Rare = false, Exotic = false},
	itemType = {Armor = false, Back = false, Bag = false, Consumable = false, Container = false, CraftingMaterial = false, Gathering = false, Gizmo = false, MiniDeck = false, SalvageTool = false, Trinket = false, Trophy = false, UpgradeComponent = false, Weapon = false,},
}
gw2_salvage_manager.tempSingleItem = {
	new = true,
	itemID = 0,
	name = "",
	preferedKit = "None",
}
gw2_salvage_manager.customChecks = {}


-- Gui stuff here.
gw2_salvage_manager.mainWindow = {
	name = GetString("salvagemanager"),
	open = false,
	visible = true,
}

function gw2_salvage_manager.ModuleInit()
	-- Init Module.

	-- init active stuff here.
	if (Settings.gw2_salvage_manager.active == nil) then
		Settings.gw2_salvage_manager.active = false
	end
	gw2_salvage_manager.active = Settings.gw2_salvage_manager.active
	-- end active init.

	-- init tooltip stuff here.
	if (Settings.gw2_salvage_manager.toolTip == nil) then
		Settings.gw2_salvage_manager.toolTip = true
	end
	gw2_salvage_manager.toolTip = Settings.gw2_salvage_manager.toolTip
	-- end tooltip init.

	-- init filter stuff here.
	if (Settings.gw2_salvage_manager.filterList == nil) then
		Settings.gw2_salvage_manager.filterList = {list = {}, nameList = {}, currID = 1}
	end
	gw2_salvage_manager.filterList = Settings.gw2_salvage_manager.filterList
	gw2_salvage_manager.filterListUpdate()
	-- end filter init.

	-- init single-item stuff here.
	if (Settings.gw2_salvage_manager.singleItemList == nil) then
		Settings.gw2_salvage_manager.singleItemList = {list = {}, nameList = {}, currID = 1}
	end
	gw2_salvage_manager.singleItemList = Settings.gw2_salvage_manager.singleItemList
	gw2_salvage_manager.singleItemListUpdate()
	-- end single-item init.

	-- init kitlist stuff here.
	gw2_salvage_manager.salvageKitListUpdate()

	-- init inventorylist stuff here.
	gw2_salvage_manager.inventoryItemListUpdate()

	-- init button in minionmainbutton
	ml_gui.ui_mgr:AddMember({ id = "GW2MINION##SALVMGR", name = "Salvage", onClick = function() gw2_salvage_manager.mainWindow.open = gw2_salvage_manager.mainWindow.open ~= true end, tooltip = "Click to open \"Salvage Manager\" window.", texture = GetStartupPath().."\\GUI\\UI_Textures\\recycle.png"},"GW2MINION##MENU_HEADER")

end

-- Gui draw function.
function gw2_salvage_manager.mainWindow.Draw(event,ticks)
	if (gw2_salvage_manager.mainWindow.open) then 
		-- set size on first use only.
		GUI:SetNextWindowSize(250,400,GUI.SetCond_FirstUseEver)
		-- update visible and open variables.
		gw2_salvage_manager.mainWindow.visible, gw2_salvage_manager.mainWindow.open = GUI:Begin(gw2_salvage_manager.mainWindow.name, gw2_salvage_manager.mainWindow.open, GUI.WindowFlags_AlwaysAutoResize) --+GUI.WindowFlags_NoCollapse
		if (gw2_salvage_manager.mainWindow.visible) then
			-- Status field.
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			GUI:Spacing()
			GUI:BeginGroup()
			gw2_salvage_manager.active = GUI:Checkbox(GetString("active"), gw2_salvage_manager.active)
			Settings.gw2_salvage_manager.active = gw2_salvage_manager.active
			GUI:Text("Supported Kits: Crude - Masters")
			GUI:Text("Copper & Silver-Fed + Runecrafter")
			GUI:EndGroup()
			if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
				GUI:SetTooltip("Turn Salvaging on or off.")
			end
			-----------------------------------------------------------------------------------------------------------------------------------
			GUI:Separator()
			-----------------------------------------------------------------------------------------------------------------------------------
			-- Filter group here.
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			GUI:SetNextTreeNodeOpened(true, GUI.SetCond_Appearing) -- open the tree *BUG* conditions not working as expected.
			if (GUI:TreeNode(GetString("filters"))) then -- create the tree, only pop inside if.
				GUI:PushItemWidth(200)
				gw2_salvage_manager.filterList.currID = GUI:ListBox("##msalvagem-filterlist",gw2_salvage_manager.filterList.currID,gw2_salvage_manager.filterList.nameList, 5)
				GUI:PopItemWidth()
				GUI:SameLine()
				GUI:BeginGroup()
				GUI:Spacing()
				-- NewFilter Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("newfilter"), 100,25)) then
					GUI:OpenPopup("##msalvagem-filterPopup")
					gw2_salvage_manager.tempFilter = {
						new = true,
						name = "",
						preferedKit = "None",
						rarity = {Common = false, Fine = false, Masterwork = false, Rare = false, Exotic = false},
						itemType = {Armor = false, Back = false, Bag = false, Consumable = false, Container = false, CraftingMaterial = false, Gathering = false, Gizmo = false, MiniDeck = false, SalvageTool = false, Trinket = false, Trophy = false, UpgradeComponent = false, Weapon = false,},
					}
					gw2_salvage_manager.salvageKitList.currID = 1
				end
				if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
					GUI:SetTooltip("Create a new filter.")
				end
				-- Edit Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("editfilter"), 100,25)) then
					if (gw2_salvage_manager.filterList.list[gw2_salvage_manager.filterList.currID] ~= nil) then
						GUI:OpenPopup("##msalvagem-filterPopup")
						gw2_salvage_manager.tempFilter = gw2_salvage_manager.filterList.list[gw2_salvage_manager.filterList.currID]
						gw2_salvage_manager.salvageKitList.currID = gw2_salvage_manager.salvageKitList.saveidList[gw2_salvage_manager.tempFilter.preferedKit]
					end
				end
				if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
					GUI:SetTooltip("Edit the selected filter.")
				end
				-- Create New/Edit filter button response.
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 420, GUI.SetCond_Once)
				if (GUI:BeginPopup("##msalvagem-filterPopup")) then
					GUI:Spacing()
					GUI:Text("Filter details:")
					GUI:Spacing()
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					-----------------------------------------------------------------------------------------------------------------------------------
					--name
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text("Name:")
					GUI:SameLine(180)
					gw2_salvage_manager.tempFilter.name = GUI:InputText("##msalvagem-filtername",gw2_salvage_manager.tempFilter.name)
					--prefkit
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("preferedKit"))
					GUI:SameLine(180)
					gw2_salvage_manager.salvageKitList.currID = GUI:Combo("##msalvagem-filterprefkit",gw2_salvage_manager.salvageKitList.currID,gw2_salvage_manager.salvageKitList.nameList)
					gw2_salvage_manager.tempFilter.preferedKit = gw2_salvage_manager.salvageKitList.savenameList[gw2_salvage_manager.salvageKitList.currID]
					--rarity
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("rarity"))
					GUI:SameLine(180)
					GUI:BeginChild("##msalvagem-filterrarity", 209, 80, true)
					gw2_salvage_manager.tempFilter.rarity.Common = GUI:Checkbox(GetString("rarityCommon"),gw2_salvage_manager.tempFilter.rarity.Common)
					GUI:SameLine(110)
					gw2_salvage_manager.tempFilter.rarity.Fine = GUI:Checkbox(GetString("rarityFine"),gw2_salvage_manager.tempFilter.rarity.Fine)
					gw2_salvage_manager.tempFilter.rarity.Masterwork = GUI:Checkbox(GetString("rarityMasterwork"),gw2_salvage_manager.tempFilter.rarity.Masterwork)
					GUI:SameLine(110)
					gw2_salvage_manager.tempFilter.rarity.Rare = GUI:Checkbox(GetString("rarityRare"),gw2_salvage_manager.tempFilter.rarity.Rare)
					gw2_salvage_manager.tempFilter.rarity.Exotic = GUI:Checkbox(GetString("rarityExotic"),gw2_salvage_manager.tempFilter.rarity.Exotic)
					GUI:EndChild()
					--itemtype
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text("Item-types:")
					GUI:SameLine(110)
					GUI:BeginChild("##msalvagem-filteritemtype", 279, 173, true)
					gw2_salvage_manager.tempFilter.itemType.Armor = GUI:Checkbox("Armor",gw2_salvage_manager.tempFilter.itemType.Armor)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.Back = GUI:Checkbox("Back",gw2_salvage_manager.tempFilter.itemType.Back)
					gw2_salvage_manager.tempFilter.itemType.Bag = GUI:Checkbox("Bag",gw2_salvage_manager.tempFilter.itemType.Bag)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.Consumable = GUI:Checkbox("Consumable",gw2_salvage_manager.tempFilter.itemType.Consumable)
					gw2_salvage_manager.tempFilter.itemType.CraftingMaterial = GUI:Checkbox("Crafting-Material",gw2_salvage_manager.tempFilter.itemType.CraftingMaterial)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.Gathering = GUI:Checkbox("Gathering",gw2_salvage_manager.tempFilter.itemType.Gathering)
					gw2_salvage_manager.tempFilter.itemType.Gizmo = GUI:Checkbox("Gizmo",gw2_salvage_manager.tempFilter.itemType.Gizmo)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.MiniDeck = GUI:Checkbox("MiniDeck",gw2_salvage_manager.tempFilter.itemType.MiniDeck)
					gw2_salvage_manager.tempFilter.itemType.SalvageTool = GUI:Checkbox("Salvage-Tool",gw2_salvage_manager.tempFilter.itemType.SalvageTool)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.Trinket = GUI:Checkbox("Trinket",gw2_salvage_manager.tempFilter.itemType.Trinket)
					gw2_salvage_manager.tempFilter.itemType.UpgradeComponent = GUI:Checkbox("Upgrade-Component",gw2_salvage_manager.tempFilter.itemType.UpgradeComponent)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.Weapon = GUI:Checkbox("Weapon",gw2_salvage_manager.tempFilter.itemType.Weapon)
					gw2_salvage_manager.tempFilter.itemType.Container = GUI:Checkbox("Container",gw2_salvage_manager.tempFilter.itemType.Container)
					GUI:SameLine(155)
					gw2_salvage_manager.tempFilter.itemType.Trophy = GUI:Checkbox("Trophy",gw2_salvage_manager.tempFilter.itemType.Trophy)
					GUI:EndChild()
					-- Layout spacing.
					GUI:Spacing()
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					------------------------------------------------------------------------------------------------------------------------
					-- Layout spacing.
					GUI:Dummy(100,20)
					GUI:Spacing()
					-- CANCEL BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					-- OK BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(240)
					if (GUI:Button(GetString("ok"),80,30)) then
						if (gw2_salvage_manager.validFilter(gw2_salvage_manager.tempFilter)) then
							-- save new filter here.
							if (gw2_salvage_manager.tempFilter.new) then
								gw2_salvage_manager.tempFilter.new = nil
								table.insert(gw2_salvage_manager.filterList.list, gw2_salvage_manager.tempFilter)
							-- save edited filter here.
							else
								gw2_salvage_manager.filterList.list[gw2_salvage_manager.filterList.currID] = gw2_salvage_manager.tempFilter
							end
							-- update.
							gw2_salvage_manager.filterListUpdate()
							GUI:CloseCurrentPopup()
						else
							GUI:OpenPopup("Invalid Filter.")
						end
					end
					GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
					GUI:SetNextWindowSize(400, 140, GUI.SetCond_Always)
					if (GUI:BeginPopupModal("Invalid Filter.",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
						GUI:Spacing()
						GUI:SameLine(150)
						GUI:Text("Invalid Filter.")
						GUI:Spacing()
						GUI:SameLine(135)
						GUI:SetWindowFontScale(0.8)
						GUI:Text("Please check the filter.")
						GUI:SetWindowFontScale(1)
						
						GUI:Spacing()
						GUI:Separator()
						GUI:Dummy(100,20)
						GUI:Spacing()
						GUI:SameLine(160)
						if (GUI:Button(GetString("ok"),80,30)) then
							GUI:CloseCurrentPopup()
						end
						GUI:EndPopup()
					end
					GUI:EndPopup()
				end
				
				-- Delete Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("deletefilter"), 100,25)) then
					if (gw2_salvage_manager.filterList.list[gw2_salvage_manager.filterList.currID] ~= nil) then
						GUI:OpenPopup("##msalvagem-deletefilterPopup")
					end
				end
				if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
					GUI:SetTooltip("Delete the selected filter.")
				end
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 140, GUI.SetCond_Always)
				if (GUI:BeginPopupModal("##msalvagem-deletefilterPopup",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
					GUI:Spacing()
					GUI:SameLine(50)
					GUI:Text("Are you sure you want to delete this filter?")
					GUI:Spacing()
					GUI:SameLine(80)
					GUI:SetWindowFontScale(0.8)
					GUI:Text("Press \"Delete\" to delete, \"Cancel\" to cancel. ")
					GUI:SetWindowFontScale(1)
					
					GUI:Spacing()
					GUI:Separator()
					GUI:Dummy(100,20)
					GUI:Spacing()
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					GUI:SameLine(240)
					if (GUI:Button(GetString("delete"),80,30)) then
						table.remove(gw2_salvage_manager.filterList.list, gw2_salvage_manager.filterList.currID)
						gw2_salvage_manager.filterListUpdate()
						GUI:CloseCurrentPopup()
					end
					GUI:EndPopup()
				end
				
				GUI:EndGroup()
				GUI:TreePop()
			end
			-----------------------------------------------------------------------------------------------------------------------------------
			GUI:Separator()
			-----------------------------------------------------------------------------------------------------------------------------------
			
			-- Single item group here.
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			GUI:SetNextTreeNodeOpened(true, GUI.SetCond_FirstUseEver)
			if (GUI:TreeNode(GetString("singleitems"))) then
				GUI:PushItemWidth(200)
				gw2_salvage_manager.singleItemList.currID = GUI:ListBox("##msalvagem-singleitemlist",gw2_salvage_manager.singleItemList.currID,gw2_salvage_manager.singleItemList.nameList, 5)
				GUI:PopItemWidth()
				GUI:SameLine()
				
				GUI:BeginGroup()
				GUI:Spacing()
				-- New-Item Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("newitem"), 100,25)) then
					GUI:OpenPopup("##msalvagem-itemPopup")
					gw2_salvage_manager.inventoryItemListUpdate()
					gw2_salvage_manager.tempSingleItem = {
						new = true,
						itemID = 0,
						name = "",
						preferedKit = "None",
					}
					gw2_salvage_manager.salvageKitList.currID = 1
				end
				if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
					GUI:SetTooltip("Add a new item.")
				end
				-- Edit item Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("edititem"), 100,25)) then
					if (gw2_salvage_manager.singleItemList.list[gw2_salvage_manager.singleItemList.currID] ~= nil) then
						GUI:OpenPopup("##msalvagem-itemPopup")
						gw2_salvage_manager.inventoryItemListUpdate()
						gw2_salvage_manager.tempSingleItem = gw2_salvage_manager.singleItemList.list[gw2_salvage_manager.singleItemList.currID]
						gw2_salvage_manager.salvageKitList.currID = gw2_salvage_manager.salvageKitList.saveidList[gw2_salvage_manager.tempSingleItem.preferedKit]
					end
				end
				if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
					GUI:SetTooltip("Edit the selected item.")
				end
				-- Create Button response.
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 160,GUI.SetCond_Once)
				if (GUI:BeginPopup("##msalvagem-itemPopup")) then
					GUI:Spacing()
					GUI:Text("Choose an item:")
					GUI:Spacing()
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					-----------------------------------------------------------------------------------------------------------------------------------
					--name
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text("Item:")
					GUI:PushItemWidth(240)
					GUI:SameLine(150)
					if (gw2_salvage_manager.tempSingleItem.new) then
						gw2_salvage_manager.inventoryItemList.currID = GUI:Combo("##msalvagem-inventorylist",gw2_salvage_manager.inventoryItemList.currID,gw2_salvage_manager.inventoryItemList.nameList)
						gw2_salvage_manager.tempSingleItem.itemID = gw2_salvage_manager.inventoryItemList.list[gw2_salvage_manager.inventoryItemList.currID].itemID
						gw2_salvage_manager.tempSingleItem.name = gw2_salvage_manager.inventoryItemList.list[gw2_salvage_manager.inventoryItemList.currID].name
					else
						GUI:InputText("##msalvagem-editItemName",gw2_salvage_manager.tempSingleItem.name,GUI.InputTextFlags_ReadOnly)
					end
					--prefkit
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("preferedKit"))
					GUI:SameLine(150)
					gw2_salvage_manager.salvageKitList.currID = GUI:Combo("##msalvagem-itemprefkit",gw2_salvage_manager.salvageKitList.currID,gw2_salvage_manager.salvageKitList.nameList)
					gw2_salvage_manager.tempSingleItem.preferedKit = gw2_salvage_manager.salvageKitList.savenameList[gw2_salvage_manager.salvageKitList.currID]
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					-----------------------------------------------------------------------------------------------------------------------------------
					-- Layout spacing.
					GUI:Dummy(100,20)
					GUI:Spacing()
					-- CANCEL BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					-- OK BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(240)
					if (GUI:Button(GetString("ok"),80,30)) then
						-- save new single item here.
						if (gw2_salvage_manager.tempSingleItem.new) then
							gw2_salvage_manager.tempSingleItem.new = nil
							table.insert(gw2_salvage_manager.singleItemList.list, gw2_salvage_manager.tempSingleItem)
						-- save edited single-item here.
						else
							gw2_salvage_manager.singleItemList.list[gw2_salvage_manager.singleItemList.currID] = gw2_salvage_manager.tempSingleItem
						end
						-- update.
						gw2_salvage_manager.singleItemListUpdate()
						GUI:CloseCurrentPopup()
					end
					GUI:EndPopup()
				end
				
				-- Delete Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button("Delete Item", 100,25)) then
					if (gw2_salvage_manager.singleItemList.list[gw2_salvage_manager.singleItemList.currID] ~= nil) then
						GUI:OpenPopup("Delete Item?")
					end
				end
				if (GUI:IsItemHovered() and gw2_salvage_manager.toolTip) then
					GUI:SetTooltip("Delete the selected item.")
				end
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 140, GUI.SetCond_Always)
				if (GUI:BeginPopupModal("Delete Item?",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
					GUI:Spacing()
					GUI:SameLine(50)
					GUI:Text("Are you sure you want to delete this item?")
					GUI:Spacing()
					GUI:SameLine(80)
					GUI:SetWindowFontScale(0.8)
					GUI:Text("Press \"Delete\" to delete, \"Cancel\" to cancel. ")
					GUI:SetWindowFontScale(1)
					
					GUI:Spacing()
					GUI:Separator()
					GUI:Dummy(100,20)
					GUI:Spacing()
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					GUI:SameLine(240)
					if (GUI:Button(GetString("delete"),80,30)) then
						table.remove(gw2_salvage_manager.singleItemList.list, gw2_salvage_manager.singleItemList.currID)
						gw2_salvage_manager.singleItemListUpdate()
						GUI:CloseCurrentPopup()
					end
					GUI:EndPopup()
				end
				GUI:EndGroup()
				GUI:TreePop()
			end
			-----------------------------------------------------------------------------------------------------------------------------------
			GUI:Separator()
			-----------------------------------------------------------------------------------------------------------------------------------
		end
		GUI:End()
	end
end

-- Salvage list function here.
function gw2_salvage_manager.salvageKitListUpdate()
	for id,kit in pairs(gw2_salvage_manager.salvageKitList.list) do
		gw2_salvage_manager.salvageKitList.kitlist[kit.itemid] = {name = kit.id; rarity = kit.rarity}
		table.insert(gw2_salvage_manager.salvageKitList.nameList,kit.name)
		table.insert(gw2_salvage_manager.salvageKitList.savenameList,kit.id)
		gw2_salvage_manager.salvageKitList.saveidList[kit.id] = id
	end
end

-- Filter list functions.
function gw2_salvage_manager.filterListUpdate()
	gw2_salvage_manager.filterList.nameList = {}
	for id,filter in ipairs(gw2_salvage_manager.filterList.list) do
		table.insert(gw2_salvage_manager.filterList.nameList,filter.name)
	end
	Settings.gw2_salvage_manager.filterList = gw2_salvage_manager.filterList
end

function gw2_salvage_manager.itemMatchesFilter(nItem)
	if (table.valid(nItem)) then
		for _,filter in pairs(gw2_salvage_manager.filterList.list) do
			local matchFilterRarity = false
			local matchFilterItemType = false
			for id,allowed in pairs(filter.rarity) do
				if (allowed and GW2.ITEMRARITY[id] == nItem.rarity) then
					matchFilterRarity = true
					break
				end
			end
			if (matchFilterRarity) then
				for id,allowed in pairs(filter.itemType) do
					if (allowed and GW2.ITEMTYPE[id] == nItem.itemtype) then
						matchFilterItemType = true
						break
					end
				end
				if (matchFilterItemType) then
					nItem.preferedKit = filter.preferedKit
					return true,nItem
				end
			end
		end
	end
	return false
end

function gw2_salvage_manager.validFilter(filter)
	return (table.valid(filter) and string.valid(filter.name) and table.contains(filter.rarity,true) and table.contains(filter.itemType,true))
end

-- Single-item list functions.
function gw2_salvage_manager.singleItemListUpdate()
	gw2_salvage_manager.singleItemList.nameList = {}
	for id,item in ipairs(gw2_salvage_manager.singleItemList.list) do
		table.insert(gw2_salvage_manager.singleItemList.nameList,item.name)
	end
	Settings.gw2_salvage_manager.singleItemList = gw2_salvage_manager.singleItemList
end

function gw2_salvage_manager.singleItemListContains(nItem)
	if (table.valid(nItem)) then
		for _,eItem in pairs(gw2_salvage_manager.singleItemList.list) do
			if (eItem.itemID == nItem.itemID) then
				nItem.preferedKit = eItem.preferedKit
				return true,nItem
			end
		end
	end
	return false
end

-- Inventory functions.
function gw2_salvage_manager.inventoryItemListUpdate()
	local inventory = Inventory("salvagable")
	gw2_salvage_manager.inventoryItemList.list = {}
	gw2_salvage_manager.inventoryItemList.nameList = {}
	gw2_salvage_manager.inventoryItemList.currID = 1
	for id,nItem in pairsByValueAttribute(inventory,"name") do
		if (table.valid(nItem) and gw2_salvage_manager.singleItemListContains(nItem) == false) then
			table.insert(gw2_salvage_manager.inventoryItemList.list,nItem)
			table.insert(gw2_salvage_manager.inventoryItemList.nameList,nItem.name)
		end
	end
end

-- Add custom checks. Functions added HAVE to return true(can salvage) or false(cant salvage).
function gw2_salvage_manager.addCustomChecks(newFunction)
	if (type(newFunction) == "function") then
		table.insert(gw2_salvage_manager.customChecks,newFunction)
	end
end

-- Custom checks check.
function gw2_salvage_manager.checkCustomChecks()
	for _,customCheck in ipairs(gw2_salvage_manager.customChecks) do
		if (type(customCheck) == "function") then
			if (customCheck() == false) then
				return false
			end
		end
	end
	return true
end

-- Salvage List stuff here.
function gw2_salvage_manager.createItemList()
	local inventoryItems = Inventory("salvagable")
	local filteredItems = {}
	if (table.valid(inventoryItems)) then
		for slot,nItem in pairs(inventoryItems) do
			nItem = nItem
			if (gw2_salvage_manager.itemMatchesFilter(nItem) or gw2_salvage_manager.singleItemListContains(nItem)) then
				nItem.slot = slot
				table.insert(filteredItems,nItem)
			end
		end
	end
	return filteredItems
end

-- working checks here.
function gw2_salvage_manager.haveSalvagebleItems()
	if (table.valid(gw2_salvage_manager.createItemList())) then
		return true
	end
	return false
end

function gw2_salvage_manager.haveSalvageTools()
	if (table.valid(Inventory("itemtype="..GW2.ITEMTYPE.SalvageTool))) then
		return true
	end
	return false
end

function gw2_salvage_manager.getBestTool(item)
	if (item) then
		local tList = Inventory("itemtype="..GW2.ITEMTYPE.SalvageTool)
		local returnTool = nil
		if (tList) then
			for _,tool in pairs(tList) do
				if ( gw2_salvage_manager.salvageKitList.kitlist[tool.itemID] ~= nil ) then
					-- Search for preftool
					if ( gw2_salvage_manager.salvageKitList.kitlist[tool.itemID].name == item.preferedKit) then
						return tool
					end
					-- Search for besttool
					if (returnTool == nil or math.abs(item.rarity - gw2_salvage_manager.salvageKitList.kitlist[tool.itemID].rarity) < math.abs(item.rarity - returnTool.rarity)) then
						returnTool = tool
					end
				end
			end
			if (returnTool) then
				return returnTool
			end
		end
	end
end

--salvage fun here.
function gw2_salvage_manager.salvage()
	if (gw2_salvage_manager.active and ml_global_information.Player_Inventory_SlotsFree >= 2 and ml_global_information.Player_Alive and gw2_salvage_manager.checkCustomChecks()) then
		local salvageItems = gw2_salvage_manager.createItemList()
		if (table.valid(salvageItems)) then
			for _,item in pairs(salvageItems) do
				local tool = gw2_salvage_manager.getBestTool(item)
				if (tool and Player:GetCurrentlyCastedSpell() == ml_global_information.MAX_SKILLBAR_SLOTS) then
					d("Salvaging "..item.name.." with "..tool.name)
					tool:Use(item)
					return true
				end
			end
		end
	end
	return false
end

-- Toggle menu. TODO: replace with new gui stuff yeah.
function gw2_salvage_manager.ToggleMenu()
	gw2_salvage_manager.mainWindow.open = gw2_salvage_manager.mainWindow.open ~= true
end

-- Register Events here.
RegisterEventHandler("Module.Initalize",gw2_salvage_manager.ModuleInit)
RegisterEventHandler("Gameloop.Draw", gw2_salvage_manager.mainWindow.Draw)
