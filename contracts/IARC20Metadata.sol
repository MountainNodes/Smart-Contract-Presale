// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ARC20/extensions/IARC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IARC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ARC20 standard.
 *
 * _Available since v4.1._
 */
interface IARC20Metadata is IARC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}