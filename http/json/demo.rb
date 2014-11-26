# encode: UTF-8

def json_demo request,args,session,event
  puts "OKxxxxxxxxxxx"
  data={
    now:Time.now.to_i,
  }
  return ["text/json",data]
end 