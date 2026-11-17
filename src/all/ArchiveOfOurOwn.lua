-- {"id":1308639966,"ver":"1.0.18","libVer":"1.1.0","author":"Jobobby04"}

local baseURL = "https://archiveofourown.org"
local settings = {}

-- Shared choices
-- Browse sort: defaults to Date Updated (matches AO3 browse pages)
local B_SORT_COLUMNS = {
	"Date Updated", "Date Posted", "Creator", "Title",
	"Word Count", "Hits", "Kudos", "Comments", "Bookmarks",
}
local B_SORT_COLUMN_VALUES = {
	"revised_at", "created_at", "authors_to_sort_on", "title_to_sort_on",
	"word_count", "hits", "kudos_count", "comments_count", "bookmarks_count",
}
-- Search sort: defaults to Best Match / relevance (matches AO3 search)
local S_SORT_COLUMNS = {
	"Best Match", "Creator", "Title", "Date Posted", "Date Updated",
	"Word Count", "Hits", "Kudos", "Comments", "Bookmarks",
}
local S_SORT_COLUMN_VALUES = {
	"_score", "authors_to_sort_on", "title_to_sort_on", "created_at", "revised_at",
	"word_count", "hits", "kudos_count", "comments_count", "bookmarks_count",
}
local COMPLETIONS = { "All", "Complete", "Incomplete" }
local COMPLETE_VALUES = { "", "T", "F" }

-- Browse page filter IDs (/works, /tags/.../works)
local FID_B_SORT = 2
local FID_B_COMPLETE = 3
local FID_B_CROSSOVER = 4
local FID_B_WORDS_FROM = 5
local FID_B_WORDS_TO = 6
local FID_B_DATE_FROM = 7
local FID_B_DATE_TO = 8
local FID_B_QUERY = 9
local FID_B_LANGUAGE = 10
-- Include tags
local FID_B_INC_RATING = 11
local FID_B_INC_WARN_CREATOR = 12
local FID_B_INC_WARN_NONE = 13
local FID_B_INC_WARN_VIOLENCE = 14
local FID_B_INC_WARN_DEATH = 15
local FID_B_INC_WARN_NONCON = 16
local FID_B_INC_WARN_UNDERAGE = 17
local FID_B_INC_CAT_GEN = 18
local FID_B_INC_CAT_FM = 19
local FID_B_INC_CAT_MM = 20
local FID_B_INC_CAT_FF = 21
local FID_B_INC_CAT_MULTI = 22
local FID_B_INC_CAT_OTHER = 23
local FID_B_INC_OTHER_TAGS = 24
-- Exclude tags
local FID_B_EXC_RATING_NOTRATED = 25
local FID_B_EXC_RATING_GA = 26
local FID_B_EXC_RATING_T = 27
local FID_B_EXC_RATING_M = 28
local FID_B_EXC_RATING_E = 29
local FID_B_EXC_WARN_CREATOR = 30
local FID_B_EXC_WARN_NONE = 31
local FID_B_EXC_WARN_VIOLENCE = 32
local FID_B_EXC_WARN_DEATH = 33
local FID_B_EXC_WARN_NONCON = 34
local FID_B_EXC_WARN_UNDERAGE = 35
local FID_B_EXC_CAT_GEN = 36
local FID_B_EXC_CAT_FM = 37
local FID_B_EXC_CAT_MM = 38
local FID_B_EXC_CAT_FF = 39
local FID_B_EXC_CAT_MULTI = 40
local FID_B_EXC_CAT_OTHER = 41
local FID_B_EXC_OTHER_TAGS = 42

-- Crossovers is a 3-way radio on the browse form (include / exclude / only)
local B_CROSSOVER_CHOICES = { "Include crossovers", "Exclude crossovers", "Show only crossovers" }
local B_CROSSOVER_VALUES = { "", "F", "T" }

-- Include Ratings is a single-select radio on the browse form
local B_INC_RATING_CHOICES = { "Not Rated", "General Audiences", "Teen And Up", "Mature", "Explicit" }
local B_INC_RATING_IDS = { "9", "10", "11", "12", "13" }

-- Checkbox filter id -> AO3 tag id. Include and exclude share the same ids.
local B_INC_WARNING_IDS = {
	[FID_B_INC_WARN_CREATOR] = "14",
	[FID_B_INC_WARN_NONE] = "16",
	[FID_B_INC_WARN_VIOLENCE] = "17",
	[FID_B_INC_WARN_DEATH] = "18",
	[FID_B_INC_WARN_NONCON] = "19",
	[FID_B_INC_WARN_UNDERAGE] = "20",
}
local B_EXC_WARNING_IDS = {
	[FID_B_EXC_WARN_CREATOR] = "14",
	[FID_B_EXC_WARN_NONE] = "16",
	[FID_B_EXC_WARN_VIOLENCE] = "17",
	[FID_B_EXC_WARN_DEATH] = "18",
	[FID_B_EXC_WARN_NONCON] = "19",
	[FID_B_EXC_WARN_UNDERAGE] = "20",
}
local B_INC_CATEGORY_IDS = {
	[FID_B_INC_CAT_GEN] = "21",
	[FID_B_INC_CAT_FM] = "22",
	[FID_B_INC_CAT_MM] = "23",
	[FID_B_INC_CAT_FF] = "116",
	[FID_B_INC_CAT_MULTI] = "2246",
	[FID_B_INC_CAT_OTHER] = "24",
}
local B_EXC_CATEGORY_IDS = {
	[FID_B_EXC_CAT_GEN] = "21",
	[FID_B_EXC_CAT_FM] = "22",
	[FID_B_EXC_CAT_MM] = "23",
	[FID_B_EXC_CAT_FF] = "116",
	[FID_B_EXC_CAT_MULTI] = "2246",
	[FID_B_EXC_CAT_OTHER] = "24",
}
local B_EXC_RATING_IDS = {
	[FID_B_EXC_RATING_NOTRATED] = "9",
	[FID_B_EXC_RATING_GA] = "10",
	[FID_B_EXC_RATING_T] = "11",
	[FID_B_EXC_RATING_M] = "12",
	[FID_B_EXC_RATING_E] = "13",
}

