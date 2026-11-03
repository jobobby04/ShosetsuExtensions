-- {"id":1308639970,"ver":"1.1.0","libVer":"1.1.0","author":"Jobobby04"}

local baseURL = "https://www.literotica.com"
local settings = {}

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
	return url:gsub("^.-literotica%.com", "")
end

local function expandURL(url)
	if url:match("^https?://") then
		return url
	elseif url:sub(1, 1) == "/" then
		return baseURL .. url
	end

	return baseURL .. "/" .. url
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	-- Strip non-story elements
	element:select("a[href*='dialog=report-work']"):remove()
	return element
end

--- @param elements Elements
--- @return Element
local function selectLast(elements)
	return elements:get(elements:size() - 1)
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = ClientGetDocument(expandURL(chapterURL))
	local chap = document:selectFirst("div[itemprop='articleBody']")
	if chap == nil then
		error("Unable to locate chapter content")
	end

	local titleElement = document:selectFirst("article[itemtype='https://schema.org/Article'] h1")
	local title = titleElement and titleElement:text() or ""

	local summaryElement = document:selectFirst("[data-tab='tabpanel-info'] [class*='_widget__info_']")
	local summary = summaryElement and summaryElement:text() or ""

	local tagsElements = document:select("[data-tab='tabpanel-tags'] a[href*='tags.literotica.com']")
	local tags = map(tagsElements, function(v)
		return v:text()
	end)

	-- Combine all pages
	local pagesElements = document:select("a[href*='?page=']")
	if pagesElements:size() > 1 then
		local lastPage = selectLast(pagesElements):attr("href")
		local lastPageNumber = tonumber(lastPage:match("[?&]page=(%d+)")) or tonumber(lastPage:match("%d+$"))
		if lastPageNumber ~= nil then
			for i = 2, lastPageNumber do
				local nextBody = ClientGetDocument(expandURL(chapterURL) .. "?page=" .. i):selectFirst(
					"div[itemprop='articleBody']"
				)
				if nextBody ~= nil then
					nextBody = cleanupDocument(nextBody)
					local children = nextBody:children()
					for j = 0, children:size() - 1 do
						chap:appendChild(children:get(j))
					end
				end
			end
		end
	end

	chap = cleanupDocument(chap)

	-- Adds Chapter Info

	local tagString = table.concat(tags, ", ")

	if tagString ~= "" then
		chap:child(0):before("<h4>" .. "Tags: " .. tagString .. "</h4>")
	end
	chap:child(0):before("<h4>" .. summary .. "</h4>")
	chap:child(0):before("<h1>" .. title .. "</h1>")
	return pageOfElem(chap, true)
end

local function textToInteger(text)
	local number, unit = text:gsub(",", ""):match("(%d+%.?%d*)(%a*)")
	number = tonumber(number)

	if unit == "k" then
		number = number * 1000
	elseif unit == "m" or unit == "M" then
		 number = number * 1000000
	end

	return math.floor(number)
end

local function getNovelInfoFromSeries(document)
	local titleElement = document:selectFirst("h1")
	local title = titleElement and titleElement:text() or ""

	local summaryElement = titleElement and titleElement:parent():selectFirst("p")
	local summary = nil
	if summaryElement ~= nil and summaryElement:hasText() then
		local text = summaryElement:wholeText()
		if text ~= nil and text ~= "" then
			summary = text
		end
	end

	local tags = map(document:select("[data-tab='tabpanel-tags'] a"), function(v)
		return v:text()
	end)

	return {
		title = title,
		summary = summary,
		tags = tags,
		viewCount = nil,
		favoriteCount = nil,
		commentCount = nil
	}
end

local function getNovelInfoFromPage(document)
	local titleElement = document:selectFirst("article[itemtype='https://schema.org/Article'] h1")
	local title = titleElement and titleElement:text() or ""

	local summaryElement = document:selectFirst("[data-tab='tabpanel-info'] [class*='_widget__info_']")
	local summary = summaryElement and summaryElement:text() or ""

	local tagsElements = document:select("[data-tab='tabpanel-tags'] a[href*='tags.literotica.com']")
	local tags = map(tagsElements, function(v)
		return v:text()
	end)

  local views = document:selectFirst("[data-tab='tabpanel-info'] div[title=Views]")
  local faves = document:selectFirst("[data-tab='tabpanel-info'] div[title=Favorites]")
  local comments = document:selectFirst("[data-tab='tabpanel-info'] a[href$='/comments']")

	return {
		title = title,
		summary = summary,
		tags = tags,
		viewCount = views and textToInteger(views:attr("data-value")) or nil,
		favoriteCount = faves and textToInteger(faves:attr("data-value")) or nil,
		commentCount = comments and textToInteger(comments:attr("data-value")) or nil
	}
end

