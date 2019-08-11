#!/usr/bin/python

# Yearly problem, consume 1 digit at a time, construct trees and evaluate when all digits are consumed
import argparse

solutions = {}

def list_to_string(l):
  return ''.join(map(str,l))

def list_to_int(l):
  return int(list_to_string(l))

# produce a triple from a tree: (value of tree, number of operators, tree)
def eval_tree(tree):
  # print (tree)
  t0 = tree[0]
  if type(t0) == list:
    return (list_to_int(t0), 0, tree)

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

def eval_trees(trees):
  for t in trees:
    v = eval_tree(t)
    k = v[0]
    if k < 1 or k > 100:
      continue

    k = int(round(k))
    if k != v[0]:
      continue
    if k in solutions:
      curr_v = solutions[k]
      if v[1] >= curr_v[1]:
        continue
    solutions[k] = v

def precidence(op):
  if op == '+' or op == '-':
    return 1
  if op == '*' or op == '/':
    return 2
  if op == '^':
    return 3
  return 4 # noop

def commutative(op):
  if op == '-' or op == '/' or op == '^':
    return False
  return True

def need_parens(parent, child):
  if child == '':
    return False
  if not commutative(parent) and precidence(parent) == precidence(child):
    return True
  return precidence(parent) > precidence(child)

def format_tree(tree):
  if len(tree) == 1:
    return (list_to_string(tree[0]), '')

  left = format_tree(tree[1])
  l = left[0]
  right = format_tree(tree[2])
  r = right[0]
  op = tree[0]

  if need_parens(op, left[1]):
    l = "(" + l + ")"
  if need_parens(op, right[1]):
    r = "(" + r + ")"

  return (l + " " + op + " " + r, op)

# Return all the trees that can be made by adding the new digit to the
# tree. For every number in the tree:
# 1) Add the new digit to every possible position in the number (n+1 positions
#    for an n digit number) 
# 2) Replace the number with new subtrees with the digit on one side and the
#    number on the other. Create left and right versions for non-commutative
#    operators (-, /, ^), but only (op d n) for commutative ones (+, *), so eight
#    new trees total from each application
def add_digit_to_tree(tree, d):
  new_trees = []

  ld = [d]

  # Just a number
  if len(tree) == 1:
    # Add digit to number
    t0 = tree[0]
    #print (t0)
    for i in range(len(t0) + 1):
      nt0 = t0[0:i] + ld + t0[i:]
      #print (nt0)
      new_trees.append([nt0])

  else:
    for l in add_digit_to_tree(tree[1], d):
        new_trees.append([tree[0], l, tree[2]])
    for r in add_digit_to_tree(tree[2], d):
        new_trees.append([tree[0], tree[1], r])

  # Add new subtrees
  for op in ['+', '-', '*', '/', '^']:
    new_trees.append([op, [ld], tree])
    if not commutative(op):
      new_trees.append([op, tree, [ld]])

  return new_trees

def add_digit_to_trees(trees, d):
  new_trees = []
  for t in trees:
    new_trees.extend(add_digit_to_tree(t, d))
  return new_trees

def solve(year):
  trees = []

  while year > 0:
    d = year % 10
    year = year / 10

    if len(trees) == 0:
      trees = [[[d]]]
    else:
      trees = add_digit_to_trees(trees, d)

  eval_trees(trees)

def main():

  parser = argparse.ArgumentParser()
  parser.add_argument("year", type=int)
  args = parser.parse_args()

  print ("Solution for year {}:".format(args.year))

  solve(args.year)

  for k in solutions.keys():
    v = format_tree(solutions[k][2])[0]
    print ("{}: {}".format(k, v))

if __name__ == "__main__":
    main()