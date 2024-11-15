Installing ExaNB and Your application on Adastra
================================================

Disclaimer: This section has been written the 02/07/24 and the environment may have changed in the meantime. This section gives some commands to help users to compile and use their application on Adastra. Example are done with `exaDEM`.²


Download  sources
-----------------

.. code-block:: bash

	cd ${HOME}
	mkdir sources; cd sources
	(git clone https://github.com/Collab4exaNBody/exaDEM.git;
	cd exaDEM;
	git checkout xdm-parallel-execution-streaming)
	(git clone https://github.com/Collab4exaNBody/exaNBody.git;
	cd exaNBody;
	git checkout parallel-execution-streaming)
	SRC_DIR=$HOME/sources/exaDEM
	XNB_DIR=$HOME/sources/exaNBody


Load your Environment:
----------------------

.. code-block:: bash

	PROJECT_SETUP_ENV_COMMANDS="module purge ; module load PrgEnv-gnu/8.5.0 ; module load craype-x86-trento craype-accel-amd-gfx90a ; module load rocm/5.5.1 ; ml .omnitrace/1.10.4 ; ml .omniperf/1.0.10"
	eval ${PROJECT_SETUP_ENV_COMMANDS}
	BUILD_DIR=$WORKDIR/build/exaDEM
	RUN_DIR=$WORKDIR/bench

Configuration File Example
--------------------------

Put the following lines in your configure-exaDEM.sh file

.. code-block:: bash

	cmake \
	     -DCMAKE_C_COMPILER=hipcc \
	     -DCMAKE_CXX_COMPILER=hipcc \
	     -DCMAKE_CXX_FLAGS="-Wpass-failed" \
	     -DCMAKE_HIP_FLAGS="-Wpass-failed" \
	     -DXNB_BUILD_CUDA=ON \
	     -DXNB_ENABLE_HIP=ON  \
	     -DCMAKE_HIP_PLATFORM=amd \
	     -DONIKA_HAVE_OPENMP_DETACH=OFF \
	     -DONIKA_HAVE_OPENMP_TOOLS=OFF \
	     -DONIKA_HIP_COMPILE_FLAGS="-Werror=return-stack-address;-Werror=return-type" \
	     -DOpenMP_CXX_LIB_NAMES="gomp;pthread" \
	     -DOpenMP_gomp_LIBRARY=/opt/rocm-5.5.1/llvm/lib/libgomp.so \
	     -DHOST_HW_CORES=192 \
	     -DHOST_HW_THREADS=384 \
	     -DCMAKE_HIP_ARCHITECTURES=gfx90a \
	     -DCMAKE_BUILD_TYPE=Release \
	     -DEXASTAMP_TEST_DATA_DIR=${HOME}/data \
	     -DPROJECT_SETUP_ENV_COMMANDS="${PROJECT_SETUP_ENV_COMMANDS}" \
	     -DCMAKE_INSTALL_PREFIX=${HOME}/install/exaDEM \
	     -Dyaml-cpp_DIR=/lus/home/CT6/cad14959/tcarrard/install/yaml-cpp/lib64/cmake/yaml-cpp \
	     -DexaNBody_DIR=${XNB_DIR} \
	     ${SRC_DIR}

Comment: You will need to specify your YAML-CPP installation.

Compilation:
------------


.. code-block:: bash

	source configure-exaDEM.sh
	mkdir -p $BUILD_DIR
	rm -rf $BUILD_DIR/*
	cd $BUILD_DIR


Compile And Run Your Application On Adastra
--------------------------------------------

Get a node: 

.. code-block:: bash

	salloc  --reservation=HackathonGPU -n 1 --account=cad14959 --gpus-per-node=8 --nodes=1 --cpus-per-task=32 --constraint=MI250 --time 2:00:0

Compile your code: 

.. code-block:: bash

	srun --cpus-per-task 32 make -j 32
	make UpdatePluginDataBase

Run your code:

.. code-block:: bash

	mkdir ${RUN_DIR}; cd ${RUN_DIR}
	cp <ROOT>/input.msp .
	srun ${BUILD_DIR}/exaDEM input.msp

Profiling tools:
----------------

Rocprof:

.. code-block:: bash

	srun rocprof --stats --hsa-trace --hip-trace --basenames off --timestamp on -o genesis_${SLURM_JOBID}.${SLURM_PROCID}.csv "$@" ../exaDEM input.msp

Omniperf: Run and Analyze

.. code-block:: bash

	srun omniperf profile -n name_run --roof-only -- binary ../exaDEM input.msp
	omniperf analyze -p workloads/name_run/mi200 > omniperf_analyze.out

Omnitrace:

.. code-block:: bash

	srun omnitrace-avail -G omnitrace.cfg --all 
	export OMNITRACE_CONFIG_FILE=./omnitrace.cfg
	srun omnitrace-sample ../exaDEM input.msp

