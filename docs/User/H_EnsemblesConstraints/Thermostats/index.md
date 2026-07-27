# **Thermostats**

Operators that couple the system to a target temperature by adjusting velocities or forces directly, rather than replacing the time-integration scheme (see [NVT ensemble](../nvt_ensemble.md) for the Nosé-Hoover alternative, which does replace it).

- [**Berendsen Thermostat**](berendsen.md) — weak-coupling velocity rescaling, appended after the integration step
- [**Langevin Thermostat**](langevin.md) — implicit-solvent damping + random force, inserted into the force-computation step
