pragma solidity >= 0.5.0;

contract F {

  // keccak256(bytes memory) returns (bytes32)


  function hash(bytes memory input)
        public view returns (bytes32)
  {
      bytes32 x;
      x = keccak256(input);
      return x;
  }

}
