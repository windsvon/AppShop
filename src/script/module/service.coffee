service = {}
W.service = service

api = W.api

# 获取所有app
service.getApps = ()->
    #    api.get("resource/App")
    Promise.resolve(true)


# ======================
# 缓存

ONE_HOUR_MILLiSECONDS = 1000 * 60 * 60

DATA_CACHE_PREFIX = 'data_cache_'

enableCache = (key, liveness, initFun)->
    item = localStorage.getItem DATA_CACHE_PREFIX + key
    item = item and JSON.parse(item)
    now = Date.now()
    if item? and (item.expiredOn - now > 0)
        console.log 'cache hit ' + key
        Promise.resolve(item.data)
    else
        initFun().then (data)->
            item = {data, expiredOn: Date.now() + liveness}
            localStorage.setItem DATA_CACHE_PREFIX + key, JSON.stringify(item)
            return data

# =======================================
# 数据

# 缓存 app categories
service.getAppCategoryList = ->
    q = api.get('resource/FenLei?pageNo=-1&pageSize=-1')
    q.then (r)->
        r.page

# 获取游戏分类
service.getGameCategories = ->
    service.getAppCategoryList().then (list) ->
        arr = _.filter list, (category) ->
            category.type == "game"
        return arr

# 获取应用分类
service.getAppCategories = ->
    service.getAppCategoryList().then (list) ->
        arr = _.filter list, (category) ->
            category.type == "app"
        return arr



# 根据id批量获取一批应用
service.getAppsOfIds = (ids)->
    q = api.get('resource/App', {pageSize: -1, criteria: JSON.stringify(_id: {in: ids})})
    q.then (r)->
        # 按照传入进来的ids排序
        arr = []
        for id in ids
            app = _.find r.page, _id: id
            arr.push(app) if app
        arr

service.getCategoriesByIds = (ids)->
    q = api.get('resource/FenLei', {pageSize: -1, criteria: JSON.stringify(_id: {in: ids})})
    q.then (r)->
        # 按照传入进来的ids排序
        arr = []
        for id in ids
            app = _.find r.page, _id: id
            arr.push(app) if app
        arr

# 根据id批量获取一批应用
service.getAppsOfIdsWithCategories = (ids)->
    q = service.getAppsOfIds(ids)
    q.then (arr)->
        service.getAppCategoryList().then (categories)->
            arr.forEach (app)->
                if app.categories.length
                    app.categories = app.categories.map (c)->
                        _.find(categories, _id: c)?.name || ''
            return arr

# 根据id获取 应用|游戏 详情
service.getAppDetail = (id)->
    q = api.get('resource/App/' + id)
    q.then (app)->
        service.getAppCategoryList().then (categories)->
            app.categories = app.categories.map (c)->
                _.find(categories, _id: c)?.name || ''
            return app

# 根据id批量获取应用,包含类型名称
service.getAppsOfIdsWithType = (ids) ->
    q = service.getAppsOfIds(ids)
    q.then (arr)->
        service.getAppCategoryList().then (categories)->
            arr.forEach (app)->
                app.type = _.find(categories, _id: app.categories[0])?.type
                if app.categories.length
                    app.categories = app.categories.map (c)->
                        _.find(categories, _id: c)?.name || ''
            return arr

# =======================================
# 游戏页

# 获取游戏顶部广告数据
service.getGameAdList = ->
    q = api.get 'resource/s2GameTopAd?pageNo=1&pageSize=10&sortBy=position&sortOrder=asc'
    q.then (r)-> r.page

# 获取游戏排行榜  默认降序
service.getGameTops = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/PaiHangBang/55dbc73beb59c8eb4cbed197?pageNo=#{pageNo}&pageSize=#{pageSize}&repo=main")
    q.then (r)->
        _.take r.apps, pageSize
    .then service.getAppsOfIdsWithCategories

# 获取热门网游推荐
service.getHotGameList = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/s2GameTjFenLei/577f7f2ba9c21a6434a261bf?repo=main")
    q.then (r)->
        _.take r.games, pageSize
    .then service.getAppsOfIdsWithCategories

# 获取手柄游戏推荐
service.getHandleGameList = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/s2GameTjFenLei/577f7f58a9c21a6434a261c0?repo=main")
    q.then (r)->
        _.take r.games, pageSize
    .then service.getAppsOfIdsWithCategories

