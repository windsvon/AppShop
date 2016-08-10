initUserEvent = ->
    $('.user-bar').on 'click', '.sign-in', (e)->
        W.preventDefault e
        W.signInDialog()

    $('.user-bar').on 'click', '.sign-out', (e)->
        W.preventDefault e
        q = W.api.post('sign-out')
        q.then (r)->
            W.buildUserHtml()
        q.catch W.alertAjaxError

initSearchEvent = ->
    $('.search-shop input').on 'keydown', (e)->
        if e.keyCode == 13
            val = encodeURI(_.trim this.value)
            APP.navigate("search/" + val, {trigger: true, replace: true}) if val
    $('.search-shop .form').find('.submit').on 'click', ->
        val = encodeURI(_.trim $('.search').val())
        APP.navigate("search/" + val, {trigger: true, replace: true}) if val

resize = ()->
    defaultWidth = 980
    width = $(window).outerWidth()
    $('meta[name="viewport"]').attr('content', 'width=' + defaultWidth + ',initial-scale=' + width / defaultWidth)

$ ->
    resize()

    window.APP = new Routers()
    Backbone.history.start()

    W.ping()

    initUserEvent()
    initSearchEvent()