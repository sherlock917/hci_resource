# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'ready', () ->
  
  $('#file-submit').on 'click', () ->
    if $('#file-input')[0].files.length > 0
      file = $('#file-input')[0].files[0]
      upload file

  $('#btn-upload').on 'click', () ->
    $('.input-window').show().animate({opacity:1}, 300)

  $('.btn-download').on 'click', (e) ->
    updateItem(e)

  upload = (file) ->
    token = $('meta[name="qiniu-token"]').attr 'content'
    fd = new FormData()
    fd.append 'file', file
    fd.append 'key', file.name
    fd.append 'token', token
    $('#file-submit').attr('disabled', true).text '开始上传...'
    window.onbeforeunload = () ->
      '现在退出将会终止上传，真的要离开吗？'
    $.ajax
      url: 'http://up.qiniu.com',
      dataType: 'json',
      method: 'post',
      data: fd,
      contentType: false,
      processData: false,
      success : (data) ->
        createItem file,data.key
      xhr : () ->
        xhr = $.ajaxSettings.xhr()
        xhr.upload.onprogress = (progress) ->
          percentage = Math.floor(progress.loaded / progress.total * 100)
          $('#file-submit').text '已上传 ' + percentage + '%'
        xhr.upload.onload = () ->
          $('#file-submit').text '更新列表...'
        xhr

  createItem = (file, key) ->
    size = parseInt(file.size)
    if (size > 1024 * 1024)
      size = (size / 1024 / 1024).toFixed(2) + 'MB'
    else
      size = Math.floor(size / 1024) + 'KB' 
    item = {
      name : file.name,
      type : file.type,
      size : size,
      cate : $('#file-cate').val(),
      info : $('#file-info').val(),
      qiniu_key : key,
      url : 'http://scauhci.qiniudn.com/' + key
    }
    $.post('/item', item)
    .done(createDoneCallback)
    .fail(createFailCallback)

  createDoneCallback = () ->
    window.onbeforeunload = null
    location.reload()

  createFailCallback = () ->
    alert 'create item failed'

  updateItem = (e) ->
    data = {
      download_count : parseInt($(e.target).attr('item_count')) + 1
    }
    $.ajax
      url: '/item/' + $(e.target).attr('item_id'),
      method: 'put',
      data: data,
      success : (data) ->
        $(e.target)
        .attr('item_count', data.download_count)
        .parentsUntil('.item')
        .parent()
        .find('.item-download-count')
        .text data.download_count 