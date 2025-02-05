-- {"id":1308639972,"ver":"1.0.1","libVer":"1.3.0","author":"Jobobby04","dep":["ReadWN>=1.0.11"]}

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
    "Historical Romance",
    "Gay Romance",
    "Game",
    "Games",
    "Romantic",
    "Military",
    "Urban",
    "Farming",
    "Modern Life",
    "Urban Life",
    "Billionaire",
    "CEO",
    "Chinese",
    "Korean",
    "Japanese",
    "Yuri",
    "Two-dimensional",
    "Shoujo Ai",
    "Fan-Fiction",
    "Erciyuan",
    "Isekai",
    "Magic",
    "Virtual Reality",
    "Faloo",
}

return Require("ReadWN")("https://www.wuxiafox.com", {
    id = 1308639972,
    name = "WuxiaFox",
    imageURL = "https://jobobby04.github.io/ShosetsuExtensions/beta/icons/wuxia_one.png",
    shrinkURLNovel = "^.-wuxiafox%.com",
    hasCloudFlare = true,

    genres = GENRES,

    listingsMap = {
        {
            name = "Recently Added Chapters",
            increments = false,
            selector = "#latest-updates .novel-list.grid.col .novel-item a",
            url = function(data)
                return "https://www.wuxiafox.com"
            end
        },
        {
            name = "Popular Daily Updates",
            increments = true,
            url = function(data)
                return "https://www.wuxiafox.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "Most Popular",
            increments = true,
            url = function(data)
                return "https://www.wuxiafox.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "New to Web Novels",
            increments = true,
            url = function(data)
                return "https://www.wuxiafox.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"
            end
        }
    },
})
