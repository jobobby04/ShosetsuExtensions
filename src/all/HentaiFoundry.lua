-- {"id":1308639967,"ver":"1.0.0","libVer":"1.3.0","author":"Jobobby04"}

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
	element = tostring(element):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	element = Document(element):selectFirst('body')
	return element
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

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		local how = NovelInfo {
			title = "How to use this source",
			description = "Make sure your logged into webview!!\n\n You can use this source by:\n1. searching on the hentai-foundry.com website and inputting the url of the story in the search bar."
		}
	end

	local document = ClientGetDocument(expandURL(novelURL))
	local title = document:selectFirst(".titlebar > a"):text()
	local summaryElement = document:selectFirst(".story  .storyDescript")
	local summary = ""
	summary = Document(tostring(summaryElement))
	summary:selectFirst(".storyRead"):remove()
	summary:selectFirst(".storyCategoryRating"):remove()
	summary:selectFirst(".storyVote"):remove()
	summary:select("br"):prepend("\\n")
	summary:select("p"):prepend("\\n\\n")
	summary = summary:wholeText():gsub("\\n", "\n"):gsub('^%s*(.-)%s*$', '%1')

	local genres = { summaryElement:selectFirst(".storyCategoryRating .categoryBreadcrumbs"):text() }
	local tags = summaryElement:select(".storyCategoryRating .ratings_box span")
	if tags ~= nil and tags:size() ~= 0 then
		for i = 0, tags:size() - 1 do
			table.insert(genres, tags:get(i):attr("title"))
		end
	end

	local info = NovelInfo {
		title = title,
		description = summary,
		genres = genres,
		authors = { document:selectFirst(".storyInfo > .col1 > a"):text() },
		status = ({
			Complete = NovelStatus.COMPLETED,
			Incomplete = NovelStatus.PUBLISHING
		})[selectLast(document:select(".storyInfo >.col2 > span.indent")):text()]
	}

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

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = filters[PAGE]
	local url = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if page == 1 and shrinkURL(url):match("/stories/user/%a+/%d+") then
		local novelUrl = url:gsub("/chapters.*$", ""):gsub("/$", "")
		local novel = ClientGetDocument(novelUrl):selectFirst(".titlebar > a")
		return {
			NovelInfo {
				title = novel:text(),
				link = novel:attr("href"),
				imageURL = ""
			}
		}
	end

	return {}
end

return {
	id = 1308639967,
	name = "Hentai Foundry",
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

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