# 获取热门游戏分类
service.getHotGameCategories = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/s2GameRmFenLei?pageNo=#{pageNo}&pageSize=#{pageSize}&sortBy=position&sortOrder=desc")
    q.then (r)->
        list = r.page
        service.getAppCategoryList().then (categories)->
            list.forEach (app)->
                app.categories = _.find(categories, _id: app.fenlei)?.name || ''
            return list

# 根据分类获取 游戏的推荐  应用无此选项  使用 service.getAppsOfCategory
service.getAppsByCategory = (categoryName, pageNo = 1, pageSize = 5)->
    service.getAppCategoryList().then (categories)->
        cId = _.find(categories, {name: categoryName})?._id
        q = api.get("resource/FenLei/#{cId}")
        q.then (r)->
            _.take r.tops, pageSize
        .then service.getAppsOfIdsWithCategories

# 列出分类下的所有应用，分页  使用场景: 《猜你喜欢》等
service.getAppsOfCategory = (categoryId, pageNo = 1, pageSize = 9) ->
    criteria = {categories: {has: categoryId}}
    sort = {"categoryOrder_#{categoryId}": -1, createdOn: -1}
    q = api.get("resource/App?pageNo=#{pageNo}&pageSize=#{pageSize}&criteria=#{JSON.stringify(criteria)}&sort=#{JSON.stringify(sort)}")
    q.then (r) ->
        r
# =======================================
# 应用页

# 获取游戏顶部广告数据

service.getAppAdList = ->
    q = api.get 'resource/s2AppTopAd?pageNo=1&pageSize=10&sortBy=position&sortOrder=asc'
    q.then (r)-> r.page

# 获取游戏排行榜  默认降序
service.getAppTops = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/PaiHangBang/55dbc755eb59c8eb4cbed198?pageNo=#{pageNo}&pageSize=#{pageSize}&repo=main")
    q.then (r)->
        _.take r.apps, pageSize
    .then service.getAppsOfIdsWithCategories

# 获取本周热门
service.getHotAppList = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/s2AppTjFenLei/57888268190171b369f4c7da?repo=main")
    q.then (r)->
        _.take r.games, pageSize
    .then service.getAppsOfIdsWithCategories

# 获取7月更新
service.getHandleGameList = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/s2AppTjFenLei/5788832d190171b369f4c7db?repo=main")
    q.then (r)->
        _.take r.games, pageSize
    .then service.getAppsOfIdsWithCategories

# 获取热门应用分类
service.getHotAppCategories = (pageNo = 1, pageSize = 12)->
    q = api.get("resource/s2AppRmFenLei?pageNo=#{pageNo}&pageSize=#{pageSize}&sortBy=position&sortOrder=desc")
    q.then (r)->
        list = r.page
        service.getAppCategoryList().then (categories)->
            list.forEach (app)->
                app.categories = _.find(categories, _id: app.fenlei)?.name || ''
            return list

# =======================================
# 专题页

#根据id获取应用列表并在添加专题名称作为标签
service.getAppsOfIdsWithZhuanti = (ids, zName)->
    q = api.get('resource/App', {pageSize: -1, criteria: JSON.stringify(_id: {in: ids})})
    q.then (r)->

# 按照传入进来的ids排序
        arr = [zName]
        for id in ids
            app = _.find r.page, _id: id
            arr.push(app) if app
        arr


# 专题列表
service.getZhuantiList = (pageNo = 1, pageSize = 20)->
    q = api.get("resource/Zhuanti?pageNo=#{pageNo}&pageSize=#{pageSize}&sortBy=position&sortOrder=desc")

# 大家都在搜
service.getSearchTextAd = ->
    q = api.get 'resource/AppStoreSearchTextAd'

# 搜索
service.getAppByKeyword = (keyword)->
    api.get encodeURI('/search/app?keyword=' + keyword)


# 获取应用的评论
service.getComments = (app, pageNo, pageSize)->
    q = api.get "resource/AppComment?pageNo=#{pageNo}&pageSize=#{pageSize}&app=#{app}&sortBy=createdOn&sortOrder=desc"

# 提交评论
service.addComment = (app, userId, username, score, comment)->
    q = api.post 'app/comment', app: app, userId: userId, username: username, score: score, comment: comment
