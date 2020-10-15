const Blake3 = artifacts.require("./Blake3")

IV = [
  0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
  0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
]

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
    it('checks mixing function G', async () => {
      const contract = await Blake3.deployed()
      await contract.G(1, 2, 3, 4, 5, 6).then(
        function(res) {
          assert.equal(res[0].toNumber(), 1048782, 'results do not match')
          assert.equal(res[1].toNumber(), 2275162169, 'results do not match')
          assert.equal(res[2].toNumber(), 3456900099, 'results do not match')
          assert.equal(res[3].toNumber(), 3456113664, 'results do not match')
      })
    })

    it('checks compression function', async () => {
      const contract = await Blake3.deployed()
      await contract.compress(
        [1, 2, 3, 4, 5, 6, 7, 8],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
        1,
        16,
        0
      ).then((res) => {
        assert.equal(res[0].toNumber(), 1026070643, 'results do not match')
        assert.equal(res[1].toNumber(), 2044347425, 'results do not match')
        assert.equal(res[2].toNumber(), 730350557, 'results do not match')
        assert.equal(res[3].toNumber(), 292570700, 'results do not match')
        assert.equal(res[4].toNumber(), 1300339734, 'results do not match')
        assert.equal(res[5].toNumber(), 3654734489, 'results do not match')
        assert.equal(res[6].toNumber(), 513022977, 'results do not match')
        assert.equal(res[7].toNumber(), 3352352573, 'results do not match')
        assert.equal(res[8].toNumber(), 3781553364, 'results do not match')
        assert.equal(res[9].toNumber(), 3125397589, 'results do not match')
        assert.equal(res[10].toNumber(), 3728701371, 'results do not match')
        assert.equal(res[11].toNumber(), 1496197852, 'results do not match')
        assert.equal(res[12].toNumber(), 2680672175, 'results do not match')
        assert.equal(res[13].toNumber(), 3640847171, 'results do not match')
        assert.equal(res[14].toNumber(), 3257159665, 'results do not match')
        assert.equal(res[15].toNumber(), 1237596367, 'results do not match')
      })
    })

    it('checks chunk processing function', async () => {
      const contract = await Blake3.deployed()
      await contract.process_chunk(
          IV,
          Array(10).fill(null).map((u, i) => i+1),
          0,
          true
      ).then((res) => {
        numbers = res.map((currentValue) => currentValue.toNumber())
        s = array_uint32_to_array_hex_64(numbers)
        console.log(s)
      })

      await contract.process_chunk(IV, [], 0, true).then((res) => {
        numbers = res.map((currentValue) => currentValue.toNumber())
        s = array_uint32_to_array_hex_64(numbers)
        console.log(s)
      })

      await contract.process_chunk(
        IV,
        Array(128).fill(3),
        0,
        true
      ).then((res) => {
        numbers = res.map((currentValue) => currentValue.toNumber())
        s = array_uint32_to_array_hex_64(numbers)
        console.log(s)
      })

      await contract.process_chunk(
        IV,
        Array(150).fill(5),
        0,
        true
      ).then((res) => {
        numbers = res.map((currentValue) => currentValue.toNumber())
        s = array_uint32_to_array_hex_64(numbers)
        console.log(s)
      })
    })

    it('checks the bytes to uint32 conversion function', async () => {
      const contract = await Blake3.deployed()
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
      contract.keyed_hash(
        Array(2048).fill(2),
        IV
      ).then((res) => {
        numbers = res.map((currentValue) => currentValue.toNumber())
        s = array_uint32_to_array_hex_64(numbers)
        console.log(s)
      })
    })

    it('runs the hash function', async () => {
      const contract = await Blake3.deployed()
      contract.hash(
        Array(2048).fill(2)
      ).then((res) => {
        numbers = res.map((currentValue) => currentValue.toNumber())
        s = array_uint32_to_array_hex_64(numbers)
        console.log(s)
      })
    })
})
