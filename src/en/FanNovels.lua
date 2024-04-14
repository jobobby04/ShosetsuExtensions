-- {"id":1308639969,"ver":"1.0.2","libVer":"1.0.0","author":"Jobobby04","dep":["ReadWN>=1.0.11"]}

local GENRES = {
    "All",
    "Fan-Fiction",
    "Billionaire",
    "Douluo",
    "Faloo",
    "Dragon Ball",
    "Football",
    "NBA",
    "Marvel",
    "Pokemon",
    "Elf",
    "Hogwarts",
    "System",
    "Naruto",
    "One Piece",
    "Villain",
    "Sign in",
    "Derivative Fanfic",
    "Hot",
    "Korean",
    "Action",
    "Adventure",
    "Anime",
    "Comedy",
    "Systemflow",
    "Competitive Sports",
    "Contemporary Romance",
    "Detective",
    "Drama",
    "Eastern Fantasy",
    "Ecchi",
    "Fantasy",
    "Fantasy Romance",
    "Game",
    "Gender Bender",
    "Harem",
    "Historical",
    "Historical Romance",
    "Horror",
    "Josei",
    "LGBT",
    "Lolicon",
    "Magic",
    "Magical Realism",
    "Martial Arts",
    "Mecha",
    "Military",
    "Modern Life",
    "Movies",
    "Mystery",
    "Psychological",
    "Realistic Fiction",
    "Reincarnation",
    "Romance",
    "School Life",
    "Sci-fi",
    "Science fiction",
    "Secret",
    "Seinen",
    "Shoujo",
    "Shoujo Ai",
    "Shounen",
    "Shounen Ai",
    "Slice of Life",
    "Smut",
    "Sports",
    "Supernatural",
    "Suspense",
    "Terror",
    "Tragedy",
    "Video Games",
    "War",
    "Wuxia",
    "Xianxia",
    "Xuanhuan",
    "Yaoi",
    "Yuri",
    "Urban Life",
    "Travel Through Time",
    "BL",
    "BG",
    "GL",
    "Other",
    "Crossing",
    "Rebirth",
}

return Require("ReadWN")("https://www.fannovels.com", {
    id = 1308639969,
    name = "FanNovels",
    imageURL = "https://github.com/jobobby04/ShosetsuExtensions/raw/master/icons/fan_novels.png",
    shrinkURLNovel = "^.-fannovels%.com",
    hasCloudFlare = true,

    genres = GENRES,

    listingsMap = {
        {
            name = "Recently Added Chapters",
            increments = false,
            selector = "#latest-updates .novel-list.grid.col .novel-item a",
            url = function(data)
                return "https://www.fannovels.com"
            end
        },
        {
            name = "Popular Daily Updates",
            increments = true,
            url = function(data)
                return "https://www.fannovels.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "Most Popular",
            increments = true,
            url = function(data)
                return "https://www.fannovels.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"
            end
        },
        {
            name = "New to Web Novels",
            increments = true,
            url = function(data)
                return "https://www.fannovels.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"
            end
        }
    },
})
