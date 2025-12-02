# src/main.py
from src.common import logger, measure_time, memory_trace


@measure_time
@memory_trace
def main():
    logger.info("This is main.py")


if __name__ == "__main__":
    main()
