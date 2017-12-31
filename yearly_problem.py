#!/usr/bin/python

import argparse
import itertools


solutions = {}

perm_seen = set()

# produce a triple from a tree: (value of tree, number of operators, tree)
def eval_tree(tree):
  t0 = tree[0]
  if type(t0) == int:
    return (t0, 0, tree)

  t1 = eval_tree(tree[1])
  t2 = eval_tree(tree[2])

  if t0 == '+':
    return (t1[0] + t2[0], 1 + t1[1] + t2[1], tree)
  if t0 == '-':
    return (t1[0] - t2[0], 1 + t1[1] + t2[1], tree)
  if t0 == '*':
    return (t1[0] * t2[0], 1 + t1[1] + t2[1], tree)
  if t0 == '/':
    if t2[0] == 0:
      return (0, 1000, tree)
    return (float(t1[0]) / t2[0], 1 + t1[1] + t2[1], tree)
  if t0 == '^':
    if t1[0] == 0 and t2[0] < 0:
      return (0, 1000, tree)
    if t1[0] >= 2 and t2[0] > 7:
      return (0, 1000, tree)
    if t1[0] < 0 and round(t2[0]) != t2[0]:
      return (0, 1000, tree)
    return (pow(t1[0],t2[0]), 1 + t1[1] + t2[1], tree)

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
  for t in trees_from_tuple(group):
    v = eval_tree(t)
    k = int(round(v[0]))
    if k != v[0]:
      continue
    if k < 1 or k > 100:
      continue
    if k in solutions:
      curr_v = solutions[k]
      if v[1] >= curr_v[1]:
        continue
    solutions[k] = v

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

  for k in solutions.keys():
    v = solutions[k]
    print ("{}: {}".format(k, v))

if __name__ == "__main__":
    main()
