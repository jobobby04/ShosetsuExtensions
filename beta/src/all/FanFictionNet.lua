-- {"id":1308639978,"ver":"1.0.0","libVer":"1.0.0","author":"Jobobby04"}

local baseURL = "https://www.fanfiction.net"
local settings = {}


local SORT_ID = 2 -- srt
local SortOptions = {
	{ name = "Update Date", value = "1" },
	{ name = "Publish Date", value = "2" },
	{ name = "Reviews", value = "3" },
	{ name = "Favorites", value = "4" },
	{ name = "Follows", value = "5" }
}
local sortByNameToValue = {}
for key, option in pairs(SortOptions) do
	sortByNameToValue[option.name] = option.value
end

local RATING_ID = 6 -- r
local RatingOptions = {
	{ name = "All", value = "10" },
	{ name = "Rated K -> T", value = "103" },
	{ name = "Rated K -> K+", value = "102" },
	{ name = "Rated K", value = "1" },
	{ name = "Rated K+", value = "2" },
	{ name = "Rated T", value = "3" },
	{ name = "Rated M", value = "4" },
}
local ratingByNameToValue = {}
for key, option in pairs(RatingOptions) do
	ratingByNameToValue[option.name] = option.value
end

local TIME_RANGE_ID = 3 -- t
local TimeRangeOptions = {
	{ name = "All", value = "0" },
	{ name = "Updated within 24 hours", value = "1" },
	{ name = "Updated within 1 week", value = "2" },
	{ name = "Updated within 1 month", value = "3" },
	{ name = "Updated within 6 months", value = "4" },
	{ name = "Updated within 1 year", value = "5" },
	{ name = "Published within 24 hours", value = "11" },
	{ name = "Published within 1 week", value = "12" },
	{ name = "Published within 1 month", value = "13" },
	{ name = "Published within 6 months", value = "14" },
	{ name = "Published within 1 year", value = "15" },
}
local timeRangeByNameToValue = {}
for key, option in pairs(TimeRangeOptions) do
	timeRangeByNameToValue[option.name] = option.value
end

local GENRE_A_ID = 4 -- g1
local GENRE_B_ID = 5 -- g2
local GENRE_EXCLUDE_ID = 10 -- _g1
local GenreOptions = {
	{ name = "All", value = "0" },
	{ name = "Adventure", value = "6" },
	{ name = "Angst", value = "10" },
	{ name = "Crime", value = "18" },
	{ name = "Drama", value = "4" },
	{ name = "Family", value = "19" },
	{ name = "Fantasy", value = "14" },
	{ name = "Friendship", value = "21" },
	{ name = "General", value = "1" },
	{ name = "Horror", value = "8" },
	{ name = "Humor", value = "3" },
	{ name = "Hurt/Comfort", value = "20" },
	{ name = "Mystery", value = "7" },
	{ name = "Parody", value = "9" },
	{ name = "Poetry", value = "5" },
	{ name = "Romance", value = "2" },
	{ name = "Sci-Fi", value = "13" },
	{ name = "Spiritual", value = "15" },
	{ name = "Supernatural", value = "11" },
	{ name = "Suspense", value = "12" },
	{ name = "Tragedy", value = "16" },
	{ name = "Western", value = "17" },
}
local genreByNameToValue = {}
for key, option in pairs(GenreOptions) do
	genreByNameToValue[option.name] = option.value
end

local LANGUAGE_ID = 7 -- lan
local LanguageOptions = { -- lan
	{ name = "Language", value = "0" },
	{ name = "Bahasa Indonesia", value = "32" },
	{ name = "Català", value = "34" },
	{ name = "Deutsch", value = "4" },
	{ name = "Eesti", value = "41" },
	{ name = "English", value = "1" },
	{ name = "Español", value = "2" },
	{ name = "Esperanto", value = "22" },
	{ name = "Français", value = "3" },
	{ name = "Italiano", value = "11" },
	{ name = "Język polski", value = "13" },
	{ name = "LINGUA LATINA", value = "35" },
	{ name = "Magyar", value = "14" },
	{ name = "Nederlands", value = "7" },
	{ name = "Norsk", value = "18" },
	{ name = "Português", value = "8" },
	{ name = "Slovenčina", value = "43" },
	{ name = "Suomi", value = "20" },
	{ name = "Svenska", value = "17" },
	{ name = "čeština", value = "31" },
	{ name = "Русский", value = "10" },
	{ name = "Українська", value = "44" },
	{ name = "עברית", value = "15" },
	{ name = "ภาษาไทย", value = "38" },
	{ name = "中文", value = "5" },
	{ name = "日本語", value = "6" },
}
local languageByNameToValue = {}
for key, option in pairs(LanguageOptions) do
	languageByNameToValue[option.name] = option.value
end

