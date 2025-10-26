// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {IERC165} from "src/interfaces/erc/IERC165.sol";
import {IERC7572} from "src/interfaces/erc/IERC7572.sol";

import {Ownable} from "solady/auth/Ownable.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

library ERC20BaseStorage {

    /// @custom:storage-location erc7201:thirdweb.erc20.base
    bytes32 public constant ERC20_ASSET_STORAGE_POSITION =
        keccak256(abi.encode(uint256(keccak256("thirdweb.erc20.base")) - 1)) & ~bytes32(uint256(0xff));

    struct Data {
        string name;
        string symbol;
        string contractURI;
    }

    function data() internal pure returns (Data storage $) {
        bytes32 position = ERC20_ASSET_STORAGE_POSITION;
        assembly {
            $.slot := position
        }
    }

}

contract ERC20Base is ERC20, Ownable, IERC7572, IERC165 {

    /// @notice Initialize the ERC20 asset with token parameters and mint initial supply
    /// @dev This function can only be called once due to the initializer modifier.
    ///      Sets up the token with name, symbol, contract URI, and mints the entire max supply to the caller.
    /// @param _name The human-readable name of the token (e.g., "My Token")
    /// @param _symbol The ticker symbol of the token (e.g., "MTK")
    /// @param _contractURI The URI pointing to contract-level metadata (EIP-7572)
    /// @param _maxSupply The maximum supply of tokens to mint initially (in wei units)
    /// @param _owner The address that will become the owner of this contract
    function _initialize(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        uint256 _maxSupply,
        address _owner
    ) internal {
        ERC20BaseStorage.Data storage data = _erc20BaseStorage();

        data.name = _name;
        data.symbol = _symbol;
        data.contractURI = _contractURI;

        _initializeOwner(_owner);
        _mint(msg.sender, _maxSupply);

        emit ContractURIUpdated();
    }

    /// @dev Returns the name of the token.
    function name() public view override returns (string memory) {
        return _erc20BaseStorage().name;
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return _erc20BaseStorage().symbol;
    }

    /// @dev Returns the storage pointer for the ERC20 asset data
    function _erc20BaseStorage() internal pure returns (ERC20BaseStorage.Data storage data) {
        data = ERC20BaseStorage.data();
    }

    //
    // ERC20 Functions
    //

    /// @dev Burns tokens from the caller's account
    /// @param amount The amount of tokens to burn
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /// @dev Burns tokens from a specified account
    /// @param from The address from which tokens will be burned
    /// @param amount The amount of tokens to burn
    function burnFrom(address from, uint256 amount) external {
        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
    }

    //
    // EIP-7572 Contract-Level Metadata
    //

    /// @notice Get the contract-level metadata URI
    /// @dev Returns the URI pointing to contract-level metadata as per EIP-7572 specification
    /// @return The contract metadata URI string
    function contractURI() external view returns (string memory) {
        return _erc20BaseStorage().contractURI;
    }

    /// @notice Update the contract-level metadata URI
    /// @dev Only the contract owner can call this function. Emits ContractURIUpdated event as per EIP-7572
    /// @param _contractURI The new URI pointing to updated contract-level metadata
    function setContractURI(string calldata _contractURI) external onlyOwner {
        _erc20BaseStorage().contractURI = _contractURI;

        emit ContractURIUpdated();
    }
    //
    // EIP-165 Interface Detection
    //

    /// @notice Check if this contract implements a specific interface
    /// @dev Returns true if this contract implements the interface defined by interfaceId as per EIP-165.
    ///      Supports IERC7572 (Contract-Level Metadata), and IERC165 interfaces.
    /// @param interfaceId The 4-byte interface identifier to check
    /// @return True if the interface is supported, false otherwise
    function supportsInterface(bytes4 interfaceId) external pure virtual override returns (bool) {
        return interfaceId == type(IERC7572).interfaceId || interfaceId == type(IERC165).interfaceId;
    }

}
