// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

// import {DSTestPlus} from "./utils/DSTestPlus.sol";
// import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract ERC20Test is Test {
    IERC20 token;

    address public bob = address(0xb0b);

    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function setUp() public {
        vm.label(bob, "bob");

        token = IERC20(HuffDeployer.deploy("erc20"));
        vm.stopPrank();
    }

    function testMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
        assertEq(token.decimals(), 18);
    }

    function testMint() public {
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(bob), 0);
        token.mint(bob, 1e18);
        assertEq(token.totalSupply(), 1e18);
        assertEq(token.balanceOf(bob), 1e18);

    }


    function testBurn() public {
        token.mint(bob, 1e18);
        assertEq(token.balanceOf(bob), 1e18);
        token.burn(bob, 0.5e18);

        assertEq(token.balanceOf(bob), 0.5e18);
        assertEq(token.totalSupply(), 0.5e18);
    }

    function testApprove() public {
        assertTrue(token.approve(address(0xBEEF), 1e18));
        assertEq(token.allowance(address(this), address(0xBEEF)), 1e18);
    }


    function testTransfer() public {
        token.mint(address(this), 1e18);

        assertTrue(token.transfer(address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        console.log('token.allowance(from, address(this))', token.allowance(from, address(this)));
        vm.prank(from);
        token.approve(address(this), 1e18);

        console.log('token.balanceOf(from)', token.balanceOf(from));
        console.log('token.balanceOf(address(this))', token.balanceOf(address(this)));
        console.log('token.balanceOf(address(0xbeef))', token.balanceOf(address(0xbeef)));
        console.log('token.allowance(from, address(this))', token.allowance(from, address(this)));
        console.log("token.transferFrom(from, address(0xBEEF), 1e18)");
        assertTrue(token.transferFrom(from, address(0xBEEF), 1e18));
        console.log('token.balanceOf(from)', token.balanceOf(from));
        console.log('token.balanceOf(address(this))', token.balanceOf(address(this)));
        console.log('token.balanceOf(address(0xbeef))', token.balanceOf(address(0xbeef)));

        assertEq(token.totalSupply(), 1e18);
        console.log('token.allowance(from, address(this))', token.allowance(from, address(this)));
        assertEq(token.allowance(from, address(this)), 0);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }
    function testInfiniteApproveTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        vm.prank(from);
        token.approve(address(this), type(uint256).max);

        assertTrue(token.transferFrom(from, address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(from, address(this)), type(uint256).max);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

//     function testPermit() public {
//         uint256 privateKey = 0xBEEF;
//         address owner = vm.addr(privateKey);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(
//             privateKey,
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     token.DOMAIN_SEPARATOR(),
//                     keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
//                 )
//             )
//         );

//         token.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);

//         assertEq(token.allowance(owner, address(0xCAFE)), 1e18);
//         assertEq(token.nonces(owner), 1);
//     }

    function testFailTransferInsufficientBalance() public {
        token.mint(address(this), 0.9e18);
        token.transfer(address(0xBEEF), 1e18);
    }

    function testFailTransferFromInsufficientAllowance() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        vm.prank(from);
        token.approve(address(this), 0.9e18);

        token.transferFrom(from, address(0xBEEF), 1e18);
    }

    function testFailTransferFromInsufficientBalance() public {
        address from = address(0xABCD);

        token.mint(from, 0.9e18);

        vm.prank(from);
        token.approve(address(this), 1e18);

        token.transferFrom(from, address(0xBEEF), 1e18);
    }

//     function testFailPermitBadNonce() public {
//         uint256 privateKey = 0xBEEF;
//         address owner = vm.addr(privateKey);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(
//             privateKey,
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     token.DOMAIN_SEPARATOR(),
//                     keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 1, block.timestamp))
//                 )
//             )
//         );

//         token.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
//     }

//     function testFailPermitBadDeadline() public {
//         uint256 privateKey = 0xBEEF;
//         address owner = vm.addr(privateKey);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(
//             privateKey,
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     token.DOMAIN_SEPARATOR(),
//                     keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
//                 )
//             )
//         );

//         token.permit(owner, address(0xCAFE), 1e18, block.timestamp + 1, v, r, s);
//     }

//     function testFailPermitPastDeadline() public {
//         uint256 privateKey = 0xBEEF;
//         address owner = vm.addr(privateKey);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(
//             privateKey,
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     token.DOMAIN_SEPARATOR(),
//                     keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp - 1))
//                 )
//             )
//         );

//         token.permit(owner, address(0xCAFE), 1e18, block.timestamp - 1, v, r, s);
//     }

//     function testFailPermitReplay() public {
//         uint256 privateKey = 0xBEEF;
//         address owner = vm.addr(privateKey);

//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(
//             privateKey,
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     token.DOMAIN_SEPARATOR(),
//                     keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
//                 )
//             )
//         );

//         token.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
//         token.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
//     }

    // function testMetadata(
    //     string calldata name,
    //     string calldata symbol,
    //     uint8 decimals
    // ) public {
    //     MockERC20 tkn = new MockERC20(name, symbol, decimals);
    //     assertEq(tkn.name(), name);
    //     assertEq(tkn.symbol(), symbol);
    //     assertEq(tkn.decimals(), decimals);
    // }

    // function testMint(address from, uint256 amount) public {
    //     token.mint(from, amount);

    //     assertEq(token.totalSupply(), amount);
    //     assertEq(token.balanceOf(from), amount);
    // }
}