local LENGTH_ID = 8 -- len
local LengthOptions = { -- len
	{ name = "All", value = "0" },
	{ name = "< 1K words", value = "11" },
	{ name = "< 5K words", value = "51" },
	{ name = "> 1K words", value = "1" },
	{ name = "> 5K words", value = "5" },
	{ name = "> 10K words", value = "10" },
	{ name = "> 20K words", value = "20" },
	{ name = "> 40K words", value = "40" },
	{ name = "> 60K words", value = "60" },
	{ name = "> 100K words", value = "100" },
}
local lengthByNameToValue = {}
for key, option in pairs(LengthOptions) do
	lengthByNameToValue[option.name] = option.value
end

local STATUS_ID = 9 -- s
local StatusOptions = { -- s
	{ name = "All", value = "0" },
	{ name = "In-Progress", value = "1" },
	{ name = "Complete", value = "2" },
}
local statusByNameToValue = {}
for key, option in pairs(StatusOptions) do
	statusByNameToValue[option.name] = option.value
end

local function shrinkURL(url)
	return url:gsub("^.-hentai-foundry%.com", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	element = tostring(element):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	element = Document(element):selectFirst('body')
	return element
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = GETDocument(expandURL(chapterURL))
	local chap = document:selectFirst(".storytextp .storytext")
	-- local title = document:selectFirst(".titlebar > a"):text()

	-- This is for the sake of consistant styling
	chap:select(".landmark"):remove()
	chap = cleanupDocument(chap)
	-- Adds Chapter Title

	-- chap:child(0):before("<h1>" .. title .. "</h1>")
	return pageOfElem(chap, true)
end

--- @param elements Elements
--- @return Element
local function selectLast(elements)
	return elements:get(elements:size() - 1)
end

local function splitByMinus(query)
	local res = {}
	local lastCharWasSpace = false
	local lastCharWasMinus = false
	local queuedRawText = {}

	local function flush()
		if #queuedRawText > 0 then
			table.insert(res, table.concat(queuedRawText))
			queuedRawText = {}
		end
	end

	for i = 1, #query do
		local char = query:sub(i, i)
		if char == " " or char == "-" then
			if lastCharWasSpace then
				if lastCharWasMinus then
					table.remove(queuedRawText, #queuedRawText)
					table.remove(queuedRawText, #queuedRawText)
					flush()
				else
					table.insert(queuedRawText, char)
				end
				lastCharWasMinus = true
			else
				table.insert(queuedRawText, char)
			end
			lastCharWasSpace = true
		else
			lastCharWasMinus = false
			lastCharWasSpace = false
			table.insert(queuedRawText, char)
		end
	end

	flush()

	return res
end

local function startsWith(str, start)
	return str:sub(1, #start) == start
end

local function split(str, delimiter)
	local result = {}
	for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

local function getGenres(genreString)
	local genres = split(genreString, "/")
	for _, genre in ipairs(genres) do
		if genreByNameToValue[genre] == nil then
			return nil
		end
	end
	return genres
end

--- @param storyInfoDocument Element
--- @return table
local function parseStoryInfo(storyInfoDocument)
	local storyInfo = storyInfoDocument:text()

	local rating, language, tags, characters
	local chapterCount, wordCount, reviewCount, favCount, followsCount = 0,0,0,0,0

	local storyInfoTable = splitByMinus(storyInfo)
	for k, v in pairs(storyInfoTable) do
		if startsWith(v, "Chapters:") then
			chapterCount = v:gsub("Chapters: ", "")
		elseif startsWith(v, "Words:") then
			wordCount = v:gsub("Words: ", "")
		elseif startsWith(v, "Reviews:") then
			reviewCount = v:gsub("Reviews: ", "")
		elseif startsWith(v, "Favs:") then
			favCount = v:gsub("Favs: ", "")
		elseif startsWith(v, "Follows:") then
			followsCount = v:gsub("Follows: ", "")
		elseif startsWith(v, "Rated:") then
			rating = v:gsub("Rated: ", "")
			if startsWith(rating, "Fiction ") then
				rating = v:gsub("Fiction ", "")
			end
		elseif k == 2 then
			language = v
		elseif startsWith(v, "Updated:") or startsWith(v, "Published:") or startsWith(v, "id:") then
			-- ignore
		else
			if tags ~= nil then -- assume characters
				characters = v
			else
				tags = getGenres(v)
				if tags == nil then -- assume characters
					characters = v
				end
			end
		end
	end
	if characters == nil then
		characters = ""
	end
	if tags == nil then
		tags = {}
	end

	-- Match updated, published, and complete status
	local dates = storyInfoDocument:select("span[data-xutime]")
	local updated, published
	if dates:size() == 2 then
		updated = tonumber(dates:get(0):attr("data-xutime"))
		updated = updated * 1000
		published = tonumber(dates:get(1):attr("data-xutime"))
		published = published * 1000
	else
		updated = 0
		published = tonumber(dates:get(0):attr("data-xutime"))
		published = published * 1000
	end
	local completedStatus = storyInfo:match("Status: Complete") or storyInfo:match(" - Complete")

	---- Convert numeric values
	chapterCount = tonumber(chapterCount)
	wordCount = (wordCount):gsub(",", "")
	wordCount = tonumber(wordCount)
	reviewCount = tonumber(reviewCount) or 0
	favCount = tonumber(favCount) or 0
	followsCount = tonumber(followsCount) or 0

	-- Parse characters
	local characterTable = {}
	local relationshipTable = {}
	for rel_group in characters:gmatch("%[([^%]]+)%]") do
		local relationship = {}
		for char in rel_group:gmatch("([^,]+)") do
			char = char:match("^%s*(.-)%s*$")
			if char ~= nil and char ~= "" then
				table.insert(characterTable, char)
				table.insert(relationship, char)
			end
		end
		table.insert(relationshipTable, relationship)
	end

	local charText = characters:gsub("%[[^%]]+%]", "")
	for char in charText:gmatch("([^,]+)") do
		char = char:match("^%s*(.-)%s*$")
		if char ~= nil and char ~= "" then
			table.insert(characterTable, char)
		end
	end

	-- Store data in a table
	return {
		rating = rating,
		language = language,
		tags = tags,
		chapterCount = chapterCount,
		wordCount = wordCount,
		reviewCount = reviewCount,
		favCount = favCount,
		followsCount = followsCount,
		updated = updated,
		published = published,
		characters = characterTable,
		relationships = relationshipTable,
		completed = completedStatus ~= nil
	}
end

--- @param storyInfoDocument Element
--- @param novelURL string
--- @param novelTitle string
--- @param thumbnail string | nil
--- @return NovelInfo
local function parseInfoDataIntoNovelInfo(
	storyInfoDocument,
	novelURL,
	novelTitle,
	thumbnail
)
	local infoData = parseStoryInfo(storyInfoDocument)
	local tags = {}
	if infoData.rating ~= nil and infoData.rating ~= "" then
		table.insert(tags, "Rating: " .. infoData.rating)
	end
	for _, v in pairs(infoData.tags) do
		table.insert(tags, "Genre: " .. v)
	end
	for _, v in pairs(infoData.relationships) do
		table.insert(tags, "Relationship: " .. "[" .. table.concat(v, ", ") .. "]")
	end
	for _, v in pairs(infoData.characters) do
		table.insert(tags, "Character: " .. v)
	end

	local status = NovelStatus.PUBLISHING
	if infoData.completed then
		status = NovelStatus.COMPLETED
	end

	local info = NovelInfo {
		title = novelTitle,
		link = novelURL,
		imageURL = thumbnail,
		language = infoData.language,
		wordCount = infoData.wordCount,
		chapterCount = infoData.chapterCount,
		commentCount = infoData.reviewCount,
		favoriteCount = infoData.favCount,
		status = status,
		genres = tags,
		--viewCount = views
	}

	return info
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		return NovelInfo {
			title = "How to use this source",
			description = "You can use this source by:\n1. Searching on the fanfiction.net website and inputting the url of the story in the search bar.\n2. On the Fanfiction website open one of the browse options and copy the url to the search bar."
		}
	end

	local document = GETDocument(expandURL(novelURL))
	local novelTitle = document:selectFirst("#profile_top > b"):text()
	local thumbnail = document:selectFirst("#profile_top .cimage")
	if thumbnail ~= nil then
		thumbnail = expandURL(thumbnail:attr("src"))
	end

	local info = parseInfoDataIntoNovelInfo(
			document:selectFirst("span.xgray"),
			novelURL,
			novelTitle,
			thumbnail
	)

	if loadChapters then
		local chaptersDocument = document:select("span #chap_select > option")
		local chapters
		if chaptersDocument ~= nil and chaptersDocument:size() ~= 0 then
			chapters = map(chaptersDocument, function(v, i)
				return NovelChapter {
					order = i,
					title = v:text(),
					link =  novelURL .. v:attr("value")
				}
			end)
		else
			chapters = {
				NovelChapter {
					order = 0,
					title = novelTitle,
					link = novelURL
				}
			}
		end

		info:setChapters(AsList(chapters))
	end

	return info
end

--- @param document Element
--- @return NovelInfo
local function parseBrowseNovel(document)
	local titleElement = document:selectFirst(".stitle")
	local title = titleElement:text()
	local url = titleElement:attr("href"):match("/s/%d+/")
	local thumbnailElement = titleElement:selectFirst("img")
	local thumbnail = thumbnailElement:attr("data-original")
	if thumbnail == nil then
		thumbnailElement = thumbnailElement:attr("src")
	end
	if thumbnail ~= nil then
		thumbnail = expandURL(thumbnail)
	end
	return parseInfoDataIntoNovelInfo(
			document:selectFirst("div div.xgray"),
			url,
			title,
			thumbnail
	)
end

local function searchFilters()
	local sortOptions = {}
	for _, option in pairs(SortOptions) do
		table.insert(sortOptions, option.name)
	end
	local ratingOptions = {}
	for _, option in pairs(RatingOptions) do
		table.insert(ratingOptions, option.name)
	end
	local timeRangeOptions = {}
	for _, option in pairs(TimeRangeOptions) do
		table.insert(timeRangeOptions, option.name)
	end
	local genreOptions = {}
	for _, option in pairs(GenreOptions) do
		table.insert(genreOptions, option.name)
	end
	local languageOptions = {}
	for _, option in pairs(LanguageOptions) do
		table.insert(languageOptions, option.name)
	end
	local lengthOptions = {}
	for _, option in pairs(LengthOptions) do
		table.insert(lengthOptions, option.name)
	end
	local statusOptions = {}
	for _, option in pairs(StatusOptions) do
		table.insert(statusOptions, option.name)
	end

	return {
		DropdownFilter(
				SORT_ID,
				"Sort",
				sortOptions
		),
		DropdownFilter(
				TIME_RANGE_ID,
				"Time Range",
				timeRangeOptions
		),
		DropdownFilter(
				GENRE_A_ID,
				"Genre (A)",
				genreOptions
		),
		DropdownFilter(
				GENRE_B_ID,
				"Genre (B)",
				genreOptions
		),
		DropdownFilter(
				RATING_ID,
				"Rating",
				ratingOptions
		),
		DropdownFilter(
				LANGUAGE_ID,
				"Language",
				languageOptions
		),
		DropdownFilter(
				LENGTH_ID,
				"Length",
				lengthOptions
		),
		DropdownFilter(
				STATUS_ID,
				"Status",
				statusOptions
		),
		DropdownFilter(
				GENRE_EXCLUDE_ID,
				"Genre (Exclude)",
				genreOptions
		),
	}
end

--- @param filters table
--- @param httpUrlBuilder HttpUrlBuilder
--- @return NovelInfo
local function applyFilters(filters, httpUrlBuilder)
	local sort = filters[SORT_ID] or SortOptions[1].name
	local timeRange = filters[TIME_RANGE_ID]
	local genreA = filters[GENRE_A_ID]
	local genreB = filters[GENRE_B_ID]
	local rating = filters[RATING_ID] or RatingOptions[1].name
	local language = filters[LANGUAGE_ID]
	local length = filters[LENGTH_ID]
	local status = filters[STATUS_ID]
	local genreExclude = filters[GENRE_EXCLUDE_ID]

	httpUrlBuilder:setQueryParameter("srt", sortByNameToValue[sort])
	if timeRange ~= nil then
		httpUrlBuilder:setQueryParameter("t", timeRangeByNameToValue[timeRange])
	end
	if genreA ~= nil then
		httpUrlBuilder:setQueryParameter("g1", genreByNameToValue[genreA])
	end
	if genreB ~= nil then
		httpUrlBuilder:setQueryParameter("g2", genreByNameToValue[genreB])
	end
	httpUrlBuilder:setQueryParameter("r", genreByNameToValue[rating])
	if language ~= nil then
		httpUrlBuilder:setQueryParameter("lan", languageByNameToValue[language])
	end
	if length ~= nil then
		httpUrlBuilder:setQueryParameter("len", lengthByNameToValue[length])
	end
	if status ~= nil then
		httpUrlBuilder:setQueryParameter("s", statusByNameToValue[status])
	end
	if genreExclude ~= nil then
		httpUrlBuilder:setQueryParameter("_g1", genreByNameToValue[genreExclude])
	end
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = filters[PAGE]
	local query = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if page == 1 and string.match(query, "^.-fanfiction%.net") ~= nil then
		local novelUrl = shrinkURL(query):match("/s/%d+/")
		if novelUrl ~= nil and novelUrl ~= "" then
			local novel = parseNovel(novelUrl, false)
			return {
				novel
			}
		end
	end

	if shrinkURL(query):match("/[^%/]+/[^%/]+/") then
		local urlBuilder = HttpUrl(query):newBuilder()
		urlBuilder:setQueryParameter("p", tostring(page))
		applyFilters(filters, urlBuilder)
		local document = GETDocument(urlBuilder:build():toString())
		local works = document:select("div.z-list")

		return map(works, function(v)
			return parseBrowseNovel(v)
		end)
	end

	return {}
end

return {
	id = 1308639978,
	name = "FanFiction.net",
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
				Novel {
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
	searchFilters = searchFilters(),

	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
