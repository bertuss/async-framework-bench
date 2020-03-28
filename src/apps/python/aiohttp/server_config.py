import multiprocessing
import os

workers = (2 * multiprocessing.cpu_count()) + 1

bind = "0.0.0.0:8000"
errorlog = "-"

worker_class = "aiohttp.worker.GunicornUVLoopWebWorker"
