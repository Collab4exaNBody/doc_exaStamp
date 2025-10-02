# **Release 3.7.3**

## **Deterministic capabilities for testing and CI**

**Related PR:**

* Operators with deterministic random capabilities by @lafourcadep in https://github.com/Collab4exaNBody/exaStamp/pull/48

**Description:** 

If activated, all operators that use random generators are made deterministic i.e. the results is the same if launched using any combination of MPI processes or OMP threads.

**Usage example:**

```yaml
+compute_force:
    - langevin_thermostat: { T: 300. K, gamma: 0.1 ps^-1}

global:
  simulation_end_iteration: 20
  simulation_log_frequency: 50
  simulation_dump_thermo_frequency: -1
  simulation_dump_frequency: -1
  deterministic_noise: true
```

## Small changes

**File lencensing for open source release**

* 33 file licensing by @lafourcadep in https://github.com/Collab4exaNBody/exaStamp/pull/37

**Remove contribs/taz and place it in a separate repository

* remove taz by @rprat-pro in https://github.com/Collab4exaNBody/exaStamp/pull/43

**Cleanup contribs folder and reorganize folders/files in exaStamp

* 42 cleanup contribs folder by @lafourcadep in https://github.com/Collab4exaNBody/exaStamp/pull/44

**Full Changelog**: https://github.com/Collab4exaNBody/exaStamp/compare/v3.7.2...v3.7.3  
