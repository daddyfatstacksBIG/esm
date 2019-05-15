pragma solidity ^0.5.6;

import "ds-auth/auth.sol";
import "ds-note/note.sol";

contract GemLike {
    function balanceOf(address) public view returns (uint256);
    function transfer(address, uint256) public returns (bool);
    function transferFrom(address, address, uint256) public returns (bool);
}

contract EndLike {
    function cage() public;
}

contract ESM is DSAuth, DSNote {
    uint256 public cap;
    GemLike public gem;
    EndLike public end;
    uint256 public sum;
    address public sun;

    mapping(address => uint256) public gems;

    uint256 public state;
    uint256 public constant BASIC = 0;
    uint256 public constant FREED = 1;
    uint256 public constant BURNT = 2;
    uint256 public constant FIRED = 3;

    bool public done;

    constructor(address gem_, address end_, address sun_, uint256 cap_, address owner_, address authority_) public {
        gem = GemLike(gem_);
        end = EndLike(end_);
        sun = sun_;
        cap = cap_;
        owner = owner_;
        authority = DSAuthority(authority_);
    }

    // -- math --
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require(z >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x - y;
        require(z <= x);
    }

    // -- admin --
    function file(bytes32 job, address val) external auth note {
        if (job == "end") end = EndLike(val);
        if (job == "sun") sun = val;
    }

    function file(bytes32 job, uint256 val) external auth note {
        if (job == "cap") cap = val;
    }

    // -- esm actions --
    function fire() external note {
        require(!done && full(), "esm/not-fireable");

        end.cage();

        done = true;
    }

    function free() external auth note {
        state = FREED;
    }

    function lock() external auth note {
        require(state == FREED, "esm/not-freed");

        state = BASIC;
    }

    function burn() external auth note {
        bool ok = gem.transfer(address(sun), gem.balanceOf(address(this)));
        sum = 0;

        require(ok, "esm/failed-transfer");

        done  = true;
        state = BURNT;
    }

    // -- user actions --
    function join(uint256 wad) external note {
        require(state == BASIC && !done, "esm/not-joinable");

        gems[msg.sender] = add(gems[msg.sender], wad);
        sum = add(sum, wad);

        bool ok = gem.transferFrom(msg.sender, address(this), wad);

        require(ok, "esm/failed-transfer");
    }

    function exit(address usr, uint256 wad) external note {
        require(state == FREED, "esm/not-freed");

        gems[msg.sender] = sub(gems[msg.sender], wad);
        sum = sub(sum, wad);

        bool ok = gem.transfer(usr, wad);

        require(ok, "esm/failed-transfer");
    }

    // -- helpers --
    function full() public view returns (bool) {
        return sum >= cap;
    }
}
