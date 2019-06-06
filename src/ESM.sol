// Copyright (C) 2019 Maker Ecosystem Growth Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.5.6;

import "ds-math/math.sol";
import "ds-note/note.sol";

contract GemLike {
    function balanceOf(address) public view returns (uint256);
    function transfer(address, uint256) public returns (bool);
    function transferFrom(address, address, uint256) public returns (bool);
}

contract EndLike {
    function cage() public;
}

contract ESM is DSMath, DSNote {
    uint256 public cap;
    GemLike public gem;
    EndLike public end;
    uint256 public sum;
    address public sun;

    mapping(address => uint256) public gems;

    uint256 public constant START = 0;
    uint256 public constant FREED = 1;
    uint256 public constant BURNT = 2;
    uint256 public constant FIRED = 3;
    uint256 public          state = START;

    mapping(address => uint256) public wards;
    function rely(address usr) public auth note { wards[usr] = 1; }
    function deny(address usr) public auth note { wards[usr] = 0; }
    modifier auth() { require(wards[msg.sender] == 1, "esm/unauthorized"); _; }

    constructor(address ward, address gem_, address end_, address sun_, uint256 cap_) public {
        wards[ward] = 1;

        gem = GemLike(gem_);
        end = EndLike(end_);
        sun = sun_;
        cap = cap_;
    }

    // -- admin --
    function file(bytes32 job, address obj) external auth note {
        if (job == "end") end = EndLike(obj);
        if (job == "sun") sun = obj;
    }

    function file(bytes32 job, uint256 val) external auth note {
        if (job == "cap") cap = val;
    }

    // -- state changes --
    function fire() external note {
        require(state == START && full(), "esm/not-fireable");

        end.cage();

        state = FIRED;
    }

    function free() external auth note {
        require(state == START || state == FIRED, "esm/not-freeable");

        state = FREED;
    }

    function burn() external auth note {
        require(state == START || state == FIRED, "esm/not-burnable");

        sum   = 0;
        state = BURNT;

        bool ok = gem.transfer(address(sun), gem.balanceOf(address(this)));

        require(ok, "esm/failed-transfer");
    }

    // -- user actions --
    function join(uint256 wad) external note {
        require(state == START, "esm/not-joinable");

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
