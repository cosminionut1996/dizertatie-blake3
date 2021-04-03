const fs = require('fs');
const readline = require('readline');

const readInterface = readline.createInterface({
    input: fs.createReadStream('./blockchain/test_inputs'),
    // output: fs.createWriteStream('out'), //process.stdout,
    // terminal: false
});

readInterface.on('line', function(line) {
    console.log(Buffer.from(line, 'base64'));
});
