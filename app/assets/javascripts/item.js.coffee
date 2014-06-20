# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'ready', () ->
  
  $('#file-submit').on 'click', () ->
    if $('#file-input')[0].files.length > 0
      file = $('#file-input')[0].files[0]
      if uploadable(file)
        upload file
      else
        if file.size > 104857600
          alert '不支持上传大于100M的文件！'
        else
          alert '仅支持上传rar、zip、pdf、doc、xls、ppt以及图片！'

  $('.btn-download').on 'click', (e) ->
    updateItem(e)

  $('.btn-upload').on 'click', () ->
    showUpload()

  $('#input-exit').on 'click', () ->
    hideUpload()

  $('#nav-search').on 'click', () ->
    showSearch()

  $('#search-submit').on 'click', () ->
    startSearch()

  $('#search-cancel').on 'click', () ->
    hideSearch()

  uploadable = (file) ->
    type = file.name.split('.').pop()
    size = file.size
    (size < 104857600) &&
    (type == 'rar' || 
    type == 'zip' ||
    type == '7z' ||
    type == 'pdf' ||
    type == 'doc' ||
    type == 'docx' ||
    type == 'xls' ||
    type == 'xlsx' ||
    type == 'ppt' ||
    type == 'pptx' ||
    type == 'jpeg' ||
    type == 'jpg' ||
    type == 'png' || 
    type == 'gif' ||
    type == 'ico')

  showUpload = () ->
    if $('#file-submit').attr('disabled') == 'disabled'
      $('.input-window').removeClass('input-window-min')
    else
      $('.input-window').addClass('input-window-show')

  hideUpload = () ->
    if $('#file-submit').attr('disabled') == 'disabled'
      $('.input-window').addClass('input-window-min')
    else
      $('.input-window').removeClass('input-window-show')

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

  showSearch = () ->
    if $('.search-box').hasClass('search-box-show')
      $('.search-box').removeClass('search-box-show')
    else
      $('.search-box').addClass('search-box-show')
      $('#search-input').focus()
    false

  hideSearch = () ->
    $('.search-box').removeClass('search-box-show')
    false

  startSearch = () ->
    if $('#search-input').val() != ''
      location.href = '/item/search/' + $('#search-input').val()
    false