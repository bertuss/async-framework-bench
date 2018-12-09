init = function(args)
    local r = {}
    r[1] = wrk.format(nil, "/")
    r[2] = wrk.format(nil, "/healthz")
 
    req = table.concat(r)
end
 
request = function()
    return req
end