import argparse
from pathlib import Path

import docker
from icecream import ic
from loguru import logger


parser = argparse.ArgumentParser(description="Run benchmarks")
parser.add_argument(
    "-s",
    "--server",
    dest="server",
    default=None,
    help="The docker server where benchmark will be run",
)

args = parser.parse_args()


NETWORK_NAME = "bench"


if args.server:
    d = docker.DockerClient(base_url=args.server)
else:
    d = docker.from_env()

if not d.ping():
    logger.error("Could not connect to docker.")

d_info = d.info()
logger.info(
    f'Connected to docker `{d_info["Name"]}` running version {d_info["ServerVersion"]}.'
)
logger.info(
    "Docker server info:\n"
    f'Operating system: {d_info["OperatingSystem"]}\n'
    f'OS Type: {d_info["OSType"]}\n'
    f'Kernel Version: {d_info["KernelVersion"]}\n'
    f'CPU: {d_info["NCPU"]}\n'
    f'Memory: {(d_info["MemTotal"] / 1000 ** 3):.2f} GB\n'
    f"{'-' * 30}\n"
    f'Images: {d_info["Images"]}\n'
    f'Containers: {d_info["Containers"]}\n'
    f'Containers Paused: {d_info["ContainersPaused"]}\n'
    f'Containers Running: {d_info["ContainersRunning"]}\n'
    f'Containers Stopped: {d_info["ContainersStopped"]}'
)

try:
    network = d.networks.get(NETWORK_NAME)
    logger.info(f"Network `{network.name}` found")
except docker.errors.NotFound:
    network = d.networks.create("bench", driver="bridge")
    logger.info(f"Network created")


wrk_dockerfile = Path("bench/Dockerfile")
wrk_image = d.images.build(
    path=str(wrk_dockerfile.parent), dockerfile=str(wrk_dockerfile.resolve())
)

for dockerfile in Path().glob("apps/**/*.Dockerfile"):
    logger.info(f"Building image {dockerfile}")

    language = dockerfile.parts[1]
    framework = dockerfile.parts[2]
    app_type = dockerfile.parts[3].split(".")[0]
    tag = f"bench-{language}-{framework}-{app_type}"

    image, _ = d.images.build(
        path=str(dockerfile.parent), dockerfile=str(dockerfile.resolve()), tag=tag
    )
    logger.info("Done building")

    ic(image.tags)
    exit()

