-- {"id":-999,"version":"0.0.0","author":"TechnoJo4","repo":""}
---@author TechnoJo4

-- ! ! ! ! !  DO NOT RUN AS AN EXTENSION  ! ! ! ! !
-- ! THIS FILE CONTAINS EmmyLua CLASS DEFINITIONS !
-- ! ! ! ! !  DO NOT RUN AS AN EXTENSION  ! ! ! ! !

-- Please, do NOT auto-format this file.

---@alias int number

-- base java/kotlin
do
    ---@class Array
    local Array = {}

    ---@param index int
    ---@return any
    function Array:get(index) return end

    ---@param index int
    ---@param value any
    ---@return
    function Array:set(index, value) return end

    ---@class ArrayList : Array
    local ArrayList = {}

    ---@param value any
    ---@return void
    function ArrayList:add(value) return end

    ---@return void
    function ArrayList:reverse() return end

    ---@return int
    function ArrayList:size() return end
end

-- jsoup
do
    ---@class Document : Element
    local Document = {}

    ---@class Element : Node
    local Element = {}

    ---@class Elements : ArrayList
    local Elements = {}

    ---@param query string
    ---@return Elements
    function Element:select(query) return end

    ---@param query string
    ---@return Element
    function Element:selectFirst(query) return end

    ---@return string
    function Element:text() return end

    ---@return string
    function Element:id() return end

    ---@return Elements
    function Element:children() return end

    ---@return number
    function Elements:size() return end

    ---@param index number
    ---@return Element
    function Elements:get(index) return end

    ---@param attributeKey string
    ---@return string
    function Elements:attr(attributeKey) return end

    ---@param query string
    ---@return Elements
    function Elements:select(query) return end

    ---@param query string
    ---@return Elements
    function Elements:selectFirst(query) return end

    ---@return string
    function Elements:text() return end

    ---@class Node
    local Node = {}

    ---@param attributeKey string
    ---@return string
    function Node:attr(attributeKey) return end
end

