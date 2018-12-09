from aiohttp import web
import argparse


async def handle(request):
    return web.Response(text="Hello, world!")

async def health_check(request):
    return web.Response(text="OK")


app = web.Application()
app.add_routes([
    web.get('/', handle), 
    web.get('/healthz', health_check)
])


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--uvloop', default=False, action='store_true')
    parser.add_argument('--host', default='0.0.0.0', type=str)
    parser.add_argument('--port', default=8000, type=int)
    args = parser.parse_args()

    if args.uvloop:
        import asyncio
        import uvloop
        asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
        print('Using UVLoop')

    web.run_app(app, host=args.host, port=args.port, access_log=False)