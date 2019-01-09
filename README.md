# Yearly Problem

<div id="main"></div>

<script type="text/javascript">
{% include assets/yearly.js %}
</script>
<script>
var mainNode = document.getElementById('main');
var app = Elm.Main.init( { node: mainNode });
</script>

## The Idea

Since 1975, Technology Review's Puzzle Pages has run a "Yearly Problem" with the following rules:

> How many integers from 1 to 100 can you form using the digits of the current year exactly once each,
> along with the operators +, -, * (multiplication), / (division), and ˆ (exponentiation)?
> We desire solutions containing the minimum number of operators; among solutions having a given number
> of operators, those using the digits of the year in order are preferred. Parentheses may be used; they
> do not count as operators. A leading minus sign, however, does count as an operator. (Description lightly
> edited so it is not year-specific.)

[Puzzle Corner](https://cs.nyu.edu/~gottlieb/tr/) has been run since its inception by Allan Gottlieb of NYU. You can find more details, including published solutions to the Yearly Problem, at the link.

## The Implementation

The whole page, including the solver, is written in [Elm](http://elm-lang.org). Each time a new digit is typed the solver is run and solutions displayed. The steps are:

1. Generate all unique permutations of the digits in the number.
2. For each permutation, generate all the ways to group the digits together. For example, a three digit number yields four different groupings: 123, (12 3), (1 23), (1 2 3).
3. For each grouping, generate all the ways to apply the operators +, -, *, /, ^.
4. Evaluate each of those and keep the ones the result in integers from 1 to 100.
5. When collecting solutions, prefer ones with fewer operators and where the original digit order is preserved.
6. Display an ordered list with the best solutions. Solutions with digits in the order of the input are shown in bold.

For a four digit year with unique digits, we consider tens of thousands of trees, an exhaustive search over the permutations.

## Postmortem

**Performance:** I originally worried the solution would be slow and that I would need to spend quite a bit of time optimizing. I wanted the page to be instantly reactive to typing. To my surprise, the first implementation was fast enough. Beyond deduplicating the set of permutations in step (1) above, no optimizations were made.

**Formatting the solutions:** My original plan was to use MathML to format the solutions. MathML is not supported in all browsers, but works in [Firefox and Safari](https://caniuse.com/#search=mathml). I could not get it to work in Elm -- Elm generated the correct DOM, as I could verify using Firefox's inspector, but it was not rendered correctly. So ultimately I just generated HTML to superscript the exponents.

## Update, January 2019

This app was originally written in Elm 0.18. In January 2019 I upgraded it to Elm 0.19 to take advantage of Elm's new optimization features. The recompile cut the size of the javascript file from 450K to 210K. Zipping the JS dropped the size to 41K, much easier to load.
