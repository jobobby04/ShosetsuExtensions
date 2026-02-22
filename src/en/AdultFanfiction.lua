-- {"id":1308639978,"ver":"1.0.0","libVer":"1.0.0","author":"Jobobby04"}

local baseURL = "https://www.adult-fanfiction.org"
local settings = {}

local function shrinkURL(url)
	local subdomain, rest = url:match(
		"^https?://([^./]+)%.?adult%-fanfiction%.org(/.*)$"
	)
	return (subdomain or "www") .. "@" .. (rest or "/")
end

local function expandURL(shrunkUrl)
	return "https://" .. shrunkUrl:gsub("@", ".adult-fanfiction.org")
end

--- @param url string
--- @return Document
local function GETDocumentAdult(url)
	return RequestDocument(
			RequestBuilder()
					:get()
					:url(url)
					:addHeader("Cookie", "age_verified=1")
					:build()
	)
end

--- @param element Element
--- @return Element
local function cleanupDocument(element)
	element = tostring(element):gsub('<div', '<p'):gsub('</div', '</p'):gsub('<br>', '</p><p>')
	element = Document(element):selectFirst('body')
	return element
end

local Tags =  {
	["3Plus"] = "Threesomes/Moresomes",
	["ABDL"] = "Adult Baby Diaper Lover",
	["Abortion"] = "Abortion",
	["Abuse"] = "Abuse",
	["AFFO"] = "AFFO Exclusive",
	["Ageplay"] = "Ageplay - Age based play",
	["AI-AS"] = "AI story development",
	["AI-BS"] = "AI story brainstorming",
	["AI-SGT"] = "AI spelling",
	["Anal"] = "Anal",
	["Angst"] = "Angst",
	["Anthro"] = "Anthro",
	["BDSM"] = "BDSM",
	["Beast"] = "Bestiality",
	["Bi"] = "Bisexuality",
	["Bigotry"] = "Bigotry",
	["BMod"] = "Body modification",
	["Bond"] = "Bondage",
	["BP"] = "Blood Play",
	["CBT"] = "Cock/Ball Torture",
	["ChallengeFic"] = "ChallengeFic",
	["COMPLETE"] = "COMPLETE",
	["Contro"] = "Controversial",
	["CR"] = "Corruption",
	["Cuck"] = "Cuckold",
	["Cuckquean"] = "Cuckquean",
	["Dom"] = "Male or Female Domination",
	["DP"] = "Double Penetration",
	["Ds"] = "Dominance/submission",
	["Exhib"] = "Exhibitionism",
	["FD"] = "Futanari/Dickgirls",
	["Fet"] = "Fetish",
	["FF"] = "F/F",
	["Fingering"] = "Fingering",
	["Fist"] = "Fisting",
	["GB"] = "Gender Bender",
	["HC"] = "Hurt/Comfort",
	["Herm"] = "Hermaphrodite",
	["HJ"] = "Handjob",
	["Hum"] = "Humanoid",
	["Humil"] = "Humiliation",
	["Inc"] = "Incest",
	["loli"] = "Loli",
	["MBP"] = "Menstrual blood play",
	["MC"] = "Mind Control",
	["MCD"] = "Main Character Death",
	["MF"] = "M/F",
	["MiCD"] = "Minor Character Death",
	["Minor1"] = "Minor under 14",
	["Minor2"] = "Minor over 14",
	["MM"] = "M/M",
	["MPreg"] = "Male Pregnancy",
	["Ms"] = "Master/slave",
	["Nec"] = "Necrophilia",
	["Non-Fic"] = "Non Fiction",
	["NoSex"] = "No Sexual Content",
	["OC"] = "Original Character",
	["Oneshot"] = "Oneshot",
	["Oral"] = "Oral sex",
	["Other"] = "Other",
	["Parody"] = "Parody",
	["Peg"] = "Pegging",
	["Preg"] = "Pregnancy",
	["PWP"] = "Porn without Plot",
	["Racist"] = "Racism",
	["Rape"] = "Rape",
	["Rim"] = "Rimming",
	["SandM"] = "Sadism/Masochism",
	["Scat"] = "Scat",
	["SH"] = "Sexual Harassment",
	["Shouta"] = "Shota",
	["SI"] = "Self-Insertion",
	["Slave"] = "Slavery",
	["Solo"] = "Masturbation",
	["Spank"] = "Spanking",
	["TBDL"] = "Teen Baby Diaper Lover",
	["Tent"] = "Tentacles",
	["TF"] = "Transformation",
	["Tort"] = "Torture",
	["Toys"] = "Sex toys",
	["Trans"] = "Transgender",
	["UST"] = "Unresolved Sexual Tension",
	["Violence"] = "Violence",
	["Voy"] = "Voyeurism",
	["WAFF"] = "Warm and Fuzzy Feeling",
	["WD"] = "Wet Dream",
	["WIP"] = "Work In Progress",
	["WS"] = "Water-sports",
	["Xeno"] = "Xenophilia"
}

local TagsIndexed = {}
for k, v in pairs(Tags) do
	table.insert(TagsIndexed, {key = k, value = v})
end
table.sort(TagsIndexed, function(a, b) return a.value < b.value end)

