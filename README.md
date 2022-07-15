# tron-staking

Проверка функционала через [Tron-IDE](tronide.io) на Nile Testnet.

### Smart Contract ID
```
414ac88109189d8f81fefeccd2b2be4079df567d0b
```

### Get contract
```sh
curl --request POST \ 
             --url https://nile.trongrid.io/wallet/getcontract \
             --header 'Accept: application/json' \
             --header 'Content-Type: application/json' \
             --data '
    {
         "value": "414ac88109189d8f81fefeccd2b2be4079df567d0b",
         "visible": false
    }
    '
```
