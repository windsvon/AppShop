view = null
$w = $(window)

class CategoryDetail extends W.Controller


    events: [
        ['click', '.page-num, .last, .next', 'toPage']
        ['click', '.category-name', 'categoryDetail']
        ['click', '.link-container', 'appDetail']
    ]


    init: (data) ->
        @id = data.id
        @group = data.group
        @pageSize = 12

        @$view = $(WT.CategoryDetail(group: @group))
        $('.top-views').empty().append @$view

        @initHotCategories(@group, @id)
        @initAppsByCategory(@id)

        @bindEvents()


        return Promise.resolve(this)

    getHotCategories: (group) ->
        if group == "game"
            return W.service.getGameCategories()
        if group == "app"
            return W.service.getAppCategories()

    initHotCategories: (group, id) ->
        @getHotCategories(group).then (list) =>
            @$list = $(WT.HotCategories(list: list))
            @$view.find('.category-list').append @$list
            currentCategory = '[data-target="' + id + '"]'
            $(currentCategory).addClass('active')

    initAppsByCategory: (id, pageNo = 1) ->
        W.service.getAppsOfCategory(id, pageNo, @pageSize).then (r) =>
            console.log r
            total = r.total
            @$list = $(WT.AppListByCategory(list: r.page))
            $('.app-list').append @$list
            @initPagination(total, pageNo)

    initPagination: (total, pageNo) ->
        @pageCount = Math.ceil(total/@pageSize)
        $pagination = $(WT.Pagination(pageCount: @pageCount, pageNo: pageNo))
        $('.app-list').append($pagination)
        currentPage = '[data-target="' + pageNo + '"]'
        @$view.find('.pagination-block')
        .find('.active').removeClass('active')
        .siblings(currentPage).addClass('active')


    toPage: (e) =>
        W.preventDefault(e)
        $this = $ e.currentTarget
        pageNo = $this.attr('data-target')
        if pageNo <= @pageCount and pageNo > 0
            $('.app-list').empty()
            @initAppsByCategory(@id, pageNo)


    categoryDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.attr('data-target')
        location.hash = "/category/#{@group}/#{id}"
        return

    appDetail: (e)->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.parent().attr('data-target')
        location.hash = "/#{@group}/#{id}"
        return



    dispose: ->
        view = null
        Promise.resolve true

    @show: (data)->
        view = new CategoryDetail()
        view.init(data)

W.View.CategoryDetail = CategoryDetail
