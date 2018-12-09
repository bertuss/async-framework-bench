local json = require "json"

done = function(summary, latency, requests)
    report = {
        bytes=summary.bytes,
        errors=summary.errors,
        duration=summary.duration,
        requests=summary.requests,
        latency_statistics={
            min=latency.min,
            max=latency.max,
            mean=latency.mean,
            stdev=latency.stdev,
            percentiles={
                ["50"]=latency:percentile(50),
                ["90"]=latency:percentile(90),
                ["99"]=latency:percentile(99), 
                ["99.999"]=latency:percentile(99.999)
            }
        },
        requests_statistics={
            min=requests.min,
            max=requests.max,
            mean=requests.mean,
            stdev=requests.stdev,
            percentiles={
                ["50"]=requests:percentile(50),
                ["90"]=requests:percentile(90),
                ["99"]=requests:percentile(99), 
                ["99.999"]=requests:percentile(99.999)
            }
        }
    }

    io.write(json.encode(report))
end