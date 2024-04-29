-- {"id":1308639970,"ver":"1.0.4","libVer":"1.3.0","author":"Jobobby04"}

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
	return baseURL .. url
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	element:select(".aa_hv.aa_hy"):remove()
	element = tostring(element):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	element = Document(element):selectFirst('body')
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
	local chap = document:selectFirst(".aa_eQ.article > .aa_ht > div")
	local title = document:selectFirst(".headline.j_eQ"):text()
	local summary = document:selectFirst("#tabpanel-info .bn_B"):text()
	local tags = map(document:select("#tabpanel-tags > .bn_ar > a"),function(v)
		return v:text()
	end)


	-- This is for the sake of consistant styling
	chap = cleanupDocument(chap)

	local pagesElements = document:select("a.l_bJ")
	if pagesElements:size() > 1 then
		local lastPage = selectLast(document:select("a.l_bJ")):attr("href")
		local lastPageNumber = tonumber(lastPage:match("%d+$"))
		for i = 2, lastPageNumber do
			local nextDocument = ClientGetDocument(expandURL(chapterURL) .. "?page=" .. i)
					:selectFirst(".aa_eQ.article > .aa_ht > div")
			nextDocument = cleanupDocument(nextDocument):selectFirst('body'):children()
			chap:selectFirst('body'):lastChild():after(nextDocument)
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
	local number, unit = text:match("(%d+%.?%d*)(%a*)")
	number = tonumber(number)

	if unit == "k" then
		number = number * 1000
	end

	return math.floor(number)
end

local function getNovelInfoFromSeries(document)
	local title = document:selectFirst(".headline.j_bm"):text()
	local summary = document:selectFirst(".bp_rh")
	if summary ~= nil then
		summary = summary:wholeText()
	else
		local firstChapter = document:selectFirst("li.br_ri p")
		firstChapter:select("p > a"):remove()
		summary = firstChapter:wholeText()
	end

	local tags = map(document:select("#tabpanel-tags > a"),function(v)
		return v:text()
	end)

	return {
		title = title,
		summary = summary,
		tags = tags
	}
end

local function getNovelInfoFromPage(document)
	local title = document:selectFirst(".headline.j_eQ"):text()
	local summary = document:selectFirst("#tabpanel-info .bn_B"):text()
	local tags = map(document:select("#tabpanel-tags .bn_ar > a"),function(v)
		return v:text()
	end)

	return {
		title = title,
		summary = summary,
		tags = tags
	}
end

local function getNovel(document, novelUrl, mainInfo)
	local title = mainInfo.title
	local summary = mainInfo.summary
	local tags = mainInfo.tags
	local author = document:selectFirst(".y_eS > .y_eU"):text()
	local views = document:selectFirst("div[title=Views] > span.aT_cl")
	local faves = document:selectFirst("div[title=Favorites] > span.aT_cl")
	local comments = document:selectFirst("div[title=Comments] > span.aT_cl")

	local info = NovelInfo {
		title = title,
		link = novelUrl,
		description = summary,
		genres = tags,
		authors = { author },
	}

	if views then
		info:setViewCount(textToInteger(views:text()))
	end

	if faves then
		info:setFavoriteCount(textToInteger(faves:text()))
	end

	if comments then
		info:setFavoriteCount(textToInteger(comments:text()))
	end

	return info
end

