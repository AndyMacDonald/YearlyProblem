# Yearly Problem
Since 1975, Technology Review's Puzzle Pages has run a "Yearly Problem" with the following rules:

```markdown
How many integers from 1 to 100 can you form using the digits of the current year exactly once each, along with the operators +, &minus;, &times; (multiplication), / (division), and ˆ (exponentiation)? We desire solutions containing the minimum number of operators; among solutions having a given number of operators, those using the digits of the year in order are preferred. Parentheses may be used; they do not count as operators. A leading minus sign, however, does count as an operator.
```


<div id="main"></div>

<script type="text/javascript">
{% include assets/yearly.js %}
</script>
<script>
var node = document.getElementById('main');
var app = Elm.Main.embed(node);
</script>

You can use the [editor on GitHub](https://github.com/AndyMacDonald/YearlyProblem/edit/master/README.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/AndyMacDonald/YearlyProblem/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
