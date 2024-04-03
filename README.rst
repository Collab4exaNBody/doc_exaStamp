# README for exaStamp

## Build static html doc

```
make html
cd build/html
firefox index.html
```

## Build pdf doc from auto-generated latex files 

```
make latexpdf
cd build/latex
evince doc.pdf
```

## Install prerequisites on Ubuntu
sudo apt install sphinx sphinx-doc sphinx-rtd-theme-common python3-pip texlive-full latexmk
pip install sphinx_rtd_theme
