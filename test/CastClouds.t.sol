// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CastClouds, Ownable} from "../src/CastClouds.sol";

    error MintingOpen();
    error MintingClosed();
    error Locked();
    error OneMintPerAccount();

contract CastCloudsTest is Test {
    CastClouds public castClouds;

    address public owner;
    address public alice;
    address public bob;
    address public chad;

    function setUp() public {
        owner = createUser(0);
        alice = createUser(1);
        bob = createUser(2);
        chad = createUser(3);

        castClouds = new CastClouds(owner);
    }

    function createUser(uint32 i) public returns (address) {
        address user = vm.addr(vm.deriveKey("test test test test test test test test test test test junk", i));
        vm.deal(user, 1 ether);
        return user;
    }

    function test_OnlyOpenMinting() public {
        vm.prank(alice);
        vm.expectRevert(CastClouds.MintingClosed.selector);
        castClouds.mint(0);

        vm.prank(owner);
        castClouds.openMinting(0);

        vm.prank(alice);
        castClouds.mint(0);

        assertEq(castClouds.balanceOf(alice, 0), 1);

        vm.prank(owner);
        castClouds.closeMinting(0);

        vm.prank(bob);
        vm.expectRevert(CastClouds.MintingClosed.selector);
        castClouds.mint(0);
    }

    function test_OnlyOneMintPerUser() public {
        vm.prank(owner);
        castClouds.openMinting(0);

        vm.prank(alice);
        castClouds.mint(0);

        assertEq(castClouds.balanceOf(alice, 0), 1);

        vm.prank(alice);
        vm.expectRevert(CastClouds.OneMintPerAccount.selector);
        castClouds.mint(0);

        vm.prank(bob);
        castClouds.mint(0);

        assertEq(castClouds.balanceOf(bob, 0), 1);

        vm.prank(bob);
        vm.expectRevert(CastClouds.OneMintPerAccount.selector);
        castClouds.mint(0);
    }

    function test_LockingAccessControl() public {
        assertEq(castClouds.locked(0), false);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        castClouds.lock(0);

        vm.prank(owner);
        castClouds.lock(0);

        assertEq(castClouds.locked(0), true);
    }

    function test_Locking() public {
        vm.prank(owner);
        castClouds.lock(0);

        assertEq(castClouds.locked(0), true);

        vm.prank(owner);
        vm.expectRevert(CastClouds.Locked.selector);
        castClouds.openMinting(0);

        vm.prank(owner);
        vm.expectRevert(CastClouds.Locked.selector);
        castClouds.updateUri(0, "newUri");
    }

    function test_Uri() public {
        assertEq(castClouds.uri(0), "");

        vm.prank(owner);
        castClouds.updateUri(0, "newUri");

        assertEq(castClouds.uri(0), "newUri");
    }

    function test_OpenMinting() public {
        assertEq(castClouds.mintingOpen(0), false);

        vm.prank(owner);
        castClouds.openMinting(0);

        assertEq(castClouds.mintingOpen(0), true);

        vm.prank(owner);
        vm.expectRevert(CastClouds.MintingOpen.selector);
        castClouds.openMinting(0);

        assertEq(castClouds.mintingOpen(1), false);

        vm.prank(owner);
        castClouds.openMinting(1);

        assertEq(castClouds.mintingOpen(1), true);

        vm.prank(owner);
        vm.expectRevert(CastClouds.MintingOpen.selector);
        castClouds.openMinting(1);
    }

    function test_TotalSupply() public {
        assertEq(castClouds.totalSupply(0), 0);

        vm.prank(owner);
        castClouds.openMinting(0);

        vm.prank(alice);
        castClouds.mint(0);

        assertEq(castClouds.totalSupply(0), 1);

        vm.prank(bob);
        castClouds.mint(0);

        assertEq(castClouds.totalSupply(0), 2);

        vm.prank(chad);
        castClouds.mint(0);

        assertEq(castClouds.totalSupply(0), 3);        
    }
}
