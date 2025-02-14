Contributing
============

.. warning::
   
   This page is currently under construction.

Any source code modification or new features in ``Onika``, ``exaNBody`` or ``exaStamp`` should be processed through the dedicated `GitHub <https://github.com/Collab4exaNBody>`_ repositories listed below, all part of the ``Collab4exaNBody`` workspace.

GitHub repositories
*******************

Below are listed the GitHub repositories associated with the three applications you need to compile and use exaStamp, namely Onika, exaNBody and exaStamp. 

.. list-table:: 
   :widths: 40 40
   :header-rows: 1
   :align: center

   * - Application
     - Repository
   * - ``onika``
     - https://github.com/Collab4exaNBody/onika
   * - ``exaNBody``
     - https://github.com/Collab4exaNBody/exaNBody
   * - ``exaStamp``
     - https://github.com/Collab4exaNBody/exaStamp

Forking repositories
********************
      
If you're willing to develop in one of these applications, we strongly advise you to fork these repositories on your personal GitHub account.

To do that, go to the web repositories addresses listed above and fork the corresponding project. Before pursuing, untick the option 'Copy the main branch only' so that you have access to the full list of dev branches.

This fork process provides you a personal copy of the project on your GitHub account, located at https://github.com/your-user-name/exaStamp for example. You can then clone the repository on your local machine.

.. code-block:: bash

   git clone git@github.com:your-user-name/exaStamp.git
   cd exaStamp
   git remote -v
   
In that git folder, typing ``git remote -v`` should only show ``origin`` as pointing to your copy of the projet located at https://github.com/your-user-name/exaStamp. You should add another remote named ``upstream`` by typing the following in the git folder:

.. code-block:: bash

   git remote add upstream git@github.com/Collab4exaNBody/exaStamp.git
   git remote -v

Typing a second time ``git remote -v`` should now show both ``origin`` and ``upstream`` pointing to https://github.com/your-user-name/exaStamp and https://github.com/Collar4exaNBody/exaStamp respectively. Finally, to check all available branches from all remotes you are tracking, you can type:

.. code-block:: bash

   git remote add upstream git@github.com/Collab4exaNBody/exaStamp.git
   git branch -a

Issues and Pull Request
***********************

Coding rules
************
