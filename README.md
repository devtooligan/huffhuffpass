# ERC20 Implmentation

- Fully functional ERC20 (includes eip-2612) written in [Huff](https://docs.huff.sh/) (based on [Solmate](https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)).
- Passes all Solmate tests (except for invariant tests -- DappTools not supported in this repo).
- Includes `transferFrom()` and `permit()` functions, which are not included in any currently available implementations that I've seen.
- Because there's no immutables in Huff, meta data that is available in advance (`name`, `symbol`, `decimals`) is hardcoded into the fns.  `ChainID` and `INITIAL_DOMAIN_SEPARATOR` use storage.

TODO:

 - [ ] add missing events and revert strings (Solmate doesn't test for these!)
 - [ ] refactor / gas golf -- TransferFrom especially needs some tlc
 - [ ] idk why CI tests failing, everything passes locally even w fuzz runs cranked to 50k
