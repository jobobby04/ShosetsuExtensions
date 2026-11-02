-- {"id":1308639977,"ver":"1.1.0","libVer":"1.1.0","author":"Jobobby04","dep":["dkjson>=1.0.1"]}

local baseURL = "https://www.mcstories.com"
local settings = {}
local dkjson = Require("dkjson")

---@param request Request
---@return string
local function ClientRequestDocument(request)
	local response = Request(request)
	local status = response:code()
	if status >= 200 and status <= 299 then
		return response:body():string()
	else
		error("Http error " .. status)
	end
end

---@return Document
local function ClientGetDocument(url)
	return Document(ClientRequestDocument(GET(url)))
end

local function shrinkURL(url)
	return url:gsub("^.-mcstories%.com", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = ClientGetDocument(expandURL(chapterURL))
	local chap = document:selectFirst("#mcstories")
	return pageOfElem(chap, true)
end

local svengaliTags = {}
local svengaliTagsFlattened = {}

local function flatten(tagsTable, parents)
	local children = tagsTable["children"]
	if children == nil then
		return
	end
	local tags = children["tag"]
	if tags == nil then
		return
	end
	for i, v in ipairs(tags) do
		local item = {
			name = v["name"],
			id = tonumber(v["id"]),
			parents = parents,
		}
		table.insert(
			svengaliTagsFlattened,
			item
		)
		local newParents = {}
		for _, a in ipairs(parents) do
			table.insert(newParents, a)
		end
		table.insert(newParents, item)
		flatten(v, newParents)
	end
end

local function flattenToFilters(tagsTable, layer)
	local children = tagsTable["children"]
	if children == nil then
		return {}
	end
	local tags = children["tag"]
	if tags == nil then
		return {}
	end
	local filters = {}
	for i, v in ipairs(tags) do
		local name = v["name"]
		for t = 2, layer do
			name = "  " .. name
		end
		table.insert(filters, CheckboxFilter(tonumber(v["id"]) + 2, name))
		local childFilters = flattenToFilters(v, layer + 1)
		for _, y in ipairs(childFilters) do
			table.insert(filters, y)
		end

	end
	return filters
end

local function SvengaliGETDocument(url)
	local response = ClientRequestDocument(GET(url))
	return dkjson.decode(response:gsub("^%(", ""):gsub("%)$", ""))
end

local function getSvengaliTagsIfNeeded()
	if next(svengaliTags) == nil then
		svengaliTags = SvengaliGETDocument("https://www.gregariousfrog.com/svengali/servers/GetTagList.php")
		flatten(svengaliTags, {})
	end
end

local function idToTag(id)
	for _, tag in ipairs(svengaliTagsFlattened) do
		if tag.id == id then
			return tag
		end
	end
	return nil
end

local function tagFullName(tag)
	local names = {}
	for i, v in ipairs(tag.parents) do
		table.insert(names, v["name"])
	end
	local parents = table.concat(names, " > ")
	if parents ~= "" then
		return parents .. " > " .. tag.name
	else
		return tag.name
	end
end

local Tags = {
	{ name = "bd", value = "bondage and/or discipline" },
	{ name = "be", value = "bestiality" },
	{ name = "ca", value = "cannibalism" },
	{ name = "cb", value = "comic book: super-hero/heroine" },
	{ name = "ds", value = "dominance and/or submission" },
	{ name = "ex", value = "exhibitionism" },
	{ name = "fd", value = "female dominant" },
	{ name = "ff", value = "female/female sex" },
	{ name = "ft", value = "fetish (usually clothing)" },
	{ name = "fu", value = "furry" },
	{ name = "gr", value = "growth/enlargement of bodies and parts" },
	{ name = "hm", value = "humiliation" },
	{ name = "hu", value = "humor" },
	{ name = "in", value = "incest" },
	{ name = "la", value = "lactation" },
	{ name = "ma", value = "masturbation" },
	{ name = "mc", value = "mind control" },
	{ name = "md", value = "male dominant" },
	{ name = "mf", value = "male/female sex" },
	{ name = "mm", value = "male/male sex" },
	{ name = "nc", value = "non-consensual" },
	{ name = "rb", value = "robots" },
	{ name = "sc", value = "scatology" },
	{ name = "sf", value = "science fiction" },
	{ name = "ts", value = "time stop" },
	{ name = "ws", value = "watersports" },
}

local function mapTag(name)
	-- "mg" on svengali means "mf".
	if name == "mg" then
		name = "mf"
	end
	for _, tag in ipairs(Tags) do
		if tag.name == name then
			return tag.value
		end
	end
	return name
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		return NovelInfo {
			title = "How to use this source",
			description = "You can use this source by:\n1. pasting the url of a story in the search bar\nOr selecting one or more tags in the search filters."
		}
	end

	local document = ClientGetDocument(expandURL(novelURL))

	local title = document:selectFirst("#mcstories > .title"):text()
	local author = document:selectFirst("#mcstories > .byline > a"):text()
	local description = document:selectFirst("#mcstories > section.synopsis"):wholeText()
	getSvengaliTagsIfNeeded()
	local svengaliItemTags = SvengaliGETDocument("https://www.gregariousfrog.com/svengali/servers/GetTitleTags.php?titleurl=" .. novelURL:match("/([^/]+)/index%.html$"))
	local tags = map(document:select("#mcstories > .storyCodes > a"), function(v)
		return "Category > " .. mapTag(v:text())
	end)
	if svengaliItemTags and svengaliItemTags["TitleTags"] then
		for _, v in ipairs(svengaliItemTags["TitleTags"]) do
			local tag = idToTag(v)
			if tag then
				table.insert(tags, tagFullName(tag))
			end
		end
	end
	local wordCount = 0

	local chapter = document:selectFirst("#mcstories > div.chapter")
	local chapters
	if chapter then
		wordCount = tonumber(chapter:text():match("%((.-)%)"):match("%d+"))
		chapters = {
			NovelChapter {
				title = chapter:select("a"):text(),
				link = shrinkURL(novelURL:gsub("index.html", "") .. chapter:select("a"):attr("href"))
			}
		}
	else
		chapters = map(document:select("#mcstories > table > tbody > tr:not(:has(th))"), function(v)
			wordCount = wordCount + tonumber(v:selectFirst("td:nth-child(2)"):text():match("%d+"))
			return NovelChapter {
				title = v:select("a"):text(),
				link = shrinkURL(novelURL:gsub("index.html", "") .. v:select("a"):attr("href"))
			}
		end)
	end

	local info = NovelInfo {
		title = title,
		authors = { author },
		link = novelURL,
		description = description,
		genres = tags,
		wordCount = wordCount
	}

	if loadChapters then
		info:setChapters(AsList(chapters))
	end

	print(info)

	return info
end

--- Tri-state filters for the category codes, used for client-side filtering.
--- @return Filter[]
local function categoryFilters()
	local filters = {}
	for i = 1, #Tags do
		table.insert(filters, TriStateFilter(100 + (i - 1), Tags[i].name .. ": " .. Tags[i].value))
	end
	return filters
end

--- @param stories table[] @raw story data, each with a `codes` array
--- @return NovelInfo[]
local function toNovelInfos(stories)
	local result = {}
	for _, s in ipairs(stories) do
		local genres = {}
		for _, code in ipairs(s.codes) do
			table.insert(genres, mapTag(code))
		end
		table.insert(result, NovelInfo {
			title = s.title,
			link = s.link,
			genres = genres,
			authors = s.authors,
			description = s.description,
		})
	end
	return result
end

--- Keep only the stories matching the include/exclude category-code filters.
--- @param stories table[] @raw story data
--- @param data table @filter values
--- @return table[]
local function filterByCodes(stories, data)
	local include, exclude = {}, {}
	for i = 1, #Tags do
		local value = data[100 + (i - 1)] or 0
		if value == 1 then
			table.insert(include, Tags[i].name)
		elseif value == 2 then
			table.insert(exclude, Tags[i].name)
		end
	end
	if #include == 0 and #exclude == 0 then
		return stories
	end
	local result = {}
	for _, s in ipairs(stories) do
		local match = true
		for _, code in ipairs(include) do
			local has = false
			for _, c in ipairs(s.codes) do
				if c == code then
					has = true
					break
				end
			end
			if not has then
				match = false
				break
			end
		end
		if match then
			for _, code in ipairs(exclude) do
				for _, c in ipairs(s.codes) do
					if c == code then
						match = false
						break
					end
				end
				if not match then
					break
				end
			end
		end
		if match then
			table.insert(result, s)
		end
	end
	return result
end

--- @return table[] @raw "Whats New" story data
local function fetchWhatsNew()
	local document = ClientGetDocument("https://mcstories.com/WhatsNew.html")
	local stories = {}
	local elems = document:select("div.story")
	for i = 0, elems:size() - 1 do
		local v = elems:get(i)
		local items = v:select("div")
		local codes = {}
		for code in items:get(2):text():match("%((.-)%)"):gmatch("%S+") do
			table.insert(codes, code)
		end
		table.insert(stories, {
			title = items:get(1):select("a"):text(),
			link = "/" .. items:get(1):select("a"):attr("href"),
			authors = { items:get(2):select("a"):text() },
			description = v:selectFirst("div.synopsis"):text(),
			codes = codes,
		})
	end
	return stories
end

--- @param code string @category code
--- @return table[] @raw category story data
local function fetchCategory(code)
	local document = ClientGetDocument("https://mcstories.com/Tags/" .. code .. ".html")
	local stories = {}
	local rows = document:select("tbody > tr")
	for i = 0, rows:size() - 1 do
		local v = rows:get(i)
		local items = v:select("td")
		local codes = {}
		for c in items:get(1):text():gmatch("%S+") do
			table.insert(codes, c)
		end
		table.insert(stories, {
			title = items:get(0):select("a"):text(),
			link = "/" .. items:get(0):select("a"):attr("href"):gsub("%.%.", ""),
			codes = codes,
		})
	end
	return stories
end

--- @return ListingItem
local function whatsNewListing()
	return ListingItem {
		name = "Whats New",
		link = "whatsNew",
		isIncrementing = false,
		func = function(data)
			return toNovelInfos(fetchWhatsNew())
		end,
		search = function(data)
			return toNovelInfos(filterByCodes(fetchWhatsNew(), data))
		end,
		searchFilters = categoryFilters(),
	}
end

--- @param category table @{name, value}
--- @return ListingItem
local function categoryListing(category)
	return ListingItem {
		name = category.name .. ": " .. category.value,
		link = "cat=" .. category.name,
		isIncrementing = false,
		func = function(data)
			return toNovelInfos(fetchCategory(category.name))
		end,
		search = function(data)
			return toNovelInfos(filterByCodes(fetchCategory(category.name), data))
		end,
		searchFilters = categoryFilters(),
	}
end

--- @param data table @filter values
--- @return NovelInfo[]
local function svengaliSearch(data)
	local searchTags = {}
	for i, v in pairs(data) do
		if i < 9999 and i > 2 and v == true then
			table.insert(searchTags, i - 2)
		end
	end
	if next(searchTags) == nil then
		return {}
	end
	local searchResults = SvengaliGETDocument("https://www.gregariousfrog.com/svengali/servers/SearchOnTagsV2.php?tags=" .. table.concat(searchTags, ","))
	return map(searchResults["Titles"], function(v)
		local infoTable = {}
		for substr in v:gmatch("[^%%]+") do
			table.insert(infoTable, substr)
		end
		local tags
		if #infoTable == 4 then
			tags = { mapTag(infoTable[3]), infoTable[4] .. "% match" }
		else
			tags = { infoTable[3] .. "% match" }
		end
		return NovelInfo {
			title = infoTable[1],
			link = "/" .. infoTable[2] .. "/index.html",
			genres = tags
		}
	end)
end

--- @return ListingItem
local function svengaliListing()
	getSvengaliTagsIfNeeded()
	return ListingItem {
		name = "Svengali Tag Search",
		link = "svengali",
		isIncrementing = false,
		func = function(data)
			return {
				NovelInfo {
					title = "How to use Svengali Tag Search",
					link = "how",
					description = "Select one or more tags to search for stories.",
				}
			}
		end,
		search = svengaliSearch,
		searchFilters = flattenToFilters(svengaliTags, 1),
	}
end

--- @param data table @filter values, [QUERY] is the story url
--- @return NovelInfo[]
local function addByUrlSearch(data)
	local url = data[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if not url:match("index.html") then
		return {}
	end
	local novel = ClientGetDocument(url):selectFirst("#mcstories > .title")
	return {
		NovelInfo {
			title = novel:text(),
			link = shrinkURL(url),
			imageURL = ""
		}
	}
end

--- @return ListingItem
local function addByUrlListing()
	return ListingItem {
		name = "Add by URL",
		link = "addByUrl",
		isIncrementing = false,
		func = function(data)
			return {
				NovelInfo {
					title = "How to use Add by URL",
					link = "how",
					description = "Paste a MCStories story URL to add it.",
				}
			}
		end,
		search = addByUrlSearch,
		searchIsIncrementing = false,
	}
end

--- @param link string @"" for the root, otherwise a listing link
--- @return ListingList|ListingItem
local function getListing(link)
	if link == "" then
		return ListingList {
			name = "MCStories",
			link = "",
			func = function()
				local listings = {}
				table.insert(listings, whatsNewListing())
				for i = 1, #Tags do
					table.insert(listings, categoryListing(Tags[i]))
				end
				table.insert(listings, svengaliListing())
				table.insert(listings, addByUrlListing())
				return listings
			end
		}
	end
	if link == "whatsNew" then
		return whatsNewListing()
	end
	if link == "svengali" then
		return svengaliListing()
	end
	if link == "addByUrl" then
		return addByUrlListing()
	end
	local code = link:match("^cat=(.+)$")
	if code then
		for i = 1, #Tags do
			if Tags[i].name == code then
				return categoryListing(Tags[i])
			end
		end
	end
	return getListing("")
end

return {
	id = 1308639977,
	name = "MCStories",
	baseURL = baseURL,

	-- Optional values to change
	imageURL = "",
	hasCloudFlare = false,

	---@diagnostic disable-next-line: undefined-global
	chapterType = ChapterType.HTML,

	getListing = getListing,

	-- Default functions that have to be set
	getPassage = getPassage,
	parseNovel = parseNovel,

	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