-- okhttp
do
    -- You shouldn't use methods of these classes manually in extension code unless you know what you're doing anyways,
    -- So I didn't bother making documentation for them. Refer to the existing kotlin okhttp documentation.

    ---@class OkHttpClient
    local OkHttpClient = {}
    ---@class Request
    local Request = {}
    ---@class Headers
    local Headers = {}
    ---@class RequestBody
    local RequestBody = {}
    ---@class CacheControl
    local CacheControl = {}
    ---@class MediaType
    local MediaType = {}
    ---@class Cookie
    local Cookie = {}
    ---@class CookieJar
    local CookieJar = {}
    ---@class HttpUrl
    local HttpUrl = {}
    ---@class Interceptor
    local Interceptor = {}

    do
        ---@class OkHttpClientBuilder
        local OkHttpClientBuilder = {}
        ---@return OkHttpClient
        function OkHttpClientBuilder:build() return end

        ---@param interceptor Interceptor
        ---@return OkHttpClientBuilder
        function OkHttpClientBuilder:addInterceptor(interceptor) return end

        ---@param interceptor Interceptor
        ---@return OkHttpClientBuilder
        function OkHttpClientBuilder:addNetworkInterceptor(interceptor) return end
    end

    do
        ---@return HttpUrl
        function Request:url() return end

        ---@return string
        function Request:method() return end

        ---@return Headers
        function Request:headers() return end

        ---@return RequestBody | nil
        function Request:body() return end

        ---@param name string
        ---@return string | nil
        function Request:header(name) return end

        ---@param name string
        ---@return string[] | Array | table
        function Request:headers(name) return end

        ---@return RequestBuilder
        function Request:newBuilder() return end
    end

    do
        ---@class RequestBuilder
        local RequestBuilder = {}
        ---@return Request
        function RequestBuilder:build() return end

        ---@param url string
        ---@return RequestBuilder
        function RequestBuilder:url(url) return end

        ---@param name string
        ---@param value string
        ---@return RequestBuilder
        function RequestBuilder:addHeader(name, value) return end

        ---@param body string
        ---@return RequestBuilder
        function RequestBuilder:post(body) return end

        ---@param headers Headers
        ---@return RequestBuilder
        function RequestBuilder:headers(headers) return end

        ---@param cacheControl CacheControl
        ---@return RequestBuilder
        function RequestBuilder:cacheControl(cacheControl) return end

        ---@return RequestBuilder
        function RequestBuilder:get() return end
    end

    do
        ---@class HeadersBuilder
        local HeadersBuilder = {}
        ---@return Headers
        function HeadersBuilder:build() return end

        ---@param name string
        ---@return string
        function HeadersBuilder:get(name) return end

        ---@param name string
        ---@param value string
        ---@return HeadersBuilder
        function HeadersBuilder:add(name, value) return end

        ---@param name string
        ---@param value string
        ---@return HeadersBuilder
        function HeadersBuilder:set(name, value) return end
    end

    do
        ---@class FormBodyBuilder
        local FormBodyBuilder = {}
        ---@return RequestBody
        function FormBodyBuilder:build() return end

        ---@param name string
        ---@param value string
        ---@return FormBodyBuilder
        function FormBodyBuilder:add(name, value) return end
    end

    do
        ---@class Response
        local Response = {}
        ---@return ResponseBody
        function Response:body() return end

        ---@return int
        function Response:code() return end

        ---@return Headers
        function Response:headers() return end

        ---@return Request
        function Response:request() return end

        ---@class ResponseBody
        local ResponseBody = {}
        ---@return string
        function ResponseBody:string() return end
    end

    do
        ---@class CookieBuilder
        local CookieBuilder = {}
        ---@return Cookie
        function CookieBuilder:build() return end

        ---@param name string
        ---@return CookieBuilder
        function CookieBuilder:name(name) return end

        ---@param value string
        ---@return CookieBuilder
        function CookieBuilder:value(value) return end

        ---@param expiresAt int
        ---@return CookieBuilder
        function CookieBuilder:expiresAt(expiresAt) return end

        ---@param domain string
        ---@return CookieBuilder
        function CookieBuilder:domain(domain) return end

        ---@param domain string
        ---@return CookieBuilder
        function CookieBuilder:hostOnlyDomain(domain) return end

        ---@param path string
        ---@return CookieBuilder
        function CookieBuilder:path(path) return end

        ---@return CookieBuilder
        function CookieBuilder:secure() return end

        ---@return CookieBuilder
        function CookieBuilder:httpOnly() return end
    end

    do
        ---@return string
        function Cookie:name() return end

        ---@return string
        function Cookie:value() return end

        ---@return int
        function Cookie:expiresAt() return end

        ---@return string
        function Cookie:domain() return end

        ---@return string
        function Cookie:path() return end

        ---@return boolean
        function Cookie:secure() return end

        ---@return boolean
        function Cookie:httpOnly() return end

        ---@return boolean
        function Cookie:persistent() return end

        ---@return boolean
        function Cookie:hostOnly() return end

        ---@return CookieBuilder
        function Cookie:newBuilder() return end
    end

    do
        ---@param url HttpUrl
        ---@param cookies Cookie[] | Array | table
        ---@return string
        function CookieJar:saveFromResponse(url, cookies) return end

        ---@param url HttpUrl
        ---@return Cookie[] | Array | table
        function CookieJar:loadForRequest(url) return end
    end

    do
        ---@class HttpUrlBuilder
        local HttpUrlBuilder = {}
        ---@return HttpUrl
        function HttpUrlBuilder:build() return end

        ---@param scheme string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:scheme(scheme) return end

        ---@param username string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:username(username) return end

        ---@param encodedUsername string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:encodedUsername(encodedUsername) return end

        ---@param password string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:password(password) return end

        ---@param encodedPassword string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:encodedPassword(encodedPassword) return end

        ---@param host string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:host(host) return end

        ---@param port int
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:port(port) return end

        ---@param pathSegment string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:addPathSegment(pathSegment) return end

        ---@param pathSegments string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:addPathSegments(pathSegments) return end

        ---@param encodedPathSegment string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:addEncodedPathSegment(encodedPathSegment) return end

        ---@param encodedPathSegments string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:addEncodedPathSegments(encodedPathSegments) return end

        ---@param index int
        ---@param pathSegment string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:setPathSegment(index, pathSegment) return end

        ---@param index int
        ---@param encodedPathSegment string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:setEncodedPathSegment(index, encodedPathSegment) return end

        ---@param index int
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:removePathSegment(index) return end

        ---@param encodedPath string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:encodedPath(encodedPath) return end

        ---@param query string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:query(query) return end

        ---@param encodedQuery string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:encodedQuery(encodedQuery) return end

        ---@param name string
        ---@param value string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:addQueryParameter(name, value) return end

        ---@param encodedName string
        ---@param encodedValue string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:addEncodedQueryParameter(encodedName, encodedValue) return end

        ---@param name string
        ---@param value string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:setQueryParameter(name, value) return end

        ---@param encodedName string
        ---@param encodedValue string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:setEncodedQueryParameter(encodedName, encodedValue) return end

        ---@param name string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:removeAllQueryParameters(name) return end

        ---@param encodedName string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:removeAllEncodedQueryParameters(encodedName) return end

        ---@param canonicalName string
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:removeAllCanonicalQueryParameters(canonicalName) return end

        ---@param fragment string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:fragment(fragment) return end

        ---@param encodedFragment string | nil
        ---@return OkHttpClientBuilder
        function HttpUrlBuilder:encodedFragment(encodedFragment) return end
    end

    do
        ---@return string
        function HttpUrl:scheme() return end

        ---@return string
        function HttpUrl:username() return end

        ---@return string
        function HttpUrl:password() return end

        ---@return string
        function HttpUrl:host() return end

        ---@return int
        function HttpUrl:port() return end

        ---@return string[] | Array | table
        function HttpUrl:pathSegments() return end

        ---@return string | nil
        function HttpUrl:fragment() return end

        ---@return HttpUrlBuilder
        function HttpUrl:newBuilder() return end

        ---@param name string
        ---@return string | nil
        function HttpUrl:queryParameter(name) return end

        ---@param name string
        ---@return string[] | nil[] | Array | table
        function HttpUrl:queryParameterValues(name) return end

        ---@param name int
        ---@return string
        function HttpUrl:queryParameterName(index) return end

        ---@param name int
        ---@return string | nil
        function HttpUrl:queryParameterValue(index) return end
    end

