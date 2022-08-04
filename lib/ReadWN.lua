-- {"ver":"1.0.0","author":"Jobobby04"}

-- rename this if you ever figure out its real name

---@type fun(tbl: table , url: string): string

local defaults = {}

local GENRE_SELECT = 2
local STATUS_SELECT = 3
local STATUS_VALUES = {
    "All",
    "Completed",
    "Ongoing"
}

local SORT_BY_SELECT = 4
local SORT_BY_VALUES = {
    "New",
    "Popular",
    "Updates"
}


function defaults:shrinkURL(url)
    return url:gsub("^.-readwn%.com", "")
end

function defaults:expandURL(url)
    return baseURL .. url
end

--- @param chapterURL string
--- @return string
function defaults:getPassage(chapterURL)
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
function defaults:selectChapters(document, startIndex)
    return map(document:select("ul.chapter-list a"), function(v, i)
        return NovelChapter {
            order = startIndex + i,
            title = v:selectFirst("strong"):text(),
            link = shrinkURL(v:attr("href"))
        }
    end)
end


function defaults:tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--- @param elements Elements
--- @return Element
function defaults:selectLast(elements)
    return elements:get(elements:size() - 1)
end

--- @param novelURL string
--- @param loadChapters boolean
--- @return NovelInfo
function defaults:parseNovel(novelURL, loadChapters)
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
function defaults:parseBrowseWithSelector(document,selector)
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
function defaults:parseBrowse(document)
    return parseBrowseWithSelector(document, ".novel-item a")
end

local searchMap = {}

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @return Novel[]
function defaults:search(filters)
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

    return {}
end

--- @param filters table @of applied filter values [QUERY] is the search query, may be empty
--- @param f fun(): Novel[]
--- @return Novel[]
function defaults:getListings(filters, f)
    local genre = filters[GENRE_SELECT]
    local status = filters[STATUS_SELECT]
    local sortBy = filters[SORT_BY_SELECT]

    local genreFailed = genre == nil or genre == 0
    local statusFailed = status == nil or status == 0
    local sortByFailed = sortBy == nil or sortBy == 0
    if genreFailed and statusFailed and sortByFailed then
        return f()
    else
        local part1 = "all"
        if genre ~= nil and genre ~= 0 then
            part1 = GENRE_VALUES[genre+1]:lower():gsub(" ", "-")
        end
        local part2 = "all"
        if status ~= nil and status ~= 0 then
            part2 = STATUS_VALUES[status+1]
        end

        local part3 = "newstime"
        if sortBy ~= nil and sortBy ~= 0 then
            if sortBy == 1 then
                part3 = "onclick"
            elseif sortBy == 2 then
                part3 = "lastdotime"
            end
        end
        return parseBrowse(GETDocument("https://www.readwn.com/list/" .. part1 .. "/" .. part2 .. "-" .. part3 .. "-" .. (filters[PAGE] - 1) .. ".html"))
    end
end

return function(baseURL, _self)
    _self = setmetatable(_self or {}, { __index = function(_, k)
        local d = defaults[k]
        return (type(d) == "function" and wrap(_self, d) or d)
    end })
    _self["baseURL"] = baseURL

    _self["chapterType"] = ChapterType.HTML

    _self["hasSearch"] = true
    _self["isSearchIncrementing"] = true
    _self["search"] = search
    _self["searchFilters"] = {
        DropdownFilter(_self.genres, "Genre / Category", GENRE_VALUES),
        DropdownFilter(STATUS_SELECT, "Status", STATUS_VALUES),
        DropdownFilter(SORT_BY_SELECT, "Sort by", SORT_BY_VALUES)
    }
end