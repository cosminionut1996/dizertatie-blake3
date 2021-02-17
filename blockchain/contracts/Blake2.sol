pragma solidity >= 0.5.0;

contract Blake2 {

  bytes8 constant IV0 = 0x6a09e667f3bcc908;
  bytes8 constant IV1 = 0xbb67ae8584caa73b;
  bytes8 constant IV2 = 0x3c6ef372fe94f82b;
  bytes8 constant IV3 = 0xa54ff53a5f1d36f1;
  bytes8 constant IV4 = 0x510e527fade682d1;
  bytes8 constant IV5 = 0x9b05688c2b3e6c1f;
  bytes8 constant IV6 = 0x1f83d9abfb41bd6b;
  bytes8 constant IV7 = 0x5be0cd19137e2179;


  function compress(
    bytes8[8] memory h,         // state vector
    bytes32[4] memory chunk,    // 128-byte chunk of message to compress
    uint128 t,                  // count of bytes that have been fed into the compression
    bool is_last_block
  ) public view
  returns (bytes8[8] memory)
  {
    bytes32[7] memory input;        // needs to be 213 bytes
    // uint32 rounds = 12;
    bytes32[2] memory fnc_output;

    assembly {
      mstore8(add(input, 3), 12)                      // sets rounds
    }

    // sets h correctly
    for (int i = 0; i < 8; i++) {
      assembly {
        let input_start := add(4, mul(8, i))
        let input_end := add(3, mul(8, add(i, 1)))
        let middle := add(div(add(input_start, input_end), 2), 1)
        let aux := 0
        let offset2 := 0

        // sets h
        mstore(
          add(input, add(4, mul(8, i))),
          mload(add(h, mul(32, i)))
        )

        // swap byte order - go implementation requires little endian, not big endian
        for {let j := input_start} lt(j, middle) { j := add(j, 1) } {
          // j := input_start
          offset2 := add(sub(input_end, j), input_start)
          aux := mload(add(input, j))
          mstore8(add(input, j), shr(248, mload(add(input, offset2))))
          mstore8(add(input, offset2), shr(248, aux))
        }

      }
    }

    assembly {
      mstore(add(input, 68), mload(chunk))            // sets message
      mstore(add(input, 100), mload(add(chunk, 32)))
      mstore(add(input, 132), mload(add(chunk, 64)))
      mstore(add(input, 164), mload(add(chunk, 96)))

      mstore(add(input, 196), shl(128, t))               // sets t

      let aux := 0
      let offset2 := 0
      // swap byte order - go implementation requires little endian, not big endian
      for {let j := 196} lt(j, 204) { j := add(j, 1) } {
        // j := input_start
        offset2 := add(sub(211, j), 196)
        aux := mload(add(input, j))
        mstore8(add(input, j), shr(248, mload(add(input, offset2))))
        mstore8(add(input, offset2), shr(248, aux))
      }
    }
    
    if (is_last_block) {
      assembly { mstore8(add(input, 212), 1) }
    }
    else {
      assembly { mstore8(add(input, 212), 0) }
    }

    assembly {
			// mstore(xti, 2)            //Place size
			// mstore(add(x,0x04), 123)  //Place first argument directly next to signature
			// mstore(add(x,0x24), 456)  //Place second argument next to first, padded to 32 bytes
			if iszero(staticcall(      //This is the critical change (Pop the top stack value)
								gas(),     //gas
								0x9,       //Contract addr
								// 0,      //No value
								input,     //Inputs are stored at location x
								213,       //Input number of bytes
								fnc_output,    //Output address
								64)        //Output number of bytes
      ) {
        revert(0, 0)
      }
		}

    assembly { 
      for {
        let ih := 0
        let ifnc_output := 0
      } lt(ih, 256) {
         ih := add(ih, 32)
         ifnc_output := add(ifnc_output, 8)
      } {
        mstore(add(h, ih), mload(add(fnc_output, ifnc_output)))
      }

    }

    return h;
  }

  function hash(
      bytes memory input
  ) public view
  returns (bytes8[8] memory) {

    uint128 i;
    uint128 p;
    bytes32[4] memory chunk;
    bytes32 temp;

    uint64 cbKeyLen = 0;    // No keyed hash
    // Initialize State vector h with IV
    bytes8[8] memory h = [IV0, IV1, IV2, IV3, IV4, IV5, IV6, IV7];

    //Mix key size (cbKeyLen) and desired hash length (cbHashLen) into h0
    //kk = key len in bytes
    //nn = desired hash len in bytes - 64 = 0x40
    h[0] = h[0] ^ 0x0000000001010040;    // 0x0101kknn

    //Each time we Compress we record how many bytes have been compressed
    uint128 cBytesCompressed = 0;
    uint128 cBytesRemaining = uint128(input.length);

    //If there was a key supplied (i.e. cbKeyLen > 0) 
    //then pad with trailing zeros to make it 128-bytes (i.e. 16 words) 
    //and prepend it to the message M
    if (cbKeyLen > 0) {     // won't be > 0 for these tests
        // M = pad(key, 128) || M
        cBytesRemaining = cBytesRemaining + 128;
    }

    //Compress whole 128-byte chunks of the message, except the last chunk
    while (cBytesRemaining > 128) {
        //chunk = get next 128bytes chunk from M
        for( i = 0; i < 4; i = i + 1) {
            p = 32 + cBytesCompressed + (i * 32);
            assembly {
                temp := mload(add(input, p))
                mstore(add(chunk, mul(i, 32)), temp)
            }
            // chunk[i] = temp;
        }

        cBytesCompressed = cBytesCompressed + 128;
        cBytesRemaining = cBytesRemaining - 128;
        h = compress(h, chunk, cBytesCompressed, false);    // false => not last chunk

        // reverse endianness for h
        assembly { 
          for {let ih := 0} lt(ih, 256) {ih := add(ih, 32)} {
           
            let aux := 0
            let offset1 := 0
            let offset2 := 0
            // swap byte order - go implementation requires little endian, not big endian
            for {let j := 0} lt(j, 4) { j := add(j, 1) } {
              // j := input_start
              offset1 := add(ih, j)
              offset2 := add(ih, sub(7, j))
              aux := mload(add(h, offset1))
              mstore8(add(h, offset1), shr(248, mload(add(h, offset2))))
              mstore8(add(h, offset2), shr(248, aux))
            }
          }

        }
    }

    //Compress the final bytes from M

    //    chunk ← Pad(chunk, 128)  If M was empty, then we will still compress a final chunk of zeros
    chunk[0] = 0; chunk[1] = 0; chunk[2] = 0; chunk[3] = 0;
    //    chunk ← get next 128 bytes of message M  We will get cBytesRemaining bytes (i.e. 0..128 bytes)
    for (i = 0; i < cBytesRemaining; i++) {
        assembly{
            let offset := add(add(cBytesCompressed, i), 32)
            // ((char*)chunk)[i] = input[32 + cBytesCompressed + i]
            mstore8(add(chunk, i), shr(248, mload(add(input, offset))))
        }
    }
    cBytesCompressed = cBytesCompressed + cBytesRemaining;  // The actual number of bytes leftover in M

    h = compress(h, chunk, cBytesCompressed, true);          // true ⇒ this is the last chunk
    return h;
  }

}
