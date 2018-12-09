from sanic import Sanic
from sanic.response import text
from sanic import response

app = Sanic()

@app.route("/")
async def handle(request):
    return text("Hello, world!")


@app.route("/healthz")
async def heath_check(request):
    return text("OK")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, access_log=False)