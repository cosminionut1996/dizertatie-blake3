pragma solidity >= 0.5.0;

contract HelloWorld {

  uint storedData;
  address creator;
  string message;

  constructor () public {
    creator = msg.sender;
    message = "hello world";
  }

  function getCreator() public view returns(address) {
    return creator;
  }

  function getMessage() public view returns(string memory) {
    return message;
  }

  function setMessage(string memory new_message)
      public
      returns(string memory) {
    message = new_message;
  }

  function set(uint x) public {
    storedData = x;
  }

  function get() public view returns (uint) {
    return storedData;
  }

}
