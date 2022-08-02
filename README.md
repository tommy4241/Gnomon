# MindGames Gnomon


how to deploy
forge create --rpc-url https://mumbai.polygonscan.com/ --private-key 60f64c959a64baedb87521aa52ca6649fa4084b345c6cdb30a76b81c9e8d02c0 src/MyContract.sol:MyContract --constructor-args "Hello Foundry" "Arg2"

mumbai rpc & chainID

https://rpc-mumbai.matic.today
80001

Fantom testnet rpc & chainID
https://rpc.testnet.fantom.network/

1. deploy gnomon

forge create --rpc-url https://rpc.testnet.fantom.network/ --private-key 60f64c959a64baedb87521aa52ca6649fa4084b345c6cdb30a76b81c9e8d02c0 src/Gnomon.sol:Gnomon

0x6096e1BF06db99bd0223FD979Ef6d5D7248285E7

2. deploy heart

forge create --rpc-url https://rpc.testnet.fantom.network/ --private-key 60f64c959a64baedb87521aa52ca6649fa4084b345c6cdb30a76b81c9e8d02c0 src/Heart.sol:Heart

0xe6743E27C934933BB26EC6cEd51a99026B558295

3. set heart
4. deploy mystery

forge create --rpc-url https://rpc.testnet.fantom.network/ --private-key 60f64c959a64baedb87521aa52ca6649fa4084b345c6cdb30a76b81c9e8d02c0 src/Mystery.sol:MysteryBox --constructor-args "Mystery" "Myst"

0xFdBdf2Be2a6eb739d0A33f87e019c1001F809683

5. set Gnomon to mystery

6. premint nfts to gnomon

7. deploy 10 tokens

forge create --rpc-url https://rpc.testnet.fantom.network/ --private-key 60f64c959a64baedb87521aa52ca6649fa4084b345c6cdb30a76b81c9e8d02c0 src/RewardToken.sol:RewardToken --constructor-args "A" "A"

0x04689CC0D9ba72880E531f1BC541130A5CDf4018
0x9a91D1a388dA6E61fe455743Abc878dB5bB23E56
0x1FDf37C463249E1017928572E0bC2c8E3Bc50Db0
0x5C90b4C55C14244EA0F75E42DaaB468A698dE989
0x8a4BB8f558397d20afc204ce222ce0f9625fEb11
0x9B9e9D420C1829D7e94111c1933F9D8674365173
0x9E35c79DA2431E0c0922c7518b2D1D239cD614f2
0xB8dfad3221005D6F774d425bf99EF987C028716b
0xCA61F7Cf71Ece0d6aA1A5CCd887a2C3E6B456C7D
0xD96Ea61fE8a1FD42B97BF9b58E06391B8AF0853e

9. mint to gnomon
10. mint to team to test
11. update cell
12. update common tier
13. update rare tier
14. update legendary tier