local function removeAfterColon(str)
	local index = string.find(str, ":")
	if index then
		return string.sub(str, 1, index - 1)
	else
		return str
	end
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		return NovelInfo {
			title = "How to use this source",
			description = "You can use this source by:\n1. searching on the literotica.com website and inputting the url of the story in the search bar.\nOr you can search tags in a comma-delimited list like \"oral,blowjob\""
		}
	end

	local document = ClientGetDocument(expandURL(novelURL))

	local series = document:selectFirst("#tabpanel-series")
	if series ~= nil then
		series = series:selectFirst("div.bn_au > a")
		if series ~= nil then
			series = ClientGetDocument(series:attr("href"))
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
			chapters = map(series:select("li.br_ri"), function(v, i)
				local chapter = v:selectFirst(".br_rj")
				return NovelChapter {
					order = i,
					title = chapter:text(),
					link = shrinkURL(chapter:attr("href"))
				}
			end)
		else
			chapters = {
				NovelChapter {
					order = 0,
					title = info.title,
					link = novelURL,
				}
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
	{ name = "Celebrities & Fan Fiction", tagCategory = "celebrities-fan-fiction-category-tags", category = "celebrity-stories" },
	{ name = "Chain Stories", tagCategory = "chain-stories-category-tags", category = "chain-stories" },
	{ name = "Erotic Couplings", tagCategory = "erotic-couplings-category-tags", category = "erotic-couplings" },
	{ name = "Erotic Horror", tagCategory = "erotic-horror-category-tags", category = "erotic-horror" },
	{ name = "Exhibitionist & Voyeur", tagCategory = "exhibitionist-voyeur-category-tags", category = "exhibitionist-voyeur" },
	{ name = "Fetish", tagCategory = "fetish-category-tags", category = "fetish-stories" },
	{ name = "First Time", tagCategory = "first-time-category-tags", category = "first-time-sex-stories" },
	{ name = "Gay Male", tagCategory = "gay-male-category-tags", category = "gay-sex-stories" },
	{ name = "Group Sex", tagCategory = "group-sex-category-tags", category = "group-sex-stories" },
	{ name = "How To", tagCategory = "how-to-category-tags", category = "adult-how-to" },
	{ name = "Humor & Satire", tagCategory = "humor-satire-category-tags", category = "adult-humor" },
	{ name = "Illustrated", tagCategory = "illustrated-category-tags", category = "illustrated-erotic-fiction" },
	{ name = "Incest/Taboo", tagCategory = "incest-taboo-category-tags", category = "taboo-sex-stories" },
	{ name = "Interracial Love", tagCategory = "interracial-love-category-tags", category = "interracial-erotic-stories" },
	{ name = "Lesbian Sex", tagCategory = "lesbian-sex-category-tags", category = "lesbian-sex-stories" },
	{ name = "Letters & Transcripts", tagCategory = "letters-transcripts-category-tags", category = "erotic-letters" },
	{ name = "Loving Wives", tagCategory = "loving-wives-category-tags", category = "loving-wives" },
	{ name = "Mature", tagCategory = "mature-category-tags", category = "mature-sex" },
	{ name = "Mind Control", tagCategory = "mind-control-category-tags", category = "mind-control" },
	{ name = "Non-English", tagCategory = "non-english-category-tags", category = "non-english-stories" },
	{ name = "Non-Erotic", tagCategory = "non-erotic-category-tags", category = "non-erotic-stories" },
	{ name = "NonConsent/Reluctance", tagCategory = "nonconsent-reluctance-category-tags", category = "non-consent-stories" },
	{ name = "NonHuman", tagCategory = "nonhuman-category-tags", category = "non-human-stories" },
	{ name = "Novels and Novellas", tagCategory = "novels-and-novellas-category-tags", category = "erotic-novels" },
	{ name = "Reviews & Essays", tagCategory = "reviews-essays-category-tags", category = "reviews-and-essays" },
	{ name = "Romance", tagCategory = "romance-category-tags", category = "adult-romance" },
	{ name = "Sci-Fi & Fantasy", tagCategory = "sci-fi-fantasy-category-tags", category = "science-fiction-fantasy" },
	{ name = "Toys & Masturbation", tagCategory = "toys-masturbation-category-tags", category = "masturbation-stories" },
	{ name = "Transgender & Crossdressers", tagCategory = "transgender-crossdressers-category-tags", category = "transgender-crossdressers" },
}


-- Function to split a string by a delimiter
local function split(str, delimiter)
	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
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
	{ name = "Favorite", value = "favorite" }
}

local WithinOptions = {
	{ name = "All Time", value = "" },
	{ name = "7 Days", value = "week" },
	{ name = "30 Days", value = "month" },
	{ name = "1 Year", value = "year" }
}

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = filters[PAGE]
	local url = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if shrinkURL(url):match("/s/%a+") then
		if page ~= 1 then
			return {}
		end
		local novelUrl = url:gsub("/$", "")
		local novel = ClientGetDocument(novelUrl):selectFirst(".headline.j_eQ")
		return {
			NovelInfo {
				title = novel:text(),
				link = shrinkURL(url),
				imageURL = ""
			}
		}
	end



	local query = filters[QUERY]
	local tags = split(query, ",")
	table.sort(tags)

	if next(tags) then
		local searchUrl = "https://tags.literotica.com/"
		local category = Categories[tonumber(filters[2])]
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
		local sortBy = SortByOptions[tonumber(filters[3])]
		if sortBy and sortBy.value ~= "" then
			searchUrl = searchUrl .. "&sort_by=" .. sortBy.value
		end
		local within = WithinOptions[tonumber(filters[4])]
		if within and within.value ~= "" then
			searchUrl = searchUrl .. "&period=" .. within.value
		end

		local document = ClientGetDocument(searchUrl)

		return map(document:select(".panel.ai_gJ"), function(v)
			local views = v:selectFirst("div[title=Views] > span")
			if views == nil then
				views = "0"
			else
				views = views:text()
			end
			local favorites = v:selectFirst("div[title=Favorites] > span")
			if favorites == nil then
				favorites = "0"
			else
				favorites = favorites:text()
			end
			local comments = v:selectFirst("div[title=Comments] > span")
			if comments == nil then
				comments = "0"
			else
				comments = comments:text()
			end
			return NovelInfo {
				title = v:selectFirst(".ai_ii h4"):text(),
				link = shrinkURL(v:selectFirst(".ai_ii"):attr("href")),
				description = v:selectFirst(".ai_ij p"):text(),
				authors = { v:selectFirst(".ai_il > span.ai_im"):text() },
				genres = { selectLast(v:select(".ai_il > span.ai_im")):text() },
				viewCount = textToInteger(views),
				favoriteCount = textToInteger(favorites),
				commentCount = textToInteger(comments),
			}
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
		DropdownFilter(
			2,
			"Category",
			categoryOptions
		),
		DropdownFilter(
			3,
			"Sort By",
			sortByOptions
		),
		DropdownFilter(
			4,
			"Within",
			withinOptions
		),
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
				NovelInfo {
					title = "How to use this source",
					link = "how",
					imageURL = ""
				}
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
	expandURL = expandURL
}
