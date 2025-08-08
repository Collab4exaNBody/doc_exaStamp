<div style="display: flex; align-items: center; justify-content: center; height: 400px;">
  <div style="text-align: center; width: 75%;">
    <p style="margin: 0; font-size: 2em; line-height: 1.5;">
      Welcome to the <strong>exaStamp</strong> code documentation. exaStamp stands for <strong>exa</strong>scale <strong>S</strong>imulation of <strong>T</strong>ime-dependent <strong>A</strong>tomic and <strong>M</strong>olecular systems in <strong>P</strong>arallel.
    </p>
  </div>
  <div style="text-align: center; width: 25%;">
    <img src="_static/xsp_logo.png" style="width: 100%; vertical-align: middle;" />
  </div>
</div>

-----------------------------------------------------------------------------------------------------------

<div style="text-align: center; width: 100%;">
  <p style="margin: 0; font-size: 1.5em; line-height: 1.5;">
  This is the <strong>exaStamp</strong> software package, a high performance molecular dynamics simulation code, originated at CEA/DAM. <strong>exaStamp</strong> stands for <strong>S</strong>imulations <strong>T</strong>emporelles <strong>A</strong>tomistiques et <strong>M</strong>oléculaires <strong>P</strong>arallèles à l'<strong>exa</strong>scale (in French) or <strong>exa</strong>scale <strong>S</strong>imulations of <strong>T</strong>ime-dependent <strong>A</strong>tomistic and <strong>M</strong>olecular systems in <strong>P</strong>arallel (in English). This software is distributed under the Apache 2.0 public license.  
  </p>
</div>

-----------------------------------------------------------------------------------------------------------

<div style="text-align: center; width: 100%;">
  <p style="margin: 0; font-size: 1.5em; line-height: 1.5;">
  <strong>exaStamp</strong> is designed to run efficiently on supercomputers as well as laptops or workstations. It takes advantage of hybrid parallelism with the ability to run using MPI + X where X is either OpenMP or Cuda/HIP. This code is the result of a long-time effort at CEA/DAM/DIF, France. It is an open-source code, distributed freely under the terms of the Apache Public License version 2.0.
  </p>
</div>

-----------------------------------------------------------------------------------------------------------

<div style="display: grid; grid-template-columns: auto auto; align-items: center; justify-content: center; column-gap: 60px; row-gap: 20px; height: 250px;">

  <!-- Row 1: Texts -->
  <div style="text-align: center; font-weight: bold;">exaStamp GitHub Repository</div>
  <div style="text-align: center; font-weight: bold;">Open a New Issue</div>

  <!-- Row 2: Images -->
  <div style="text-align: center; margin-top: -100px;">
    <a href="https://github.com/Collab4exaNBody/exaStamp" target="_blank">
      <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" alt="GitHub" style="height: 120px;">
    </a>
  </div>

  <div style="text-align: center; margin-top: -100px;">
    <a href="https://github.com/Collab4exaNBody/exaStamp/issues/new" target="_blank">
      <img src="https://raw.githubusercontent.com/primer/octicons/main/icons/issue-opened-16.svg" alt="Create Issue" style="height: 90px;">
    </a>
  </div>

</div>

<div style="text-align: center; width: 100%;">
  <p style="margin: 0; font-size: 1.5em; line-height: 1.5;">
  To access the <strong>exaStamp</strong> GitHub repository, please use the GitHub link above (left). If, by running the code or during the installation procedure, you were to identify a problem or if you would like to suggest any improvements or require a new feature, please use the "Open a New Issue" link above.
  </p>
</div>

-----------------------------------------------------------------------------------------------------------

# exaStamp documentation

```{toctree}
:name: exastamp_variant
:maxdepth: 2
:caption: exaStamp
project_exaStamp/1_Background/index.md
project_exaStamp/2_Build_and_Install.rst
project_exaStamp/3_Beginners_guide.rst
project_exaStamp/4_Domain_Regions.rst
project_exaStamp/5_Grids.rst   
project_exaStamp/6_Particles.rst
project_exaStamp/7_Interactions.rst
project_exaStamp/8_Constraints.rst
project_exaStamp/3bis_microStamp.rst
project_exaStamp/Exhaustive_plugins.rst
project_exaStamp/9_Contributing.rst
```