# Documentation

exaStamp documentation is built using [Zensical](https://zensical.org/).

## Prerequisities

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install zensical
```

## Preview as you write
  
Zensical includes a web server, so you can preview exaStamp documentation site as you write. The server will automatically rebuild the site when you make changes to source files. Start it with:

```bash
zensical serve
```
  
Point your browser to [localhost:8000](localhost:8000) and you should see it appear.

## Build exaStamp site

When you're finished editing, you can build a static site from your Markdown files with:

```bash
zensical build
```
  
The contents of this directory make up your project documentation. There's no need for operating a database or server, as it is completely self-contained.