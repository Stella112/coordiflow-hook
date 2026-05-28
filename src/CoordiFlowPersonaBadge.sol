// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";

import {ICoordiFlowPersonaHook} from "./interfaces/ICoordiFlowPersonaHook.sol";

contract CoordiFlowPersonaBadge {
    using PoolIdLibrary for PoolKey;

    string public constant name = "CoordiFlow Persona Badge";
    string public constant symbol = "CFLOW-SBT";

    address public immutable owner;
    ICoordiFlowPersonaHook public immutable hook;
    uint256 public nextTokenId = 1;

    mapping(uint256 tokenId => address owner) public ownerOf;
    mapping(address owner => uint256 balance) public balanceOf;
    mapping(uint256 tokenId => uint8 persona) public tokenPersona;
    mapping(uint256 tokenId => PoolId poolId) public tokenPoolId;
    mapping(PoolId poolId => mapping(address wallet => uint256 tokenId)) public badgeOf;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event BadgeMinted(bytes32 indexed poolId, address indexed wallet, uint256 indexed tokenId, uint8 persona);

    error NonTransferable();
    error NoPersona();
    error AlreadyMinted();
    error OnlyOwner();

    constructor(ICoordiFlowPersonaHook hook_) {
        owner = msg.sender;
        hook = hook_;
    }

    function mint(PoolKey calldata key) external returns (uint256 tokenId) {
        return _mint(key, msg.sender);
    }

    function mintFor(PoolKey calldata key, address wallet) external returns (uint256 tokenId) {
        if (msg.sender != owner) revert OnlyOwner();
        return _mint(key, wallet);
    }

    function _mint(PoolKey calldata key, address wallet) internal returns (uint256 tokenId) {
        PoolId poolId = key.toId();
        if (badgeOf[poolId][wallet] != 0) revert AlreadyMinted();

        uint8 persona = hook.personaOf(key, wallet);
        if (persona == 0) revert NoPersona();

        tokenId = nextTokenId++;
        ownerOf[tokenId] = wallet;
        balanceOf[wallet]++;
        tokenPersona[tokenId] = persona;
        tokenPoolId[tokenId] = poolId;
        badgeOf[poolId][wallet] = tokenId;

        emit Transfer(address(0), wallet, tokenId);
        emit BadgeMinted(PoolId.unwrap(poolId), wallet, tokenId, persona);
    }

    function approve(address, uint256) external pure {
        revert NonTransferable();
    }

    function setApprovalForAll(address, bool) external pure {
        revert NonTransferable();
    }

    function transferFrom(address, address, uint256) external pure {
        revert NonTransferable();
    }

    function safeTransferFrom(address, address, uint256) external pure {
        revert NonTransferable();
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure {
        revert NonTransferable();
    }
}
