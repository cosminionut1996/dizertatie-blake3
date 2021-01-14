function stack_size(input_size) {
    var full_chunks = input_size >> 10;
    var last_chunk_size = input_size & 0x7ff
    var num_chunks = full_chunks + Number(last_chunk_size != 0)

    var stack_size = 1
    for (var i = 1; i < num_chunks; i = i << 1) {
        stack_size += 1
    }
    
    return [stack_size, num_chunks]
}

console.log(
    Array(
        1024,
        1024 + 1,
        2 * 1024,
        2 * 1024 + 1,
        4096,
        4097,
        8 * 1024,
        8 * 1024 + 1
    ).map(
        x => stack_size(x)
    )
)
