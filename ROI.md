# ROI

<!-- $$
ROI = \frac {Current \ Value \ of \ Investment - Cost \ of \ Investment} {Cost \ of \ Investment}  
$$ --> 

<div align="center"><img src="svg/HHAtckrr2q.svg"/></div>

## LP_TOKEN

### mint

```solidity
if (_totalSupply == 0) {
    liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
    _mint(address(0), MINIMUM_LIQUIDITY);
} else {
    liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
}
```

### burn

```solidity
uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
amount0 = liquidity.mul(balance0) / _totalSupply;
amount1 = liquidity.mul(balance1) / _totalSupply;
```

LP: 33.89  
ring: 43.7387  
gold: 26.282

add 1 gold + 1.6642 ring  
LP: 1.29  

- supply = 0

  <!-- $$
  k = x*y  \\
  liquidity = \sqrt{ k }
  $$ -->

<div align="center"><img src="svg/gKu6tLqtB8.svg"/></div>

- supply > 0
  <!-- $$
  \frac {liquidity} {total} = \frac {amount} {reserve} 
  $$ --> 

<div align="center"><img src="svg/9CzUbKN25u.svg"/></div> 

## Land Base

uint256 `resourceRateAttr`  
`[00 i^2...i^32]`  
uint16 gold_rate = `i = [31, 32]`  
uint16 wood_rate = `i = [29, 30]`  
uint16 water_rate = `i = [27, 28]`  
uint16 fire_rate = `i = [25, 26]`  
uint16 soil_rate = `i = [23, 24]`  

resource will decrease 1/10000 every day.  
startTime = 1544083267 | 2018/12/6 16:1:7  
remainDays = (now - startTime) / 86400  
minableBalance = rate * (1 - remainDays/10000)  

Per Apostle BaseStrength <!-- $\approx$ --> <img style="transform: translateY(0.25em);" src="svg/OCcjcm4u1l.svg"/> 1 Element

## ROI base GOLD (stable)

```
enhanceStrength = 3%
Daily ROI: 0.03 GOLD / (1000 GOLD * 2) = 0.0015%
Weekly ROI: 0.003% * 7 = 0.0105%
Yearly ROI: 0.003% * 365 = 0.5475%
```

## ROI base RING (unstable)

```
GOLD price = reserveRING / reserveGOLD
0.01 = 1 / 100
RING amount = 1000 * priceGOLD
10 = 1000 * 0.01
Daily ROI: 0.03 * 0.01 / (10 * 2) = 0.0015%
```
