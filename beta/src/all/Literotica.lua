-- {"id":1308639970,"ver":"1.0.10","libVer":"1.3.0","author":"Jobobby04"}

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
	element:select(".aa_hv.aa_hy"):remove()
	element = tostring(element):gsub("<div", "<p"):gsub("</div", "</p"):gsub("<br>", "</p><p>")
	element = Document(element):selectFirst("body")
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

	-- This is for the sake of consistant styling
	chap = cleanupDocument(chap)

	local pagesElements = document:select("a[href*='?page=']")
	if pagesElements:size() > 1 then
		local lastPage = selectLast(pagesElements):attr("href")
		local lastPageNumber = tonumber(lastPage:match("[?&]page=(%d+)")) or tonumber(lastPage:match("%d+$"))
		if lastPageNumber ~= nil then
			for i = 2, lastPageNumber do
				local nextDocument = ClientGetDocument(expandURL(chapterURL) .. "?page=" .. i):selectFirst(
					"div[itemprop='articleBody']"
				)
				nextDocument = cleanupDocument(nextDocument):selectFirst("body"):children()
				chap:selectFirst("body"):lastChild():after(nextDocument)
			end
		end
	end

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
	local titleElement = document:selectFirst("h1.headline")
	local title = titleElement and titleElement:text() or ""

	local summary = document:selectFirst("#tabpanel-info div:nth-of-type(2)")
	if summary ~= nil and summary:hasText() then
	    local text = summary:wholeText()
	    if text ~= nil and text ~= "" then
	        summary = text
	    end
	else
	    summary = nil
	end

	if summary == nil then
		summary = document:selectFirst("ul.series__works p")
		if summary ~= nil then
			local a = summary:selectFirst("a")
			if a ~= nil then
					a:remove()
			end
			summary = summary:wholeText()
		end
	end


	local tags = map(document:select("#tabpanel-tags > a"), function(v)
		return v:text()
	end)

  local views = document:selectFirst("div[title=Views]")
  local faves = document:selectFirst("div[title=Favorites]")
  local comments = document:selectFirst("a[href$='/comments']")

	return {
		title = title,
		summary = summary,
		tags = tags,
		viewCount = views and textToInteger(views:text()) or nil,
		favoriteCount = faves and textToInteger(faves:text()) or nil,
		commentCount = comments and textToInteger(comments:text()) or nil
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

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	local normalizedURL = shrinkURL(novelURL):gsub("^/+", ""):gsub("/+$", "")
	if normalizedURL == "how" then
		return NovelInfo({
			title = "How to use this source",
			description = 'You can use this source by:\n1. searching on the literotica.com website and inputting the url of the story in the search bar.\nOr you can search tags in a comma-delimited list like "oral,blowjob"',
		})
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
			local chapterEntries = series:select("ul.series__works li")
			if chapterEntries:size() > 0 then
				chapters = map(chapterEntries, function(v, i)
					local chapter = v:selectFirst("a[href*='/s/']")
					local chapterTitle = chapter and chapter:text() or v:text()
					local chapterLink = chapter and chapter:attr("href") or ""
					return NovelChapter({
						order = i,
						title = chapterTitle,
						link = shrinkURL(chapterLink),
					})
				end)
			end
		else
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

local Categories = {
	{ name = "All", tagCategory = "", category = "" },
	{ name = "Anal", tagCategory = "anal-category-tags", category = "anal-sex-stories" },
	{ name = "Audio", tagCategory = "audio-category-tags", category = "audio-sex-stories" },
	{ name = "BDSM", tagCategory = "bdsm-category-tags", category = "bdsm-stories" },
	{ name = "Chain Stories", tagCategory = "chain-stories-category-tags", category = "chain-stories" },
	{ name = "Crossdressing", tagCategory = "crossdressing-category-tags", category = "crossdressing" },
	{ name = "Erotic Couplings", tagCategory = "erotic-couplings-category-tags", category = "erotic-couplings" },
	{ name = "Erotic Horror", tagCategory = "erotic-horror-category-tags", category = "erotic-horror" },
	{
		name = "Exhibitionist & Voyeur",
		tagCategory = "exhibitionist-voyeur-category-tags",
		category = "exhibitionist-voyeur",
	},
	{
		name = "Fan Fiction & Celebrities",
		tagCategory = "fan-fiction-celebrities-category-tags",
		category = "celebrity-stories",
	},
	{ name = "Fetish", tagCategory = "fetish-category-tags", category = "fetish-stories" },
	{ name = "First Time", tagCategory = "first-time-category-tags", category = "first-time-sex-stories" },
	{ name = "Gay Male", tagCategory = "gay-male-category-tags", category = "gay-sex-stories" },
	{ name = "Group Sex", tagCategory = "group-sex-category-tags", category = "group-sex-stories" },
	{ name = "How To", tagCategory = "how-to-category-tags", category = "adult-how-to" },
	{ name = "Humor & Satire", tagCategory = "humor-satire-category-tags", category = "adult-humor" },
	{ name = "Illustrated", tagCategory = "illustrated-category-tags", category = "illustrated-erotic-fiction" },
	{
		name = "Interracial Love",
		tagCategory = "interracial-love-category-tags",
		category = "interracial-erotic-stories",
	},
	{ name = "Lesbian Sex", tagCategory = "lesbian-sex-category-tags", category = "lesbian-sex-stories" },
	{ name = "Letters & Transcripts", tagCategory = "letters-transcripts-category-tags", category = "erotic-letters" },
	{ name = "Loving Wives", tagCategory = "loving-wives-category-tags", category = "loving-wives" },
	{ name = "Mature", tagCategory = "mature-category-tags", category = "mature-sex" },
	{ name = "Mind Control", tagCategory = "mind-control-category-tags", category = "mind-control" },
	{ name = "Non-English", tagCategory = "non-english-category-tags", category = "non-english-stories" },
	{ name = "Non-Erotic", tagCategory = "non-erotic-category-tags", category = "non-erotic-stories" },
	{ name = "NonHuman", tagCategory = "nonhuman-category-tags", category = "non-human-stories" },
	{ name = "Novels and Novellas", tagCategory = "novels-and-novellas-category-tags", category = "erotic-novels" },
	{
		name = "Reluctance/NonConsent",
		tagCategory = "reluctance-nonconsent-category-tags",
		category = "non-consent-stories",
	},
	{ name = "Reviews & Essays", tagCategory = "reviews-essays-category-tags", category = "reviews-and-essays" },
	{ name = "Romance", tagCategory = "romance-category-tags", category = "adult-romance" },
	{ name = "Sci-Fi & Fantasy", tagCategory = "sci-fi-fantasy-category-tags", category = "science-fiction-fantasy" },
	{ name = "Taboo/Incest", tagCategory = "taboo-incest-category-tags", category = "taboo-sex-stories" },
	{
		name = "Toys & Masturbation",
		tagCategory = "toys-masturbation-category-tags",
		category = "masturbation-stories",
	},
	{ name = "Transgender", tagCategory = "transgender-category-tags", category = "transgender" },
}

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

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = filters[PAGE]
	local url = filters[QUERY]:gsub("^%s*(.-)%s*$", "%1")
	if shrinkURL(url):match("/s/%a+") then
		if page ~= 1 then
			return {}
		end
		local novelUrl = url:gsub("/$", "")
		local novelDocument = ClientGetDocument(expandURL(novelUrl))
		local novel = novelDocument:selectFirst("article[itemtype='https://schema.org/Article'] h1")
		return {
            NovelInfo({
				title = novel and novel:text() or "",
				link = shrinkURL(url),
				imageURL = "",
			}),
		}
	end

	local query = filters[QUERY]
	local tags = split(query, ",")
	table.sort(tags)

	if next(tags) then
		local searchUrl = "https://tags.literotica.com/"
		local category = Categories[tonumber(filters[2]) + 1]
		if category and category.tagCategory ~= "" then
			searchUrl = searchUrl .. category.tagCategory .. "/"
		end
		for i in pairs(tags) do
			if i == 1 then
				searchUrl = searchUrl .. tags[i] .. "/"
			elseif i == 2 then
				searchUrl = searchUrl .. "?tag[]=" .. tags[i]
			else
				searchUrl = searchUrl .. "&tag[]=" .. tags[i]
			end
		end
		if #tags >= 2 then
			searchUrl = searchUrl .. "&page=" .. filters[PAGE]
		else
			searchUrl = searchUrl .. "?page=" .. filters[PAGE]
		end
		local sortBy = SortByOptions[tonumber(filters[3]) + 1]
		if sortBy and sortBy.value ~= "" then
			searchUrl = searchUrl .. "&sort_by=" .. sortBy.value
		end
		local within = WithinOptions[tonumber(filters[4]) + 1]
		if within and within.value ~= "" then
			searchUrl = searchUrl .. "&period=" .. within.value
		end

		local document = ClientGetDocument(searchUrl)

		return map(document:select(".panel[property='itemListElement']"), function(v)
			local views = v:selectFirst("div[title=Views]")
			if views == nil then
				views = "0"
			else
				views = views:attr("data-value")
			end
			local favorites = v:selectFirst("div[title=Favorites]")
			if favorites == nil then
				favorites = "0"
			else
				favorites = favorites:attr("data-value")
			end
			local comments = v:selectFirst("div[title=Comments]")
			if comments == nil then
				comments = "0"
			else
				comments = comments:attr("data-value")
			end
			return NovelInfo({
				title = v:selectFirst("[href*='/s/'] h4"):text(),
				link = shrinkURL(v:selectFirst("[href*='/s/']"):attr("href")),
				description = v:selectFirst("p[property='headline']"):text(),
				authors = { v:select("a[typeof='Person'] > meta"):attr("content") },
				genres = { v:selectFirst("[href*='/c/'] > span"):text() },
				viewCount = textToInteger(views),
				favoriteCount = textToInteger(favorites),
				commentCount = textToInteger(comments),
			})
		end)
	end

	return {}
end

local function searchFilters()
	local categoryOptions = {}
	for i in pairs(Categories) do
		table.insert(categoryOptions, Categories[i].name)
	end
	local sortByOptions = {}
	for _, option in pairs(SortByOptions) do
		table.insert(sortByOptions, option.name)
	end
	local withinOptions = {}
	for _, option in pairs(WithinOptions) do
		table.insert(withinOptions, option.name)
	end

	return {
		DropdownFilter(2, "Category", categoryOptions),
		DropdownFilter(3, "Sort By", sortByOptions),
		DropdownFilter(4, "Within", withinOptions),
	}
end

return {
	id = 1308639970,
	name = "Literotica",
	baseURL = baseURL,

	-- Optional values to change
	imageURL = "",
	hasCloudFlare = false,
	hasSearch = true,

	chapterType = ChapterType.HTML,

	-- Must have at least one value
	listings = {
		Listing("Nothing", false, function(data)
			return {
                NovelInfo({
					title = "How to use this source",
					link = "how",
					imageURL = "",
				}),
			}
		end),
	},

	-- Default functions that have to be set
	getPassage = getPassage,
	parseNovel = parseNovel,
	search = search,

	updateSetting = function(id, value)
		settings[id] = value
	end,

	searchFilters = searchFilters(),

	shrinkURL = shrinkURL,
	expandURL = expandURL,
}
