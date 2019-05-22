Examples of Common Formatting
=============================

.. TODO:: Examples need to be removed from your class

.. HINT:: To remove this page:

   #. Edit the ``index.rst`` file and remove the ``examples`` line
   #. Delete the ``examples.rst`` file

This page has examples of many different types of formatting that can be
achieved using reStructuredText.  Complete documentation is available at:

http://www.sphinx-doc.org/en/stable/rest.html

.. HINT::
   `Click here to view the source of this page <_sources/examples.rst.txt>`__

Text Markup
-----------

Emphasis
~~~~~~~~

*italic text*

**bold text**

Code Samples
~~~~~~~~~~~~

``code sample``

This is one example of a code block::

    import math
    print 'import done'

Code block without syntax highlighting:

.. code::

   $ ls -l
   total 96
   -rw-r--r--  1 user  staff   610 Jun 22 17:51 Makefile
   drwxr-xr-x  4 user  staff   136 Jun 22 21:14 _build
   drwxr-xr-x  3 user  staff   102 Jun 22 21:16 _static
   drwxr-xr-x  3 user  staff   102 Jun 22 17:55 _templates
   drwxr-xr-x  5 user  staff   170 Jun 22 21:00 class1
   -rw-r--r--  1 user  staff  6764 Jun 22 21:26 conf.py
   -rw-r--r--@ 1 user  staff   733 Jun 22 21:41 examples.rst
   -rw-r--r--  1 user  staff   152 Jun 22 21:32 index.rst
   -rw-r--r--  1 user  staff   995 Jun 22 20:55 intro.rst
   -rw-r--r--  1 user  staff   817 Jun 22 17:51 make.bat
   $

Code block with syntax highlighting:

.. NOTE:: A list of supported languages can be found at
   `here <http://build-me-the-docs-please.readthedocs.io/en/latest/Using_Sphinx/ShowingCodeExamplesInSphinx.html#pygments-lexers>`__

.. code-block:: python

   import math
   a = 1
   b = 2
   sum = a + b
   print 'Sum: %s' % sum


Code block with highlighting and line numbers:

.. code-block:: python
   :linenos:

   import math
   a = 1
   b = 2
   sum = a + b
   print 'Sum: %s' % sum


Code block with highlighting, line numbers, and line highlighting:

.. code-block:: python
   :linenos:
   :emphasize-lines: 4-5

   import math
   a = 1
   b = 2
   sum = a + b
   print 'Sum: %s' % sum

Substitutions
-------------


rST:

.. code-block:: rst

   .. |name| replace:: replacement *text*

   |name|

Result:

.. |name| replace:: replacement *text*

|name|

Pre-configured Substitutions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A number of common substitutions are pre-configured for convenience:

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Name
     - Value
   * - ``|classname|``
     - |classname|
   * - ``|classbold|``
     - |classbold|
   * - ``|classitalic|``
     - |classitalic|
   * - ``|ltm|``
     - |ltm|
   * - ``|adc|``
     - |adc|
   * - ``|gtm|``
     - |gtm|
   * - ``|dns|``
     - |dns|
   * - ``|asm|``
     - |asm|
   * - ``|afm|``
     - |afm|
   * - ``|apm|``
     - |apm|
   * - ``|ipi|``
     - |ipi|
   * - ``|iwf|``
     - |iwf|
   * - ``|biq|``
     - |biq|
   * - ``|bip|``
     - |bip|
   * - ``|f5|``
     - |f5|
   * - ``|f5i|``
     - |f5i|
   * - ``|year|``
     - |year|

Hyperlinks
----------

External
~~~~~~~~

- Bare URL: https://www.f5.com
- Named Link: Click `here <https://www.f5.com>`__ to goto F5's website

Internal
~~~~~~~~

- Reference section headers in this document: `Hyperlinks <#hyperlinks>`__
- Reference other pages: :ref:`Welcome`



Lists
-----

Unordered Lists
~~~~~~~~~~~~~~~

- This
- Is
- A
- List

Ordered Lists
~~~~~~~~~~~~~

#. One
#. Two
#. Three
#. Four

Nested Lists
~~~~~~~~~~~~

- This

  #. One
  #. Two

     - Alpha
     - Bravo
     - Charlie

- Is

  - 1
  - 2

- A
- Nested
- List

Tables
------

List Tables
~~~~~~~~~~~

With Stub Column
^^^^^^^^^^^^^^^^

.. list-table::
    :widths: 20 40 40
    :header-rows: 1
    :stub-columns: 1

    * - **Column 1 (Stub)**
      - **Column 2**
      - **Column 3**
    * - Row 1
      - Value 1
      - Value 2
    * - Row 2
      - Value 1
      - Value 2

