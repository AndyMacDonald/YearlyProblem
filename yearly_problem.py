#!/usr/bin/python

import argparse
import itertools

perm_seen = set()

# produce a pair from a tree: (value of tree, number of operators)
def eval_tree(tree):
  t0 = tree[0]
  if type(t0) == int:
    return (t0, 0)

  t1 = eval_tree(tree[1])
  t2 = eval_tree(tree[2])

  if t0 == '+':
    return (t1[0] + t2[0], 1 + t1[1] + t2[1])
  if t0 == '-':
    return (t1[0] - t2[0], 1 + t1[1] + t2[1])
  if t0 == '*':
    return (t1[0] * t2[0], 1 + t1[1] + t2[1])
  if t0 == '/':
    if t2[0] == 0:
      return 0
    return (t1[0] / t2[0], 1 + t1[1] + t2[1])
  if t0 == '^':
    return (pow(t1[0],t2[0]), 1 + t1[1] + t2[1])

# from a tuple of numbers, produce all trees of operators
def trees_from_tuple(tpl):
  splits = len(tpl) - 1

  if splits == 0:
    return [tpl]

  trees = []

  for i in range(splits):
    lefts = trees_from_tuple(tpl[:i+1])
    rights = trees_from_tuple(tpl[i+1:])

    for l in lefts:
      for r in rights:
        trees.append(('+', l, r))
        trees.append(('-', l, r))
        trees.append(('*', l, r))
        trees.append(('/', l, r))
        trees.append(('^', l, r))

  return trees

# given a tuple of individual digits, produce all groupings
# of the digits into larger numbers, preserving order
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

def solve_group(group):
  trees = trees_from_tuple(group)
  print trees
  
def solve_digit_tuple(digits):
  for g in groups_from_digits(digits):
    solve_group(g)

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