local B_LANGUAGE_CHOICES = {
"Any",
	"af Soomaali",
	"Afrikaans",
	"𒀝𒅗𒁺𒌑",
	"العربية",
	"American Sign Language",
	"𓂋𓏺𓈖 𓆎𓅓𓏏𓊖",
	"Ἑλληνικὴ φωνή",
	"Anishinaabemowin",
	"ܐܪܡܝܐ | ארמיא",
	"հայերեն",
	"asturianu",
	"Aynu itak | アイヌ イタㇰ",
	"Azərbaycan dili | آذربایجان دیلی",
	"Bahasa Indonesia",
	"Bahasa Malaysia",
	"Български",
	"বাংলা",
	"Basa Jawa",
	"ᮘᮞ ᮞᮥᮔ᮪ᮓ | Basa Sunda",
	"Башҡорт теле",
	"беларуская",
	"Boarisch",
	"Bosanski",
	"Brezhoneg",
	"British Sign Language",
	"Буряад хэлэн | ᠪᠤᠷᠢᠶᠠᠳ ᠮᠣᠩᠭᠣᠯ ᠬᠡᠯᠡ",
	"Català",
	"Cebuano",
	"Čeština",
	"Chinuk Wawa",
	"Чӑваш чӗлхи",
	"Creolese",
	"Cymraeg",
	"Dansk",
	"Deutsch",
	"ދިވެހި,",
	"eesti keel",
	"Ελληνικά",
	"𒅴𒂠",
	"Eald Englisċ",
	"English",
	"Español",
	"Esperanto",
	"Euskara",
	"فارسی",
	"Filipino",
	"Finuʼ Chamorro",
	"Vlaams Nederlands",
	"Français",
	"Friisk",
	"Frysk",
	"Furlan",
	"Gaeilge",
	"Gàidhlig",
	"Galego",
	"𐌲𐌿𐍄𐌹𐍃𐌺𐌰",
	"한국어",
	"Hausa | هَرْشَن هَوْسَ",
	"हिन्दी",
	"Hmoob dawb",
	"Hrvatski",
	"ʻŌlelo Hawaiʻi",
	"Interlingua",
	"isiZulu",
	"Íslenska",
	"Italiano",
	"עברית",
	"Kalaallisut",
	"Хальмг Өөрдин келн",
	"Kanienʼkéha",
	"ಕನ್ನಡ",
	"ქართული",
	"Kernewek",
	"ភាសាខ្មែរ",
	"Khuzdul",
	"Kiswahili",
	"kreyòl ayisyen",
	"Kurdî | کوردی",
	"Кыргызча",
	"Ladino / לאדינו",
	"Langue des signes québécoise",
	"Latviešu valoda",
	"Lëtzebuergesch",
	"Lietuvių kalba",
	"Lingua latina",
	"Magyar",
	"македонски",
	"മലയാളം",
	"Malti",
	"ᠮᠠᠨᠵᡠ ᡤᡳᠰᡠᠨ",
	"Mando'a",
	"मराठी",
	"Mi'kmaq",
	"Middel Englisch",
	"Mikisúkî",
	"Moob leeg",
	"ᠮᠣᠩᠭᠣᠯ ᠪᠢᠴᠢᠭ᠌ | Монгол Кирилл үсэг",
	"မြန်မာဘာသာ",
	"Lìʼfya leNaʼvi",
	"Nāhuatl",
	"Nawat",
	"Nederlands",
	"日本語",
	"Norsk",
	"Нохчийн мотт",
	"O’odham Ñiok",
	"لسان عثمانى",
	"پښتو",
	"Pennsilfaanisch Deitsch",
	"Plattdüütsch",
	"Polski",
	"Português brasileiro",
	"Português europeu",
	"Pulaar",
	"ਪੰਜਾਬੀ",
	"qazaqşa | қазақша",
	"Quenya",
	"Română",
	"RRomani Ćhib",
	"Русский",
	"Sámi",
	"саха тыла",
	"Scots",
	"Shqip",
	"Sindarin",
	"සිංහල",
	"Slovenčina",
	"Slovenščina",
	"Slověnьskъ Językъ",
	"Sprēkō Þiudiskō",
	"Српски",
	"suomi",
	"Svenska",
	"தமிழ்",
	"te reo Māori",
	"తెలుగు",
	"ትግርኛ",
	"ไทย",
	"Thermian",
	"བོད་སྐད་",
	"Tiếng Việt",
	"ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ",
	"tlhIngan-Hol",
	"Tok Pisin",
	"toki pona",
	"Trinidadian Creole",
	"τσακώνικα",
	"ᏣᎳᎩ ᎦᏬᏂᎯᏍᏗ",
	"Türkçe",
	"Українська",
	"Unangam Tunuu",
	"Uncategorized Constructed Languages",
	"اُردُو",
	"ئۇيغۇر تىلى",
	"O'zbekcha",
	"Volapük",
	"Walon",
	"יידיש",
	"maayaʼ tʼàan",
	"къырымтатар тили | qırımtatar tili",
	"татар теле",
	"Эрзянь кель",
	"አማርኛ",
	"中文-吴语",
	"中文-客家话",
	"中文-广东话 粵語",
	"中文-普通话 國語",
	"中文-闽南话 臺語",
}

local B_LANGUAGE_VALUES = {
"",
	"so",
	"afr",
	"akk",
	"ar",
	"ase",
	"egy",
	"grc",
	"oji",
	"arc",
	"hy",
	"ast",
	"ain",
	"azj",
	"id",
	"ms",
	"bg",
	"bn",
	"jv",
	"sun",
	"ba",
	"be",
	"bar",
	"bos",
	"br",
	"bfi",
	"bua",
	"ca",
	"ceb",
	"cs",
	"chn",
	"chv",
	"gyn",
	"cy",
	"da",
	"de",
	"div",
	"et",
	"el",
	"sux",
	"ang",
	"en",
	"es",
	"eo",
	"eu",
	"fa",
	"fil",
	"cha",
	"nld",
	"fr",
	"frr",
	"fry",
	"fur",
	"ga",
	"gd",
	"gl",
	"got",
	"ko",
	"hau",
	"hi",
	"mww",
	"hr",
	"haw",
	"ia",
	"zu",
	"is",
	"it",
	"he",
	"kal",
	"xal",
	"moh",
	"kan",
	"kat",
	"cor",
	"khm",
	"qkz",
	"sw",
	"ht",
	"ku",
	"kir",
	"lad",
	"fcs",
	"lv",
	"lb",
	"lt",
	"la",
	"hu",
	"mk",
	"ml",
	"mt",
	"mnc",
	"qmd",
	"mr",
	"mic",
	"enm",
	"mik",
	"hnj",
	"mon",
	"my",
	"qnv",
	"nah",
	"ppl",
	"nl",
	"ja",
	"no",
	"ce",
	"ood",
	"ota",
	"ps",
	"pdc",
	"nds",
	"pl",
	"ptBR",
	"ptPT",
	"fuc",
	"pa",
	"kaz",
	"qya",
	"ro",
	"rom",
	"ru",
	"smi",
	"sah",
	"sco",
	"sq",
	"sjn",
	"si",
	"sk",
	"slv",
	"sla",
	"gem",
	"sr",
	"fi",
	"sv",
	"ta",
	"mri",
	"tel",
	"tir",
	"th",
	"tqx",
	"bod",
	"vi",
	"cop",
	"tlh",
	"tpi",
	"tok",
	"trf",
	"tsd",
	"chr",
	"tr",
	"uk",
	"ale",
	"qlq",
	"urd",
	"uig",
	"uzb",
	"vol",
	"wln",
	"yi",
	"yua",
	"crh",
	"tat",
	"myv",
	"amh",
	"wuu",
	"hak",
	"yue",
	"zh",
	"nan",
}