local function getNovel(document, novelUrl, mainInfo)
	local title = mainInfo.title
	local summary = mainInfo.summary
	local tags = mainInfo.tags
	local authorElement = document:selectFirst("a[href*='/authors/'][href*='/works/stories'][title]")
	if authorElement == nil then
		authorElement = document:selectFirst("a[href*='/authors/'][href$='/works'][title]")
	end
	local author = authorElement and (authorElement:attr("title") or authorElement:text()) or ""
	local views = mainInfo.viewCount
	local faves = mainInfo.favoriteCount
	local comments = mainInfo.commentCount

	local authors = {}
	if author ~= "" then
		authors = { author }
	end

	local info = NovelInfo({
		title = title,
		link = novelUrl,
		description = summary,
		genres = tags,
		authors = authors,
		viewCount = views,
		favoriteCount = faves,
		commentCount = comments
	})

	return info
end

local cachedCategories = nil

--- Fetches the tag categories from the tags site. The dropdown is rendered
--- twice (mobile + desktop), so entries are deduped by tagCategory. "All" is
--- prepended as the no-category view.
--- @return table[] @of {name: string, tagCategory: string}
local function getCategories()
	if cachedCategories ~= nil then
		return cachedCategories
	end
	local categories = {
		{ name = "All", tagCategory = "" },
	}
	local seen = {}
	local document = ClientGetDocument("https://tags.literotica.com/")
	local links = document:select("a[href$='-category-tags']")
	for i = 0, links:size() - 1 do
		local a = links:get(i)
		local tagCategory = a:attr("href"):match("^/([^/]+)$")
		if tagCategory and not seen[tagCategory] then
			seen[tagCategory] = true
			local name = a:text()
			if name ~= "" then
				table.insert(categories, {
					name = name,
					tagCategory = tagCategory,
				})
			end
		end
	end
	cachedCategories = categories
	return categories
end

--- @param category table @{name, tagCategory}
--- @return NovelInfo
local function howNovelInfo(category)
	return NovelInfo({
		title = category.name,
		link = "how/" .. category.tagCategory,
		description = "Enter at least one tag in the Tags filter to browse "
			.. category.name .. " stories. No novels are shown until a tag is set."
	})
end

--- @return NovelInfo
local function addByUrlHowInfo()
	return NovelInfo({
		title = "How to use Add by URL",
		link = "how/addByUrl",
		description = "Paste a Literotica story URL to add it."
	})
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	local normalizedURL = shrinkURL(novelURL):gsub("^/+", ""):gsub("/+$", "")
	if normalizedURL == "how" or normalizedURL:match("^how/") then
		local slug = normalizedURL:match("^how/?(.*)$") or ""
		if slug == "addByUrl" then
			return addByUrlHowInfo()
		end
		local category = { name = "All", tagCategory = "" }
		for _, c in ipairs(getCategories()) do
			if c.tagCategory == slug then
				category = c
				break
			end
		end
		return howNovelInfo(category)
	end

	local document = ClientGetDocument(expandURL(novelURL))

	local seriesPanel = document:selectFirst("[data-tab='tabpanel-series']")
	local series
	if seriesPanel ~= nil then
		local seriesLink = seriesPanel:selectFirst("a[href*='/series/se/']")
		if seriesLink ~= nil then
			series = ClientGetDocument(expandURL(seriesLink:attr("href")))
		end
	end
	local info
	if series ~= nil then
		info = getNovel(series, novelURL, getNovelInfoFromSeries(series))
	else
		info = getNovel(document, novelURL, getNovelInfoFromPage(document))
	end

	if loadChapters then
		local chapters
		if series ~= nil then
			local chapterEntries = series:select("li a[href*='/s/']")
			if chapterEntries:size() > 0 then
				chapters = map(chapterEntries, function(v, i)
					return NovelChapter({
						order = i,
						title = v:text(),
						link = shrinkURL(v:attr("href")),
					})
				end)
			end
		end
		if chapters == nil then
			chapters = {
				NovelChapter({
					order = 0,
					title = info:getTitle(),
					link = novelURL,
				}),
			}
		end
		info:setChapters(AsList(chapters))
	end

	return info
end

-- Function to split a string by a delimiter
local function split(str, delimiter)
	local result = {}
	for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

-- Function to trim whitespace from the beginning and end of a string
local function trim(s)
	return s:gsub("^%s+", ""):gsub("%s+$", "")
end

local SortByOptions = {
	{ name = "Newest", value = "" },
	{ name = "Views", value = "views" },
	{ name = "Rating", value = "rating" },
	{ name = "Favorite", value = "favorite" },
}

local WithinOptions = {
	{ name = "All Time", value = "" },
	{ name = "7 Days", value = "week" },
	{ name = "30 Days", value = "month" },
	{ name = "1 Year", value = "year" },
}

--- @param document Document
--- @return NovelInfo[]
local function parseStoryEntries(document)
	return map(document:select("article"), function(v)
		local titleLink = v:selectFirst("a[href*='/s/']")
		local description = v:selectFirst("p")
		local author = v:selectFirst("a[href*='/authors/']")
		local category = v:selectFirst("a[href*='/c/']")
		local views = v:selectFirst("span[title=Views]")
		local favorites = v:selectFirst("span[title=Favorites]")
		local comments = v:selectFirst("span[title=Comments]")
		return NovelInfo({
			title = titleLink and titleLink:text() or "",
			link = titleLink and shrinkURL(titleLink:attr("href")) or "",
			description = description and description:text() or "",
			authors = author and { author:text() } or {},
			genres = category and { category:text() } or {},
			viewCount = views and textToInteger(views:attr("data-value")) or 0,
			favoriteCount = favorites and textToInteger(favorites:attr("data-value")) or 0,
			commentCount = comments and textToInteger(comments:attr("data-value")) or 0,
		})
	end)
