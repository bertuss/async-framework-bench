import uvicorn

class App():
    def __init__(self, scope):
        self.scope = scope

    async def __call__(self, receive, send):
        await send({
            'type': 'http.response.start',
            'status': 200,
            'headers': [
                [b'content-type', b'text/plain'],
            ]
        })
        await send({
            'type': 'http.response.body',
            'body': b'Hello, world!',
        })


if __name__ == "__main__":
    print("Run server")
    uvicorn.run(App, "127.0.0.1", 8000, log_level="info")