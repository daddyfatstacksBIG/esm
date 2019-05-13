pragma solidity ^0.5.6;

import "ds-test/test.sol";

import "./ESM.sol";

contract ESMTest is DSTest {
    ESM esm;

    function setUp() public {
        esm = new ESM();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