end

-- dkjson
do
    ---@class dkjson
    local dkjson = {}

    ---@return string
    ---@param tbl table
    function dkjson.encode(tbl) return end

    ---@return table
    ---@param str string @JSON string
    function dkjson.decode(str) return end

    ---@param url string
    ---@return string | table @Response
    function dkjson.GET(url, ...) return end

    ---@param url string
    ---@param body string | table
    ---@return string | table @Response
    function dkjson.POST(url, body, ...) return end
end

-- Filter things
do
    ---@class Filter
    local Filter = {}

    ---@class HeaderFilter : Filter
    ---@field name string
    local HeaderFilter = {}

    ---@class SeparatorFilter : Filter
    local SeparatorFilter = {}

    ---@class TextFilter : Filter
    ---@field id int
    ---@field name string
    ---@field state string
    local TextFilter = {}

    ---@class PasswordFilter : Filter
    ---@field id int
    ---@field name string
    ---@field state string
    local PasswordFilter = {}

    ---@class SwitchFilter : Filter
    ---@field id int
    ---@field name string
    ---@field state boolean
    local SwitchFilter = {}

    ---@class CheckboxFilter : Filter
    ---@field id int
    ---@field name string
    ---@field state boolean
    local CheckboxFilter = {}

    ---@class TriStateFilter : Filter
    ---@field id int
    ---@field name string
    ---@field state int "0 = Ignored, 1 = Included, 2 = Excluded"
    local TriStateFilter = {}

    ---@class DropdownFilter : Filter
    ---@field id int
    ---@field name string
    ---@field choices string[] | Array | table
    ---@field state int
    local DropdownFilter = {}

    ---@class RadioGroupFilter : Filter
    ---@field id int
    ---@field name string
    ---@field choices string[] | Array | table
    ---@field state int
    local RadioGroupFilter = {}

    ---@class FilterList : Filter
    ---@field name string
    ---@field filters Filter[] | Array | table
    local FilterList = {}

    ---@class FilterGroup : Filter
    ---@type Filter
    ---@field name string
    ---@field filters Filter[] | Array | table
    local FilterGroup = {}

