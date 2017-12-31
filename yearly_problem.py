#!/usr/bin/python

import argparse
import itertools

def solve_digit_tuple(digits):
	print digits

def solve(year):
	digits = [int(d) for d in str(year)]
	print digits

	for x in itertools.permutations(digits):
		solve_digit_tuple(x)

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("year", type=int)
	args = parser.parse_args()

	print ("Solution for year {}:".format(args.year))

	solve(args.year)


if __name__ == "__main__":
    main()
