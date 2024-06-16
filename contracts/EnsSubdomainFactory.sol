//pragma solidity ^0.4.26;
//pragma solidity >=0.8.4;
pragma solidity >=0.5.15;

import './EnsRegistry.sol';
import './EnsResolver.sol';
//import './ReverseRegistrar.sol';

// ---------------------------------------------------------------------------------------------------
// EnsSubdomainFactory - allows creating and configuring custom ENS subdomains with one contract call.
//
// @author Radek Ostrowski / https://startonchain.com - MIT Licence.
// Source: https://github.com/radek1st/ens-subdomain-factory
// ---------------------------------------------------------------------------------------------------

/**
 * @title EnsSubdomainFactory
 * @dev Allows to create and configure a subdomain for Ethereum ENS in one call.
 * After deploying this contract, change the owner of the domain you want to use
 * to this deployed contract address. For example, transfer the ownership of "startonchain.eth"
 * so anyone can create subdomains like "radek.startonchain.eth".
 */
 /*
 const rinkebyEns={ens:'0x98325eDBE53119bB4A5ab7Aa35AA4621f49641E6',
        resolver:'0xAe41CFDE7ABfaaA2549C07b2363458154355bAbD',
        reverse: '0xFdb1b60AdFCba28f28579D709a096339F5bEb651'}
 */
