-- {"id":1308639967,"ver":"1.1.1","libVer":"1.1.0","author":"Jobobby04"}

local baseURL = "https://www.hentai-foundry.com"
local settings = {}

local enterAgreeInterceptor = Interceptor(
	function(chain)
		---@type Request
		local request = chain:request()
		if request:method() == "GET" then
			local newUrl = request:url():newBuilder():addQueryParameter("enterAgree", "1"):build()
			return chain:proceed(request:newBuilder():url(newUrl):build())
		else
			return chain:proceed(request)
		end

	end
)

---@type OkHttpClient
local client = HttpClientBuilder()
	:addInterceptor(enterAgreeInterceptor)
	:build()

---@param request Request
---@return Response
local function ClientRequest(request)
	return client:newCall(request):execute()
end

---@param request Request
---@return string
local function ClientRequestDocument(request)
	local response = ClientRequest(request)
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
	return url:gsub("^.-hentai-foundry%.com", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	local html = tostring(element)
	-- Don't wrap source that already has block elements, or we nest <p> in <p>
	-- and the parser drops the passage.
	local hasBlock = html:match('<p[ >]') ~= nil or html:match('<div[ >]') ~= nil
	html = html:gsub('<br%s*/?>', '</p><p>')
	html = html:gsub('<div[^>]*>', '<p>'):gsub('</div>', '</p>')
	if not hasBlock then
		html = '<p>' .. html .. '</p>'
	end
	html = html:gsub('<p>%s*</p>', '')
	return Document(html):selectFirst('body')
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = ClientGetDocument(expandURL(chapterURL))
	local chap = document:selectFirst(".container #viewChapter .boxbody")
	local title = document:selectFirst(".titlebar > a"):text()

	-- This is for the sake of consistant styling
	chap:select(".landmark"):remove()
	chap = cleanupDocument(chap)
	-- Adds Chapter Title

	chap:child(0):before("<h1>" .. title .. "</h1>")
	return pageOfElem(chap, true)
end

--- @param elements Elements
--- @return Element
local function selectLast(elements)
	return elements:get(elements:size() - 1)
end

local function getNovel(document)
	local title = document:selectFirst(".titlebar > a")
	local summaryElement = document:selectFirst(".story  .storyDescript")
	local summary = ""
	summary = Document(tostring(summaryElement))
	summary:selectFirst(".storyRead"):remove()
	summary:selectFirst(".storyCategoryRating"):remove()
	local storyVote = summary:selectFirst(".storyVote")
	if storyVote then
		storyVote:remove()
	end
	summary = summary:wholeText():gsub("\\n", "\n"):gsub('^%s*(.-)%s*$', '%1'):gsub('\n\n', '\n'):gsub('\n%s+', '\n')

	local genres = { summaryElement:selectFirst(".storyCategoryRating .categoryBreadcrumbs"):text() }
	local tags = summaryElement:select(".storyCategoryRating .ratings_box span")
	if tags ~= nil and tags:size() ~= 0 then
		for i = 0, tags:size() - 1 do
			table.insert(genres, tags:get(i):attr("title"))
		end
	end
	local colum3 = tostring(document:selectFirst(".col3"))

	local chapters = colum3:match('<span class="label">Chapters:</span> (.-)<br>'):gsub(',', ''):gsub("%s", '')
	local words = colum3:match('<span class="label">Words:</span> (.-)<br>'):gsub(',', ''):gsub("%s", '')
	local views = colum3:match('<span class="label">Views:</span> (.-)<br>'):gsub(',', ''):gsub("%s", '')
	local faves = colum3:match('<span class="label">.*Faves.*</span>(.-)<br>'):gsub(',', ''):gsub("%s", '')
	local comments = colum3:match('<span class="label">Comments:</span> (.-)<br>'):gsub(',', ''):gsub("%s", '')

	return NovelInfo {
		title = title:text(),
		link = title:attr("href"),
		description = summary,
		genres = genres,
		authors = { document:selectFirst(".storyInfo > .col1 > a"):text() },
		status = ({
			Complete = NovelStatus.COMPLETED,
			Incomplete = NovelStatus.PUBLISHING
		})[selectLast(document:select(".storyInfo >.col2 > span.indent")):text()],
		chapterCount = tonumber(chapters),
		wordCount = tonumber(words),
		viewCount = tonumber(views),
		favoriteCount = tonumber(faves),
		commentCount = tonumber(comments)
	}
end

--- @return NovelInfo
local function addByUrlHowInfo()
	return NovelInfo {
		title = "How to use Add by URL",
		link = "how/addByUrl",
		description = "Paste a HentaiFoundry story URL to add it."
	}
end

--- @return NovelInfo
local function userStoriesHowInfo()
	return NovelInfo {
		title = "How to use User Stories",
		link = "how/userStories",
		description = "Type a HentaiFoundry username to browse all of their stories."
	}
end

--- @return NovelInfo
local function searchHowInfo()
	return NovelInfo {
		title = "How to use Story Search",
		link = "how/search",
		description = "Type a search query to find stories by title, keywords, or description."
	}
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL == "how/addByUrl" then
		return addByUrlHowInfo()
	end
	if novelURL == "how/userStories" then
		return userStoriesHowInfo()
	end
	if novelURL == "how/search" then
		return searchHowInfo()
	end

	local document = ClientGetDocument(expandURL(novelURL))

	local info = getNovel(document)

	if loadChapters then
		local chaptersDocument = document:selectFirst(".container > .box > .boxbody")
		local chapters  = map(chaptersDocument:select("a"), function(v, i)
			return NovelChapter {
				order = i,
				title = v:text(),
				link = v:attr("href")
			}
		end)

		info:setChapters(AsList(chapters))
	end

	return info
end

local ratings = {
	"None",
	"Mild",
	"Moderate",
	"Explicit"
}

local ratingToFormValue = {
	None = "0",
	Mild = "1",
	Moderate = "2",
	Explicit = "3"
}

local FilterOrderOption = {
	{ name = "Date Submitted (Newest)", value = "date_new" },
	{ name = "Date Submitted (Oldest)", value = "date_old" },
	{ name = "Date updated (Newest)", value = "update_new" },
	{ name = "Date updated (Oldest)", value = "update_old" },
	{ name = "Title A-Z", value = "a-z" },
	{ name = "Title Z-A", value = "z-a" },
	{ name = "Views (most first)", value = "views most" },
	{ name = "Rating (highest first)", value = "rating highest" },
	{ name = "Comments (most first)", value = "comments most" },
	{ name = "Faves (most first)", value = "faves most" },
	{ name = "Popularity (highest first)", value = "popularity most" }
}

local sortByNameToValue = {}
for key, option in pairs(FilterOrderOption) do
	sortByNameToValue[option.name] = option.value
end

local function DupeIfTrue(formBodyBuilder, key, value)
	formBodyBuilder:add(key, "0")
	if value then
		formBodyBuilder:add(key, "1")
	end
end

--- @param filters table
local function createFormBody(token, filters)
	local nudity = filters[2] or (#ratings - 1)
	local violence = filters[3] or (#ratings - 1)
	local racism = filters[4] or (#ratings - 1)
	local profanity = filters[5] or (#ratings - 1)
	local sexualContent = filters[6] or (#ratings - 1)
	local spoilerWarning = filters[7] or (#ratings - 1)
	local yaoi = filters[8]
	local yuri = filters[9]
	local teen = filters[10]
	local guro = filters[11]
	local furry = filters[12]
	local beast = filters[13]
	local male = filters[14]
	local female = filters[15]
	local futa = filters[16]
	local other = filters[17]
	local scat = filters[18]
	local incest = filters[19]
	local rape = filters[20]
	local sortBy = filters[21]
	for index, value in pairs(FilterOrderOption) do
		if sortBy == index - 1 then
			sortBy = value.value
			break
		end
	end

	local formBody = FormBodyBuilder():add("YII_CSRF_TOKEN", token)

	-- Add the values to the form body
	formBody:add("rating_nudity", nudity)
	formBody:add("rating_violence", violence)
	formBody:add("rating_profanity", profanity)
	formBody:add("rating_racism", racism)
	formBody:add("rating_sex", sexualContent)
	formBody:add("rating_spoilers", spoilerWarning)
	DupeIfTrue(formBody, "rating_yaoi", yaoi)
	DupeIfTrue(formBody, "rating_yuri", yuri)
	DupeIfTrue(formBody, "rating_teen", teen)
	DupeIfTrue(formBody, "rating_guro", guro)
	DupeIfTrue(formBody, "rating_furry", furry)
	DupeIfTrue(formBody, "rating_beast", beast)
	DupeIfTrue(formBody, "rating_male", male)
	DupeIfTrue(formBody, "rating_female", female)
	DupeIfTrue(formBody, "rating_futa", futa)
	DupeIfTrue(formBody, "rating_other", other)
	DupeIfTrue(formBody, "rating_scat", scat)
	DupeIfTrue(formBody, "rating_incest", incest)
	DupeIfTrue(formBody, "rating_rape", rape)
	-- Unused
	formBody:add("filter_media", "A")
	formBody:add("filter_order", sortBy)
	-- Unused
	formBody:add("filter_type", "0")

	return formBody:build()
end

local function urldecode(s)
	s = s:gsub('+', ' ')
	s = s:gsub('%%(%x%x)', function(hex)
		return string.char(tonumber(hex, 16))
	end)
	return s
end

local function urlencode(s)
	return (s:gsub("[^%w%-_%.~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

local function getToken()
	local cookies = HttpClient():cookieJar():loadForRequest(HttpUrl("https://www.hentai-foundry.com"))

	for i = 0, cookies:size() - 1 do
		if cookies:get(i):name() == "YII_CSRF_TOKEN" then
			return cookies:get(i):value()
		end
	end
end

--- Shared browse for paginated story lists.
--- @param listUrl string @relative story-list URL, e.g. "/categories/5/Misc/stories"
--- @param page number
--- @return NovelInfo[]
local function browseStoryList(listUrl, page)
	local document = ClientGetDocument(expandURL(listUrl) .. "/page/" .. page)
	return map(document:select(".storyRow"), function(v)
		return getNovel(v)
	end)
end

--- Story text search. Paginated via a `page` query param (not a `/page/N` path).
--- @param query string
--- @param page number
--- @return NovelInfo[]
local function searchStories(query, page)
	local url = expandURL("/search/stories") .. "?query=" .. urlencode(query) .. "&page=" .. page
	local document = ClientGetDocument(url)
	return map(document:select(".storyRow"), function(v)
		return getNovel(v)
	end)
end

--- Applies the rating/sort filters to a category via the site's filter form.
--- @param catUrl string @relative category URL
--- @param filters table
--- @return NovelInfo[]
local function filterCategory(catUrl, filters)
	local token = getToken()
	if token == nil then
		ClientGetDocument("https://www.hentai-foundry.com")
		token = getToken()
	end
	local formBody = createFormBody(urldecode(token):match('"([^"]+)"'), filters)
	local response = ClientRequest(POST("https://www.hentai-foundry.com/site/filters", DEFAULT_HEADERS(), formBody))
	response:close()
	return browseStoryList(catUrl, filters[PAGE])
end

--- @param filters table
--- @return NovelInfo[]
local function addByUrl(filters)
	local url = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if filters[PAGE] == 1 and shrinkURL(url):match("/stories/user/%w+/%d+") then
		local novelUrl = shrinkURL(url):gsub("/chapters.*$", ""):gsub("/$", "")
		local novel = ClientGetDocument(expandURL(novelUrl)):selectFirst(".titlebar > a")
		return {
			NovelInfo {
				title = novel:text(),
				link = novel:attr("href")
			}
		}
	end
	return {}
end

---@param name string
---@param choices string[] | Array | table
local function CreateDropdownFilterLastOption(id, name, choices)
	local filter = DropdownFilter(id, name, choices)
	filter:setState(#choices - 1)
	return filter
end

---@param name string
local function CreateCheckboxFilterEnabled(id, name)
	local filter = CheckboxFilter(id, name)
	filter:setState(true)
	return filter
end

local function searchFilters()
	local orderOptions = {}
	for _, option in pairs(FilterOrderOption) do
		table.insert(orderOptions, option.name)
	end

	return {
		CreateDropdownFilterLastOption(
			2,
			"Nudity",
			ratings
		),
		CreateDropdownFilterLastOption(
			3,
			"Violence",
			ratings
		),
		CreateDropdownFilterLastOption(
			4,
			"Racism",
			ratings
		),
		CreateDropdownFilterLastOption(
			5,
			"Profanity",
			ratings
		),
		CreateDropdownFilterLastOption(
			6,
			"Sexual Content",
			ratings
		),
		CreateDropdownFilterLastOption(
			7,
			"Spoiler Warning",
			ratings
		),
		CreateCheckboxFilterEnabled(8, "Yaoi"),
		CreateCheckboxFilterEnabled(9, "Yuri"),
		CheckboxFilter(10, "Teen"),
		CheckboxFilter(11, "Guro"),
		CheckboxFilter(12, "Furry"),
		CheckboxFilter(13, "Beast"),
		CreateCheckboxFilterEnabled(14, "Male"),
		CreateCheckboxFilterEnabled(15, "Female"),
		CheckboxFilter(16, "Futa"),
		CheckboxFilter(17, "Other"),
		CheckboxFilter(18, "Scat"),
		CheckboxFilter(19, "Incest"),
		CheckboxFilter(20, "Rape"),
		DropdownFilter(
			21,
			"Sort By",
			orderOptions
		),
	}
end



--- @param li Element @an <li class="item_level_N"> category node
--- @return table? @{id, path, name, children}
local function parseCategoryLi(li)
	local a = li:selectFirst("a")
	local id, path = a:attr("href"):match("/categories/(%d+)/(.+)/pictures")
	if not id then
		return nil
	end
	local node = { id = id, path = path, name = a:text(), children = {} }
	local subUl = li:selectFirst("> ul")
	if subUl then
		local subLis = subUl:select("> li")
		for i = 0, subLis:size() - 1 do
			local child = parseCategoryLi(subLis:get(i))
			if child then
				table.insert(node.children, child)
			end
		end
	end
	return node
end

local categoryTree
--- @return table[] @top-level category nodes {id, path, name, children}
local function getCategoryTree()
	if categoryTree then
		return categoryTree
	end
	local document = ClientGetDocument(expandURL("/category/browse"))
	local topLis = document:select(".browseCategoriesDiv .item_level_1")
	categoryTree = {}
	for i = 0, topLis:size() - 1 do
		local node = parseCategoryLi(topLis:get(i))
		if node then
			table.insert(categoryTree, node)
		end
	end
	return categoryTree
end

--- @param id string
--- @param path string
--- @return table | nil
local function findCategory(id, path)
	local function search(nodes)
		for _, n in ipairs(nodes) do
			if n.id == id and n.path == path then
				return n
			end
			local found = search(n.children)
			if found then
				return found
			end
		end
		return nil
	end
	return search(getCategoryTree())
end

--- @param nodes table[] @category nodes
--- @return table[] @nodes with unique urls (id+path), first occurrence kept
local function dedupeByUrl(nodes)
	local seen = {}
	local result = {}
	for _, n in ipairs(nodes) do
		local key = n.id .. "@" .. n.path
		if not seen[key] then
			seen[key] = true
			table.insert(result, n)
		end
	end
	return result
end

--- @param id string
--- @param path string
--- @param name string
--- @param linkSuffix string? @disambiguates a group's "All" item from the group itself
--- @return Listing
local function makeCategoryListing(id, path, name, linkSuffix)
	local catUrl = "/categories/" .. id .. "/" .. path .. "/stories"
	return ListingItem {
		name = name,
		link = "cat@" .. id .. "@" .. path .. (linkSuffix or ""),
		isIncrementing = true,
		func = function(data)
			return browseStoryList(catUrl, data[PAGE])
		end,
		search = function(data)
			return filterCategory(catUrl, data)
		end,
		searchFilters = searchFilters(),
		searchIsIncrementing = true
	}
end

--- A category with subcategories is a group holding an "All" item plus its
--- children; a leaf category is a plain item.
--- @param node table
--- @return Listing
local function makeCategoryNode(node)
	if #node.children == 0 then
		return makeCategoryListing(node.id, node.path, node.name)
	end
	return ListingList {
		name = node.name,
		link = "cat@" .. node.id .. "@" .. node.path,
		func = function()
			local items = { makeCategoryListing(node.id, node.path, node.name .. " (All)", "@all") }
			for _, child in ipairs(dedupeByUrl(node.children)) do
				table.insert(items, makeCategoryNode(child))
			end
			return items
		end
	}
end

--- @return Listing
local function makeAddByUrlListing()
	return ListingItem {
		name = "Add by URL",
		link = "addByUrl",
		isIncrementing = false,
		func = function()
			return { addByUrlHowInfo() }
		end,
		search = addByUrl,
		searchIsIncrementing = false
	}
end

--- @return Listing
local function makePopularListing()
	return ListingItem {
		name = "Popular Stories",
		link = "popular",
		isIncrementing = true,
		func = function(data)
			return browseStoryList("/stories/popular", data[PAGE])
		end
	}
end

local recentCalendar
--- The site's "Recent" page is a calendar of the dates that have submissions
--- (newest first). Fetch it once and cache the date list.
--- @return table[] @entries {date, name} in newest-first order
local function getRecentCalendar()
	if recentCalendar then
		return recentCalendar
	end
	local document = ClientGetDocument(expandURL("/stories/recent"))
	local links = document:select("table.calendar a")
	recentCalendar = {}
	local seen = {}
	for i = 0, links:size() - 1 do
		local date = links:get(i):attr("href"):match("/stories/recent/([%d]+%-%d+%-%d+)$")
		if date and not seen[date] then
			seen[date] = true
			table.insert(recentCalendar, { date = date, name = date })
		end
	end
	return recentCalendar
end

--- @return Listing
local function makeRecentAllListing()
	return ListingItem {
		name = "All (last 30 days)",
		link = "recent@all",
		isIncrementing = true,
		func = function(data)
			return browseStoryList("/stories/recent/all", data[PAGE])
		end
	}
end

--- @param date string @YYYY-MM-DD
--- @return Listing
local function makeRecentDateListing(date)
	return ListingItem {
		name = date,
		link = "recent@" .. date,
		isIncrementing = true,
		func = function(data)
			return browseStoryList("/stories/recent/" .. date, data[PAGE])
		end
	}
end

--- A group: an "All" item plus one item per date that has submissions.
--- @return Listing
local function makeRecentListing()
	return ListingList {
		name = "Recent Stories",
		link = "recent",
		func = function()
			local items = { makeRecentAllListing() }
			for _, entry in ipairs(getRecentCalendar()) do
				table.insert(items, makeRecentDateListing(entry.date))
			end
			return items
		end
	}
end

--- Search-only: the user types a username, we browse that user's stories.
--- @return Listing
local function makeUserStoriesListing()
	return ListingItem {
		name = "User Stories",
		link = "userStories",
		isIncrementing = false,
		func = function()
			return { userStoriesHowInfo() }
		end,
		search = function(data)
			local username = data[QUERY]:gsub('^%s*(.-)%s*$', '%1')
			if username == "" then
				return {}
			end
			return browseStoryList("/stories/user/" .. username, data[PAGE])
		end,
		searchIsIncrementing = true
	}
end

--- Search-only: the user types a text query, we run the site's story search.
--- @return Listing
local function makeSearchListing()
	return ListingItem {
		name = "Search Stories",
		link = "search",
		isIncrementing = false,
		func = function()
			return { searchHowInfo() }
		end,
		search = function(data)
			local query = data[QUERY]:gsub('^%s*(.-)%s*$', '%1')
			if query == "" then
				return {}
			end
			return searchStories(query, data[PAGE])
		end,
		searchIsIncrementing = true
	}
end

--- @param link string @"" for the root, a fixed listing id ("popular", "recent",
--- "search", "userStories", "addByUrl"), or "cat@<id>@<path>"/"cat@<id>@<path>@all"
--- @return Listing
local function getListing(link)
	if link == "" then
		return ListingList {
			name = "",
			link = "",
			func = function()
				local items = {
					makePopularListing(),
					makeRecentListing(),
				}
				for _, n in ipairs(dedupeByUrl(getCategoryTree())) do
					table.insert(items, makeCategoryNode(n))
				end
				table.insert(items, makeSearchListing())
				table.insert(items, makeUserStoriesListing())
				table.insert(items, makeAddByUrlListing())
				return items
			end
		}
	end
	if link == "popular" then
		return makePopularListing()
	end
	if link == "recent" then
		return makeRecentListing()
	end
	if link == "recent@all" then
		return makeRecentAllListing()
	end
	local recentDate = link:match("^recent@([%d]+%-%d+%-%d+)$")
	if recentDate then
		return makeRecentDateListing(recentDate)
	end
	if link == "search" then
		return makeSearchListing()
	end
	if link == "userStories" then
		return makeUserStoriesListing()
	end
	if link == "addByUrl" then
		return makeAddByUrlListing()
	end
	local id, path = link:match("^cat@(%d+)@(.+)@all$")
	if id then
		local node = findCategory(id, path)
		return makeCategoryListing(id, path, (node and node.name or "Category") .. " (All)", "@all")
	end
	id, path = link:match("^cat@(%d+)@(.+)$")
	if id then
		local node = findCategory(id, path)
		if node then
			return makeCategoryNode(node)
		end
	end
	error("Unknown listing link: " .. link)
end

return {
	id = 1308639967,
	name = "Hentai Foundry",
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
