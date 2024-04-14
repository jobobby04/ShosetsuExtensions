-- {"id":1308639974,"ver":"1.0.1","libVer":"1.0.0","author":"Jobobby04","dep":["ReadWN>=1.0.11"]}

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
    "Fan-Fiction",
    "Game",
    "Virtual Reality",
    "Urban",
    "Faloo",
    "Military",
    "Urban Life",
    "Isekai",
    "Magic",
    "Two-dimensional",
    "Erciyuan",
    "Wuxia Xianxia",
    "Official Circles",
    "Science Fiction",
    "Suspense Thriller",
    "Travel Through Time",
    "Ancient Romance",
    "Korean",
}

return Require("ReadWN")("https://www.wuxiaone.com", {
    id = 1308639974,
    name = "WuxiaOne",
    imageURL = "https://github.com/jobobby04/ShosetsuExtensions/raw/master/icons/wuxia_one.png",
    shrinkURLNovel = "^.-wuxiaone%.com",
    hasCloudFlare = true,

    genres = GENRES,

    listingsMap = {
        {
            name = "Recently Added Chapters",
            increments = false,
            selector = "#latest-updates .novel-list.grid.col .novel-item a",
            url = function(data)
                return "https://www.wuxiaone.com"
            end
        },
        {
            name = "Popular Daily Updates",
            increments = true,
            url = function(data)
                return "https://www.wuxiaone.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "Most Popular",
            increments = true,
            url = function(data)
                return "https://www.wuxiaone.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "New to Web Novels",
            increments = true,
            url = function(data)
                return "https://www.wuxiaone.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"
            end
        }
    },
})
