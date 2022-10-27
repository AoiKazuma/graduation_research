// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./register_units.sol";
import "./shipper_units.sol";
import "./identifier_units.sol";

/// @dev システムを実行するコントラクト
contract RunSystem is RegisterUnits, ShipperUnits, IdentifierUnits {

}