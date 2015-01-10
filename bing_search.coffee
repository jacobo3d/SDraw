#
# Bingで画像検索する
#

# https://datamarket.azure.com/account/keys
# account key: piWl0WnCx9b4HytksVqG3h0crLcki4MrY4XrwwS0Jo0
# "toshiyukimasui" で取得したAPIキー

window.bing_search = (keyword, callback) ->
  url = "https://api.datamarket.azure.com/Bing/Search/Image?$format=json&Query='#{keyword}'"
  acctkey = "piWl0WnCx9b4HytksVqG3h0crLcki4MrY4XrwwS0Jo0";
  encoded = btoa(acctkey + ":" + acctkey);
  $.ajax
    url: url
    type: 'PUT'
    headers: 'Authorization': "Basic #{encoded}"
    dataType: "json"
    success: (data) ->
      images = data['d']['results'].map (d) ->
        d['MediaUrl']
      callback images
    error: (xhr, textStatus, errorThrown) ->
      alert "error #{textStatus}"
