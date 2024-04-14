-- {"id":1308639965,"ver":"1.0.5","libVer":"1.3.0","author":"Jobobby04","dep":["ReadWN>=1.0.11"]}

local GENRES = {
    "All",
    "Action",
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
    "Modern Romance",
    "Romantic",
    "CEO",
    "Urban",
    "Urban Life",
    "Historical Romance",
    "Modern Life",
    "Game",
    "Hentai",
    "Isekai",
    "LitRPG",
    "Magic",
    "Fan-Fiction",
    "Urban",
    "Virtual Reality",
    "Faloo",
    "Qihuan",
    "Korean",
}

return Require("ReadWN")("https://www.wuxiamate.com", {
    id = 1308639965,
    name = "WuxiaMate",
    imageURL = "https://github.com/jobobby04/ShosetsuExtensions/raw/master/icons/wuxia_mate.png",
    shrinkURLNovel = "^.-wuxiamate%.com",
    hasCloudFlare = true,

    genres = GENRES,

    listingsMap = {
        {
            name = "Recently Added Chapters",
            increments = false,
            selector = "#latest-updates .novel-list.grid.col .novel-item a",
            url = function(data)
                return "https://www.wuxiamate.com"
            end
        },
        {
            name = "Popular Daily Updates",
            increments = true,
            url = function(data)
                return "https://www.wuxiamate.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "Most Popular",
            increments = true,
            url = function(data)
                return "https://www.wuxiamate.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "New to Web Novels",
            increments = true,
            url = function(data)
                return "https://www.wuxiamate.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"
            end
        }
    },
})
