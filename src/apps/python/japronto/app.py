from japronto import Application


def hello(request):
    return request.Response(text='Hello, world!')


def health_check(request):
    return request.Response(text='OK')


app = Application()
app.router.add_route('/', hello)
app.router.add_route('/healthz', health_check)
app.run(debug=False, port=8000)