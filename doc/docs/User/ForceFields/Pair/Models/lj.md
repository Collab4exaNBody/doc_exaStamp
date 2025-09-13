# **Lennard-Jones**

## **Description**
        
The `lj_compute_force` operator calculates the standard 12/6 Lennard-Jones pair potential computes the given by

$$
E = 4 \epsilon \left[ \left(\frac{\sigma}{r}\right)^{12} - \left(\frac{\sigma}{r}\right)^{6} \right] \quad \text{for} \quad r<r_c
$$

with $r_c$, $\epsilon$ and $\sigma$ the potential parameters decribed in the following table.
  
<div class="center-table" markdown>
  
| Parameter     | Units    | Description                                   |
| :------------ | :------: | :-------------------------------------------- |
| $\varepsilon$ | energy   | Depth of energy well                          |
| $\sigma$      | distance | Distance of energy well from central particle |
| $r_c$         | distance | Cutoff radius                                 |
  
</div>
  
## **YAML syntax**
    
```yaml
lj_compute_force:
  rcut: VALUE UNITS
  parameters: { epsilon: VALUE UNITS , sigma: VALUE UNITS }
```

- [x] VALUE = Physical value of the intended parameter.
- [x] UNITS = Units of the provided value that will be passed to the conversion helper for internal units conversion.

## **Usage examples**
  
!!! example "**Systems with a single atomic specy**"
    ```yaml
    # Default variant
    lj_compute_force:
      parameters: { epsilon: 0.0104 eV , sigma: 3.4 ang }
      rcut: 8.0 ang

    # Symetric variant
    lj_compute_force_symetric:
      parameters: { epsilon: 0.0104 eV , sigma: 3.4 ang }
      rcut: 8.0 ang  
    ```

!!! example "**Systems with multiple atomic species**"
  
    ```yaml
    lj_multi_force:
      rcut: 8. ang
      common_parameters: { epsilon: 0.0 , sigma: 0.0 }
      parameters:
        - { type_a: Zn , type_b: Zn , rcut: 6.10 ang , parameters: { epsilon: 2.522E-20 J , sigma: 0.244E-09 m } }
        - { type_a: Cu , type_b: Zn , rcut: 5.89 ang , parameters: { epsilon: 4.853E-20 J , sigma: 0.236E-09 m } }
    ```  