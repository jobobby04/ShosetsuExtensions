-- {"id":1308639977,"ver":"1.0.2","libVer":"1.3.0","author":"Jobobby04","dep":["dkjson>=1.0.1"]}

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
	local chap = cleanupDocument(document:selectFirst("#mcstories"))
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
	for _, tag in ipairs(Tags) do
		if tag.name == name then
			return tag.value
		end
	end
	return nil
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

	local title = document:selectFirst("#mcstories > .title"):text()
	local author = document:selectFirst("#mcstories > .byline > a"):text()
	local description = document:selectFirst("#mcstories > section.synopsis"):wholeText()
	getSvengaliTagsIfNeeded()
	local tags = SvengaliGETDocument("https://www.gregariousfrog.com/svengali/servers/GetTitleTags.php?titleurl=" .. novelURL:match("/([^/]+)/index%.html$"))
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
		genres = map(tags["TitleTags"], function(v)
			return tagFullName(idToTag(v))
		end),
		wordCount = wordCount
	}

	if loadChapters then
		info:setChapters(AsList(chapters))
	end

	print(info)

	return info
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	local page = filters[PAGE]
	local url = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	if page == 1 and shrinkURL(url):match("index.html") then
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

	if page > 1 then
		return {}
	end

	local categoryNumber = tonumber(filters[2])
	if categoryNumber > 1 then
		local category = Tags[categoryNumber]
		local document = ClientGetDocument("https://mcstories.com/Tags/" .. category.name .. ".html")
		return map(document:select("tbody > tr"), function(v)
			local items = v:select("td")
			local tags = {}
			for i in items:get(1):text():gmatch("%S+") do
				table.insert(tags, mapTag(i))
			end
			return NovelInfo {
				title = items:get(0):select("a"):text(),
				link = items:get(0):select("a"):attr("href"):gsub("%.%.", ""),
				genres = tags
			}
		end)
	end

	return {}
end


local function searchFilters()
	local categoryOptions = {
		"None",
	}
	for i in pairs(Tags) do
		table.insert(categoryOptions, Tags[i].value)
	end

	return {
		DropdownFilter(
			2,
			"Category",
			categoryOptions
		),
	}
end

return {
	id = 1308639977,
	name = "MCStories",
	baseURL = baseURL,

	-- Optional values to change
	imageURL = "",
	hasCloudFlare = false,
	hasSearch = true,

	chapterType = ChapterType.HTML,

	-- Must have at least one value
	listings = {
		Listing("Whats New", false, function(data)
			getSvengaliTagsIfNeeded()
			local document = ClientGetDocument("https://mcstories.com/WhatsNew.html")
			return map(document:select("div.story"), function(v)
				local items = v:select("div")
				local tags = {}
				for i in items:get(1):text():match("%((.-)%)"):gmatch("%S+") do
					table.insert(tags, mapTag(i))
				end
				return NovelInfo {
					title = items:get(0):select("a"):text(),
					link = "/" .. items:get(0):select("a"):attr("href"),
					authors = { items:get(1):select("a"):text() },
					description = v:selectFirst("div.synopsis"):text(),
					genres = tags
				}
			end)
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
