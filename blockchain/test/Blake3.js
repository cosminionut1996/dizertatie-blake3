const Blake3 = artifacts.require("./Blake3")

IV = [
  0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
  0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
]

IV_BYTES = [0x67, 0xe6, 0x9, 0x6a, 0x85, 0xae, 0x67, 0xbb, 0x72, 0xf3, 0x6e, 0x3c, 0x3a, 0xf5, 0x4f, 0xa5, 0x7f, 0x52, 0xe, 0x51, 0x8c, 0x68, 0x5, 0x9b, 0xab, 0xd9, 0x83, 0x1f, 0x19, 0xcd, 0xe0, 0x5b]


function array_uint32_to_array_hex_64(numbers) {
  b = Buffer.alloc(64)
  for (var i = 0; i < 16; i++) {
    b.writeUInt32LE(numbers[i], 4*i)
  }
  s = ""
  for (var i = 0; i < 64; i++) {
    s += b[i].toString('16')
    s += ' '
  }
  return s
}


contract('Blake3', function(accounts) {

    it('checks compression function', async () => {
      const contract = await Blake3.deployed()
      await contract.compress(
        [1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 6, 0, 0, 0, 7, 0, 0, 0, 8, 0, 0, 0],
        [
          [0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 6, 0, 0, 0, 7, 0, 0, 0],
          [8, 0, 0, 0, 9, 0, 0, 0, 10, 0, 0, 0, 11, 0, 0, 0, 12, 0, 0, 0, 13, 0, 0, 0, 14, 0, 0, 0, 15, 0, 0, 0]
        ],
        1,
        16,
        0
      ).then((res) => {
        assert.equal(res[0].toString(), '0x7398283d2144da79dd43882b4c467011169c814d99d2d6d9011c941e3dd7d0c7', 'bad compression result')
        assert.equal(res[1].toString(), '0xd4ec65e155c849babb773fdedc2a2e59afcfc79f43eb02d9f14f24c2cf38c449', 'bad compression result')
      })
    })

    it('checks chunk processing function', async () => {
      const contract = await Blake3.deployed()
      message = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]

      // Empty message
      await contract.process_chunk(IV_BYTES, message, 0, 0, true).then((res) => {
        assert.equal(res[0], '0xaf1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262', 'bad process_chunk function')
        assert.equal(res[1], '0xe00f03e7b69af26b7faaf09fcd333050338ddfe085b8cc869ca98b206c08243a', 'bad process_chunk function')
      })

      // A couple of bytes
      message[0] = [1, 0, 0, 0]
      await contract.process_chunk(IV_BYTES, message, 4, 0, true).then((res) => {
        assert.equal(res[0], '0xc610e85212d0697cb161d4ba431ba603f273feee7dcb7927c9ff5d74ae6cbfa3', 'bad process_chunk function')
        assert.equal(res[1], '0x3e99c42522429acfaa8e366cddf802d100076a1318db6ec475fbb1dbbac35895', 'bad process_chunk function')
      })

      message[0] = [1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, 5, 0, 0, 0, 6, 0, 0, 0, 7, 0, 0, 0, 8, 0, 0, 0]
      message[1] = [9, 0, 0, 0, 10, 0, 0, 0]
      await contract.process_chunk(IV_BYTES, message, 40, 0, true).then((res) => {
        assert.equal(res[0], '0xf0b6ef611a0583cc91676d5ada0576fb4511b59b26a7ed4e6fd6307a7571a541', 'bad process_chunk function')
        assert.equal(res[1], '0x6378142f41953a78de7d9e8227016df592bc9c2e3a38425d714486882a3e9d08', 'bad process_chunk function')
      })

      message[0] = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
      message[1] = message[0]
      message[2] = message[0]
      message[3] = message[0]
      await contract.process_chunk(IV_BYTES, message, 128, 0, true).then((res) => {
        assert.equal(res[0], '0xaf894595c5f4f086c867042df34916f80158b75146aa4dd888f765074f90199c', 'bad process_chunk function')
        assert.equal(res[1], '0x7a644242e81e7be6a395b6256f857229a8e7ad513ce15247a732962c90478ec4', 'bad process_chunk function')
      })

      message[0] = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
      message[1] = message[0]
      message[2] = message[0]
      message[3] = message[0]
      message[4] = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
      await contract.process_chunk(IV_BYTES, message, 150, 0, true).then((res) => {
        assert.equal(res[0], '0x3dbb2d2129b0e52efe516119d7dd6ac13ee983883e1791c49daef8ba2c9911d4', 'bad process_chunk function')
        assert.equal(res[1], '0xd99ae8a988bb9b697240497f17ddc8de612ab62b8c81d462c9da7a66741da24c', 'bad process_chunk function')
      })
    })

    it('checks the bytes to uint32 conversion function', async () => {
      const contract = await Blake3.deployed()

      gas = await contract.mybytestouint32.estimateGas(() => {})
      console.log("Gas estimation - mybytestouint32 - ", gas)

      await contract.mybytestouint32(
        [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A]
      ).then((res) => {
        assert.equal(res[0].toNumber(), 0x4030201, 'bad first int')
        assert.equal(res[1].toNumber(), 0x8070605, 'bad second int')
        assert.equal(res[2].toNumber(), 0xA09, 'bad third int')
      })
    })

    it('runs the keyed hash function', async () => {
      const contract = await Blake3.deployed()

      // gas = await contract.keyed_hash.estimateGas(() => {})
      // console.log("Gas estimation - keyed_hash - ", gas)

      await contract.keyed_hash(
        Array(1024).fill(2),
        IV_BYTES
      ).then((res) => {
        assert.equal(res[0], '0xfa8af17567c147993830cdd42cea9d8a8f157c9b98b4e7ef5677f417a5d8ae61', 'bad keyed_hash function')
        assert.equal(res[1], '0xd69756eedb1818331b5c857e900384350a5659ff439d353b02431621cb3f5f0b', 'bad keyed_hash function')
      })

      await contract.keyed_hash(
        Array(2048).fill(2),
        IV_BYTES
      ).then((res) => {
        assert.equal(res[0], '0x2c3465f993eca019e0de8d085ac02284d0f1e9ad592e0fda9b6f33ee7ecf8adb', 'bad keyed_hash function')
        assert.equal(res[1], '0xb8b9fec6daacff07ac49612623d4105bfca15f10ea9020c8505c7173b26279e1', 'bad keyed_hash function')
      })

      await contract.keyed_hash(
        Array(2047).fill(2),
        IV_BYTES
      ).then((res) => {
        assert.equal(res[0], '0xb0ba41d1c6e1597a7427ef5395691cd5a3045df0de11e6f8a9d32e5341707a69', 'bad keyed_hash function')
        assert.equal(res[1], '0xc191f3b53f7d60e92f262df5b94feadf71af8bc0db27cfd3b517b41d6e11ad40', 'bad keyed_hash function')
      })

    })

    // it('runs the hash function', async () => {
    //   const contract = await Blake3.deployed()
    //   contract.hash(
    //     Array(2048).fill(2)
    //   ).then((res) => {
    //     numbers = res.map((currentValue) => currentValue.toNumber())
    //     s = array_uint32_to_array_hex_64(numbers)
    //     console.log(s)
    //   })
    // })
})
