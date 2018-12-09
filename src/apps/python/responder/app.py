import responder

api = responder.API()


@api.route("/")
async def greet_world(req, resp, *args):
    resp.text = "Hello, world!"


@api.route("/healthz")
async def health_check(req, resp, *args):
    resp.text = "OK"


if __name__ == '__main__':
    api.run(
        port=8000, 
        log_level="warning",
        loop="uvloop"
    )