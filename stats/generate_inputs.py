import random
from typing import List
import base64


DAIS_SIZES = [64, 128, 256, 512, 1024, 2048, 4096]
DAIS_ROUNDS = 100
OUT_FNAME = "./blockchain/test_inputs"


def append_random_base64_input_line(fname: str, input_size: int):
    rnd_bytes = random.randbytes(input_size)
    with open(fname, "ab") as gout:
        gout.write(base64.encodebytes(rnd_bytes).replace(b'\n', b''))
        gout.write(b'\n')


def generate_all_combos(fname: str, sizes: List[int], rounds: int):
    """ Will create a file that contains sizes * rounds lines.
    Each line is a base64 encoding of randomly generated data.
    They can be used to generate stats"""
    for size in sizes:
        for _ in range(rounds):
            append_random_base64_input_line(fname, size)


generate_all_combos(OUT_FNAME, DAIS_SIZES, DAIS_ROUNDS)
