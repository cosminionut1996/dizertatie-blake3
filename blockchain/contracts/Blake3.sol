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

  // function tada() public returns (bytes32[2] memory c) {

  //   uint256[3] memory input;
  //   input[0] = 1;
  //   input[1] = 2;
  //   input[2] = 3;

  //   assembly {
	// 		let x := mload(0x40)    //Find empty storage location using "free memory pointer"

	// 		// mstore(xti, 2)            //Place size
	// 		// mstore(add(x,0x04), 123)  //Place first argument directly next to signature
	// 		// mstore(add(x,0x24), 456)  //Place second argument next to first, padded to 32 bytes

	// 		let success := staticcall(      //This is the critical change (Pop the top stack value)
	// 							gas(),      //gas
	// 							0x13,       //Contract addr
	// 							// 0, //No value
	// 							input,      //Inputs are stored at location x
	// 							96,        //Input number of bytes
	// 							x,         //Output address
	// 							96)        //Output number of bytes

  //     mstore(c, mload(x))
  //     mstore(add(c, 32), mload(add(x, 32)))
  //     mstore(add(c, 64), mload(add(x, 64)))

	// 		mstore(0x40,add(x,0x44))    // Set storage pointer to empty space
	// 	}
	// }

  function compress(
    bytes32           in_cv,    // chaining value
    bytes32[2] memory in_m,     // message
    uint64            t,        // counter - t=t0t1 - t0 lower order, t1 higher order
    uint32            b,        // number of bytes in the block
    uint32            d         // flags
  ) public view
  returns (bytes32[2] memory output)
  {
    bytes32[4] memory input;

    input[0] = in_cv;
    input[1] = in_m[0];
    input[2] = in_m[1];
    input[3] = 0;
    input[3] = input[3] | bytes32((uint256(t & 0xffffffffffffffff) << 192));
    input[3] = input[3] | bytes32((uint256(b & 0xffffffff) << 160));
    input[3] = input[3] | bytes32((uint256(d & 0xffffffff) << 128));

    assembly {

			// mstore(xti, 2)            //Place size
			// mstore(add(x,0x04), 123)  //Place first argument directly next to signature
			// mstore(add(x,0x24), 456)  //Place second argument next to first, padded to 32 bytes

			if iszero(staticcall(      //This is the critical change (Pop the top stack value)
								gas(),      //gas
								0x13,       //Contract addr
								// 0, //No value
								input,     //Inputs are stored at location x
								112,       //Input number of bytes
								output,         //Output address
								64)        //Output number of bytes
      ) {
        revert(0, 0)
      }

		}

    return output;
  }

  function process_chunk(
    bytes32               cv,       // chaining value
    bytes32[32] memory    message,  // message
    uint32                len_m,    // message size
    uint64                t,        // chunk number
    bool                  is_root   // root or not
  ) public view
  returns (bytes32[2] memory slice)
  {
    uint32 num_full_blocks = len_m >> 6;    // div 64
    uint32 last_block_sz = len_m & 0x3f;    // mod 64
    uint32 last_block;
    uint32 i;
    uint32 d;


    if (0 == len_m) {
      if (is_root) {
        d = d | ROOT;
      }
      slice[0] = message[0];
      slice[1] = message[1];
      return compress(cv, slice, t, 0, CHUNK_START | CHUNK_END | d);
    }

    if (last_block_sz == uint32(0)) {
      last_block = num_full_blocks - 1;
    }
    else {
      last_block = num_full_blocks;
    }

    for (i = 0; i < num_full_blocks; i++) {

      // prepare message for compression
      slice[0] = message[i*2];
      slice[1] = message[i*2 + 1];

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

      slice = compress(cv, slice, t, 64, d);

      // truncate result
      cv = slice[0];

    }

    if (last_block_sz != 0) {
      d = CHUNK_END;
      if (num_full_blocks == 0) {
        d = d | CHUNK_START;
      }
      if (is_root) {
        d = d | ROOT;
      }

      if (last_block_sz != 0) {
        slice[0] = message[num_full_blocks * 2];
        slice[1] = message[num_full_blocks * 2 + 1];
        slice = compress(cv, slice, t, last_block_sz, d);
      }
    }

    return slice;
  }

  // function keyed_hash(
  //   bytes memory input,
  //   uint32[8] memory key
  // ) public view
  // returns (bytes32[2] memory)
  // {
  //   uint256 i;
  //   uint256 j;

  //   bytes32[32] memory message;

  //   uint32[16] memory m;
  //   bytes32[2] memory res;

  //   uint256 stack_size;
  //   uint256 num_chunks;

  //   (stack_size, num_chunks) = stack_size_num_chunks(input.length);
  //   uint32[] memory stack = new uint32[](stack_size * 8);

  //   uint32 stack_index = 0;
  //   uint64 chunk_nb = 0;
  //   uint64 aux_chunk_nb;
  //   uint32 max = 0;


  //   for (i = 0; i < input.length; i += 1024) {

  //     for(j = 0; j < 1024; j++) {
  //       message[j] = bytes1(input[j+i]);
  //     }
  //     res = process_chunk(key, message, chunk_nb, false);

  //     for(j = 0; j < 8; j++) {
  //       stack[stack_index + j] = res[j];
  //     }
  //     stack_index += 8;

  //     chunk_nb += 1;
  //     aux_chunk_nb = chunk_nb;
  //     max = 0;
  //     while ((aux_chunk_nb > 0) && (aux_chunk_nb & 1 == 0)) {
  //       max += 1;
  //       if (max == 100) {
  //         res[0] = uint32(aux_chunk_nb);
  //         return res;
  //       }
  //       aux_chunk_nb = aux_chunk_nb / 2;

  //       stack_index -= 16;
  //       for (j = 0; j < 16; j++) {
  //         m[j] = stack[stack_index + j];
  //       }

  //       if ( (chunk_nb == num_chunks) && (stack_index == 0) ) {
  //         return compress(key, m, 0, 64, PARENT | ROOT);
  //       }

  //       res = compress(key, m, 0, 64, PARENT);
  //       for(j = 0; j < 8; j++) {
  //         stack[stack_index + j] = res[j];
  //       }
  //       stack_index += 8;

  //     }

  //   }

  //   // for(i=0;i<1024; i++) {
  //   //   message[i] = input[i];
  //   // }
  //   // res1 = process_chunk(
  //   //   key,
  //   //   message,
  //   //   0,
  //   //   false
  //   // );

  //   // for(i=1024;i<2048; i++) {
  //   //   message[i-1024] = input[i];
  //   // }
  //   // res2 = process_chunk(
  //   //   key,
  //   //   message,
  //   //   1,
  //   //   false
  //   // );

  //   // for (i=0; i<8; i++) {
  //   //   m[i] = res1[i];
  //   // }
  //   // for (i=8; i<16; i++) {
  //   //   m[i] = res2[i-8];
  //   // }
    
  //   // res3 = compress(
  //   //   key,
  //   //   m,
  //   //   0,
  //   //   64,
  //   //   PARENT | ROOT
  //   // );

  //   // return res3;
    
  //   // for(j = 0; j < 16; j++) {
  //   //   res[j] = stack[j];
  //   // }
  //   // return res;
  //   return res;
  // }

  // function hash(
  //   bytes memory input
  // ) public view
  // returns (uint32[16] memory)
  // {
  //   uint32[8] memory key = [IV0, IV1, IV2, IV3, IV4, IV5, IV6, IV7];
  //   return keyed_hash(input, key);
  }

  function stack_size_num_chunks(uint256 input_size)
    private pure
    returns (uint256, uint256) {
      uint256 full_chunks = input_size >> 10;
      uint256 last_chunk_sz = input_size & 0x7ff;
      uint256 num_chunks = full_chunks;
      if (last_chunk_sz != 0) {
        num_chunks += 1;
      }

      uint256 stack_size = 1;
      uint256 i;
      for (i = 1; i < num_chunks; i <<= 1) {
        stack_size += 1;
      }

      return (stack_size, num_chunks);
  }

  function mybytestouint32(bytes memory input)
    public pure
  returns (uint32[16] memory) {
    // takes in at most 64 bytes
    // returns an array of unsigned integers
    uint data_ptr;
    uint state_ptr;
    uint i;
    uint32[16] memory ret;

    assembly {
      data_ptr := add(input, 1)
      state_ptr := add(ret, 31)
    }

    while (i < input.length) {
      
      assembly {
        mstore8(state_ptr, mload(data_ptr))
        data_ptr := add(data_ptr, 1)
        state_ptr := sub(state_ptr, 1)

        i := add(i, 1)
      }

      if (0 == (i & 0x3) ) {
        state_ptr += 36;
      }
      
    }

    return ret;
  }
}
