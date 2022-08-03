-- {"id":1,"ver":"1.0.2","libVer":"1.0.0","author":"Jobobby04"}

local baseURL = "https://www.readwn.com"
local settings = {}

local function shrinkURL(url)
	return url:gsub("^.-readwn%.com", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	return ""
end

--- @param novelURL string
--- @return NovelInfo
local function parseNovel(novelURL)
	return NovelInfo()
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @param reporter fun(v : string | any)
--- @return Novel[]
local function search(filters, reporter)
	return {}
end

return {
	id = 1308639964,
	name = "ReadWN",
	baseURL = baseURL,

	-- Optional values to change
	--[[imageURL = "",
	hasCloudFlare = false,
	hasSearch = true,]]


	-- Must have at least one value
	listings = {
		Listing("Popular Daily Updates", true, function(data, index)
			return {}
		end),
		Listing("Most Popular", true, function(data, index)
			return {}
		end),
		Listing("New to Web Novels", true, function(data, index)
			return {}
		end),
		Listing("Recently Added Chapters", false, function(data)
			return map(GETDocument(baseURL):select("#latest-updates .novel-list.grid.col .novel-item a"), function(v)
				return Novel {
					title = v:attr("title"),
					link = shrinkURL(v:attr("href")),
					imageURL = expandURL(v:selectFirst("img"):attr("src"))
				}
			end)
		end)
	},

	-- Optional if usable
	--[[searchFilters = {
		TextFilter(1, "RANDOM STRING INPUT"),
		SwitchFilter(2, "RANDOM SWITCH INPUT"),
		CheckboxFilter(3, "RANDOM CHECKBOX INPUT"),
		TriStateFilter(4, "RANDOM TRISTATE CHECKBOX INPUT"),
		RadioGroupFilter(5, "RANDOM RGROUP INPUT", { "A","B","C" }),
		DropdownFilter(6, "RANDOM DDOWN INPUT", { "A","B","C" })
	},]]
	--[[settings = {
		TextFilter(1, "RANDOM STRING INPUT"),
		SwitchFilter(2, "RANDOM SWITCH INPUT"),
		CheckboxFilter(3, "RANDOM CHECKBOX INPUT"),
		TriStateFilter(4, "RANDOM TRISTATE CHECKBOX INPUT"),
		RadioGroupFilter(5, "RANDOM RGROUP INPUT", { "A","B","C" }),
		DropdownFilter(6, "RANDOM DDOWN INPUT", { "A","B","C" })
	},]]

	-- Default functions that have to be set
	getPassage = getPassage,
	parseNovel = parseNovel,
	search = search,
	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