end

--- @param category table @{name, tagCategory, category}
--- @return string
local function categoryBaseURL(category)
	local url = "https://tags.literotica.com/"
	if category.tagCategory ~= "" then
		url = url .. category.tagCategory .. "/"
	end
	return url
end

--- @param input string @comma-delimited tags
--- @return string[]
local function parseTags(input)
	local tags = {}
	for _, tag1 in ipairs(split(input, ",")) do
		local tag = trim(tag1)
		if tag ~= "" then
			table.insert(tags, tag)
		end
	end
	table.sort(tags)
	return tags
end

--- @param category table @{name, tagCategory, category}
--- @param data table @contains [PAGE] and filter values ([2] tags, [3] sort, [4] within)
--- @return NovelInfo[]
local function searchCategory(category, data)
	local tags = parseTags(data[2] or "")
	if next(tags) == nil then
		return {}
	end

	local searchUrl = categoryBaseURL(category)
	for i = 1, #tags do
		if i == 1 then
			searchUrl = searchUrl .. tags[i] .. "/"
		elseif i == 2 then
			searchUrl = searchUrl .. "?tag[]=" .. tags[i]
		else
			searchUrl = searchUrl .. "&tag[]=" .. tags[i]
		end
	end
	if #tags >= 2 then
		searchUrl = searchUrl .. "&page=" .. data[PAGE]
	else
		searchUrl = searchUrl .. "?page=" .. data[PAGE]
	end
	local sortBy = SortByOptions[tonumber(data[3] or 0) + 1]
	if sortBy and sortBy.value ~= "" then
		searchUrl = searchUrl .. "&sort_by=" .. sortBy.value
	end
	local within = WithinOptions[tonumber(data[4] or 0) + 1]
	if within and within.value ~= "" then
		searchUrl = searchUrl .. "&period=" .. within.value
	end

	return parseStoryEntries(ClientGetDocument(searchUrl))
end

--- @param data table @contains [QUERY]
--- @return NovelInfo[]
local function searchByURL(data)
	local url = (data[QUERY] or ""):gsub("^%s*(.-)%s*$", "%1")
	if data[PAGE] ~= 1 or not shrinkURL(url):match("/s/%a+") then
		return {}
	end
	local novelUrl = url:gsub("/$", "")
	local novelDocument = ClientGetDocument(expandURL(novelUrl))
	local novel = novelDocument:selectFirst("article[itemtype='https://schema.org/Article'] h1")
	return {
		NovelInfo({
			title = novel and novel:text() or "",
			link = shrinkURL(url)
		}),
	}
end

--- @return Filter[]
local function categorySearchFilters()
	local sortByOptions = {}
	for i = 1, #SortByOptions do
		table.insert(sortByOptions, SortByOptions[i].name)
	end
	local withinOptions = {}
	for i = 1, #WithinOptions do
		table.insert(withinOptions, WithinOptions[i].name)
	end
	return {
		TextFilter(2, "Tags"),
		DropdownFilter(3, "Sort By", sortByOptions),
		DropdownFilter(4, "Within", withinOptions),
	}
end

--- @param category table @{name, tagCategory}
--- @return ListingItem
local function makeCategoryListing(category)
	return ListingItem {
		name = category.name,
		link = "cat=" .. category.tagCategory,
		isIncrementing = false,
		func = function()
			return { howNovelInfo(category) }
		end,
		search = function(data)
			return searchCategory(category, data)
		end,
		searchFilters = categorySearchFilters(),
		searchIsIncrementing = false,
	}
end

--- @return ListingItem
local function makeAddByUrlListing()
	return ListingItem {
		name = "Add by URL",
		link = "addByUrl",
		isIncrementing = false,
		func = function()
			return { addByUrlHowInfo() }
		end,
		search = searchByURL,
		searchIsIncrementing = false,
	}
end

--- @param link string @"" for the root, otherwise "cat=<tagCategory>" or "addByUrl"
--- @return ListingList|ListingItem
local function getListing(link)
	if link == "" then
		return ListingList {
			name = "Literotica",
			link = "",
			func = function()
				local items = {}
				for _, category in ipairs(getCategories()) do
					table.insert(items, makeCategoryListing(category))
				end
				table.insert(items, makeAddByUrlListing())
				return items
			end,
		}
	end
	if link == "addByUrl" then
		return makeAddByUrlListing()
	end
	local slug = link:match("^cat=(.*)$")
	if slug then
		for _, category in ipairs(getCategories()) do
			if category.tagCategory == slug then
				return makeCategoryListing(category)
			end
		end
	end
	return getListing("")
end

return {
	id = 1308639970,
	name = "Literotica",
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
	expandURL = expandURL,
}
