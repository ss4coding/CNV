from decimal import *
import sys
getcontext().prec = 2
print ( Decimal(sys.argv[1]) / Decimal(sys.argv[2]))
