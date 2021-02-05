# MortgageCostCalculationApp
Simple RShiny App I used to help work out if my partner and I could afford to buy our second house. I threw this together in an hour so made a few assumptions:
1. House costs between 250 and 500k
2. Stamp duty is being paid

The app adds up all the costs we expect to face and various sources of income to produce a balance and plots the balance against the cost of the house to work out what we can actually afford to buy.
It allows plots using up to two different deposit percentages to be plotted.
It also allows a maximum lending amount to be specified, in this case the calculation changes: 
	* Total mortgage amount, M is given by L/(1-D) where D is the fractional deposit and balance, B = I - C - P + (L/(1-D)) where I is the Income, C = Costs and P is the purchase price of the property
	* Here, I is constant but C = f(P) = K + 0.05(P-250,000) assuming P is between 250,000 and 500,000 (this is stamp duty)
	* We can reduce this to C = 0.05P + K1 so B = (L/(1-D)) - 1.05P + K2 for M < P
	* If M > P then B = I - C - DP = I - K3 - 0.05P - DP  = K4 - (0.05 + D)P So a change point is introduced at P = L/(1-D)
	
	
