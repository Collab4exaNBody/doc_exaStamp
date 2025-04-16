Analysis
========

Per-particle analysis
---------------------

Per-atom entropy
^^^^^^^^^^^^^^^^

The ``compute_local_entropy`` operator computes the per-atom entropy as define in ref.

.. code-block:: yaml

   compute_local_entropy:
     rcut: 5.0 ang
     sigma: 0.15 ang
     local: true
     nbins: 50

.. list-table::
   :widths: 10 40 10 10
   :header-rows: 1

   * - Property
     - Description
     - Data Type
     - Default
   * - ``rcut``
     - Upper integration limit of Eq. :eq:`per_atom_entropy`. Distance unit.
     - float
     - \\( r_c^{max} \\)
   * - ``sigma``
     - Broadening parameter. Distance unit.
     - float
     - :math:`0.1 \, \AA`
   * - ``local``
     - If set to ``true`` , the \\( g_m^i \\) is normalized by the local density around atom \\( i \\).
     - bool
     - ``true``
   * - ``nbins``
     - Number of bin on which the integral is discretised.
     - int
     - \\(n = \\lfloor r_{c} / \\sigma \\rfloor \\)


The per-atom entropy \\( s^{i}_{S} \\) is computed using the following formula:

.. math::
   :label: per_atom_entropy

    s^{i}_{S} = -2 \pi \rho k_{B} \int_{0}^{r_{m}} \left[ g^i_m(r) \ln g^i_m(r) - g^i_m(r) + 1 \right] r^2 dr

where \\( g^i_m(r) \\) is a mollified version of the radial distribution function

.. math::
   :label: grm
    
    g^i_m(r) = \frac{1}{4 \pi \rho r^2} \sum_{j \neq i} \frac{1}{\sqrt{ 2 \pi \sigma^2}}\exp^{-(r - r_{ij})^2 / (2 \sigma^2)}

where \\( r_{ij} \\) is the distance between central atom \\( i \\) and its neighbour \\( j \\), and \\( \\sigma \\) is the smoothing parameter.






Coarse-grained analysis
-----------------------
