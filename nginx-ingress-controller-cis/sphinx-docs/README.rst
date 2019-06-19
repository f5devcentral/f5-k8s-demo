F5 Agility Lab Template
=======================

Introduction
------------

This repo contains a template that should be used when creating lab
documentation for F5's Agility Labs.

Setup
-----

#. Download or ``git clone`` the f5-agility-lab-template
#. Download and install Docker CE (https://docs.docker.com/engine/installation/)
#. Build the sample docs ``./containthedocs-build.sh``. The first time you build
   a container (~1G in size) will be downloaded from Docker Hub.
#. Open the ``docs/_build/html/index.html`` file on you system in a web browser

Configuration & Use
-------------------

To use this template:

#. Copy contents of this repo to a new directory ``cp -Rf . /path/to/your/docs``
#. ``cd /path/to/your/docs``
#. Edit ``docs/conf.py``
#. Modify the following lines:

   - ``classname = "Your Class Name"``
   - ``github_repo = "https://github.com/f5devcentral/your-class-repo"``

#. Build docs ``./containthedocs-build.sh`` (*see Build Scripts below*)
#. Open the ``docs/_build/html/index.html`` file on you system in a web browser
#. Edit the ``*.rst`` files as needed for your class
#. Rebuild docs as needed using ``./containthedocs-build.sh``

Converting from Microsoft Word
------------------------------

To convert a ``.docx`` file from Microsoft Work to reStructuredText:

#. Copy your ``.docx`` file into the f5-agility-lab-template directory
#. Run ``./containthedocs-convert.sh <filename.docx>``
#. Your converted file will be named ``filename.rst``
#. Images in your document will be extracted and placed in the ``media``
   directory

.. WARNING:: While the document has been converted to rST format you will still
   need to refactor the rST to use the structure implemented in this template.

.. _scripts:

Build Scripts
-------------

The repo includes build scripts for common operations:

- ``containthedocs-bash.sh``: Run to container with a BASH prompt
- ``containthedocs-build.sh``: Build HTML docs using ``make -C docs html`` to
  ``docs/_build/html``
- ``containthedocs-clean.sh``: Clean the build directory using
  ``make -C docs clean``
- ``containthedocs-cleanbuild.sh``: Clean the build directory and build HTML
  docs using ``make -C docs clean html``
- ``containthedocs-convert.sh``: Convert a Word ``.docx`` file to rST
- ``containthedocs-pdf.sh``: Build PDF docs using ``make -C docs latexpdf`` to
  ``docs/_build/latex``