end

-- Formatter things
do
    ---@class Listing
    local Listing = {}

    ---@class ListingItem | Listing
    ---@field name string
    ---@field link string
    ---@field isIncrementing boolean
    ---@field getListing fun(): NovelInfo[] | fun(data: table, inc: int): NovelInfo[] | nil
    local ListingItem = {}

    ---@class ListingList | Listing
    ---@field name string
    ---@field listings fun(): Listing[]
    local ListingList = {}

    ---@type int
    QUERY = {}

    ---@type int
    PAGE = {}

    ---@type int
    LISTING = {}
end

-- Novel Stuff
do
    ---@class NovelStatus
    local NovelStatus = {}

    ---@class NovelChapter
    ---@field release string
    ---@field title string
    ---@field link string
    ---@field order number
    local NovelChapter = {}

    ---@param release string
    ---@return void
    function NovelChapter:setRelease(release) return end

    ---@param title string
    ---@return void
    function NovelChapter:setTitle(title) return end

    ---@param link string
    ---@return void
    function NovelChapter:setLink(link) return end

    ---@param order number
    ---@return void
    function NovelChapter:setOrder(order) return end

    ---@param sourceId number
    ---@return void
    function NovelChapter:setSourceId(sourceId) return end

    ---@class NovelInfo
    ---@field title string
    ---@field alternativeTitles string[] | Array | table
    ---@field link string
    ---@field imageURL string
    ---@field language string
    ---@field description string
    ---@field status NovelStatus
    ---@field tags string[] | Array | table
    ---@field genres string[] | Array | table
    ---@field authors string[] | Array | table
    ---@field artists string[] | Array | table
    ---@field chapters NovelChapter[] | Array | table
    ---@field chapterCount int | nil
    ---@field wordCount int | nil
    ---@field commentCount int | nil
    ---@field viewCount int | nil
    ---@field favoriteCount int | nil
    local NovelInfo = {}

    ---@param title string
    ---@return void
    function NovelInfo:setTitle(title) return end

    ---@param titles Array | table
    ---@return void
    function NovelInfo:setAlternativeTitles(titles) return end

    ---@param link string
    ---@return void
    function NovelInfo:setLink(link) return end

    ---@param imageURL string|any
    ---@return void
    function NovelInfo:setImageURL(imageURL) return end

    ---@param description string
    ---@return void
    function NovelInfo:setDescription(description) return end

    ---@param genres Array | table
    ---@return void
    function NovelInfo:setGenres(genres) return end

    ---@param authors Array | table
    ---@return void
    function NovelInfo:setAuthors(authors) return end

    ---@param status "NovelStatus(3)" | NovelStatus
    ---@return void
    function NovelInfo:setStatus(status) return end

    ---@param tags Array | table
    ---@return void
    function NovelInfo:setTags(tags) return end

    ---@param artists Array | table
    ---@return void
    function NovelInfo:setArtists(artists) return end

    ---@param language string
    ---@return void
    function NovelInfo:setLanguage(language) return end

    ---@param chapters ArrayList
    ---@return void
    function NovelInfo:setChapters(chapters) return end

    ---@param chapterCount int | nil
    ---@return void
    function NovelInfo:setChapterCount(chapterCount) return end

    ---@param wordCount int | nil
    ---@return void
    function NovelInfo:setWordCount(wordCount) return end

    ---@param commentCount int | nil
    ---@return void
    function NovelInfo:setCommentCount(commentCount) return end

    ---@param viewCount int | nil
    ---@return void
    function NovelInfo:setViewCount(viewCount) return end

    ---@param favoriteCount int | nil
    ---@return void
    function NovelInfo:setFavoriteCount(favoriteCount) return end

    ---@class ChapterType
    local ChapterType = {}

	---@type ChapterType
	ChapterType.STRING = {}

	---@type ChapterType
	ChapterType.HTML = {}
