// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import {ERC20Base} from "src/assets/ERC20Base.sol";

import {Initializable} from "solady/utils/Initializable.sol";

contract ERC20Asset is Initializable, ERC20Base {

    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name,
        string memory symbol,
        string memory contractURI,
        uint256 maxSupply,
        address owner
    ) external initializer {
        _initialize(name, symbol, contractURI, maxSupply, owner);
    }

}
