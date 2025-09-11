# Documentation

SLOTH documentation is made with [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).


## How to build a static version?

### Prerequisities

MkDocs, a number of plugins and extensions are required to create the documentation and to have the desired rendering in HTML.

All these requirements are listed in the file `requirements.txt`. Their installation is done using `pip`:

```bash
pip install -r requirements.txt
```

### Documentation 

Once the prerequisites are installed, the documentation can be created by running the command:
```bash
bash install.sh
```
This will create a folder called `sloth_doc` in which users will find the `index.html` file needed 
to open the documentation with their preferred browser. 