end

-- ShosetsuLib
do
    -- OTHER
    ---@param name string
    ---@return any
    function Require(name) return end

    ---@type int @Index of search query in search data
    _G.QUERY = 0

    ---@type int @Index of search page in search data
    _G.PAGE = 1

    ---@type int @Used in shrinkURL and expandURL
    _G.KEY_NOVEL_URL = 1

    ---@type int @Used in shrinkURL and expandURL
    _G.KEY_CHAPTER_URL = 2

    -- EXTENSION METHODS
    do
        --- Map and Filter combined.
        ---@see ArrayList
        ---@param o ArrayList | Elements @Target
        ---@param f fun(v: any|Element): any
        ---@return table
        function mapNotNil(o, f) return end

        --- Filters an array.
        ---@see ArrayList
        ---@param o ArrayList | Elements @Target
        ---@param f fun(v: any|Element): any
        ---@return table
        function filter(o, f) return end

        --- Maps values of an ArrayList or Elements to a table
        ---@see ArrayList
        ---@param o ArrayList | Elements @Target
        ---@param f fun(v: any|Element): any
        ---@return table
        function map(o, f) return end

        --- Maps values of an ArrayList or Elements to another ArrayList or Elements, and then to a table (using two functions).
        --- Effectively flattens an array, which gives the function its name.
        ---@see ArrayList
        ---@see Elements
        ---@param o ArrayList | Elements @Target
        ---@param f1 fun(v: any): void | nil | ArrayList | Elements
        ---@param f2 fun(v: any): any
        ---@return table
        function map2flat(o, f1, f2) return end

        --- Returns the first element of the ArrayList or Elements whose output from the function is true.
        ---@see ArrayList
        ---@param o ArrayList | Elements
        ---@param f fun(v: any): boolean
        ---@return any
        function first(o, f) return end

        --- Wraps a function by creating a new one that prepends a specified argument then calls the underlying function.
        --- A wrapper function W(...), for a given underlying function F and object O, is equivalent to F(O, ...).
        ---@param o any @Prepended argument
        ---@param f function @Function to wrap
        ---@return function @Wrapper
        function wrap(o, f) return end
    end

    -- ArrayList
    do
        ---@return ArrayList
        function List() return end

        ---@param arr Array | table
        ---@return ArrayList
        function AsList(arr) return end

        ---@param arr ArrayList
        ---@return void
        function Reverse(arr) return end
    end

    -- OKHTTP3
    do

        ---@return OkHttpClient
        function HttpClient() return end

        ---@param url string
        ---@param headers Headers
        ---@param cacheControl CacheControl
        ---@return Request
        function GET(url, headers, cacheControl) return end

        ---@param url string
        ---@param headers Headers
        ---@param body RequestBody
        ---@param cacheControl CacheControl
        ---@return Request
        function POST(url, headers, body, cacheControl) return end

        ---@return OkHttpClientBuilder
        function HttpClientBuilder() return end
        ---@return RequestBuilder
        function RequestBuilder() return end
        ---@return HeadersBuilder
        function HeadersBuilder() return end
        ---@return FormBodyBuilder
        function FormBodyBuilder() return end
        ---@return CookieBuilder
        function CookieBuilder() return end
        ---@return CookieJar
        function CookieJar() return end
        ---@return HttpUrlBuilder
        function HttpUrlBuilder() return end
        ---@return CacheControl
        function DefaultCacheControl() return end

        ---@return CacheControl
        function DEFAULT_CACHE_CONTROL() return end
        ---@return Headers
        function DEFAULT_HEADERS() return end
        ---@return RequestBody
        function DEFAULT_BODY() return end

        --- Executes a request.
        ---@param req Request
        ---@return Response
        function Request(req) return end

        --- Obtains a document from an HTML string.
        ---@param str string
        ---@return Document
        function Document(str) return end

        --- Obtains a document from a Request.
        ---@param req Request
        ---@return Document
        function RequestDocument(req) return end

        --- Obtains a document from a url, using a GET request.
        ---
        --- No javascript is executed, you get the raw HTML.
        --- If the site loads extra in with JS,
        ---  you need to perform the post requests yourself.
        ---
        ---@param url string
        ---@return Document
        function GETDocument(url) return end

        ---@param str string
        ---@return MediaType
        function MediaType(str) return end

        ---@param data string
        ---@param type MediaType
        ---@return RequestBody
        function RequestBody(data, type) return end

        ---@param block function(chain Chain)
        ---@return Interceptor
        function Interceptor(block) return end

        ---@param saveFromResponse function(url HttpUrl, cookies List<Cookie>)
        ---@param loadForRequest function(url HttpUrl)
        ---@return CookieJar
        function CookieJar(saveFromResponse, loadForRequest) return end

        ---@param url string
        ---@return HttpUrl
        function HttpUrl(url) return end

        ---@param url string
        ---@param setCookie string
        ---@return HttpUrl
        function CookieParse(url, setCookie) return end

        ---@param url string
        ---@param headers Headers
        ---@return HttpUrl
        function CookieParseAll(url, headers) return end
    end

    -- CONSTRUCTORS
    do
        ---@param name string
        ---@param increments boolean
        ---@param func fun(): NovelInfo[] | fun(data: table, inc: int): NovelInfo[]
        ---@return ListingItem
        ---@deprecated replace with ListingItem
        function Listing(name, increments, func) return end

        ---@param name string
        ---@param link string
        ---@param increments boolean
        ---@return ListingItem
        function ListingItem(name, link, increments) return end

        ---@param name string
        ---@param listings Listing[] | Array | table
        ---@return ListingList
        function ListingList(name, listings) return end

        ---@deprecated Replace with NovelInfo
        ---@return NovelInfo
        ---@param t NovelInfo
        function Novel(t) return end

        ---@return NovelInfo
        ---@param t NovelInfo
        function NovelInfo(t) return end

        ---@return NovelChapter
        ---@param t NovelChapter
        function NovelChapter(t) return end

        ---@param type int
        ---@return NovelStatus
        function NovelStatus(type) return end

        -- FILTERS

        ---@param name string
        ---@return HeaderFilter
        function HeaderFilter(name) return end

        ---@param name string
        ---@return SeparatorFilter
        function SeparatorFilter(name) return end

        ---@param name string
        ---@return TextFilter
        function TextFilter(id, name) return end

        ---@param name string
        ---@return SwitchFilter
        function SwitchFilter(id, name) return end

        ---@param name string
        ---@return CheckboxFilter
        function CheckboxFilter(id, name) return end

        ---@param name string
        ---@return TriStateFilter
        function TriStateFilter(id, name) return end

        ---@param name string
        ---@param choices string[] | Array | table
        ---@return DropdownFilter
        function DropdownFilter(id, name, choices) return end

        ---@param name string
        ---@param choices string[] | Array | table
        ---@return RadioGroupFilter
        function RadioGroupFilter(id, name, choices) return end

        ---@param name string
        ---@param filters Filter[] | Array
        ---@return FilterList
        function FilterList(name, filters) return end

        ---@param name string
        ---@param choices Filter[] | Array
        ---@return FilterGroup
        function FilterGroup(name, choices) return end

    end
end
