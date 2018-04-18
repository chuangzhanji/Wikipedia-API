# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = python3 -msphinx
SPHINXPROJ    = Wikipedia-API
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

pypi-html:
	python3 setup.py --long-description | rst2html.py > pypi-doc.html

run-tests:
	python3 -m unittest discover tests/ '*test.py'

run-coverage:
	coverage run --source=wikipediaapi -m unittest discover tests/ '*test.py'
	coverage report -m

release: run-tests pypi-html
	if [ "x$(MSG)" = "x" ]; then \
		echo "Use make release MSG='some msg'"; \
		exit 1; \
	fi; \
	version=`grep __version__ wikipediaapi/__init__.py | sed -r 's/.*= \( *(.*), *(.*), *(.*)\)/\1.\2.\3/'`; \
	if [ "x$$version" = "x" ]; then \
		echo "Unable to extract version"; \
		exit 1; \
	fi; \
	echo "Current version: $$version"; \
	short=`echo $$version | cut -f1-2 -d.`; \
	echo "Short version: $$short"; \
	sed -ri 's/version=.*/version="'$$version'",/' setup.py; \
	sed -ri 's/^release = .*/release = "'$$version'"/' conf.py; \
	sed -ri 's/^version = .*/version = "'$$short'"/' conf.py; \
	sed -ri 's/^Current version is: = .*/Current version is: "'$$version'"/' wikipediaapi/__init__.py; \
	git commit setup.py conf.py wikipediaapi/__init__.py -m "Update version to $$version for releasing new version."; \
	git push; \
	git tag $$version -m "$(MSG)"; \
	git push --tags origin master

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)



