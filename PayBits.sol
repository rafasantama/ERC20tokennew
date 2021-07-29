// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract PayBits is ERC20 {
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;
    uint validators_count;
    uint hashDigits = 8;
    uint hashModulus = 10 ** hashDigits;
    uint current_request;
    uint current_burn;
    
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
        address wallet;
        uint value;
        uint timeStamp;
        string file_name;
    }
    struct burn_request{
        address wallet;
        uint value;
        uint timeStamp;
    }
    
    validator[] public validators;
    mint_request[] private mint_requests;
    burn_request[] private burn_requests;
    
    mapping (address => uint[]) requests_sent;
    mapping (address => uint[]) burns_sent;
    mapping (uint => bool) request_state;
    mapping (uint => bool) burn_state;
    mapping (uint => string) burn_file_name;
    mapping (address => bool) addressValidator;
    
    function add_wallet_sign(address _address, string memory _name, string memory _ID) public onlyOwner{
        uint hash_uint=uint(keccak256(abi.encodePacked(_name,_ID)));
        uint hash_data=hash_uint % hashModulus;
        validators.push(validator(hash_data,_address));
        addressValidator[_address]=true;
        validators_count++;
    }
    
    function mint_tokens_request (uint256 _value, string memory _file_name) public{
        require(_value>0,"value request must be positive");
        mint_requests.push(mint_request(msg.sender, _value, block.timestamp,_file_name));
        current_request=mint_requests.length;
        requests_sent[msg.sender].push(current_request);
    }
    
    function get_my_total_requests() public view returns (uint total_requests){
        return requests_sent[msg.sender].length;
    }
    
    function get_my_request(uint _index) public view returns (uint request_id,address _wallet, uint _value, uint _timeStamp, string memory _file_name){
        return (requests_sent[msg.sender][_index],mint_requests[requests_sent[msg.sender][_index]].wallet,mint_requests[requests_sent[msg.sender][_index]].value,mint_requests[requests_sent[msg.sender][_index]].timeStamp,mint_requests[requests_sent[msg.sender][_index]].file_name);
    }
    function admin_get_total_requests() public onlyOwner view returns (uint total_requests){
        return requests_sent[msg.sender].length;
    }
    
    function admin_get_request(uint _index) public onlyOwner view returns (address _wallet, uint _value, uint _timeStamp, string memory _file_name) {
        return (mint_requests[_index].wallet,mint_requests[_index].value,mint_requests[_index].timeStamp,mint_requests[_index].file_name);
    }
    
    function mint_tokens_approve (uint256 _request) public{
        require(_request<=mint_requests.length,"Request number invalid");
        require(!request_state[_request], "Already validated");
        require(addressValidator[msg.sender],"Only validators");
        require(msg.sender!=mint_requests[_request].wallet,"You cannot approve your own request");
        _mint(mint_requests[_request].wallet,mint_requests[_request].value);
        request_state[_request]=true;
    }
    function burn_tokens(uint256 _value) public{
        require(_value>0,"value request must be positive");
        burn_requests.push(burn_request(msg.sender, _value, block.timestamp));
        current_burn=burn_requests.length;
        burns_sent[msg.sender].push(current_burn);
        _burn(msg.sender,_value);
    }
    function get_my_total_burns() public view returns (uint total_burns){
        return burns_sent[msg.sender].length;
    }
    
    function get_my_burn(uint _index) public view returns (uint burn_id,address _wallet, uint _value, uint _timeStamp, string memory _file_name){
        return (burns_sent[msg.sender][_index],burn_requests[burns_sent[msg.sender][_index]].wallet,burn_requests[burns_sent[msg.sender][_index]].value,burn_requests[burns_sent[msg.sender][_index]].timeStamp,burn_file_name[burns_sent[msg.sender][_index]]);
    }
    function admin_get_total_burns() public onlyOwner view returns (uint total_burns){
        return burns_sent[msg.sender].length;
    }
    
    function admin_get_burn(uint _index) public onlyOwner view returns (address _wallet, uint _value, uint _timeStamp, string memory _file_name) {
        return (burn_requests[_index].wallet,burn_requests[_index].value,burn_requests[_index].timeStamp,burn_file_name[_index]);
    }
    
    function burn_tokens_approve (uint256 _burn, string memory _file_name) public{
        require(_burn<=burn_requests.length,"Request number invalid");
        require(!burn_state[_burn], "Already validated");
        require(addressValidator[msg.sender],"Only validators");
        require(msg.sender!=burn_requests[_burn].wallet,"You cannot approve your own request");
        burn_file_name[_burn]=_file_name;
        burn_state[_burn]=true;
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