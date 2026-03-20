---
icon: material/numeric-1-circle
---    

# **Benchmarking MD potentials**

A few examples to benchmark MD potentials are available in microStamp. These examples focus on the two available potentials in microStamp, namely:

- Lennard-Jones (LJ)
- Spectral Neighbor Atomistic Potential (SNAP)
  
These examples can be accessed using the following command:

```
cd ${XNB_SRC_DIR}/contribs/microStamp/samples/benchmark_lj_snap/
```

```bash
>> tree .
.
├── check_values_lj_Ni.dat
├── check_values_snap_Mo.dat
├── check_values_snap_Ni.dat
├── input_lj_Ni.msp
├── input_snap_Mo.msp
└── input_snap_Ni.msp

0 directories, 6 files
```

One example for a LJ potential is available :

- FCC Ni with a 16384 atoms baseline run for 100 time-steps

To run this case, do the following:

```bash
source ${XNB_INSTALL_DIR}/exaNBody
export OMP_NUM_THREADS=8
export N_MPI=1
mpirun -np ${N_MPI} ${XNB_INSTALL_DIR}/exaNBody input_lj_Ni.msp
```
          
Two examples for a SNAP potential are available. The first one consists in 8192 BCC Mo atoms that runs for 100 time-steps. To run this case, do the following:

```bash
source ${XNB_INSTALL_DIR}/exaNBody
export OMP_NUM_THREADS=8
export N_MPI=1
mpirun -np ${N_MPI} ${XNB_INSTALL_DIR}/exaNBody input_snap_Mo.msp
```

The second one consists in 16384 FCC Ni atoms that run for 100 time-steps. To run this case, do the following:

```bash
source ${XNB_INSTALL_DIR}/exaNBody
export OMP_NUM_THREADS=8
export N_MPI=1
mpirun -np ${N_MPI} ${XNB_INSTALL_DIR}/exaNBody input_snap_Ni.msp
```
    
If you run these case as they are defined, an automatic check will be performed to verify that the physics is correct! Reference data (positions, velocities, accelerations) are contained in the '.dat' files.