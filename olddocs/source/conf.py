# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))

# -- Project information -----------------------------------------------------

project = 'exaStamp documentation'
copyright = '2023-2024, Thierry Carrard, Raphaël Prat, Jean-Philippe Perlat, Paul Lafourcade'
author = 'Thierry Carrard, Raphaël Prat, Jean-Philippe Perlat, Paul Lafourcade'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
# extensions = ['sphinx_book_theme',
#               'sphinx_rtd_theme',
fontawesome_included = True

extensions = [
#   "sphinx_book_theme",
   "sphinx_rtd_theme",   
   "ablog",
 #  "myst_nb",
   "myst_parser",
   #    "numpydoc",
   #    "sphinx.ext.autodoc",
   #    "sphinx.ext.intersphinx",
   "sphinx.ext.viewcode",
   #    "sphinxcontrib.youtube",
   "sphinx.ext.mathjax",
   "sphinx_copybutton",
   "sphinx_design",
   "sphinx_examples",
   "sphinx_tabs.tabs",
   "sphinx_thebe",
   "sphinx_togglebutton",
   "sphinxcontrib.bibtex",
   #    "sphinxext.opengraph",
   "sphinx.ext.todo",
]
# source_suffix = {
#    '.rst': 'restructuredtext',
#    '.txt': 'markdown',
#    '.md': 'markdown',
# }

myst_enable_extensions = [
    "dollarmath",
    "amsmath",
    "deflist",
    # "html_admonition",
    # "html_image",
    "colon_fence",
    # "smartquotes",
    # "replacements",
    # "linkify",
    # "substitution",
]

mathjax3_config = {
    "tex": {
        "macros": {
            "AA": "\\unicode{197}"  # Unicode for Å
        }
    }
}

html_js_files = [
    'https://kit.fontawesome.com/##########.js',
]

bibtex_bibfiles= ["../doc_exaNBody/sources/bibliography.bib"]

bibtex_default_style = "plain"

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['requirements.txt', '*~']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
#html_theme = 'sphinx_rtd_theme'
html_theme = 'renku'
html_logo = "_static/xsp_logo.png"
html_theme_options = {
    'logo_only': False,
    'display_version': True,
    }
version = "Release 3.7.2"

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']
#html_css_files = ['css/custom.css']

def setup(app):
   app.add_css_file('css/custom.css')
