// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract PayBits is ERC20 {
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;
    uint validators_count;
    uint hashDigits = 8;
    uint hashModulus = 10 ** hashDigits;
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        string memory validator_name,
        string memory validator_ID
    ) ERC20(name, symbol) {
        _setOwner(_msgSender());
        _mint(owner(), initialSupply);
        add_wallet_sign(_msgSender(), validator_name, validator_ID);
    }

    struct validator{
        uint hash_data;
        address wallet;
    }
    struct mint_request{
        address walllet;
        uint value;
        uint timeStamp;
    }
    
    validator[] public validators;
    mint_request[] public mint_requests;
    
    mapping (address => mapping (uint => bool)) validator_signed;
    mapping (uint => uint) total_signs;
    mapping (uint => bool) request_state;
    mapping (address => bool) addressValidator;
    
    function add_wallet_sign(address _address, string memory _name, string memory _ID) public onlyOwner{
        uint hash_uint=uint(keccak256(abi.encodePacked(_name,_ID)));
        uint hash_data=hash_uint % hashModulus;
        validators.push(validator(hash_data,_address));
        addressValidator[_address]=true;
        validators_count++;
    }
    
    function mint_tokens_request (uint _cantidad) public{
        mint_requests.push(mint_request(msg.sender, _cantidad, block.timestamp));
    }
    function mint_tokens_approve (uint _request) public{
        require(_request<=mint_requests.length,"Request number invalid");
        require(!request_state[_request], "Already validated");
        require(addressValidator[msg.sender],"Only validators");
        require(!validator_signed[msg.sender][_request],"Validator already signed");
        total_signs[_request]++;
        _mint(mint_requests[_request].walllet,mint_requests[_request].value);
        request_state[_request]=true;
    }
    function burn_tokens(uint _cantidad) public{
        _burn(msg.sender,_cantidad);
    }
    
    //Ownable.sol
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}