
local min_group_items = 8 --Todo: setting

------------------------------------------------------------------------
-- Compat to creative mod - remove hardcoded grouped pages
------------------------------------------------------------------------
local function unregister_page(name)
	sfinv.pages[name] = nil

	for idx = #sfinv.pages_unordered, 1, -1 do
		if sfinv.pages_unordered[idx].name == name then
			table.remove(sfinv.pages_unordered, idx)
		end
	end
end

unregister_page("creative:nodes")
unregister_page("creative:tools")
unregister_page("creative:craftitems")


------------------------------------------------------------------------
-- Item groups collection
------------------------------------------------------------------------
local itemgroups = {}
local itemgroups_unordered = {}

local function get_or_new_itemgroup(group)
	if itemgroups[group] then
		return itemgroups[group]
	end
	local title = group:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
	local itemgroup = { name = group, title = title, items = {}, items_unordered = {}}
	itemgroups[group] = itemgroup
	table.insert(itemgroups_unordered, itemgroup)
	return itemgroup
end

------------------------------------------------------------------------
-- Get group assignment for item
------------------------------------------------------------------------
local function get_group_assingment(def)
	return def.mod_origin
end

------------------------------------------------------------------------
-- Process items after all mods loaded
------------------------------------------------------------------------
minetest.after(0,function()
	-- Sort items to groups
	for itemname, def in pairs(minetest.registered_items) do
		if def.groups.not_in_creative_inventory ~= 1 and
				def.description and def.description ~= "" then

			local group = get_group_assingment(def)
			local itemgroup = get_or_new_itemgroup(group)
			itemgroup.items[itemname] = def
			table.insert(itemgroup.items_unordered, def)
		end
	end

	-- register groups
	table.sort(itemgroups_unordered, function(a,b) return a.name < b.name end)
	local misc_group = get_or_new_itemgroup("other")

	for _, itemgroup in ipairs(itemgroups_unordered) do
		local items_count = #itemgroup.items_unordered
		if items_count >= min_group_items or 
				(items_count > 0 and itemgroup.name == "other") then
			creative.register_tab("smart_sfinv_creative:"..itemgroup.name, itemgroup.title, itemgroup.items)
		else
			-- apply to "misc" group
			for itemname, def in pairs(itemgroup.items) do
				misc_group.items[itemname] = def
				table.insert(misc_group.items_unordered, def)
			end
		end
	end
end)
