# Crayenv

## Building from CPE image provided by Cray-HPE

```
singularity build --sandbox cray_hpe_cpe_22.02-021622 docker-archive://cray_hpe_cpe_22.02-021622.tgz
```

The `crayenv` is a collection of scripts to make Cray PE conntainer easily
launchable on CISL computing resources. The container is launched
using Charliecloud framework but singularity may be used with very little
modifications. The exact commands to launch are wrapped
in the script called `crayenv`,  when invoked, it gives a bash shell 
within the container. You may check running `module list` or `module available`.
If you're not familiar with cray environment `ftn`, `cc` and `CC` are
the Fortran (Cray), C (clang) and C++ (clang) compilers respectively,
that links with mpi libraries if needed.

If invoked within PBS job environment, for the first time it will create
a small SLURM cluster (within container) involving the nodes in the PBS 
job and start the cluster.
During subsequent invokation it will use the same SLURM cluster to launch
the jobs. The SLURM cluster can be queried using usual slurm commands like
`sinfo`, `scontrol` etc. but the commands need to be invoked within the container.

## Usage Monitoring

Please note that this is a licensed product from HPE-Cray and at this time
they are allowing us to use it with an implied obligations to provide feedback
to them. We have agreed to monitor your usage and will provide your email-id to 
HPE-Cray for the purpose of seeking feedback on use of CPE container.

## Building Applications

The whole `glade` is bind mounted within the container, so all user directories
are available. The default `TCL` module is configured and basic environment is
loaded to be able to compile or build simple MPI jobs.

## Launching Applications

In batch context there are few different ways to launch an MPI program
built within the container.

- Interactive context
In a shell within a batch job invoke `crayenv` to get a shell within the container.
Then invoke `srun` as needed e.g.
```
srun -n <number-of-tasks> ./a.out
```

- Batch script
1. Just prefix the `crayenv` command with srun.
```
#!/bin/bash
  :
#PBS -l select=2:ncpus=4:mpiprocs=4
  :
crayenv srun -n 8 ./a.out
```

2. Pretend interactive environment by redirecting the stdin into `crayenv`.
```
#!/bin/bash
  :
#PBS -l select=2:ncpus=4:mpiprocs=4
  :
crayenv << EOF
srun -n 8 ./a.out
EOF
```
in this way some pre and post processing commands within the container 
environment may be inserted before and after launching.
