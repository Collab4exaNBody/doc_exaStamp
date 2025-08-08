# Release 3.7.2

## Small changes

* Use the release mode as default build type mode
* add CONTRIBUTING.md + update guidelines in README.md 
* add SUPPORT.md
* supressed paraview and xyz specific writers as they're obsolete. These operators are now defined in exaNBody directly

## EAM potentials 

EAM potentials now use exaNBody's generalized attributes for the local electronic density and embedding functions used in EAM potentials. This now allows to visualize the local electronic density as a per-atom field in OVITO or ParaView for example.  

Usage example (if an EAM potential is used!) :

```yaml
write_xyz:
  fields: [ rho_dEmb ]
```
 
:::{figure} /_static/eam_rho.gif
:width: 40%
:align: center
:::
  
## Spatial average 

Thanks to new functionalities added in exaNBody@v2.0.5, a spatial averaging function is now available in exaStamp. 

Usage example: 

```yaml
average_neighbors_scalar:
  nbh_field: mass
  avg_field: avgmass
  rcut: 8.0 ang
  weight_function: [ 1.0, 0.0, 0.0, 0.0 ]

write_xyz:
  fields: [ mass, avgmass ]
  filename: "test_avg.xyz"
```

Figure generated using ovito from test_avg.xyz file:

:::{figure} /_static/average.png
:width: 40%
:align: center
:::

**Full Changelog**: https://github.com/Collab4exaNBody/exaStamp/compare/release-v3.7.0...v3.7.2