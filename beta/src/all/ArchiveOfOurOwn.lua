-- {"id":1308639966,"ver":"1.0.6","libVer":"1.3.0","author":"Jobobby04"}

local baseURL = "https://archiveofourown.org"
local settings = {}

---@type OkHttpClient
local client = HttpClientBuilder()
		--:addInterceptor(enterAgreeInterceptor)
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
	return url:gsub("^.-archiveofourown%.org", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	element = tostring(element):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	element = Document(element):selectFirst('body')
	local removeJustifyAttributes = settings[1]
	if removeJustifyAttributes ~= nil and removeJustifyAttributes then
		local pElements = element:select("p[align]")
		for i = 0, pElements:size() - 1 do
			if pElements:get(i):attr("align") == "justify" then
				pElements:get(i):removeAttr("align")
			end
		end
	end

	return element
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = ClientGetDocument(expandURL(chapterURL))
	local chap = document:selectFirst("#workskin div.userstuff")
	local title
	local titleDoc = document:selectFirst("#workskin .chapter .title")
	if titleDoc ~= nil then
		title = titleDoc:text()
	else
		title = document:selectFirst("#workskin .title"):text()
	end
	local summary = document:selectFirst("#workskin .summary")
	local notes = document:selectFirst("#workskin .notes[role=\"complementary\"]")
	local endNotes = document:selectFirst("#workskin .chapter .end")
	-- This is for the sake of consistant styling
	chap:select(".landmark"):remove()
	chap = cleanupDocument(chap)
	-- Adds Chapter Title

	if notes ~= nil then
		chap:child(0):before(notes)
	end
	if summary ~= nil then
		chap:child(0):before(summary)
	end
	chap:child(0):before("<h1>" .. title .. "</h1>")
	if endNotes ~= nil then
		chap:appendChild(endNotes)
	end
	return pageOfElem(chap, true)
end

--- @param genres string[]
--- @param document Node
--- @param selector string
--- @param prefix string
local function addTags(genres, document, selector, prefix)
	local tags = document:select(selector)
	if tags ~= nil and tags:size() ~= 0 then
		for i = 0, tags:size() - 1 do
			table.insert(genres, prefix .. tags:get(i):text())
		end
	end
end

local function readStatus(document)
	local status = NovelStatus.COMPLETED
	local statusElement = document:selectFirst(".stats dd.chapters"):text()
	if statusElement:sub(-#"?") == "?" then
		status = NovelStatus.PUBLISHING
	else
		local chapterCount, finishedChapterCount = statusElement:match("^(.+)/(.+)$")
		if chapterCount ~= finishedChapterCount then
			status = NovelStatus.PUBLISHING
		end
	end
	return status
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		return NovelInfo {
			title = "How to use this source v2",
			description = "You can use this source by:\n1. searching on the ArchiveOfOurOwn.org website and inputting the url of the work in the search bar.\n2. Setting your queries on the ArchiveOfOurOwn.org website and copying the search to the search bar."
		}
	end

	local document = ClientGetDocument(expandURL(novelURL) .. "?view_adult=true")
	local title = document:selectFirst(".title"):text()
	local summaryElement = document:selectFirst("#workskin div .userstuff:not([role])")
	local summary = ""
	if summaryElement ~= nil then
		summary = Document(tostring(summaryElement))
		summary:select("br"):prepend("\\n")
		summary:select("p"):prepend("\\n\\n")
		summary = summary:wholeText():gsub("\\n", "\n"):gsub('^%s*(.-)%s*$', '%1'):gsub('\n%s+', '\n')
	end
	local genres = {}

	local rating = document:selectFirst(".rating .tag")
	if rating ~= nil then
		table.insert(genres, "rating: " .. rating:text())
	end

	addTags(genres, document, ".warning .tag", "warning: ")
	addTags(genres, document, ".category .tag", "category: ")
	addTags(genres, document, ".fandom .tag", "fandom: ")
	addTags(genres, document, ".relationship .tag", "relationship: ")
	addTags(genres, document, ".character .tag", "character: ")
	addTags(genres, document, ".freeform .tag", "tag: ")

	local language = document:selectFirst("dd.language")
	if language ~= nil then
		table.insert(genres, "language: " .. language:text())
	end

	local authors = map(document:select("#workskin h3.byline a[rel=\"author\"]"), function(v)
		return v:text()
	end)

	local status = readStatus(document)

	local info = NovelInfo {
		title = title,
		description = summary,
		genres = genres,
		authors = authors,
		status = status,
	}

	if loadChapters then
		local chaptersDocument = document:select("option, .actions option, form code")
		local chapters
		if chaptersDocument ~= nil and chaptersDocument:size() ~= 0 then
			chapters = map(chaptersDocument, function(v, i)
				return NovelChapter {
					order = i,
					title = v:text(),
					link =  novelURL .. "/chapters/" .. v:attr("value")
				}
			end)
		else
			chapters = {
				NovelChapter {
					order = 1,
					title = title,
					link = novelURL
				}
			}
		end

		info:setChapters(AsList(chapters))
	end

	return info
end

local function removePage(url)
	return url:gsub("&page=%d+", ""):gsub("?page=%d+&", "?"):gsub("?page=%d+", "")
end

local function addPage(url, page)
	if url:match("?[^/]+$") then
		return url .. "&page=" .. page
	else
		return url .. "?page=" .. page
	end
end

local function getSubItemOrNil(selector, element)
	local item = element:selectFirst(selector)
	if item then
		local text = item:text():gsub(',', ''):gsub("/.*$", ''):gsub("%s", '')
		return tonumber(text)
	end
end

---@param element Element
---@return NovelInfo
local function parseBrowseNovel(element)
	local title = element:selectFirst("h4.heading > a:first-child")
	local authors = map(element:select("h4.heading > a[rel=\"author\"]"), function(v)
		return v:text()
	end)

	local genres = {}

	local languageElement = element:selectFirst(".stats dd.language")
	local language = ""
	if languageElement ~= nil then
		language = languageElement:text()
	end

	addTags(genres, element, ".required-tags .rating span", "")
	addTags(genres, element, ".required-tags .category span", "")
	addTags(genres, element, ".fandoms a.tag", "")
	addTags(genres, element, "li.warnings", "")
	addTags(genres, element, "li.relationships", "")
	addTags(genres, element, "li.characters", "")
	addTags(genres, element, "li.freeforms", "")

	local words = getSubItemOrNil(".stats dd.words", element)
	local chapters = getSubItemOrNil(".stats dd.chapters", element)
	local comments = getSubItemOrNil(".stats dd.comments", element)
	local faves = getSubItemOrNil(".stats dd.bookmarks", element)
	local views = getSubItemOrNil(".stats dd.hits", element)

	local status = readStatus(element)

	local summaryElement = element:selectFirst(".summary")
	local summary = ""
	if summaryElement ~= nil then
		summary = Document(tostring(summaryElement))
		summary = summary:wholeText():gsub("\\n", "\n"):gsub('^%s*(.-)%s*$', '%1'):gsub('\n%s+', '\n')
	end

	local seriesElement = element:selectFirst(".series")
	if seriesElement ~= nil then
		summary = summary .. "\n" .. seriesElement:text()
	end

	return NovelInfo {
		title = title:text(),
		link = shrinkURL(title:attr("href")),
		imageURL = "",
		description = summary,
		genres = genres,
		status = status,
		authors = authors,
		language = language,
		wordCount = words,
		chapterCount = chapters,
		commentCount = comments,
		favoriteCount = faves,
		viewCount = views
	}
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = filters[PAGE]
	local url = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if page == 1 and shrinkURL(url):match("/works/%d+") then
		local novelUrl = url:gsub("/chapters.*$", ""):gsub("/$", "")
		local novel = ClientGetDocument(novelUrl)
		return {
			NovelInfo {
				title = novel:selectFirst(".title"):text(),
				link = shrinkURL(novelUrl),
				imageURL = ""
			}
		}
	end

	if shrinkURL(url):match("tags/.+/works") then
		local newUrl = addPage(removePage(url), page)
		local document = ClientGetDocument(newUrl)
		local works = document:select(".work > li")

		return map(works, function(v)
			return parseBrowseNovel(v)
		end)
	end
	if shrinkURL(url):match("works") then
		local newUrl = addPage(removePage(url), page)
		local document = ClientGetDocument(newUrl)
		local works = document:select(".work > li")

		return map(works, function(v)
			return parseBrowseNovel(v)
		end)
	end
	return {}
end

return {
	id = 1308639966,
	name = "ArchiveOfOurOwn",
	baseURL = baseURL,

	-- Optional values to change
	imageURL = "",
	hasCloudFlare = true,
	hasSearch = true,

	chapterType = ChapterType.HTML,


	-- Must have at least one value
	listings = {
		Listing("Nothing", false, function(data)
			return {
				NovelInfo {
					title = "How to use this source",
					link = "how.v2",
					imageURL = ""
				}
			}
		end),
	},

	-- Default functions that have to be set
	getPassage = getPassage,
	parseNovel = parseNovel,
	search = search,

	settings = {
		SwitchFilter(1, "Remove all Justify attributes"),
	},
	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
