view = null
$w = $(window)

class Search extends W.Controller
    events: [
        ['click', '.key', 'refreshSearch']
        ['click', '.page-num, .last, .next', 'toPage']
    ]

    init: (data)->
        @key = data.key
        console.log @key
        @$view = $(WT.Search())
        $('.top-views').empty().append @$view

        @pageNo = 1
        @pageSize = 5
        @$searchKeys = @$view.find('.search-keys .key-list')
        @$searchResults = @$view.find('.search-results')

        @bindEvents()

        @initAllAppsIds()
        @initSearchKeys()

        return Promise.resolve(this)

    initSearchKeys: ->
        W.service.getSearchTextAd().then (r)=>
            $keys = $ WT.SearchKeys(page: r.page)
            $keys.appendTo @$searchKeys

    initAllAppsIds:  ->
        q = W.service.getAppByKeyword(@key)
        q.then (list)=>
            @ids = list.map (r)->
                r._id
            @initAppsByPage(@ids)



    initAppsByPage: (ids, pageNo = 1) ->
        total = ids.length;
        cIds = _.slice(ids, @pageSize * (pageNo-1), @pageSize * pageNo)
        W.service.getAppsOfIdsWithType(cIds).then (list) =>
            $results = $(WT.SearchResult(key: @key, pageSize: @pageSize, page: list))
            $results.appendTo @$searchResults
        .then =>
            @initPagination(total, pageNo)

    initPagination: (total, pageNo) ->
        @pageCount = Math.ceil(total/@pageSize)
        @$view.find('.pagination-block').remove()
        $pagination = $(WT.Pagination(pageCount: @pageCount, pageNo: pageNo))
        $('.search-results').append($pagination)
        currentPage = '[data-target="' + pageNo + '"]'
        @$view.find('.pagination-block')
        .find('.active').removeClass('active')
        .siblings(currentPage).addClass('active')



    toPage: (e) =>
        W.preventDefault(e)
        $this = $ e.currentTarget
        pageNo = $this.attr('data-target')
        if pageNo <= @pageCount and pageNo > 0
            $('.search-results').empty()
            @initAppsByPage(@ids, pageNo).bind(@)



    refreshSearch: (e)->
        W.preventDefault e
        val = $(e.currentTarget).attr('data-value')
        $('.search').val(val)
        $('.search-shop .submit').trigger('click')

    dispose: ->
        view = null
        Promise.resolve true

    @show: (data)->
        view = new Search
        view.init(data)

W.View.Search = Search

