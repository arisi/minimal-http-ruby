# encode: UTF-8

def json_sse_demo request,args,session,event
  if not session or session==0
    return ["text/event-stream",{}]
  end
  sleep 3
  data={
    now:Time.now.to_i,
  }
  return ["text/event-stream",data]
end
