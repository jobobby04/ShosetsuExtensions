-- {"id":1308639978,"ver":"1.1.0","libVer":"1.1.0","author":"Jobobby04"}

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

	chap:child(0):before("<h1>" .. title .. "</h1>")
	return pageOfElem(chap, true)
end

local function startsWithPattern(mainString, startPattern)
	return mainString:find("^" .. startPattern) == 1
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
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

	local stats = map(
			document:select(".story-header-right div.story-header-stats div"),
			function(v)
				return v
			end
	)


	local genres = {}

	table.insert(
			genres,
			"Category: " .. document
					:select(".story-header-right .story-header-category span")
					:get(1)
					:text()
	)
	for _, v in pairs(stats) do
		local name = v:selectFirst("strong"):text()
		if startsWithPattern(name, "Rating") then
			table.insert(genres, "Rating: " .. v:selectFirst("span"):text())
		end
	end

	map(storyCard:select(".story-card-tags .story-tag"), function(v)
		local tag = v:text()
		table.insert(genres, Tags[tag] or tag)
	end)

	local status = NovelStatus.PUBLISHING
	for _, value in ipairs(genres) do
		if value == "COMPLETE" or value == "Oneshot" then
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

--- @param document Document
--- @param subdomain string
--- @return NovelInfo[]
local function parseStoryEntries(document, subdomain)
	local works = document:select(".story-entry")
	local urlPrefix = subdomain .. ".adult-fanfiction.org/"
	return map(works, function(v)
		local title = v:selectFirst(".story-title")
		return NovelInfo {
			title = title:text(),
			link = urlPrefix .. title:attr("href"),
			imageURL = ""
		}
	end)
end

-- Index 0 is the site default ("Recently Updated")
local SortModes = {
	[1] = "published",
	[2] = "reviews",
	[3] = "recommendations",
	[4] = "reading",
}

--- Appends the active tag and sort filters to a listing URL.
--- @param url string
--- @param data table @applied filter values
--- @return string
local function applyFilters(url, data)
	for i, tag in ipairs(TagsIndexed) do
		local value = data[i + 100] or 0
		if value == 1 then
			url = url .. "&tags[]=" .. tag.key .. "&tag_mode[" .. tag.key .. "]=include"
		elseif value == 2 then
			url = url .. "&tags[]=" .. tag.key .. "&tag_mode[" .. tag.key .. "]=exclude"
		end
	end

	local sort = data[2]
	if sort and sort > 0 then
		local sortMode = SortModes[sort]
		if sortMode then
			url = url .. "&sort=" .. sortMode
		end
	end

	return url
end

--- @param subdomain string
--- @param data table @contains [PAGE]
--- @return NovelInfo[]
local function browseStories(subdomain, data)
	local url = "https://" .. subdomain .. ".adult-fanfiction.org/index.php"
	url = addPage(url, data[PAGE])
	local document = GETDocumentAdult(url)
	return parseStoryEntries(document, subdomain)
end

--- Searches a fandom subdomain. The query may be a pasted site URL,
--- a plain-text title search, or empty (falls back to the default listing).
--- @param subdomain string
--- @param data table @contains [QUERY], [PAGE] and filter values
--- @return NovelInfo[]
local function searchStories(subdomain, data)
	local query = (data[QUERY] or ""):gsub('^%s*(.-)%s*$', '%1')

	local url
	if query:match("adult%-fanfiction%.org") then
		url = query
	elseif query ~= "" then
		url = "https://" .. subdomain .. ".adult-fanfiction.org/advancedsearch.php?title=" .. query
	else
		url = "https://" .. subdomain .. ".adult-fanfiction.org/index.php"
	end

	url = applyFilters(addPage(removePage(url), data[PAGE]), data)
	local document = GETDocumentAdult(url)
	return parseStoryEntries(document, subdomain)
end

local subdomainNames = {}

--- @return table[] @of {subdomain: string, name: string}
local function getSubdomains()
	local document = GETDocumentAdult("https://www.adult-fanfiction.org/")
	local links = document:select(".menu-main a[href*='.adult-fanfiction.org']")
	local subdomains = {}
	local seen = {}
	for i = 0, links:size() - 1 do
		local a = links:get(i)
		local href = a:attr("href")
		local subdomain = href:match("^https?://([^/]+)%.adult%-fanfiction%.org")
		if subdomain and subdomain ~= "www" and not seen[subdomain] then
			seen[subdomain] = true
			local name = a:selectFirst(".menu-text")
			local displayName = (name and name:text()) or subdomain
			subdomainNames[subdomain] = displayName
			table.insert(subdomains, {
				subdomain = subdomain,
				name = displayName
			})
		end
	end
	return subdomains
end

--- @param subdomain string
--- @return string
local function getSubdomainName(subdomain)
	if subdomainNames[subdomain] then
		return subdomainNames[subdomain]
	end
	getSubdomains()
	return subdomainNames[subdomain] or subdomain
end

--- @return Filter[]
local function searchFilters()
	local filters = {}
	for i, tag in ipairs(TagsIndexed) do
		table.insert(
				filters,
				TriStateFilter(
						i + 100,
						tag.value
				)
		)
	end

	return {
		DropdownFilter(
				2,
				"Sort",
				{
					"Recently Updated",
					"Recently Published",
					"Most Reviews",
					"Most Recommended",
					"Most Reading"
				}
		),
		FilterGroup("Tags", filters)
	}
end

--- @param subdomain string
--- @param name string?
--- @return Listing
local function makeSubdomainListing(subdomain, name)
	return ListingItem {
		name = name or getSubdomainName(subdomain),
		link = subdomain,
		isIncrementing = true,
		func = function(data)
			return browseStories(subdomain, data)
		end,
		search = function(data)
			return searchStories(subdomain, data)
		end,
		searchFilters = searchFilters(),
		searchIsIncrementing = true
	}
end

--- @param link string @"" for the root, otherwise a fandom subdomain
--- @return Listing
local function getListing(link)
	if link == "" then
		return ListingList {
			name = "",
			link = "",
			func = function()
				return map(getSubdomains(), function(v)
					return makeSubdomainListing(v.subdomain, v.name)
				end)
			end
		}
	end
	return makeSubdomainListing(link)
end

return {
	id = 1308639978,
	name = "AdultFanFiction",
	baseURL = baseURL,

	imageURL = "",
	hasCloudFlare = true,

	---@diagnostic disable-next-line: undefined-global
	chapterType = ChapterType.HTML,

	getListing = getListing,

	getPassage = getPassage,
	parseNovel = parseNovel,

	settings = {},
	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
