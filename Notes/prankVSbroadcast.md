# Understanding `msg.sender` in Foundry Tests vs Scripts

## 🧠 Problem Statement

While testing a simple ERC-20 token contract using Foundry, you encountered unexpected behavior related to `msg.sender`. Specifically:

* During deployment of the `OurToken` contract via a test file (`OurTokenTest.t.sol`), it appeared as though tokens were minted to an unexpected address.
* You were confused because the `vm.startBroadcast()` in the `DeployOurToken.s.sol` script showed one `msg.sender`, but the transfer from `ourToken.transfer(...)` seemed to work even though that address had no tokens.

This discrepancy raised the question:

> ❓ Why does `msg.sender` in the constructor behave differently between `forge script` and `forge test`?

---

## 📄 Code Structure Recap

### 1. `OurToken.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 _initialSupply) ERC20("OurToken", "OT") {
        console2.log("msg.sender in OurToken constructor:", msg.sender);
        _mint(msg.sender, _initialSupply);
    }
}
```

### 2. `DeployOurToken.s.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployOurToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (OurToken) {
        console2.log("msg.sender in DeployOurToken is 1:", msg.sender);

        vm.startBroadcast();
        console2.log("msg.sender in DeployOurToken is 2:", msg.sender);
        OurToken ourToken = new OurToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return ourToken;
    }
}
```

### 3. `OurTokenTest.t.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {DeployOurToken} from "../../script/DeployOurToken.s.sol";
import {OurToken} from "../../src/OurToken.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployOurToken;
    OurToken public ourToken;

    address bob = makeAddr("bob");
    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        console2.log("msg.sender in OurTokenTest is:", msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobStartingBalance() public {
        // Add assertions here
    }
}
```

---

## 🧪 Console Logs from `forge test -vvvv`

```
msg.sender in DeployOurToken is 1: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
msg.sender in DeployOurToken is 2: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
msg.sender in OurToken constructor: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
msg.sender in OurTokenTest is: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
```

---

## 🔍 Explanation

### 🎭 Scripts vs Tests in Foundry

#### `forge script`

* When run manually using `forge script`, `vm.startBroadcast()` is meaningful.
* It simulates sending real transactions from a real private key.
* `msg.sender` becomes the signer.

#### `forge test`

* `vm.startBroadcast()` has **no effect** inside a test context. It doesn’t sign or broadcast real transactions.
* All contract deployments happen using the test contract’s address, which is `msg.sender`.
* So even though `vm.startBroadcast()` is called in `DeployOurToken.s.sol`, it's a no-op.

### 🤯 So What Happened?

* During the test, `DeployOurToken.run()` is executed **inside the test contract**, so `msg.sender` during the `OurToken` constructor is **the test contract's address**: `0x1804c8...`
* The same address then calls `transfer(...)`, which works fine — because it already owns the tokens due to `_mint(msg.sender, ...)`.

---

## ✅ Conclusion

* `msg.sender` in tests is the test contract address.
* `vm.startBroadcast()` inside `forge test` **does nothing**.
* Don’t rely on scripts like `DeployOurToken` inside tests to simulate real-world deployment logic unless you understand this context.

