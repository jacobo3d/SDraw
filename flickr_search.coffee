#
# Flickrで画像検索する
#
# APIキーはconfig.coffee
#

window.flickr_search = (keyword, callback) ->
  if typeof window.flickr_key != 'undefined'
    url = "https://api.flickr.com/services/rest?method=flickr.photos.search&per_page=10&text='#{keyword}'&api_key=#{window.flickr_key}&format=json"
    $.ajax
      url: url
      dataType: "html"
      cache: false
      success: (data, textStatus) ->
        # JSONの先頭に謎文字列があるので削除
        data = data.replace /^jsonFlickrApi\(/, ''
        data = data.replace /\)$/, ''
        d = JSON.parse data
        photos = d['photos']['photo']
        callback photos.map (photo) ->
          # [{"id":"15364713562","owner":"26153219@N00","secret":"4e9887d769","server":"3915","farm":4,"title":"DSC_0335.jpg","ispublic":1,"isfriend":0,"isfamily":0},
          "http://farm#{photo['farm']}.staticflickr.com/#{photo['server']}/#{photo['id']}_#{photo['secret']}.jpg"
      error: (xhr, textStatus, errorThrown) ->
        alert "error #{textStatus}"
