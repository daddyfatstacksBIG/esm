pragma solidity ^0.5.6;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./ESM.sol";

contract EndTest is EndLike{
    function cage() public {}
}

contract TestUsr {
    ESM esm;

    function setESM(ESM esm_) external {
        esm = esm_;
    }

    function callApprove(DSToken gem) public {
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
    TestUsr gov;

    function setUp() public {
        gem = new DSToken("GOLD");
        end = EndLike(address(new EndTest()));
        sun = address(0x0);
        usr = new TestUsr();
        gov = new TestUsr();
        esm = new ESM(address(gem), address(end), sun, 10, address(gov), msg.sender);

        gov.setESM(esm);
        usr.setESM(esm);
        usr.callApprove(gem);
    }

    function test_constructor() public {
        assertEq(address(esm.gem()), address(gem));
        assertEq(address(esm.end()), address(end));
        assertEq(esm.sun(), address(0x0));
        assertEq(esm.cap(), 10);
        assertEq(address(esm.owner()), address(gov));
        assertEq(address(esm.authority()), address(msg.sender));
    }

    function test_fired() public {
        assertTrue(!esm.fired());
        gov.callCap(0);

        gov.callFire();

        assertTrue(esm.fired());
    }

    function test_freed() public {
        assertTrue(!esm.freed());
        gov.callCap(0);
        gov.callFire();

        gov.callFree();

        assertTrue(esm.freed());
    }

    function test_burnt() public {
        assertTrue(!esm.burnt());
        gov.callCap(0);
        gov.callFire();

        gov.callBurn();

        assertTrue(esm.burnt());
    }

    function test_burn_balance() public {
        gem.mint(address(usr), 10);

        usr.callJoin(5);

        gov.callBurn();

        assertEq(gem.balanceOf(address(esm)), 0);
        assertEq(gem.balanceOf(address(sun)), 5);
    }

    function testFail_fire_twice() public {
        gov.callCap(0);
        gov.callFire();

        gov.callFire();
    }

    function testFail_fire_cap_not_met() public {
        assertTrue(!esm.full());

        gov.callFire();
    }

    function testFail_free_already_burnt() public {
        gov.callBurn();

        gov.callFree();
    }

    // TOOD also test failed transfers
    function testFail_burn_already_freed() public {
        gov.callFree();

        gov.callBurn();
    }

    function test_free_before_fire() public {
        assertTrue(!esm.fired());

        gov.callFree();
    }

    function test_free_after_fire() public {
        gov.callCap(0);
        gov.callFire();

        gov.callFree();
    }

    function test_burn_before_fire() public {
        assertTrue(!esm.fired());

        gov.callBurn();
    }

    function test_burn_after_fire() public {
        gov.callCap(0);
        gov.callFire();

        gov.callBurn();
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
        gov.callFree();

        usr.callExit(address(usr), 10);

        assertEq(gem.balanceOf(address(esm)), 0);
        assertEq(gem.balanceOf(address(usr)), 10);
    }

    function test_exit_gift() public {
        gem.mint(address(usr), 10);

        usr.callJoin(10);
        gov.callFree();

        assertEq(gem.balanceOf(address(0x0)), 0);
        usr.callExit(address(0xdeadbeef), 10);

        assertEq(gem.balanceOf(address(esm)), 0);
        assertEq(gem.balanceOf(address(0xdeadbeef)), 10);
    }

    // -- helpers --
    function test_full() public {
        gov.callCap(10);

        gem.mint(address(usr), 10);

        usr.callJoin(5);
        assertTrue(!esm.full());

        usr.callJoin(5);
        assertTrue(esm.full());
    }
}
