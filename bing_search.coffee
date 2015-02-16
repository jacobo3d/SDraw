#
# Bingで画像検索する
#
# APIキーはconfig.coffee
#

# https://datamarket.azure.com/account/keys
# "toshiyukimasui" で取得したAPIキー

window.bing_search = (keyword, callback) ->
  # if typeof window.bing_acctkey != 'undefined'
  return unless window.bing_acctkey?
  url = "https://api.datamarket.azure.com/Bing/Search/Image?$format=json&Query='#{keyword}'"
  encoded = btoa "#{window.bing_acctkey}:#{window.bing_acctkey}" # base64エンコード
  $.ajax
    url: url
    type: 'PUT'
    headers:
      Authorization: "Basic #{encoded}"
    dataType: "json"
    success: (data) ->
      callback data['d']['results'].map (d) -> d['MediaUrl']
    error: (xhr, textStatus, errorThrown) ->
      alert "Can't perform Bing search ... #{textStatus}"
