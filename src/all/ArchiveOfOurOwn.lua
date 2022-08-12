-- {"id":-1,"ver":"1.0.0","libVer":"1.0.0","author":"","repo":"","dep":["foo","bar"]}

local baseURL = "https://archiveofourown.org"
local settings = {}

local function shrinkURL(url)
	return url:gsub("^.-archiveofourown%.org", "")
end

local function expandURL(url)
	return baseURL .. url
end

--- @param url string
--- @return Document
local function GETDocumentAdult(url)
	return RequestDocument(
			RequestBuilder()
					:get()
					:url(url)
					:addHeader("Cookie", "view_adult=true")
					:build()
	)
end

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = GETDocumentAdult(expandURL(chapterURL))
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
	chap:select("br:nth-child(even)"):remove()
	chap = tostring(chap):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	chap = Document(chap):selectFirst('body')
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
--- @param document Document
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

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL == "how" then
		return NovelInfo {
			title = "How to use this source",
			description = "You can use this source by searching on the ArchiveOfOurOwn.org website and inputting the url in the search bar."
		}
	end

	local document = GETDocumentAdult(expandURL(novelURL))
	local title = document:selectFirst(".title"):text()
	local summaryElement = document:selectFirst("#workskin div .userstuff:not([role])")
	local summary = ""
	if summaryElement ~= nil then
		summary = summaryElement:text()
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
		v:text()
	end)

	local status = NovelStatus.COMPLETED
	if document:selectFirst(".stats dd.chapters"):text():sub(-#"?") == "?" then
		status = NovelStatus.PUBLISHING
	end

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

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return Novel[]
local function search(filters)
	if filters[PAGE] == 1 then
		local novelUrl = filters[QUERY]:gsub("url:", ""):gsub('^%s*(.-)%s*$', '%1'):gsub("/chapters.*$", "")
		local novel = GETDocumentAdult(novelUrl)

		return {
			Novel {
				title = novel:selectFirst(".title"):text(),
				link = shrinkURL(novelUrl),
				imageURL = ""
			}
		}
	end
	return {}
end

return {
	id = 1308639966,
	name = "ArchiveOfOurOwn",
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
	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
