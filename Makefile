.PHONY: docs clean

SPHINXOPTS =

# Gallery path must be given relative to the docs/ folder

ifeq ($(GALLERY_PATH),)
GALLERY_PATH := ../../napari/examples
endif

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))
docs_dir := $(current_dir)docs

clean:
	echo clean
	echo $(current_dir)
	rm -rf $(docs_dir)/_build/
	rm -rf $(docs_dir)/api/napari*.rst
	rm -rf $(docs_dir)/gallery/*
	rm -rf $(docs_dir)/_tags

docs-install:
	python -m pip install -qr $(current_dir)requirements.txt

prep-docs:
	python $(docs_dir)/_scripts/prep_docs.py

docs-build: prep-docs
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 sphinx-build -b html docs/ docs/_build -D sphinx_gallery_conf.examples_dirs=$(GALLERY_PATH) $(SPHINXOPTS)

docs-xvfb: prep-docs
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 xvfb-run --auto-servernum sphinx-build -b html docs/ docs/_build -D sphinx_gallery_conf.examples_dirs=$(GALLERY_PATH) $(SPHINXOPTS)

docs: clean docs-install docs-build

html: clean docs-build

# Implies noplot, but no clean - call 'make clean' manually if needed
# Autogenerated paths need to be ignored to prevent reload loops
html-live: prep-docs
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 \
	sphinx-autobuild \
		-b html \
		docs/ \
		docs/_build \
		-D plot_gallery=0 \
		-D sphinx_gallery_conf.examples_dirs=$(GALLERY_PATH) \
		--ignore $(docs_dir)"/_tags/*" \
		--ignore $(docs_dir)"/api/napari*.rst" \
		--ignore $(docs_dir)"/gallery/*" \
		--ignore $(docs_dir)"/jupyter_execute/*" \
		--open-browser \
		--port=0 \
		$(SPHINXOPTS)

html-noplot: clean prep-docs
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 sphinx-build -D plot_gallery=0 -b html docs/ docs/_build -D sphinx_gallery_conf.examples_dirs=$(GALLERY_PATH) $(SPHINXOPTS)

linkcheck-files:
	NAPARI_APPLICATION_IPY_INTERACTIVE=0 sphinx-build -b linkcheck -D plot_gallery=0 --color docs/ docs/_build -D sphinx_gallery_conf.examples_dirs=$(GALLERY_PATH)
