-- {"id":1308639975,"ver":"1.0.0","libVer":"1.0.0","author":"Jobobby04","dep":["ReadWN>=1.0.11"]}

local GENRES = {
    "All",
    "Fan-Fiction",
    "Faloo",
    "Action",
    "Adventure",
    "Comedy",
    "Contemporary Romance",
    "Drama",
    "Eastern Fantasy",
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
    "Sports",
    "Supernatural",
    "Tragedy",
    "Video Games",
    "Wuxia",
    "Xianxia",
    "Xuanhuan",
    "Yaoi",
    "Two-dimensional",
    "Erciyuan",
    "Game",
    "Military",
    "Urban Life",
    "Yuri",
    "Chinese",
    "Korean",
    "Japanese",
    "Hentai",
    "Isekai",
    "Magic",
    "Shoujo Ai",
    "Urban",
    "Virtual Reality",
    "Wuxia Xianxia",
    "Official Circles",
    "Science Fiction",
    "Suspense Thriller",
    "Travel Through Time",
}

return Require("ReadWN")("https://www.wuxiabox.com", {
    id = 1308639975,
    name = "WuxiaBox",
    shrinkURLNovel = "^.-wuxiabox%.com",
    hasCloudFlare = true,

    genres = GENRES,

    listingsMap = {
        {
            name = "Recently Added Chapters",
            increments = false,
            selector = "#latest-updates .novel-list.grid.col .novel-item a",
            url = function(data)
                return "https://www.wuxiabox.com"
            end
        },
        {
            name = "Popular Daily Updates",
            increments = true,
            url = function(data)
                return "https://www.wuxiabox.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "Most Popular",
            increments = true,
            url = function(data)
                return "https://www.wuxiabox.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "New to Web Novels",
            increments = true,
            url = function(data)
                return "https://www.wuxiabox.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"
            end
        }
    },
})
