pragma solidity ^0.5.6;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./ESM.sol";

contract EndTest is EndLike{
    function cage() public {}
}

contract TestUsr {
    ESM esm;
    DSToken gem;

    constructor(DSToken gem_) public {
        gem = gem_;
    }

    function setESM(ESM esm_) external {
        esm = esm_;
        gem.approve(address(esm), 1000);
    }

    function callCap(uint256 val) external {
        esm.file("cap", val);
    }

    function callFire() external {
        esm.fire();
    }

    function callFree() external {
        esm.free();
    }

    function callBurn() external {
        esm.burn();
    }

    function callJoin(uint256 wad) external {
        esm.join(wad);
    }

    function callExit(address who, uint256 wad) external {
        esm.exit(who, wad);
    }
}

contract ESMTest is DSTest {
    ESM     esm;
    DSToken gem;
    EndLike end;
    uint256 cap;
    address sun;
    TestUsr usr;

    function setUp() public {
        gem = new DSToken("GOLD");
        end = EndLike(address(new EndTest()));
        sun = address(0x0);
        usr = new TestUsr(gem);

        esm = new ESM(address(gem), address(end), sun, 10, address(usr), msg.sender);
        usr.setESM(esm);
    }

    function test_constructor() public {
        assertEq(address(esm.gem()), address(gem));
        assertEq(address(esm.end()), address(end));
        assertEq(esm.sun(), address(0x0));
        assertEq(esm.cap(), 10);
        assertEq(address(esm.owner()), address(usr));
        assertEq(address(esm.authority()), address(msg.sender));
    }

    function test_fired() public {
        assertTrue(!esm.fired());
        usr.callCap(0);

        usr.callFire();

        assertTrue(esm.fired());
    }

    function test_freed() public {
        assertTrue(!esm.freed());
        usr.callCap(0);
        usr.callFire();

        usr.callFree();

        assertTrue(esm.freed());
    }

    function test_burnt() public {
        assertTrue(!esm.burnt());
        usr.callCap(0);
        usr.callFire();

        usr.callBurn();

        assertTrue(esm.burnt());
    }

    function test_burn_balance() public {
        gem.mint(address(usr), 10);

        usr.callJoin(5);

        usr.callBurn();

        assertEq(gem.balanceOf(address(esm)), 0);
        assertEq(gem.balanceOf(address(sun)), 5);
    }

    function testFail_fire_twice() public {
        usr.callCap(0);
        usr.callFire();

        usr.callFire();
    }

    function testFail_fire_cap_not_met() public {
        assertTrue(!esm.full());

        usr.callFire();
    }

    function testFail_free_already_burnt() public {
        usr.callBurn();

        usr.callFree();
    }

    // TOOD also test failed transfers
    function testFail_burn_already_freed() public {
        usr.callFree();

        usr.callBurn();
    }

    function test_free_before_fire() public {
        assertTrue(!esm.fired());

        usr.callFree();
    }

    function test_free_after_fire() public {
        usr.callCap(0);
        usr.callFire();

        usr.callFree();
    }

    function test_burn_before_fire() public {
        assertTrue(!esm.fired());

        usr.callBurn();
    }

    function test_burn_after_fire() public {
        usr.callCap(0);
        usr.callFire();

        usr.callBurn();
    }

    // -- user actions --
    function test_join() public {
        gem.mint(address(usr), 10);

        usr.callJoin(10);

        assertEq(gem.balanceOf(address(esm)), 10);
        assertEq(gem.balanceOf(address(usr)), 0);
    }

    function test_exit() public {
        gem.mint(address(usr), 10);

        usr.callJoin(10);
        usr.callFree();

        usr.callExit(address(usr), 10);

        assertEq(gem.balanceOf(address(esm)), 0);
        assertEq(gem.balanceOf(address(usr)), 10);
    }

    function test_exit_gift() public {
        gem.mint(address(usr), 10);

        usr.callJoin(10);
        usr.callFree();

        assertEq(gem.balanceOf(address(0x0)), 0);
        usr.callExit(address(0xdeadbeef), 10);

        assertEq(gem.balanceOf(address(esm)), 0);
        assertEq(gem.balanceOf(address(0xdeadbeef)), 10);
    }

    // -- helpers --
    function test_full() public {
        usr.callCap(10);

        gem.mint(address(usr), 10);

        usr.callJoin(5);
        assertTrue(!esm.full());

        usr.callJoin(5);
        assertTrue(esm.full());
    }
}