Without Stub Column
^^^^^^^^^^^^^^^^^^^

.. list-table::
    :widths: 20 40 40
    :header-rows: 1

    * - **Column 1**
      - **Column 2**
      - **Column 3**
    * - Row 1
      - Value 1
      - Value 2
    * - Row 2
      - Value 1
      - Value 2

Grid Tables
~~~~~~~~~~~

+------------------------+------------+----------+----------+
| Header row, column 1   | Header 2   | Header 3 | Header 4 |
| (header rows optional) |            |          |          |
+========================+============+==========+==========+
| body row 1, column 1   | column 2   | column 3 | column 4 |
+------------------------+------------+----------+----------+
| body row 2             | Cells may span columns.          |
+------------------------+------------+---------------------+
| body row 3             | Cells may  | - Table cells       |
+------------------------+ span rows. | - contain           |
| body row 4             |            | - body elements.    |
+------------------------+------------+----------+----------+
| body row 5             | Cells may also be     |          |
|                        | empty: ``-->``        |          |
+------------------------+-----------------------+----------+

Giant Tables
^^^^^^^^^^^^

+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+
| Header 1   | Header 2   | Header 3  | Header 1   | Header 2   | Header 3  | Header 1   | Header 2   | Header 3  | Header 1   | Header 2   | Header 3  |
+============+============+===========+============+============+===========+============+============+===========+============+============+===========+
| body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  |
+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+
| body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  |
+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+
| body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  |
+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+
| body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  | body row 1 | column 2   | column 3  |
+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+------------+------------+-----------+

Simple Tables
~~~~~~~~~~~~~

=====  =====  =======
A      B      A and B
=====  =====  =======
False  False  False
True   False  False
False  True   False
True   True   True
=====  =====  =======

Admonitions
-----------

Admonitions (a.k.a Callouts) can be used to make important information stand
out.  Examples of different admonitions are shown below.

**When including TMSH commands please use the TMSH admonition**

TMSH
~~~~

.. admonition:: TMSH

   tmsh show sys hardware

Hint
~~~~

.. HINT::
   This is a HINT admonition

Important
~~~~~~~~~

.. IMPORTANT::
   This is a IMPORTANT admonition

Tip
~~~

.. TIP::
   This is a TIP admonition

Note
~~~~

.. NOTE::
   This is a NOTE admonition

Attention
~~~~~~~~~

.. ATTENTION::
   This is a ATTENTION admonition

Caution
~~~~~~~

.. CAUTION::
   This is a CAUTION admonition


Warning
~~~~~~~

.. WARNING::
   This is a WARNING admonition

Error
~~~~~

.. ERROR::
   This is a ERROR admonition

Danger
~~~~~~

.. DANGER::
   This is a DANGER admonition

TODO's
------

TODO items can be marked in your docs.  By default the item will be included
in the generated docs and a build warning will be printed.

To change the defaults edit ``conf.py`` and look modify

.. code-block:: python

   todo_emit_warnings = True
   todo_include_todos = True

Here is the rST code for a TODO:

.. code-block:: rst

   .. TODO:: This is my example todo.  Please ignore me.

   .. TODO:: This is my second example todo.  Please ignore me.

And the TODO themselves:

.. TODO:: This is my first example todo.  Please ignore me.

.. TODO:: This is my second example todo.  Please ignore me.

You can also get a list of TODO's:

rST:

.. code-block:: rst

   .. TODOLIST::

.. TODOLIST::

Font-Awesome Icons
------------------

The ``f5-sphinx-theme`` can use icons from the Font Awesome:

http://fontawesome.io/icons/

For example:

.. code-block:: rst

   * :fonticon:`fa fa-home`
   * :fonticon:`fa fa-home fa-lg`
   * :fonticon:`fa fa-home fa-border`
   * :fonticon:`fa fa-home fa-2x`
   * :fonticon:`fa fa-home fa-3x`
   * :fonticon:`fa fa-home fa-4x`
   * :fonticon:`fa fa-gear fa-spin fa-4x`
   * :fonticon:`fa fa-gear fa-spin fa-4x text-success`

* :fonticon:`fa fa-home`
* :fonticon:`fa fa-home fa-lg`
* :fonticon:`fa fa-home fa-border`
* :fonticon:`fa fa-home fa-2x`
* :fonticon:`fa fa-home fa-3x`
* :fonticon:`fa fa-home fa-4x`
* :fonticon:`fa fa-gear fa-spin fa-4x`
* :fonticon:`fa fa-gear fa-spin fa-4x text-success`
