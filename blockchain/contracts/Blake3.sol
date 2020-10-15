pragma solidity >= 0.5.0;

contract Blake3 {

  uint32 constant IV0 = 0x6a09e667;
  uint32 constant IV1 = 0xbb67ae85;
  uint32 constant IV2 = 0x3c6ef372;
  uint32 constant IV3 = 0xa54ff53a;
  uint32 constant IV4 = 0x510e527f;
  uint32 constant IV5 = 0x9b05688c;
  uint32 constant IV6 = 0x1f83d9ab;
  uint32 constant IV7 = 0x5be0cd19;

  uint32 constant         CHUNK_START = 0x01;
  uint32 constant           CHUNK_END = 0x02;
  uint32 constant              PARENT = 0x04;
  uint32 constant                ROOT = 0x08;
  uint32 constant          KEYED_HASH = 0x10;
  uint32 constant  DERIVE_KEY_CONTEXT = 0x20;
  uint32 constant DERIVE_KEY_MATERIAL = 0x40;

  constructor() public {
  }

  function G(
    uint32 a,
    uint32 b,
    uint32 c,
    uint32 d,
    uint32 m2i0,
    uint32 m2i1
  ) public pure
    returns (uint32, uint32, uint32, uint32)
  {
    uint32 _a = a;
    uint32 _b = b;
    uint32 _c = c;
    uint32 _d = d;

    _a = _a + _b + m2i0;
    _d = (( _d ^ _a ) >> 16) + (( _d ^ _a ) << 16);
    _c = _c + _d;
    _b = (( _b ^ _c ) >> 12) + (( _b ^ _c ) << 20);
    _a = _a + _b + m2i1;
    _d = (( _d ^ _a ) >> 8) + (( _d ^ _a ) << 24);
    _c = _c + _d;
    _b = (( _b ^ _c ) >> 7) + (( _b ^ _c ) << 25);
    return (_a, _b, _c, _d);
  }

  function compress(
    uint32[8] memory h,     // chaining value
    uint32[16] memory m,    // message block
    uint64 t,               // counter (t0, t1) - t0 lower, t1 higher
    uint32 b,               // # of bytes in message block
    uint32 d                // flags
  ) public pure
    returns (uint32[16] memory)
  {
    uint32[16] memory v;

    // The rounds and permutations between rounds are unrolled.

    // round 1 (and state initialization)
    // columns
    (v[0], v[4], v[8], v[12]) = G(h[0], h[4], IV0, uint32(t), m[0], m[1]);
    (v[1], v[5], v[9], v[13]) = G(h[1], h[5], IV1, uint32(t >> 32), m[2], m[3]);
    (v[2], v[6], v[10], v[14]) = G(h[2], h[6], IV2, b, m[4], m[5]);
    (v[3], v[7], v[11], v[15]) = G(h[3], h[7], IV3, d, m[6], m[7]);
    // diagonals
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[8], m[9]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[10], m[11]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7], v[8], v[13], m[12], m[13]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[14], m[15]);

    // round 2
    (v[0], v[4],  v[8], v[12]) = G(v[0], v[4], v[8], v[12], m[2], m[6]);
    (v[1], v[5], v[9], v[13]) = G(v[1], v[5], v[9], v[13],  m[3], m[10]);
    (v[2], v[6], v[10], v[14]) = G(v[2], v[6], v[10], v[14],  m[7], m[0]);
    (v[3], v[7], v[11], v[15]) = G(v[3], v[7], v[11], v[15], m[4], m[13]);
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[1], m[11]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[12], m[5]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7],  v[8], v[13], m[9], m[14]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[15], m[8]);

    // round 3
    (v[0], v[4],  v[8], v[12]) = G(v[0], v[4], v[8], v[12], m[3], m[4]);
    (v[1], v[5], v[9], v[13]) = G(v[1], v[5], v[9], v[13],  m[10], m[12]);
    (v[2], v[6], v[10], v[14]) = G(v[2], v[6], v[10], v[14],  m[13], m[2]);
    (v[3], v[7], v[11], v[15]) = G(v[3], v[7], v[11], v[15], m[7], m[14]);
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[6], m[5]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[9], m[0]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7],  v[8], v[13], m[11], m[15]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[8], m[1]);

    // round 4
    (v[0], v[4],  v[8], v[12]) = G(v[0], v[4], v[8], v[12], m[10], m[7]);
    (v[1], v[5], v[9], v[13]) = G(v[1], v[5], v[9], v[13],  m[12], m[9]);
    (v[2], v[6], v[10], v[14]) = G(v[2], v[6], v[10], v[14],  m[14], m[3]);
    (v[3], v[7], v[11], v[15]) = G(v[3], v[7], v[11], v[15], m[13], m[15]);
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[4], m[0]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[11], m[2]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7],  v[8], v[13], m[5], m[8]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[1], m[6]);

    // round 5
    (v[0], v[4],  v[8], v[12]) = G(v[0], v[4], v[8], v[12], m[12], m[13]);
    (v[1], v[5], v[9], v[13]) = G(v[1], v[5], v[9], v[13],  m[9], m[11]);
    (v[2], v[6], v[10], v[14]) = G(v[2], v[6], v[10], v[14],  m[15], m[10]);
    (v[3], v[7], v[11], v[15]) = G(v[3], v[7], v[11], v[15], m[14], m[8]);
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[7], m[2]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[5], m[3]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7],  v[8], v[13], m[0], m[1]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[6], m[4]);

    // round 6
    (v[0], v[4],  v[8], v[12]) = G(v[0], v[4], v[8], v[12], m[9], m[14]);
    (v[1], v[5], v[9], v[13]) = G(v[1], v[5], v[9], v[13],  m[11], m[5]);
    (v[2], v[6], v[10], v[14]) = G(v[2], v[6], v[10], v[14],  m[8], m[12]);
    (v[3], v[7], v[11], v[15]) = G(v[3], v[7], v[11], v[15], m[15], m[1]);
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[13], m[3]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[0], m[10]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7],  v[8], v[13], m[2], m[6]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[4], m[7]);

    // round 7
    (v[0], v[4],  v[8], v[12]) = G(v[0], v[4], v[8], v[12], m[11], m[15]);
    (v[1], v[5], v[9], v[13]) = G(v[1], v[5], v[9], v[13],  m[5], m[0]);
    (v[2], v[6], v[10], v[14]) = G(v[2], v[6], v[10], v[14],  m[1], m[9]);
    (v[3], v[7], v[11], v[15]) = G(v[3], v[7], v[11], v[15], m[8], m[6]);
    (v[0], v[5], v[10], v[15]) = G(v[0], v[5], v[10], v[15], m[14], m[10]);
    (v[1], v[6], v[11], v[12]) = G(v[1], v[6], v[11], v[12], m[2], m[12]);
    (v[2], v[7], v[8], v[13]) = G(v[2], v[7],  v[8], v[13], m[3], m[4]);
    (v[3], v[4], v[9], v[14]) = G(v[3], v[4], v[9], v[14], m[7], m[13]);

    // finalization
    v[0] ^= v[8]; v[1] ^= v[9]; v[2] ^= v[10]; v[3] ^= v[11];
    v[4] ^= v[12]; v[5] ^= v[13]; v[6] ^= v[14]; v[7] ^= v[15];
    v[8] ^= h[0]; v[9] ^= h[1]; v[10] ^= h[2]; v[11] ^= h[3];
    v[12] ^= h[4]; v[13] ^= h[5]; v[14] ^= h[6]; v[15] ^= h[7];

    return v;
  }

  function process_chunk(
    uint32[8] memory    in_cv,   // chaining value
    bytes memory        in_m,    // message
    uint64              in_t,    // chunk number
    bool                is_root  // root or not
  ) public pure
  returns (uint32[16] memory)
  {
    uint32 len_m = uint32(in_m.length);
    uint32 num_full_blocks = len_m >> 6;                           // div 64
    uint32 last_block_sz = len_m ^ ((len_m >> 6) << 6);       // mod 64    
    uint32 last_block;

    uint64 t = in_t;

    uint32[8] memory cv;
    uint32[16] memory compression_result;
    uint32 i;
    uint32 j;
    uint32 d;

    // prepare cv
    for (i = 0; i < 8; i++) {
      cv[i] = in_cv[i];
    }

    if (0 == len_m) {
      if (is_root) {
        d = d | ROOT;
      }
      return compress(cv, compression_result, t, 0, CHUNK_START | CHUNK_END | d);
    }

    bytes memory crt_m = new bytes(64);

    if (last_block_sz == uint32(0)) {
      last_block = num_full_blocks - 1;
    }
    else {
      last_block = num_full_blocks;
    }

    for (i = 0; i < num_full_blocks; i++) {

      // prepare flags
      d = 0;

      if (i == 0) {
        d = d | CHUNK_START;
      }

      if (i == last_block) {
        d = d | CHUNK_END;
        if (is_root) {
          d = d | ROOT;
        }
      }

      // prepare crt_m
      for (j=0; j<64; j++) {
        crt_m[j] = in_m[(i << 6)+j];
      }

      compression_result = compress(
        cv,
        mybytestouint32(crt_m),
        t,
        64,
        d
      );

      // truncate result
      for (j=0;j<8;j++) {
        cv[j] = compression_result[j];
      }

    }

    if (last_block_sz != 0) {
      d = CHUNK_END;
      if (num_full_blocks == 0) {
        d = d | CHUNK_START;
      }
      if (is_root) {
        d = d | ROOT;
      }

      // prepare crt_m
      for (j=0; j<last_block_sz; j++) {
        crt_m[j] = in_m[(num_full_blocks << 6)+j];
      }
      for (j=last_block_sz; j<64; j++) {
        crt_m[j] = bytes1(0);
      }

      if (last_block_sz != uint32(0)) {
        compression_result = compress(
          cv,
          mybytestouint32(crt_m),
          t,
          last_block_sz,
          d
        );
      }
    }

    return compression_result;
  }

  function keyed_hash(
    bytes memory input,
    uint32[8] memory key
  ) public pure
  returns (uint32[16] memory)
  {
    uint256 i = 0;
    bytes memory message = new bytes(1024);
    uint32[16] memory res1;
    uint32[16] memory res2;
    uint32[16] memory res3;
    uint32[16] memory m;

    for(i=0;i<1024; i++) {
      message[i] = input[i];
    }
    res1 = process_chunk(
      key,
      message,
      0,
      false
    );

    for(i=1024;i<2048; i++) {
      message[i-1024] = input[i];
    }
    res2 = process_chunk(
      key,
      message,
      1,
      false
    );

    for (i=0; i<8; i++) {
      m[i] = res1[i];
    }
    for (i=8; i<16; i++) {
      m[i] = res2[i-8];
    }
    
    res3 = compress(
      key,
      m,
      0,
      64,
      PARENT | ROOT
    );

    return res3;
  }

  function hash(
    bytes memory input
  ) public pure
  returns (uint32[16] memory)
  {
    uint32[8] memory key = [IV0, IV1, IV2, IV3, IV4, IV5, IV6, IV7];
    return keyed_hash(input, key);
  }

  function mybytestouint32(bytes memory input)
    public pure
  returns (uint32[16] memory) {
    // takes in at most 64 bytes
    // returns an array of unsigned integers


    uint32[16] memory ret;

    uint256 full = input.length / 4;
    uint256 i;
    uint32 k;
    uint256 remainder;

    if (full > 16) {
        full = 16;
        remainder = 0;
    }
    else {
        remainder = input.length % 4;
    }

    for (i=0; i< full; i++) {
        ret[i] = 0;
        for (k=0; k<4; k++) {
            ret[i] += uint32(uint8(input[4*i + k])) << (8*k);
        }
    }
    if ( (full < 16) && (remainder != 0) ) {
        ret[full] = 0;
        for (k=0; k<remainder; k++) {
            ret[full] += uint32(uint8(input[4*full + k])) << (8*k);
        }
    }

    return ret;
  }
}
