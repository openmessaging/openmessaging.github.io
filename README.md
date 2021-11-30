# The OpenMessaging website

## Installation

In order to build the website and run it locally, you'll need to have Ruby version 2.4.1 installed. If you're using [rbenv](https://github.com/rbenv/rbenv):

```bash
$ rbenv install && rbenv local 2.4.1
```

Once you're using the correct Ruby version, you can install all dependencies:

```bash
$ make setup
```

## Running the site locally

To run the site locally:

```bash
$ make serve
```

Then navigate to http://localhost:4000 to visit the site. When you make changes to the website source in `_posts` or `_docs`, the site will update automatically in your browser.

## How to publish the site

Just push your change to `source` branch and GitHub workflow will do for the next steps.

## HTML Structure

This template is based on the [ZURB Foundation](http://foundation.zurb.com/) framework. For a primer on what the `row` and `column` classes mean, please refer to the Foundation [documentation](http://foundation.zurb.com/sites/docs/).

### HTML files

* `_layouts`
  1. `blog.html` --- The blog layout file
  2. `default.html` --- The default layout file
  3. `post.html` --- The blog post layout file
  4. `docs.html` --- The documentation page layout file
* `blog`
  1. `index.html` --- The blog index page


## CSS structure

The CSS files are based on the Foundation framework.

1. `fontello.css` --- The [Fontello](https://github.com/fontello/fontello) icon font
2. `foundation.scss` --- The Foundation framework Sass source file
3. `style.css` --- The main style
4. `font-awesome.css` --- The [Font Awesome](http://fontawesome.io/) icon font

## Javascript structure

Javascript files:

1. `app.js` --- Main JavaScript file
2. `foundation.js` --- Foundation framework JavaScript
3. `jquery.appear.js` --- jQuery plugin
4. `jquery.countTo.js` --- jQuery plugin
5. `imagesloaded.pkgd.min.js`
6. `jquery.easing.1.3.js`
7. `jquery.sequence-min.js`
8. `jquery.validate.js`
9. `json2.js`
10. `masonry.pkgd.js`
11. `slick.min.js`
12. `jquery-2.1.0.js`
13. `jquery.url.js`
14. `modernizr.foundation.js`
15. `terrific-1.1.1.js`
16. `jquery.cookie.js`
