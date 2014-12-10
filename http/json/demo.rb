# encode: UTF-8

def json_demo request,args,session,event
  data={
    now:Time.now.to_i,
  }
  return ["text/json",data]
end