-- Search page filter IDs (/works/search)
local FID_S_SORT = 2
local FID_S_SORT_DIR = 3
local FID_S_RATING = 4
local FID_S_COMPLETE = 5
local FID_S_CROSSOVER = 6
local FID_S_SINGLE_CHAPTER = 7
local FID_S_WORD_COUNT = 8
local FID_S_CAT_GEN = 10
local FID_S_CAT_FM = 11
local FID_S_CAT_FF = 12
local FID_S_CAT_MM = 13
local FID_S_CAT_MULTI = 14
local FID_S_CAT_OTHER = 15
local FID_S_WARN_NONE = 16
local FID_S_WARN_VIOLENCE = 17
local FID_S_WARN_DEATH = 18
local FID_S_WARN_NONCON = 19
local FID_S_WARN_UNDERAGE = 20
local FID_S_WARN_CREATOR = 21
local FID_S_TITLE = 22
local FID_S_CHARACTERS = 23
local FID_S_RELATIONSHIPS = 24
local FID_S_FREEFORM = 25
local FID_S_FANDOM = 26
local FID_S_MIN_HITS = 27
local FID_S_MIN_KUDOS = 28
local FID_S_MIN_COMMENTS = 29
local FID_S_MIN_BOOKMARKS = 30

local RATINGS = { "Any", "Not Rated", "General Audiences", "Teen And Up", "Mature", "Explicit" }
local RATING_VALUES = { "", "9", "10", "11", "12", "13" }

local S_CATEGORY_IDS = {
	[FID_S_CAT_GEN] = "21",
	[FID_S_CAT_FM] = "22",
	[FID_S_CAT_FF] = "116",
	[FID_S_CAT_MM] = "23",
	[FID_S_CAT_MULTI] = "2246",
	[FID_S_CAT_OTHER] = "24",
}

local S_WARNING_IDS = {
	[FID_S_WARN_NONE] = "16",
	[FID_S_WARN_VIOLENCE] = "17",
	[FID_S_WARN_DEATH] = "18",
	[FID_S_WARN_NONCON] = "19",
	[FID_S_WARN_UNDERAGE] = "20",
	[FID_S_WARN_CREATOR] = "14",
}

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

local DEFAULT_COVER = "https://jobobby04.github.io/ShosetsuExtensions/master/icons/ao3_cover.webp"

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
	local notes = document:selectFirst("#workskin .notes:not(.end)")
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

--- @return NovelInfo
local function howInfo()
	return NovelInfo {
		title = "How to use this source",
		link = "how",
		description = "Search for works by title, tag, or keyword. For adding specific works or series by URL, use the Add by URL listing."
	}
end

--- @return NovelInfo
local function addByUrlHowInfo()
	return NovelInfo {
		title = "How to use Add by URL",
		link = "how/addByUrl",
		description = "Paste the URL of a work, series, or works listing from archiveofourown.org to add it.\nExample: https://archiveofourown.org/works/12345678"
	}
end

--- @return NovelInfo
local function authorHowInfo()
	return NovelInfo {
		title = "How to use Search by Author",
		link = "how/author",
		description = "Enter an author's username or pseud to browse all of their works.\nExample: someauthor\n\nYou can also paste a user or pseud URL directly:\nhttps://archiveofourown.org/users/someauthor/works\nhttps://archiveofourown.org/users/someauthor/pseuds/somepseud"
	}
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
local function parseNovel(novelURL, loadChapters)
	if novelURL == "how" then
		return howInfo()
	end
	if novelURL == "how/addByUrl" then
		return addByUrlHowInfo()
	end
	if novelURL == "how/author" then
		return authorHowInfo()
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

	local imageElement = document:selectFirst("#chapters img")
	local imageURL = imageElement and imageElement:attr("src") or DEFAULT_COVER

	local info = NovelInfo {
		title = title,
		description = summary,
		genres = genres,
		authors = authors,
		status = status,
		imageURL = settings[2] and imageURL or nil,
	}

	if loadChapters then
		local chapters
		if (settings[3]) then
			local chaptersResponse = ClientGetDocument(expandURL(novelURL .. "/navigate"))
			local chaptersDocument = chaptersResponse:select("ol.chapter li")

			chapters = map(chaptersDocument, function(v, i)
				local item = v:selectFirst("a")
				local dateTime = v:selectFirst("span.datetime"):text():gsub("^%((.*)%)$", "%1")

				return NovelChapter {
					order = i,
					title = item:text(),
					link =  item:attr("href"),
					release = dateTime,
				}
			end)
			else
				local chaptersDocument = document:select("option, .actions option, form code")
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

local function parseListing(document)
	local works = document:select(".work > li")
	return map(works, function(v)
		return parseBrowseNovel(v)
	end)
end

