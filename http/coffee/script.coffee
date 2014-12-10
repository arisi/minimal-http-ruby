
now=0
xx=123

sse_data = (data) ->
  console.log "sse:",data
  $(".data").html(data.now)

ajax_data = (data) ->
  console.log "ajax:",data
  $(".adata").html(data.now)


@ajax = (obj) ->
  console.log "doin ajax"
  $.ajax
    url: "/demo.json"
    type: "GET"
    dataType: "json",
    contentType: "application/json; charset=utf-8",
    success: (data) ->
      ajax_data(data)
      setTimeout (->
        ajax()
        return
      ), 3000
      return
    error: (xhr, ajaxOptions, thrownError) ->
      alert thrownError
      return


$ ->
  console.log "Script Starts..."
  ajax()
  stream = new EventSource("/sse_demo.json")
  stream.addEventListener "message", (event) ->
    sse_data($.parseJSON(event.data))
    return




