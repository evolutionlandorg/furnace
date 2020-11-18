#!/usr/bin/env python
# -*- coding: utf-8 -*-

base_rate = 0.026
rates = []
for i in range(91):
    rate = round(1.026**i*100, 1) 
    rates.append(int(rate))

print(rates)
print(len(rates))