local function urlEncode(str)
	if str == nil or str == "" then
		return ""
	end
	str = str:gsub(" ", "+")
	return (str:gsub("([^%w%-_%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

--- Turns a human-readable count ("373691", "18,311,380", "1.42M", "3.4k", "")
--- into an integer. Tolerates non-strings, empty and non-numeric input.
--- @param value string|nil
--- @return integer
local function parseCount(value)
	if type(value) ~= "string" then
		return 0
	end
	local s = value:gsub("%s", ""):gsub(",", "")
	if s == "" then
		return 0
	end
	local num, unit = s:match("^(%d+%.?%d*)(%a*)")
	if num == nil then
		return 0
	end
	local n = tonumber(num)
	if n == nil then
		return 0
	end
	if unit == "k" or unit == "K" then
		n = n * 1000
	elseif unit == "m" or unit == "M" then
		n = n * 1000000
	end
	return math.floor(n)
end

--- @param element Element @a fandom <li> in the /fandoms index
--- @return table|nil @{name, slug, count}
local function parseFandomLi(element)
	local tagLink = element:selectFirst("a.tag")
	if tagLink == nil then
		return nil
	end
	local href = tagLink:attr("href")
	local slug = href:match("/tags/(.+)/works$")
	if slug == nil then
		return nil
	end
	-- The work count is the last "(N)" in the li text; anchor to the end so a
	-- bare year in the fandom name (e.g. "Show (2005)") is not mistaken for it.
	local countText = element:text():match("%((%d+%.?%d*[kKmM]?)%)%s*$")
	return {
		name = tagLink:text(),
		slug = slug,
		count = parseCount(countText),
	}
end

--- @type table[]|nil
local fandomsCache = nil

--- Fetches /fandoms once and caches the medium -> top-fandoms hierarchy.
--- @return table[] @of {name, slug, fandoms = {name, slug, count}[]}
local function fetchFandoms()
	if fandomsCache ~= nil then
		return fandomsCache
	end
	local document = ClientGetDocument(expandURL("/fandoms"))
	local mediums = {}
	local mediumElems = document:select("li.medium.listbox.group")
	for i = 0, mediumElems:size() - 1 do
		local mediumElem = mediumElems:get(i)
		local mediumLink = mediumElem:selectFirst("h3.heading > a")
		if mediumLink ~= nil then
			local mediumSlug = mediumLink:attr("href"):match("/media/(.+)/fandoms$")
			if mediumSlug ~= nil then
				local fandoms = {}
				local fandomElems = mediumElem:select("ol.index.group > li")
				for j = 0, fandomElems:size() - 1 do
					local fandom = parseFandomLi(fandomElems:get(j))
					if fandom ~= nil then
						table.insert(fandoms, fandom)
					end
				end
				table.insert(mediums, {
					name = mediumLink:text(),
					slug = mediumSlug,
					fandoms = fandoms,
				})
			end
		end
	end
	fandomsCache = mediums
	return mediums
end

--- @type table[]|nil
local tagsCache = nil

--- Fetches the /tags popular-tag cloud once and caches the tag list.
--- @return table[] @of {name, slug}
local function fetchTags()
	if tagsCache ~= nil then
		return tagsCache
	end
	local document = ClientGetDocument(expandURL("/tags"))
	local tags = {}
	local seen = {}
	local tagElems = document:select("ul.tags.cloud li > a")
	for i = 0, tagElems:size() - 1 do
		local tagLink = tagElems:get(i)
		local slug = tagLink:attr("href"):match("/tags/(.+)/works$")
		if slug ~= nil and not seen[slug] then
			seen[slug] = true
			table.insert(tags, {
				name = tagLink:text(),
				slug = slug,
			})
		end
	end
	tagsCache = tags
	return tags
end

--- @type table[string] @mediumSlug -> {letter, fandoms = {name, slug, count}[]}[]
local mediumLettersCache = {}

--- Fetches /media/<medium>/fandoms once per medium and caches the fandoms
--- grouped by their first character (the page is already lettered).
--- @param mediumSlug string
--- @return table[] @of {letter, fandoms = {name, slug, count}[]}
local function fetchMediumLetters(mediumSlug)
	if mediumLettersCache[mediumSlug] ~= nil then
		return mediumLettersCache[mediumSlug]
	end
	local document = ClientGetDocument(expandURL("/media/" .. mediumSlug .. "/fandoms"))
	local letters = {}
	local letterElems = document:select("li.letter.listbox.group")
	for i = 0, letterElems:size() - 1 do
		local letterElem = letterElems:get(i)
		local letterHeading = letterElem:selectFirst("h3.heading")
		if letterHeading ~= nil then
			local letter = letterHeading:ownText():gsub("%s", "")
			local fandoms = {}
			local fandomElems = letterElem:select("ul.tags.index.group > li")
			for j = 0, fandomElems:size() - 1 do
				local fandom = parseFandomLi(fandomElems:get(j))
				if fandom ~= nil then
					table.insert(fandoms, fandom)
				end
			end
			if #fandoms > 0 then
				table.insert(letters, { letter = letter, fandoms = fandoms })
			end
		end
	end
	mediumLettersCache[mediumSlug] = letters
	return letters
end

--- @type table[string] @mediumSlug -> {name, slug, count}[]
local mediumFandomsCache = {}

--- All fandoms in a medium, flattened across letters.
--- @param mediumSlug string
--- @return table[] @of {name, slug, count}
local function fetchMediumFandoms(mediumSlug)
	if mediumFandomsCache[mediumSlug] ~= nil then
		return mediumFandomsCache[mediumSlug]
	end
	local letters = fetchMediumLetters(mediumSlug)
	local fandoms = {}
	for i = 1, #letters do
		for j = 1, #letters[i].fandoms do
			table.insert(fandoms, letters[i].fandoms[j])
		end
	end
	mediumFandomsCache[mediumSlug] = fandoms
	return fandoms
end

--- Fetches a paginated works listing and parses its story cards.
--- @param url string @full works listing URL (no page param)
--- @param page integer @1-based page
--- @return NovelInfo[]
local function browseWorks(url, page)
	local document = ClientGetDocument(addPage(removePage(url), page))
	return parseListing(document)
end

--- Validates that a string is a non-negative integer, raises an error if not.
--- @param value string
--- @param fieldName string @display name for the error message
--- @return integer
local function validateNonNegInt(value, fieldName)
	local n = tonumber(value)
	if n == nil or n < 0 or n ~= math.floor(n) then
		error(fieldName .. " must be a whole number, got: " .. value)
	end
	return n
end

--- Appends params to a URL, using ? or & as appropriate.
--- @param baseUrl string
--- @param params string[]
--- @return string
local function appendParams(baseUrl, params)
	local sep = baseUrl:match("[?]") and "&" or "?"
	return baseUrl .. sep .. table.concat(params, "&")
end

--- @return Filter[] @filters for the browse page (/works, /tags/.../works)
local function browseFilters()
	return {
		DropdownFilter(FID_B_SORT, "Sort By", B_SORT_COLUMNS),
		FilterGroup("Include", {
			RadioGroupFilter(FID_B_INC_RATING, "Ratings", B_INC_RATING_CHOICES),
			FilterGroup("Warnings", {
				CheckboxFilter(FID_B_INC_WARN_CREATOR, "Creator Chose Not To Use"),
				CheckboxFilter(FID_B_INC_WARN_NONE, "No Archive Warnings"),
				CheckboxFilter(FID_B_INC_WARN_VIOLENCE, "Graphic Violence"),
				CheckboxFilter(FID_B_INC_WARN_DEATH, "Major Character Death"),
				CheckboxFilter(FID_B_INC_WARN_NONCON, "Rape/Non-Con"),
				CheckboxFilter(FID_B_INC_WARN_UNDERAGE, "Underage Sex"),
			}),
			FilterGroup("Categories", {
				CheckboxFilter(FID_B_INC_CAT_GEN, "Gen"),
				CheckboxFilter(FID_B_INC_CAT_FM, "F/M"),
				CheckboxFilter(FID_B_INC_CAT_MM, "M/M"),
				CheckboxFilter(FID_B_INC_CAT_FF, "F/F"),
				CheckboxFilter(FID_B_INC_CAT_MULTI, "Multi"),
				CheckboxFilter(FID_B_INC_CAT_OTHER, "Other"),
			}),
			TextFilter(FID_B_INC_OTHER_TAGS, "Other tags to include"),
		}),
		FilterGroup("Exclude", {
			FilterGroup("Ratings", {
				CheckboxFilter(FID_B_EXC_RATING_NOTRATED, "Not Rated"),
				CheckboxFilter(FID_B_EXC_RATING_GA, "General Audiences"),
				CheckboxFilter(FID_B_EXC_RATING_T, "Teen And Up"),
				CheckboxFilter(FID_B_EXC_RATING_M, "Mature"),
				CheckboxFilter(FID_B_EXC_RATING_E, "Explicit"),
			}),
			FilterGroup("Warnings", {
				CheckboxFilter(FID_B_EXC_WARN_CREATOR, "Creator Chose Not To Use"),
				CheckboxFilter(FID_B_EXC_WARN_NONE, "No Archive Warnings"),
				CheckboxFilter(FID_B_EXC_WARN_VIOLENCE, "Graphic Violence"),
				CheckboxFilter(FID_B_EXC_WARN_DEATH, "Major Character Death"),
				CheckboxFilter(FID_B_EXC_WARN_NONCON, "Rape/Non-Con"),
				CheckboxFilter(FID_B_EXC_WARN_UNDERAGE, "Underage Sex"),
			}),
			FilterGroup("Categories", {
				CheckboxFilter(FID_B_EXC_CAT_GEN, "Gen"),
				CheckboxFilter(FID_B_EXC_CAT_FM, "F/M"),
				CheckboxFilter(FID_B_EXC_CAT_MM, "M/M"),
				CheckboxFilter(FID_B_EXC_CAT_FF, "F/F"),
				CheckboxFilter(FID_B_EXC_CAT_MULTI, "Multi"),
				CheckboxFilter(FID_B_EXC_CAT_OTHER, "Other"),
			}),
			TextFilter(FID_B_EXC_OTHER_TAGS, "Other tags to exclude"),
		}),
		FilterGroup("More Options", {
			RadioGroupFilter(FID_B_CROSSOVER, "Crossovers", B_CROSSOVER_CHOICES),
			RadioGroupFilter(FID_B_COMPLETE, "Completion", COMPLETIONS),
			FilterGroup("Word Count", {
				TextFilter(FID_B_WORDS_FROM, "Min"),
				TextFilter(FID_B_WORDS_TO, "Max"),
			}),
			FilterGroup("Date Updated", {
				TextFilter(FID_B_DATE_FROM, "From"),
				TextFilter(FID_B_DATE_TO, "To"),
			}),
			TextFilter(FID_B_QUERY, "Search within results"),
			DropdownFilter(FID_B_LANGUAGE, "Language", B_LANGUAGE_CHOICES),
		}),
	}
end

--- Applies browse-page filters to a URL.
--- @param data table @filter values
--- @param baseUrl string
--- @return string
local function applyBrowseFilters(data, baseUrl)
	local params = {}

	local sortCol = data[FID_B_SORT] or 0
	table.insert(params, "work_search[sort_column]=" .. B_SORT_COLUMN_VALUES[sortCol + 1])

	-- Include tags. Array params are only sent when at least one is set; the
	-- "other tags" text field is always sent (empty when unset), like AO3.
	local incRating = data[FID_B_INC_RATING]
	if incRating and incRating > 0 then
		table.insert(params, "include_work_search[rating_ids][]=" .. B_INC_RATING_IDS[incRating + 1])
	end
	for fid, ao3Id in pairs(B_INC_WARNING_IDS) do
		if data[fid] then
			table.insert(params, "include_work_search[archive_warning_ids][]=" .. ao3Id)
		end
	end
	for fid, ao3Id in pairs(B_INC_CATEGORY_IDS) do
		if data[fid] then
			table.insert(params, "include_work_search[category_ids][]=" .. ao3Id)
		end
	end
	local incOther = data[FID_B_INC_OTHER_TAGS]
	table.insert(params, "work_search[other_tag_names]=" .. (incOther and incOther ~= "" and urlEncode(incOther) or ""))

	-- Exclude tags
	for fid, ao3Id in pairs(B_EXC_RATING_IDS) do
		if data[fid] then
			table.insert(params, "exclude_work_search[rating_ids][]=" .. ao3Id)
		end
	end
	for fid, ao3Id in pairs(B_EXC_WARNING_IDS) do
		if data[fid] then
			table.insert(params, "exclude_work_search[archive_warning_ids][]=" .. ao3Id)
		end
	end
	for fid, ao3Id in pairs(B_EXC_CATEGORY_IDS) do
		if data[fid] then
			table.insert(params, "exclude_work_search[category_ids][]=" .. ao3Id)
		end
	end
	local excOther = data[FID_B_EXC_OTHER_TAGS]
	table.insert(params, "work_search[excluded_tag_names]=" .. (excOther and excOther ~= "" and urlEncode(excOther) or ""))

	-- More options
	local crossover = data[FID_B_CROSSOVER] or 0
	table.insert(params, "work_search[crossover]=" .. B_CROSSOVER_VALUES[crossover + 1])

	local complete = data[FID_B_COMPLETE]
	table.insert(params, "work_search[complete]=" .. (complete and complete > 0 and COMPLETE_VALUES[complete + 1] or ""))

	local wFrom = data[FID_B_WORDS_FROM]
	table.insert(params, "work_search[words_from]=" .. (wFrom and wFrom ~= "" and tostring(validateNonNegInt(wFrom, "Word Count Min")) or ""))

	local wTo = data[FID_B_WORDS_TO]
	table.insert(params, "work_search[words_to]=" .. (wTo and wTo ~= "" and tostring(validateNonNegInt(wTo, "Word Count Max")) or ""))

	local dFrom = data[FID_B_DATE_FROM]
	table.insert(params, "work_search[date_from]=" .. (dFrom and dFrom ~= "" and urlEncode(dFrom) or ""))

	local dTo = data[FID_B_DATE_TO]
	table.insert(params, "work_search[date_to]=" .. (dTo and dTo ~= "" and urlEncode(dTo) or ""))

	local query = data[FID_B_QUERY]
	table.insert(params, "work_search[query]=" .. (query and query ~= "" and urlEncode(query) or ""))

	local lang = data[FID_B_LANGUAGE] or 0
	table.insert(params, "work_search[language_id]=" .. B_LANGUAGE_VALUES[lang + 1])

	return appendParams(baseUrl, params)
end

--- @return Filter[] @filters for the search page (/works/search)
local function searchFilters()
	return {
		DropdownFilter(FID_S_SORT, "Sort By", S_SORT_COLUMNS),
		DropdownFilter(FID_S_SORT_DIR, "Direction", { "Ascending", "Descending" }),
		FilterGroup("Content", {
			DropdownFilter(FID_S_RATING, "Rating", RATINGS),
			RadioGroupFilter(FID_S_COMPLETE, "Completion", COMPLETIONS),
			SwitchFilter(FID_S_CROSSOVER, "Exclude Crossovers"),
			SwitchFilter(FID_S_SINGLE_CHAPTER, "Single Chapter"),
		}),
		FilterGroup("Categories", {
			TriStateFilter(FID_S_CAT_GEN, "Gen"),
			TriStateFilter(FID_S_CAT_FM, "F/M"),
			TriStateFilter(FID_S_CAT_FF, "F/F"),
			TriStateFilter(FID_S_CAT_MM, "M/M"),
			TriStateFilter(FID_S_CAT_MULTI, "Multi"),
			TriStateFilter(FID_S_CAT_OTHER, "Other"),
		}),
		FilterGroup("Warnings", {
			TriStateFilter(FID_S_WARN_NONE, "No Warnings"),
			TriStateFilter(FID_S_WARN_VIOLENCE, "Graphic Violence"),
			TriStateFilter(FID_S_WARN_DEATH, "Major Character Death"),
			TriStateFilter(FID_S_WARN_NONCON, "Rape/Non-Con"),
			TriStateFilter(FID_S_WARN_UNDERAGE, "Underage Sex"),
			TriStateFilter(FID_S_WARN_CREATOR, "Creator Chose Not To Use"),
		}),
		TextFilter(FID_S_WORD_COUNT, "Word Count (min-max)"),
		FilterGroup("Tags", {
			TextFilter(FID_S_TITLE, "Title"),
			TextFilter(FID_S_FANDOM, "Fandom"),
			TextFilter(FID_S_CHARACTERS, "Characters"),
			TextFilter(FID_S_RELATIONSHIPS, "Relationships"),
			TextFilter(FID_S_FREEFORM, "Freeform"),
		}),
		FilterGroup("Stats", {
			TextFilter(FID_S_MIN_HITS, "Min Hits"),
			TextFilter(FID_S_MIN_KUDOS, "Min Kudos"),
			TextFilter(FID_S_MIN_COMMENTS, "Min Comments"),
			TextFilter(FID_S_MIN_BOOKMARKS, "Min Bookmarks"),
		}),
	}
end

--- Applies search-page filters to a URL.
--- @param data table @filter values
--- @param baseUrl string
--- @return string
local function applySearchFilters(data, baseUrl)
	local params = {}

	local sortCol = data[FID_S_SORT] or 0
	table.insert(params, "work_search[sort_column]=" .. S_SORT_COLUMN_VALUES[sortCol + 1])

	local sortDir = data[FID_S_SORT_DIR]
	table.insert(params, "work_search[sort_direction]=" .. (sortDir and sortDir > 0 and "desc" or "asc"))

	local rating = data[FID_S_RATING]
	if rating and rating > 0 then
		table.insert(params, "work_search[rating_ids][]=" .. RATING_VALUES[rating + 1])
	end

	local complete = data[FID_S_COMPLETE]
	table.insert(params, "work_search[complete]=" .. (complete and complete > 0 and COMPLETE_VALUES[complete + 1] or ""))

	table.insert(params, "work_search[crossover]=" .. (data[FID_S_CROSSOVER] and "F" or ""))

	table.insert(params, "work_search[single_chapter]=" .. (data[FID_S_SINGLE_CHAPTER] and "1" or "0"))

	local wc = data[FID_S_WORD_COUNT]
	table.insert(params, "work_search[word_count]=" .. (wc and wc ~= "" and urlEncode(wc) or ""))

	for fid, ao3Id in pairs(S_CATEGORY_IDS) do
		if data[fid] == 1 then
			table.insert(params, "work_search[category_ids][]=" .. ao3Id)
		end
	end

	for fid, ao3Id in pairs(S_WARNING_IDS) do
		if data[fid] == 1 then
			table.insert(params, "work_search[archive_warning_ids][]=" .. ao3Id)
		end
	end

	local textParams = {
		{ FID_S_TITLE, "title" },
		{ FID_S_FANDOM, "fandom_names" },
		{ FID_S_CHARACTERS, "character_names" },
		{ FID_S_RELATIONSHIPS, "relationship_names" },
		{ FID_S_FREEFORM, "freeform_names" },
	}
	for i = 1, #textParams do
		local val = data[textParams[i][1]]
		table.insert(params, "work_search[" .. textParams[i][2] .. "]=" .. (val and val ~= "" and urlEncode(val) or ""))
	end

	local minParams = {
		{ FID_S_MIN_HITS, "hits", "Min Hits" },
		{ FID_S_MIN_KUDOS, "kudos_count", "Min Kudos" },
		{ FID_S_MIN_COMMENTS, "comments_count", "Min Comments" },
		{ FID_S_MIN_BOOKMARKS, "bookmarks_count", "Min Bookmarks" },
	}
	for i = 1, #minParams do
		local val = data[minParams[i][1]]
		local n = ""
		if val and val ~= "" then
			n = tostring(validateNonNegInt(val, minParams[i][3]))
		end
		table.insert(params, "work_search[" .. minParams[i][2] .. "]=" .. n)
	end

	return appendParams(baseUrl, params)
end

local function simpleSearch(filters)
	local page = filters[PAGE]
	local query = filters[QUERY]

	local baseUrl = expandURL("/works/search?work_search[query]=" .. urlEncode(query))
	local newUrl = applySearchFilters(filters, baseUrl)
	local document = ClientGetDocument(addPage(newUrl, page))
	return parseListing(document)
end

--- Resolves a pasted work/series/listing URL to novels.
--- @param url string
--- @param page integer @1-based page
--- @return NovelInfo[]|nil @nil when the input is not a recognizable URL
local function resolveUrl(url, page)
	-- handler URL to a specific work
	if page == 1 and shrinkURL(url):match("/works/%d+") then
		local novelUrl = url:gsub("/chapters.*$", ""):gsub("/$", "")
		local novel = ClientGetDocument(novelUrl)
		return {
			NovelInfo {
				title = novel:selectFirst(".title"):text(),
				link = shrinkURL(novelUrl)
			}
		}
	end

	-- handle /works and /tags/.+/works listings
	if shrinkURL(url):match("/works") then
		local newUrl = addPage(removePage(url), page)
		local document = ClientGetDocument(newUrl)

		return parseListing(document)
	end

	-- handle /series listings
	if shrinkURL(url):match("/series/%d+") then
		local newUrl = addPage(removePage(url), page)
		local document = ClientGetDocument(newUrl)

		return parseListing(document)
	end

	return nil
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return NovelInfo[]
local function search(filters)
	return simpleSearch(filters)
end

--- Resolves a pasted work/series/listing URL to novels.
--- @param data table @filter values, [QUERY] is the url
--- @return NovelInfo[]
local function addByUrlSearch(data)
	local page = data[PAGE]
	local url = data[QUERY]:gsub('^%s*(.-)%s*$', '%1')

	local result = resolveUrl(url, page)
	if result ~= nil then
		return result
	end

	return {}
end

--- Resolves a pasted AO3 user/pseud URL to its /works listing path.
--- @param query string
--- @return string|nil @e.g. "/users/X/pseuds/Y/works" or "/users/X/works"
local function authorWorksUrl(query)
	-- Pseud URL: /users/<user>/pseuds/<pseud>[/works]
	local user, pseud = query:match("^https?://archiveofourown%.org/users/([^/]+)/pseuds/([^/]+)")
	if user == nil then
		user, pseud = query:match("^/users/([^/]+)/pseuds/([^/]+)")
	end
	if user ~= nil then
		return "/users/" .. user .. "/pseuds/" .. pseud .. "/works"
	end
	-- User URL with /works
	local u = query:match("^https?://archiveofourown%.org/users/([^/]+)/works$")
	if u == nil then
		u = query:match("^/users/([^/]+)/works$")
	end
	if u ~= nil then
		return "/users/" .. u .. "/works"
	end
	-- User URL without /works (profile page)
	u = query:match("^https?://archiveofourown%.org/users/([^/]+)$")
	if u == nil then
		u = query:match("^/users/([^/]+)$")
	end
	if u ~= nil then
		return "/users/" .. u .. "/works"
	end
	return nil
end

--- Searches works by author username/pseud, or resolves a pasted
--- /users/<user>[/works] or /users/<user>/pseuds/<pseud>[/works] URL to that
--- user/pseud's works listing.
--- @param data table @filter values, [QUERY] is the author name or user/pseud URL
--- @return NovelInfo[]
local function authorSearch(data)
	local page = data[PAGE]
	local query = data[QUERY]:gsub('^%s*(.-)%s*$', '%1')

	-- A pasted user/pseud URL (with or without the /works suffix): resolve it to
	-- the /works listing directly, since that is the paginated works page.
	local worksUrl = authorWorksUrl(query)
	if worksUrl ~= nil then
		return browseWorks(expandURL(worksUrl), page)
	end

	local baseUrl = expandURL("/works/search?work_search[creators]=" .. urlEncode(query))
	local newUrl = applySearchFilters(data, baseUrl)
	local document = ClientGetDocument(addPage(newUrl, page))
	return parseListing(document)
end

--- @param infoFunc fun():NovelInfo @returns the "how to use" placeholder
--- @return fun(data:table):NovelInfo[] @the placeholder on page 1, empty after
local function infoFunc(infoFunc)
	return function(data)
		if (data[PAGE] or 1) > 1 then
			return {}
		end
		return { infoFunc() }
	end
end

--- @return ListingItem
local function searchItem()
	return ListingItem {
		name = "Search",
		link = "search",
		isIncrementing = true,
		func = infoFunc(howInfo),
		search = search,
		searchFilters = searchFilters(),
	}
end

--- @return ListingItem
local function addByUrlItem()
	return ListingItem {
		name = "Add by URL",
		link = "addByUrl",
		isIncrementing = false,
		func = infoFunc(addByUrlHowInfo),
		search = addByUrlSearch,
		searchIsIncrementing = false,
	}
end

--- @return ListingItem
local function authorItem()
	return ListingItem {
		name = "Search by Author",
		link = "author",
		isIncrementing = true,
		func = infoFunc(authorHowInfo),
		search = authorSearch,
		searchFilters = searchFilters(),
	}
end

--- @return ListingItem
local function latestItem()
	return ListingItem {
		name = "Latest Works",
		link = "latest",
		isIncrementing = true,
		func = function(data)
			return browseWorks(expandURL("/works"), data[PAGE])
		end,
		search = function(data)
			local newUrl = applyBrowseFilters(data, expandURL("/works"))
			return browseWorks(newUrl, data[PAGE])
		end,
		searchFilters = browseFilters(),
	}
end

--- @param mediumSlug string
--- @param fandomSlug string
--- @param count integer|nil @optional work count, shown as a suffix
--- @return ListingItem
local function fandomItem(mediumSlug, fandomSlug, count)
	local name = fandomSlug
	local fandoms = fetchMediumFandoms(mediumSlug)
	for i = 1, #fandoms do
		if fandoms[i].slug == fandomSlug then
			name = fandoms[i].name
			break
		end
	end
	if count ~= nil then
		local formatted = tostring(count):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		name = name .. " (" .. formatted .. ")"
	end
	return ListingItem {
		name = name,
		link = "fandom@" .. mediumSlug .. "@@" .. fandomSlug,
		isIncrementing = true,
		func = function(data)
			return browseWorks(expandURL("/tags/" .. fandomSlug .. "/works"), data[PAGE])
		end,
		search = function(data)
			local newUrl = applyBrowseFilters(data, expandURL("/tags/" .. fandomSlug .. "/works"))
			return browseWorks(newUrl, data[PAGE])
		end,
		searchFilters = browseFilters(),
	}
end

--- @param mediumSlug string
--- @return ListingList
local function mediumByWorksGroup(mediumSlug)
	return ListingList {
		name = "By Works",
		link = "fandom@" .. mediumSlug .. "@works",
		func = function()
			local fandoms = fetchMediumFandoms(mediumSlug)
			table.sort(fandoms, function(a, b)
				return a.count > b.count
			end)
			local items = {}
			for i = 1, #fandoms do
				table.insert(items, fandomItem(mediumSlug, fandoms[i].slug, fandoms[i].count))
			end
			return items
		end,
	}
end

--- @param mediumSlug string
--- @param letter string
--- @return ListingList
local function mediumLetterGroup(mediumSlug, letter)
	return ListingList {
		name = letter,
		link = "fandom@" .. mediumSlug .. "@az@" .. letter,
		func = function()
			local items = {}
			local letters = fetchMediumLetters(mediumSlug)
			for i = 1, #letters do
				if letters[i].letter == letter then
					for j = 1, #letters[i].fandoms do
						table.insert(items, fandomItem(mediumSlug, letters[i].fandoms[j].slug))
					end
					break
				end
			end
			return items
		end,
	}
end

--- @param mediumSlug string
--- @return ListingList
local function mediumAZGroup(mediumSlug)
	return ListingList {
		name = "A-Z",
		link = "fandom@" .. mediumSlug .. "@az",
		func = function()
			local items = {}
			local letters = fetchMediumLetters(mediumSlug)
			for i = 1, #letters do
				table.insert(items, mediumLetterGroup(mediumSlug, letters[i].letter))
			end
			return items
		end,
	}
end

--- @param mediumSlug string
--- @return ListingList
local function mediumGroup(mediumSlug)
	return ListingList {
		name = (function()
			local fandoms = fetchFandoms()
			for i = 1, #fandoms do
				if fandoms[i].slug == mediumSlug then
					return fandoms[i].name
				end
			end
			return mediumSlug
		end)(),
		link = "fandom@" .. mediumSlug,
		func = function()
			return {
				mediumByWorksGroup(mediumSlug),
				mediumAZGroup(mediumSlug),
			}
		end,
	}
end

--- @return ListingList
local function fandomsGroup()
	return ListingList {
		name = "Browse by Fandom",
		link = "fandoms",
		func = function()
			local items = {}
			local fandoms = fetchFandoms()
			for i = 1, #fandoms do
				table.insert(items, mediumGroup(fandoms[i].slug))
			end
			return items
		end,
	}
end

--- @param tagSlug string
--- @return ListingItem
local function tagItem(tagSlug)
	local name = tagSlug
	local tags = fetchTags()
	for i = 1, #tags do
		if tags[i].slug == tagSlug then
			name = tags[i].name
			break
		end
	end
	return ListingItem {
		name = name,
		link = "tag@" .. tagSlug,
		isIncrementing = true,
		func = function(data)
			return browseWorks(expandURL("/tags/" .. tagSlug .. "/works"), data[PAGE])
		end,
		search = function(data)
			local newUrl = applyBrowseFilters(data, expandURL("/tags/" .. tagSlug .. "/works"))
			return browseWorks(newUrl, data[PAGE])
		end,
		searchFilters = browseFilters(),
	}
end

--- @return ListingList
local function tagsGroup()
	return ListingList {
		name = "Popular Tags",
		link = "tags",
		func = function()
			local items = {}
			local tags = fetchTags()
			for i = 1, #tags do
				table.insert(items, tagItem(tags[i].slug))
			end
			return items
		end,
	}
end

--- @return ListingList
local function rootList()
	return ListingList {
		name = "Archive of Our Own",
		link = "",
		func = function()
			return {
				searchItem(),
				addByUrlItem(),
				authorItem(),
				latestItem(),
				fandomsGroup(),
				tagsGroup(),
			}
		end,
	}
end

--- @param link string @"" for the root, otherwise a listing link
--- @return ListingList|ListingItem
local function getListing(link)
	if link == "" then
		return rootList()
	end
	if link == "search" then
		return searchItem()
	end
	if link == "addByUrl" then
		return addByUrlItem()
	end
	if link == "author" then
		return authorItem()
	end
	if link == "latest" then
		return latestItem()
	end
	if link == "fandoms" then
		return fandomsGroup()
	end
	if link == "tags" then
		return tagsGroup()
	end
	local mediumSlug, fandomSlug = link:match("^fandom@([^@]+)@@([^@]+)$")
	if mediumSlug ~= nil then
		return fandomItem(mediumSlug, fandomSlug)
	end
	local mediumSlug, letter = link:match("^fandom@([^@]+)@az@(.+)$")
	if mediumSlug ~= nil then
		return mediumLetterGroup(mediumSlug, letter)
	end
	local mediumSlugAz = link:match("^fandom@([^@]+)@az$")
	if mediumSlugAz ~= nil then
		return mediumAZGroup(mediumSlugAz)
	end
	local mediumSlugWorks = link:match("^fandom@([^@]+)@works$")
	if mediumSlugWorks ~= nil then
		return mediumByWorksGroup(mediumSlugWorks)
	end
	local mediumSlugOnly = link:match("^fandom@([^@]+)$")
	if mediumSlugOnly ~= nil then
		return mediumGroup(mediumSlugOnly)
	end
	local tagSlug = link:match("^tag@([^@]+)$")
	if tagSlug ~= nil then
		return tagItem(tagSlug)
	end
	return rootList()
end

return {
	id = 1308639966,
	name = "ArchiveOfOurOwn",
	baseURL = baseURL,

	-- Optional values to change
	imageURL = "https://jobobby04.github.io/ShosetsuExtensions/master/icons/ao3_icon.png",
	hasCloudFlare = true,

	---@diagnostic disable-next-line: undefined-global
	chapterType = ChapterType.HTML,

	getListing = getListing,

	-- Default functions that have to be set
	getPassage = getPassage,
	parseNovel = parseNovel,

	settings = {
		SwitchFilter(1, "Remove all Justify attributes"),
		SwitchFilter(2, "Add cover (may include spoilers)"),
		SwitchFilter(3, "Fetch chapter dates")
	},
	updateSetting = function(id, value)
		settings[id] = value
	end,

	shrinkURL = shrinkURL,
	expandURL = expandURL
}
