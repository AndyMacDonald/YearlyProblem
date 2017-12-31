#!/usr/bin/python

import argparse
import itertools

# 1234

# 1 2 3 4
# 1 2 34
# 1 23 4
# 12 3 4
# 1 234
# 123 4
# 1234
# 12 34

perm_seen = set()

def groups_from_digits(digits):
	if len(digits) == 1:
		return [digits]

	last = digits[-1]
	rest = groups_from_digits(digits[:-1])

	groups = []
	for g in rest:
		g1 = g + (last,)
		groups.append(g1)
		if g[-1] != 0:
			g2 = g[:-1] + (g[-1] * 10 + last,)
			groups.append(g2)

	return groups

def solve_digit_tuple(digits):
	groups = groups_from_digits(digits)
	
	print groups

def solve(year):
	digits = [int(d) for d in str(year)]
	print digits

	for x in itertools.permutations(digits):
		if x in perm_seen:
			continue
		perm_seen.add(x)
		solve_digit_tuple(x)

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("year", type=int)
	args = parser.parse_args()

	print ("Solution for year {}:".format(args.year))

	solve(args.year)


if __name__ == "__main__":
    main()
