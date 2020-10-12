#!/usr/bin/env python3

import math

def left_tree_size(n):
    """ n = total chunk size in bits
        returns the size of the left tree in bits
    """
    return 2 ** (
        10 + int(math.log2(
                    (n-1) // 1024
                ))
    )

print(left_tree_size(1024 * 5))
