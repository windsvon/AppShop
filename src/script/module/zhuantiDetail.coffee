view = null
$w = $(window)

class ZhuantiDetail extends W.Controller


    events: [
        ['click', '.page-num, .last, .next', 'toPage']
        ['click', '.link-container', 'appDetail']
        ['click', '.more-info', 'showMore']
    ]


    init: (data) ->
        @id = data
        @pageSize = 12

        $('.top-nav').find('.active').removeClass('active')
        $('[data-target="zhuanti"]').addClass('active')

        @$view = $(WT.ZhuantiDetail())
        $('.top-views').empty().append @$view

        @initZhuantiDetail(@id)
        @bindEvents()


        return Promise.resolve(this)


    getZhuantiById: (id) ->
        W.service.getZhuantiList().then (r) =>
            zhuanti = _.find(r.page, {_id: id})
            return zhuanti

    initZhuantiDetail: (id) ->
        @getZhuantiById(id).then (zhuanti) =>
            @$detail = $(WT.ZhuantiInfo(z: zhuanti))
            @$view.find('.container').append @$detail
            @ids = zhuanti.apps
            @initApps(@ids)

    initApps: (ids, pageNo = 1) ->
        W.service.getAppsOfIdsWithType(ids).then (list) =>

            total = list.length
            list = _.slice(list, @pageSize*(pageNo - 1), @pageSize*pageNo)
            @$list = $(WT.ZhuantiAppList(list: list))
            @$view.find('.app-list').append @$list

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
            @initApps(@ids, pageNo)


    appDetail: (e) ->
        W.preventDefault e
        $this = $ e.currentTarget
        id = $this.parent().attr('data-target')
        group = $this.attr('data-target')
        location.hash = "/#{group}/#{id}"
        return

    showMore: (e) ->
        $('.zhuanti-intro').addClass('active')

    dispose: ->
        view = null
        Promise.resolve true

    @show: (data)->
        view = new ZhuantiDetail()
        view.init(data)

W.View.ZhuantiDetail = ZhuantiDetail
