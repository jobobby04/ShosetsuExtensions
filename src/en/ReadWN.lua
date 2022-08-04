-- {"id":1,"ver":"1.0.38","libVer":"1.0.0","author":"Jobobby04"}

local baseURL = "https://www.readwn.com"
local settings = {}

local GENRE_SELECT = 2
local GENRE_VALUES = {
	"All",
	"Action",
	"Adult",
	"Adventure",
	"Comedy",
	"Contemporary Romance",
	"Drama",
	"Eastern Fantasy",
	"Ecchi",
	"Fantasy",
	"Fantasy Romance",
	"Gender Bender",
	"Harem",
	"Historical",
	"Horror",
	"Josei",
	"Lolicon",
	"Magical Realism",
	"Martial Arts",
	"Mature",
	"Mecha",
	"Mystery",
	"Psychological",
	"Romance",
	"School Life",
	"Sci-fi",
	"Seinen",
	"Shoujo",
	"Shounen",
	"Shounen Ai",
	"Slice of Life",
	"Smut",
	"Sports",
	"Supernatural",
	"Tragedy",
	"Video Games",
	"Wuxia",
	"Xianxia",
	"Xuanhuan",
	"Yaoi",
	"Two-dimensional",
	"Erciyuan",
	"Fan-Fiction",
	"Game",
	"Military",
	"Urban Life",
	"Yuri",
	"Chinese",
	"Korean",
	"Japanese",
	"Isekai",
	"Magic",
	"Shoujo Ai",
	"Urban",
	"Virtual Reality"
}

local STATUS_SELECT = 3
local STATUS_VALUES = {
	"All",
	"Completed",
	"Ongoing"
}

local SORT_BY_SELECT = 4
local SORT_BY_VALUES = {
	"Popular",
	"New",
	"Updates"
}

local function shrinkURL(url)
	return url:gsub("^.-readwn%.com", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = GETDocument(expandURL(chapterURL))
	local chap = document:selectFirst(".chapter-content")
	local title = document:selectFirst(".chapter-header h2"):text()
	-- This is for the sake of consistant styling
	chap:select("br:nth-child(even)"):remove()
	chap = tostring(chap):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	chap = Document(chap):selectFirst('body')
	-- Adds Chapter Title
	chap:child(0):before("<h1>" .. title .. "</h1>")
	return pageOfElem(chap, true)
end

--- @param document Document
--- @param startIndex int
--- @return NovelChapter[]
local function selectChapters(document, startIndex)
	return map(document:select("ul.chapter-list a"), function(v, i)
		return NovelChapter {
			order = startIndex + i,
			title = v:selectFirst("strong"):text(),
			link = shrinkURL(v:attr("href"))
		}
	end)
end


local function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

--- @param elements Elements
--- @return Element
local function selectLast(elements)
	return elements:get(elements:size() - 1)
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
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
		imageURL = expandURL(content:selectFirst(".novel-header .fixed-img img"):attr("data-src")),
		--[[status = ({
			Completed = NovelStatus.COMPLETED,
			Ongoing = NovelStatus.PUBLISHING
		})[selectLast(content:select(".novel-header .novel-info .header-stats span strong")):text()],]]
		description = content:selectFirst("#info .summary"):text(),
		authors = { selectLast(content:select(".novel-header .novel-info .author span")):text() },
		genres = categories
	}

	if loadChapters then
		local novelId = novelURL:gsub("^.-novel/", ""):gsub("%.html", "")
		local chapterList1 = GETDocument("https://www.readwn.com/e/extend/fy.php?page=0&wjm=" .. novelId)
		local lastChapterPage = selectLast(chapterList1:select("ul.pagination a")):attr("href"):match(".*page=([0-9]*).*")
		local chapters = selectChapters(chapterList1, 0)

		for i = 1, lastChapterPage do
			local newChapters = selectChapters(GETDocument("https://www.readwn.com/e/extend/fy.php?page=" .. i .. "&wjm=" .. novelId), tableLength(chapters))
			for _,v in ipairs(newChapters) do
				table.insert(chapters, v)
			end
		end
		info:setChapters(AsList(chapters))
	end

	return info
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

local searchMap = {}

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @param reporter fun(v : string | any)
--- @return Novel[]
local function search(filters, reporter)
	local query = filters[QUERY]
	local page = filters[PAGE]
	if query ~= "" then
		local searchId = searchMap[query]
		if searchId ~= nil then
			return parseBrowse(GETDocument(expandURL("/e/search/result/index.php?page=" .. (page - 1) .. "&searchid=" .. searchId)))
		else
			local request = POST(
					"https://www.readwn.com/e/search/index.php",
					nil,
					FormBodyBuilder()
							:add("show", "title")
							:add("tempid", "1")
							:add("tbname", "news")
							:add("keyboard", query:gsub(" ", "+"))
							:build()
			)
			local document = RequestDocument(request)
			if page == 1 then
				local pages = document:select("ul.pagination a")
				if pages:size() > 0 then
					searchMap[query] = selectLast(pages):attr("href"):match(".*searchid=([0-9]*).*")
				end
				return parseBrowse(document)
			else
				local pages = document:select("ul.pagination a")
				if pages:size() > 0 then
					searchMap[query] = selectLast(pages):attr("href"):match(".*searchid=([0-9]*).*")
					searchId = searchMap[query]
					return parseBrowse(GETDocument(expandURL("/e/search/result/index.php?page=" .. (page - 1) .. "&searchid=" .. searchId)))
				else
					return {}
				end
			end
		end
	end

	local genre = filters[GENRE_SELECT]
	local status = filters[STATUS_SELECT]
	local sortBy = filters[SORT_BY_SELECT]

	local part1 = "all"
	if genre ~= nil and genre ~= 0 then
		part1 = GENRE_VALUES[genre+1]:lower():gsub(" ", "-")
	end
	local part2 = "all"
	if status ~= nil and status ~= 0 then
		part2 = STATUS_VALUES[status+1]
	end

	local part3 = "newstime"
	if sortBy ~= nil and sortBy ~= 1 then
		if sortBy == 0 then
			part3 = "onclick"
		elseif sortBy == 2 then
			part3 = "lastdotime"
		end
	end
	return parseBrowse(GETDocument("https://www.readwn.com/list/" .. part1 .. "/" .. part2 .. "-" .. part3 .. "-" .. (page - 1) .. ".html"))
end

return {
	id = 1308639964,
	name = "ReadWN",
	baseURL = baseURL,

	chapterType = ChapterType.HTML,

	-- Optional values to change
	--[[imageURL = "",
	hasCloudFlare = false,]]
	hasSearch = true,
	isSearchIncrementing = true,


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
	searchFilters = {
		DropdownFilter(GENRE_SELECT, "Genre / Category", GENRE_VALUES),
		DropdownFilter(STATUS_SELECT, "Status", SELECT_VALUES),
		DropdownFilter(SORT_BY_SELECT, "Sort by", SORT_BY_VALUES)
	},

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
