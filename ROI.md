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
1. Pool Status before adding liquidity:  
LP: 33.89  
gold: 26.282  
ring: 43.7387  
price: 1:1.6642

2. Add 1 gold + 1.6642 ring to Pool.  
Return LP: 1.29 

3. Pool Status after adding liquidity:  
LP: 35.18  
gold: 27.282  
ring: 45.4029  
price: 1:1.6642 

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

Per Apostle BaseStrength: 1.1778 fire, 1.2816 wood, 1.1649 gold, 1.2042 water, 1.2815 soil (1.2151 avg)  

```
Add liquidity Formula:   

LP_GOLD_RING 
gold_liquidity_pool: r0 
ring_liquidity_pool: r1 
ring_price: p1 = r0 / r1

k = r0 * r1 
p1 = r0 / r1
r1 = sqrt(k / p1)
r0 = sqrt(k * p1)

apostle_strength: x  
drill_strength: y%  
```
## ROI of enhancing drill by GOLD (static)
Note: neglecting fees and cost of drill
```
Cost of GOLD: a0
yield of GOLD: x * y%
Daily ROI of GOLD: x * y% / a0  
                =  1.1649 * (y% / a0)
```
# 
if y = 3, a0 = 100  
Daily ROI of GOLD: 0.0349%  
Weekly ROI of GOLD: 0.0349% * 7 = 0.2446%  
Yearly ROI of GOLD: 0.0349% * 365 = 12.755%
# 
if y = 12, a0 = 200  
Daily ROI of GOLD: 0.069894%  
Weekly ROI of GOLD: 0.069894% * 7 = 0.489258%  
Yearly ROI of GOLD: 0.0396066% * 365 = 25.51131%
# 
## ROI of enhancing drill by LP_GOLD and LP_RING/LP_KTON (dynamic)

Note: neglecting fees, cost of drill.
```
LP_GOLD_RING 
liquiduty0: l0
cost_gold: a0
cost_ring: a1

LP_RING_ETH
liquiduty1: l1
cost_ring: a2
cost_eth: a3

price_gold_ring: p0 = a1 / a0
price_eth_ring: p1 = a2 / a3
   
Cost of RING: a0 * p0 + a1 + a2 + a3 * p1
yield of RING: x * y% * p0
Daily ROI in RING: x * y% * p0 / (a0 * p0 + a1 + a2 + a3 * p1) 
                =  x * y% * p0 / (2 * (a1 + a2) 
                =  0.58245 * y% * p0 / (a1 + a2)
```
# 
if only LP_GOLD_RING init with 1 : 1     
y = 6, l0 = 50, a0 = a1 = 50, a2 = a3 = 0   
then p0 = 1, p1 = 1,   
Daily ROI of RING:  0.07%   
Weekly ROI of RING: 0.489%    
Yearly ROI of RING: 25.51131%  
# 
if price change:     
y = 6, l0 = 50, p0 = 1.2  
then a0 = 45.64, a1 = 54.77   
Daily ROI of RING:  0.076%   
Weekly ROI of RING: 0.535%    
Yearly ROI of RING: 27.947%  
#
if LP_GOLD_RING and LP_RING_ETH all init with 1 : 1     
y = 6, l0= l1 = 50, a0 = a1 = 50, a2 = a3 = 50    
then p0 = 1, p1 = 1,   
Daily ROI of RING:  0.035%   
Weekly ROI of RING: 0.244%    
Yearly ROI of RING: 12.75%  
# 
if price change:  
y = 6, l1 = l2 = 50, p0 = 1.2, p1 = 0.5  
then a0 = 45.64, a1 = 54.77,  a2 = 35.355, a3 = 70.71    
Daily ROI of RING: 0.0465%  
Weekly ROI of RING: 0.326%  
Yearly ROI of RING: 16.975%  
# 
if price change: y = 6, l1 = l2 = 50, p0 = 0.6, p1 = 4   
then a0 = 64.55, a1 = 38.73,  a2 = 100, a3 = 25    
Daily ROI of RING: 0.015%  
Weekly ROI of RING: 0.105%  
Yearly ROI of RING: 5.516%  
# 
