-- {"id":1,"ver":"1.0.9","libVer":"1.0.0","author":"Jobobby04"}

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
	local fullUrl = expandURL(novelURL)
	local content = GETDocument(fullUrl)

	local categories = map(content:select(".novel-header .novel-info .categories ul li a"), function(v)
		return v:text()
	end)
	local tags = map(content:select("#info .tags ul li a"), function(v)
		return v:text()
	end)
	for _,v in ipairs(tags) do
		table.insert(categories, v)
	end


	local info = NovelInfo {
		title = content:selectFirst(".novel-header .novel-info h1"):text(),
		imageURL = content:selectFirst(".novel-header .fixed-img img"):attr("data-src"),
		status = ({
			Completed = NovelStatus.COMPLETED,
			Ongoing = NovelStatus.PUBLISHING
		})[content:selectLast(".novel-header .novel-info .header-stats span strong"):text()],
		description = content:selectFirst("#info .summary"):text(),
		authors = { content:selectLast(".novel-header .novel-info .author span"):text() },
		genres = categories
	}

	local novelId = novelURL:gsub("^.-novel/", ""):gsub("%.html", "")

	local chapterList1 = GETDocument("https://www.readwn.com/e/extend/fy.php?page=0&wjm=" .. novelId)
	return info
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @param reporter fun(v : string | any)
--- @return Novel[]
local function search(filters, reporter)
	return {}
end

--- @param document Document
--- @param selector string
--- @return Novel[]
local function parseBrowseWithSelector(document,selector)
	return map(document:select(selector), function(v)
		return Novel {
			title = v:attr("title"),
			link = shrinkURL(v:attr("href")),
			imageURL = expandURL(v:selectFirst("img"):attr("data-src"))
		}
	end)
end

--- @param document Document
--- @return Novel[]
local function parseBrowse(document)
	return parseBrowseWithSelector(document, ".novel-item a")
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
		Listing("Recently Added Chapters", false, function(data)
			return parseBrowseWithSelector(GETDocument(baseURL), "#latest-updates .novel-list.grid.col .novel-item a")
		end),
		Listing("Popular Daily Updates", true, function(data)
			return parseBrowse(GETDocument("https://www.readwn.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"))
		end),
		Listing("Most Popular", true, function(data)
			return parseBrowse(GETDocument("https://www.readwn.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"))
		end),
		Listing("New to Web Novels", true, function(data)
			return parseBrowse(GETDocument("https://www.readwn.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"))
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
