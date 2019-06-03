pragma solidity ^0.5.6;

import {ESM} from "./ESM.sol";
import {ESMFab} from "./ESMFab.sol";

import {DSToken} from "ds-token/token.sol";

import "ds-test/test.sol";

contract EndTest {
    uint256 public live = 1;
    function cage() public { live = 0; }

    mapping(address => uint256) public wards;
    function rely(address usr) public { wards[usr] = 1; }
    function deny(address usr) public { wards[usr] = 0; }
}

contract ESMFabTest is DSTest {
    ESMFab   mom;
    DSToken gem;
    EndTest end;
    address sun;

    function setUp() public {
        gem = new DSToken("GOLD");
        end = new EndTest();
        sun = address(0x1);

        mom = new ESMFab(address(this), address(gem), address(end), address(sun), 10);
        end.rely(address(mom));
    }

    function test_constructor() public {
        assertEq(mom.wards(address(this)), 1);
    }

    // -- admin --
    function test_file() public {
        assertTrue(address(mom.end()) != address(0x42));
        mom.file("end", address(0x42));
        assertTrue(address(mom.end()) == address(0x42));

        assertTrue(address(mom.sun()) != address(0x42));
        mom.file("sun", address(0x42));
        assertTrue(address(mom.sun()) == address(0x42));

        assertTrue(mom.cap() != 0x42);
        mom.file("cap", 0x42);
        assertTrue(mom.cap() == 0x42);
    }

    function testFail_unauthorized_file_end() public {
        mom = new ESMFab(address(0x0), address(gem), address(end), address(sun), 10);
        mom.file("end", address(0x42));
    }

    function testFail_unauthorized_file_sun() public {
        mom = new ESMFab(address(0x0), address(gem), address(end), address(sun), 10);
        mom.file("sun", address(0x42));
    }

    function testFail_unauthorized_file_cap() public {
        mom = new ESMFab(address(0x0), address(gem), address(end), address(sun), 10);
        mom.file("cap", 0x42);
    }

    // -- actions --
    function test_free() public {
        ESM     prev = mom.esm();
        address post = mom.free();

        assertTrue(address(prev) != post);
        assertTrue(prev.state()  == prev.FREED());
        assertEq(post, address(mom.esm()));
        assertEq(end.wards(address(prev)), 0);
        assertEq(end.wards(address(post)), 1);
        assertEq(end.wards(address(mom)),  1);
    }

    function test_free_non_live() public {
        ESM     prev = mom.esm();
        end.cage();
        address post = mom.free();

        assertTrue(address(prev) == post);
        assertTrue(prev.state()  == prev.FREED());
        assertEq(end.wards(address(prev)), 0);
        assertEq(end.wards(address(mom)),  0);
    }

    function test_burn() public {
        ESM     prev = mom.esm();
        address post = mom.burn();

        assertTrue(address(prev) != post);
        assertTrue(prev.state()  == prev.BURNT());
        assertEq(post, address(mom.esm()));
        assertEq(end.wards(address(prev)), 0);
        assertEq(end.wards(address(post)), 1);
        assertEq(end.wards(address(mom)),  1);
    }

    function test_burn_non_live() public {
        ESM     prev = mom.esm();
        end.cage();
        address post = mom.burn();

        assertTrue(address(prev) == post);
        assertTrue(prev.state()  == prev.BURNT());
        assertEq(end.wards(address(prev)), 0);
        assertEq(end.wards(address(mom)),  0);
    }

    function testFail_unauthorized_free() public {
        ESMFab mum = new ESMFab(address(0x0), address(gem), address(end), address(sun), 10);

        mum.free();
    }

    function testFail_unauthorized_burn() public {
        ESMFab mum = new ESMFab(address(0x0), address(gem), address(end), address(sun), 10);

        mum.burn();
    }

}
