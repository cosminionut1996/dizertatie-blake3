pragma solidity >= 0.5.0;

contract F {

  // keccak256(bytes memory) returns (bytes32)


  function hash(bytes memory input)
        public view returns (bytes20)
  {
      bytes20 x;
      x = ripemd160(input);
      return x;
  }

}