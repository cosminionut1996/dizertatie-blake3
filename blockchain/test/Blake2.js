const Blake2 = artifacts.require("./Blake2")

IV_BLAKE2 = ["0x6a09e667f3bcc908", "0xbb67ae8584caa73b", "0x3c6ef372fe94f82b", "0xa54ff53a5f1d36f1", "0x510e527fade682d1", "0x9b05688c2b3e6c1f", "0x1f83d9abfb41bd6b", "0x5be0cd19137e2179"]

contract('Blake2', function(accounts) {

    // it('checks blake2b compression function', async () => {
    //     const contract = await Blake2.deployed()
    //     await contract.compress(
    //         IV_BLAKE2,
    //         [
    //         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    //         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    //         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    //         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    //         ],
    //         0,
    //         true
    //     ).then((res) => {

    //         expected = [
    //             '0xdabdcd75bb7a0897',
    //             '0x85f9765ed089bb4d',
    //             '0x7f72178500e45f0a',
    //             '0xb64196a93893317d',
    //             '0xb03ebd79cf34e260',
    //             '0x26437e5e26a2dcc3',
    //             '0x14b9ed1335be3b0f',
    //             '0xe0b3987555e23743'
    //         ]

    //         for (var i = 0; i < res.length; i++) {
    //             assert.equal(res[i].toString(), expected[i], 'bad compression result')
    //         }
    //     })
    // })

    // it('checks blake2b hash function 1', async () => {
    //     const contract = await Blake2.deployed()

    //     c = Array.from(Array(10).keys())

    //     await contract.hash(c).then((res) => {

    //         expected = [
    //             '0x29102511d749db3c',
    //             '0xc9b4e335fa1f5e8f',
    //             '0xaca8421d558f6a3f',
    //             '0x3321d50d044a248b',
    //             '0xa595cfc3efd3d2ad',
    //             '0xc97334da732413f5',
    //             '0xcbf4751c362ba1d5',
    //             '0x3862ac1e8dabeee8'
    //           ]

    //           for (var i = 0; i < res.length; i++) {
    //             assert.equal(res[i].toString(), expected[i], 'bad compression result')
    //         }
    //     })
    // })

    it('checks blake2b hash function 2', async () => {
        const contract = await Blake2.deployed()

        // c = Array.from(Array(100).fill(3))
        // await contract.hash(c).then((res) => {
        //     expected = [
        //         '0x792f6cdbab1dace3',
        //         '0x5b77f85da50cb865',
        //         '0x557a6397a353cd84',
        //         '0xbd6465f02d911e95',
        //         '0xf945b98601a44eb3',
        //         '0x56d15e1d41a934b9',
        //         '0x6fb08252456a6e7e',
        //         '0x24fd316aabb7e73a'
        //     ]

        //     for (var i = 0; i < res.length; i++) {
        //         assert.equal(res[i].toString(), expected[i], 'bad compression result')
        //     }
        // })

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

        // c = Array.from(Array(129).keys())
        // await contract.hash(c).then((res) => {
        //     // console.log(res)
        //     expected = [
        //         '0xf59711d44a031d5f',
        //         '0x97a9413c065d1e61',
        //         '0x4c417ede99859032',
        //         '0x5f49bad2fd444d3e',
        //         '0x4418be19aec4e114',
        //         '0x49ac1a57207898bc',
        //         '0x57d76a1bcf356629',
        //         '0x2c20c683a5c4648f'
        //     ]
        //     for (var i = 0; i < res.length; i++) {
        //         assert.equal(res[i].toString(), expected[i], 'bad compression result')
        //     }
        // })


        // c = Array.from(Array(1000).fill(3))
        // let start = Date.now()
        // console.log(`Running hash now: ${start}`)
        // await contract.hash(c).then((res) => {
        //     // console.log(res)
        //     expected = [
        //         '0x884d2c7d0fd47e24',
        //         '0x1122364433096eb2',
        //         '0x899c622ca7f1ca03',
        //         '0x771332de9d2d9d47',
        //         '0xa2bd903136567e49',
        //         '0x5a6154ffdf45f9cb',
        //         '0xb9c160416f18ac88',
        //         '0xd4b21dff5655f526'
        //     ]
        //     for (var i = 0; i < res.length; i++) {
        //         assert.equal(res[i].toString(), expected[i], 'bad compression result')
        //     }
        // })
        // console.log("Finished running hash now")

    })

})
