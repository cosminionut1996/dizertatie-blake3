const F = artifacts.require("./F")


contract('Blake2', function(accounts) {


    it('checks F hash function', async () => {
        const contract = await F.deployed()
1
        c = Array.from(Array(4096).fill(3))
        let start = Date.now()
        console.log(`Running hash now: ${start}`)
        await contract.hash(c).then((res) => {
            // console.log(res)
            // expected = [
            //     '0x9061efb74384e444',
            //     '0xa08131e7860fd289',
            //     '0x17c7d122b1b52888',
            //     '0xe0f14637f5f6511a',
            //     '0x9a0a77baa8c588d6',
            //     '0xf45282fd3a1b5b26',
            //     '0x6e7172ad0c81ddb3',
            //     '0xa8d410201ede7263'
            // ]
            // for (var i = 0; i < res.length; i++) {
            //     assert.equal(res[i].toString(), expected[i], 'bad compression result')
            // }
        })


    })

})
