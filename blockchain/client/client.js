


var provider = new Web3.providers.HttpProvider("http://localhost:7545");
var contract = require("../contracts/HelloWorld");
 
// var MyContract = contract({
//   abi: ...,
//   unlinked_binary: ...,
//   address: ..., // optional
//   // many more
// })
// MyContract.setProvider(provider);

console.log(provider)
console.log(contract)