contract EnsSubdomainFactory {
	address payable public owner;
	address public admin;
	EnsRegistry public registry;
	EnsResolver public resolver;
//	ReverseRegistrar public reverseRegistrar;
	bool public locked;
  bytes32 emptyNamehash = 0x00;
	// 1 Ether = 2000 sundomains
	uint256 public freeNameLength = 8;
	uint256 public subdomainPrice = 500000000000000;
	uint256 public subdomainSold;

	event SubdomainCreated(address indexed creator, address indexed owner, string subdomain, string domain, string topdomain);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	event RegistryUpdated(address indexed previousRegistry, address indexed newRegistry);
	event ResolverUpdated(address indexed previousResolver, address indexed newResolver);
	event DomainTransfersLocked();

	constructor(EnsRegistry _registry, EnsResolver _resolver) public {
		owner = msg.sender;
		admin = msg.sender;
		registry = _registry;
		resolver = _resolver;
		locked = false;
	}

    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
	function transferOwnership(address payable  _owner) public onlyOwner {
		owner = _owner;
	}


    // Function to receive Ether. msg.data must be empty
//    receive() external payable {}

    // Fallback function is called when msg.data is not empty
  //  fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

	/**
	 * @dev Throws if called by any account other than the owner.
	 *
	 */
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function append(string memory a, string memory b, string memory c, string memory d, string memory e) internal pure returns (string memory) {

		return string(abi.encodePacked(a, b, c, d, e));

	}
	function setPrice(uint256 _newPrice) public{
		require(msg.sender==admin );
		subdomainPrice = _newPrice;
	}
	function setFreeNameLength(uint256 _newLength) public{
		require(msg.sender==admin );
		freeNameLength = _newLength;
	}

	/**
	 * payable subdomainPrice
	 * @dev Allows to create a subdomain (e.g. "radek.startonchain.eth"),
	 * set its resolver and set its target address
	 * @param _subdomain - sub domain name only e.g. "radek"
	 * @param _domain - domain name e.g. "startonchain"
	 * @param _topdomain - parent domain name e.g. "eth", "xyz"
	 * @param _owner - address that will become owner of this new subdomain
	 * @param _target - address that this new domain will resolve to
	 */
	function newSubdomain(string memory _subdomain, string memory _domain, string memory _topdomain, address _owner, address _target) public payable{
		//create namehash for the topdomain
		bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
		//create namehash for the domain
		bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
		//make sure this contract owns the domain
		require(registry.owner(domainNamehash) == address(this), "this contract should own the domain");
		//create labelhash for the sub domain
		bytes32 subdomainLabelhash = keccak256(abi.encodePacked(_subdomain));
		//create namehash for the sub domain
		bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, subdomainLabelhash));
		//make sure it is free or owned by the sender
		require(registry.owner(subdomainNamehash) == address(0) ||
			registry.owner(subdomainNamehash) == msg.sender, "sub domain already owned");
		// pay for subdomain
		if (bytes(_subdomain).length<freeNameLength)
			require(msg.value == (subdomainPrice));
		subdomainSold += 1;

		//create new subdomain, temporarily this smartcontract is the owner
		registry.setSubnodeOwner(domainNamehash, subdomainLabelhash, address(this));
		//set public resolver for this domain
		registry.setResolver(subdomainNamehash, address(resolver));
		//set the destination address
		resolver.setAddr(subdomainNamehash, _target);
		//change the ownership back to requested owner
		registry.setOwner(subdomainNamehash, _owner);

		emit SubdomainCreated(msg.sender, _owner, _subdomain, _domain, _topdomain);

		// do reverse, can not do it this way
		// reverseRegistrar.setName(append(_subdomain,".",_domain,".",_topdomain));
	}

	function newSubdomainName(string memory _subdomain, string memory _domain, string memory _topdomain) public pure returns (string memory) {
		return append(_subdomain,".",_domain,".",_topdomain);
	}

	/**
	 * @dev Returns the owner of a domain (e.g. "startonchain.eth"),
	 * @param _domain - domain name e.g. "startonchain"
	 * @param _topdomain - parent domain name e.g. "eth" or "xyz"
	 */
	function domainOwner(string memory _domain, string memory _topdomain) public view returns (address) {
		bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
		bytes32 namehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
		return registry.owner(namehash);
	}

	/**
	 * @dev Return the owner of a subdomain (e.g. "radek.startonchain.eth"),
	 * @param _subdomain - sub domain name only e.g. "radek"
	 * @param _domain - parent domain name e.g. "startonchain"
	 * @param _topdomain - parent domain name e.g. "eth", "xyz"
	 */
	function subdomainOwner(string memory _subdomain, string memory _domain, string memory _topdomain) public view returns (address) {
		bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
		bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
		bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain))));
		return registry.owner(subdomainNamehash);
	}

    /**
    * @dev Return the target address where the subdomain is pointing to (e.g. "0x12345..."),
    * @param _subdomain - sub domain name only e.g. "radek"
    * @param _domain - parent domain name e.g. "startonchain"
    * @param _topdomain - parent domain name e.g. "eth", "xyz"
    */
    function subdomainTarget(string memory _subdomain, string memory _domain, string memory _topdomain) public view returns (address) {
        bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
        bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
        bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain))));
        address currentResolver = registry.resolver(subdomainNamehash);
        return EnsResolver(currentResolver).addr(subdomainNamehash);
    }

	/**
	 * @dev The contract owner can take away the ownership of any domain owned by this contract.
	 * @param _node - namehash of the domain
	 * @param _owner - new owner for the domain
	 */
	function transferDomainOwnership(bytes32 _node, address _owner) public onlyOwner {
		require(!locked);
		registry.setOwner(_node, _owner);
	}

	/**
	 * @dev The contract owner can lock and prevent any future domain ownership transfers.
	 */
	function lockDomainOwnershipTransfers() public onlyOwner {
		require(!locked);
		locked = true;
		emit DomainTransfersLocked();
	}

	/**
	 * @dev Allows to update to new ENS registry.
	 * @param _registry The address of new ENS registry to use.
	 */
	function updateRegistry(EnsRegistry _registry) public onlyOwner {
		require(registry != _registry, "new registry should be different from old");
		emit RegistryUpdated(address(registry), address(_registry));
		registry = _registry;
	}

	/**
	 * @dev Allows to update to new ENS resolver.
	 * @param _resolver The address of new ENS resolver to use.
	 */
	function updateResolver(EnsResolver _resolver) public onlyOwner {
		require(resolver != _resolver, "new resolver should be different from old");
		emit ResolverUpdated(address(resolver), address(_resolver));
		resolver = _resolver;
	}

	/**
	 * @dev Allows the current owner to transfer control of the contract to a new owner.
	 * @param _owner The address to transfer ownership to.
	 */
	function transferContractOwnership(address payable _owner) public onlyOwner {
		require(_owner != address(0), "cannot transfer to address(0)");
		emit OwnershipTransferred(owner, _owner);
		owner = _owner;
	}
}