--- @param chapterURL string
--- @return string
local function getPassage(chapterURL)
	local document = GETDocumentAdult(expandURL(chapterURL))
	local title = document:selectFirst(".chapter-content-card .chapter-title"):text()
	local chap = document:selectFirst(".chapter-content-card .chapter-body")
	chap = cleanupDocument(chap)

	chap:child(0):before("<h1>" .. title .. "</h1>")
	return pageOfElem(chap, true)
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL:match("^how") then
		return NovelInfo {
			title = "How to use this source v2",
			description = "You can use this source by:\n1. searching on the adult-fanfiction.org website and inputting the url of the work in the search bar.\n2. Setting your queries on the adult-fanfiction.org website and copying the search to the search bar."
		}
	end

	local fullUrl = expandURL(novelURL)
	local document = GETDocumentAdult(fullUrl)
	local storyId = fullUrl:match("no=(%d+)")
	local title = document:selectFirst(".story-header-left > h1"):text()
	local authorElement = document:selectFirst(".story-header-author > a")
	local author = authorElement:text()
	local subdomain = fullUrl:match("^https?://([^/]+)"):match("^([^.]+)%.")
	local authorId = authorElement:attr("href"):match("id=(%d+)")
	local authorStories = GETDocumentAdult(
		"https://members.adult-fanfiction.org/load-user-stories.php?subdomain=" .. subdomain .. "&uid=" .. authorId
	)

	local storyCard = authorStories:selectFirst("a[href*='story.php?no=" .. storyId .. "']")
			:parent() -- <h3>
			:parent() -- <div class="story-card-header">
			:parent()
			:parent()

	local summary = storyCard:selectFirst(".story-card-description"):wholeText()
		:gsub('^%s*(.-)%s*$', '%1')

	local genres = map(storyCard:select(".story-card-tags .story-tag"), function(v)
		local tag = v:text()
		return Tags[tag] or tag
	end)

	local status = NovelStatus.PUBLISHING
	for _, value in ipairs(genres) do
		if value == "COMPLETE" then
			status = NovelStatus.COMPLETED
			break
		end
	end

	local info = NovelInfo {
		title = title,
		description = summary,
		genres = genres,
		authors = { author },
		status = status,
	}

	if loadChapters then
		local chaptersDocument = document:selectFirst(".chapter-select"):select("option")
		local chapters
		if chaptersDocument ~= nil then
			chapters = map(chaptersDocument, function(v, i)
				return NovelChapter {
					order = i,
					title = v:text(),
					link = novelURL .. "&chapter=" .. v:attr("value")
				}
			end)
		else
			chapters = {}
		end

		info:setChapters(AsList(chapters))
	end

	print(info)

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

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return Novel[]
local function search(filters)
	local page = filters[PAGE]
	local url = filters[QUERY]:gsub('^%s*(.-)%s*$', '%1')
	local shrunkUrl = shrinkURL(url)
	if page == 1 and shrunkUrl:match("@?[^/]*story%.php%?no=") then
		local novelUrl = url:gsub("&chapter=%d+", ""):gsub("?chapter=%d+&", "?"):gsub("?chapter=%d+", "")
		local novel = GETDocumentAdult(novelUrl)
		return {
			Novel {
				title = novel:selectFirst(".story-header-left > h1"):text(),
				link = shrinkURL(novelUrl),
				imageURL = ""
			}
		}
	end

	local subdomain = shrunkUrl:match("^@?(%w+)@/$")
	if shrunkUrl:match("@?[^?]*?cat=%d+") or (subdomain and subdomain ~= "www") then
		local newUrl = addPage(removePage(url), page)
		for i, tag in ipairs(TagsIndexed) do
			local value = filters[i + 2] or 0
			if value == 1 then
				newUrl = newUrl .. "&tags[]=" .. tag.key .. "&tag_mode[" .. tag.key .. "]=include"
			elseif value == 2 then
				newUrl = newUrl .. "&tags[]=" .. tag.key .. "&tag_mode[" .. tag.key .. "]=exclude"
			end
		end

		local document = GETDocumentAdult(newUrl)
		local works = document:select(".story-entry")

		local urlPrefix = shrunkUrl:match("^([^.]+)%@") .. ".adult-fanfiction.org/"
		return map(works, function(v)
			local title = v:selectFirst(".story-title")
			return Novel {
				title = title:text(),
				link = urlPrefix .. title:attr("href"),
				imageURL = ""
			}
		end)
	end
	return {}
end

local function searchFilters()
	local filters = {}
	for i, tag in ipairs(TagsIndexed) do
		table.insert(
				filters,
				TriStateFilter(
						i + 2,
						tag.value
				)
		)
	end

	return {
		DropdownFilter(999, "Tags", filters)
	}
end

return {
	id = 1308639978,
	name = "AdultFanfiction",
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
				Novel {
					title = "How to use this source",
					link = "how.v1",
					imageURL = ""
				}
			}
		end),
	},

	-- Default functions that have to be set
	getPassage = getPassage,
	parseNovel = parseNovel,
	search = search,

	settings = {},
	updateSetting = function(id, value)
		settings[id] = value
	end,

	searchFilters = searchFilters(),

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
