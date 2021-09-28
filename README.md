#Crayenv

The `crayenv` is a collection of scripts to make Cray PE conntainer easily
launchable on  CISL computing resources. The container is launched
using Charliecloud framework. The exact commands to launch are wrapped
in the script called `crayenv`,  when invoked, it gives a bash shell 
within the container

If invoked within PBS job environment, for the first time it will create
a small SLURM cluster involving the nodes in the PBS job and start the cluster.
During subsequent invokation it will use the same SLURM cluster to launch
the jobs.

The whole `glade` is bind mounted within the container, so all user directories
are available. In batch context there are severaal ways to launch an MPI program
built within container.

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
in this case some pre-processing within the container environment may be
performed before launching.
