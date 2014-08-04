$ ->
  bindClickEvents()

getArticle = (url, done) ->
  $.ajax({
    method: "GET"
    url: url
  }).done (result) ->
    left = result.indexOf("<p>")
    right = result.indexOf("</p>")
    paragraph = result[left...right+4]
    done paragraph

bindClickEvents = ->
  id = 0
  $("a").each ->
    $(this).attr("data-unique-nobody-use-this-link-id", id)
    if $(this).attr("data-unique-nobody-use-this-link-opened") isnt "true"
      $(this).attr("data-unique-nobody-use-this-link-opened", "false")
    id += 1

  $("a").unbind("click")
  $("a").click (evt) ->
    element = $(evt.target)
    id = $(this).attr("data-unique-nobody-use-this-link-id")
    if element.attr("data-unique-nobody-use-this-link-opened") is "true"
      element.attr("data-unique-nobody-use-this-link-opened", "false")
      $(".expand-div[data-id='#{id}']").remove()
      console.log "removed"
    else
      element.attr("data-unique-nobody-use-this-link-opened", "true")
      parent = element.parent()
      linkHtml = element[0].outerHTML
      pHtml = parent.html()
      location = pHtml.indexOf(linkHtml) + linkHtml.length
      console.log pHtml[...location]
      insertThing parent, location, id, element.attr("href")
    return false

insertThing = (para, offset, id, url) ->
  para.each ->
    current = $(this)
    text = current.html()
    words = splitWords text[offset..]
    current.html para.html()[...offset]
    height = current.height()
    i = 1
    inserted = false
    while i < words.length
      lastHtml = current.html()
      current.html (lastHtml + " " + words[i])
      if current.height() > height
        current.html lastHtml
        inserted = true
        current.html (lastHtml + " <div class=\"expand-div\" data-id=\"#{id}\"></div> ")
        current.html (current.html() + " " + words[i..].join(" "))
        bindClickEvents()
        getArticle url, (result) =>
          $(".expand-div[data-id='#{id}']").html(result)
          bindClickEvents()
        return
      i++
    console.log current
    bindClickEvents()
    return

splitWords = (text) ->
  words = []
  currentWord = ""
  i = 0
  while i < text.length
    if text[i] == " "
      words.push currentWord + " "
      currentWord = ""
    else if text[i...i+3] == "<a "
      words.push currentWord
      currentWord = ""
      endOfTag = text[i..].indexOf("</a>") + 4
      words.push text[i...i+endOfTag]
      i += endOfTag
    else
      currentWord += text[i]
    i += 1
  words.push currentWord
  return words

