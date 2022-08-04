-- {"id":1,"ver":"1.0.43","libVer":"1.0.0","author":"Jobobby04","dep":["ReadWN>=1.0.2"]}

local GENRES = {
	"All",
	"Action",
	"Adult",
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
	"Mature",
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
	"Two-dimensional",
	"Erciyuan",
	"Fan-Fiction",
	"Game",
	"Military",
	"Urban Life",
	"Yuri",
	"Chinese",
	"Korean",
	"Japanese",
	"Isekai",
	"Magic",
	"Shoujo Ai",
	"Urban",
	"Virtual Reality"
}

return Require("ReadWN")("https://www.readwn.com", {
	id = 1308639964,
	name = "ReadWN",

	listings = {
		Listing("Recently Added Chapters", false, function(data)
			return getListings(data, function()
				return parseBrowseWithSelector(GETDocument(baseURL), "#latest-updates .novel-list.grid.col .novel-item a")
			end)
		end),
		Listing("Popular Daily Updates", true, function(data)
			return getListings(data, GENRES, function()
				return parseBrowse(GETDocument("https://www.readwn.com/list/all/all-lastdotime-" .. (data[PAGE] - 1) .. ".html"))
			end, )
		end),
		Listing("Most Popular", true, function(data)
			return getListings(data, GENRES, function()
				return parseBrowse(GETDocument("https://www.readwn.com/list/all/all-onclick-" .. (data[PAGE] - 1) .. ".html"))
			end)
		end),
		Listing("New to Web Novels", true, function(data)
			return getListings(data, GENRES, function()
				return parseBrowse(GETDocument("https://www.readwn.com/list/all/all-newstime-" .. (data[PAGE] - 1) .. ".html"))
			end)
		end)
	},

	genres = GENRES
})
