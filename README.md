SafeFetch artifact evaluation repository for Usenix'24.

### Tips to navigate the repository

The main directories in this repositories (and obtained while running the artifact workflow):
 - **safefetch**: after running the artifact setup process, this directory will contain the kernel source code (cloned from [here](https://github.com/vusec/safefetch))
 - **playground/performance**: contains performance results organized by benchmark (possible benchmarks are LMBench, OSBench and Phoronix)
 -  **playground/security**: contains security results (csv files) obtained while running the security artifact.
 -  **playground/paper**: contains scripts to generate a pdf used to view the collected results while running the artifact. (check [generate_plots.py](playground/paper/scripts/generate_plots.py) to see how the artifact leverages the the results from
 the performance and security directories)
 -  **playground/kernels**: contains a directory for each precompiled kernel coming with the artifact (i.e., exploit-default, safefetch-default, midas-default and whitelist-default).
 
  The artifact workflow is executed by running rules from the top [Makefile](Makefile)

  ### SafeFetch and static keys

  Safefetch kernels use static keys by default. When first booted, all SafeFetch hooks are disabled (are simple nop instructions
  which later get patched in once the SafeFetch defense is activated)
  The [safefetch_control.sh](safefetch_control.sh) is used during runtime on SafeFetch compiled kernels to enable the
  Safefetch defense through the use of static keys.

  ### Loading precompiled kernels

  The artifact comes with four precompiled kernels (under **playground/kernels**):
  - **exploit-default**: used to run the security artifact
  - **safefetch-default**: compiled with the default SafeFetch build (including the zero-copy optimization) and used to generate the baseline and the performance results for the SafeFetch default build
  - **whitelist-default**: the SafeFetch prototype implementing the same syscall whitelisting as Midas
  - **midas-default**: the default Midas prototype build from this [repository](https://github.com/HexHive/midas)

  All the precompiled kernels use the default X86_64 linux default config.

  To load a precompiled kernel (or compiled locally) the user must run the following command:

  ```bat
make load_kernel SAVED_DIR=name
```
Where name can be either: exploit-default, safefetch-default or any kernel directory that exists in **playground/kernels**. 

When **make load_kernel** executes it will prompt the user to select which kernel to load by default as shown in the following example:

```bat
0 : menuentry 'Ubuntu, with Linux 5.11.0-safefetch+' --class ubuntu
1 : menuentry 'Ubuntu, with Linux 5.11.0-safefetch+ (recovery mode)'
2 : menuentry 'Ubuntu, with Linux 4.15.0-213-generic' --class ubuntu
3 : menuentry 'Ubuntu, with Linux 4.15.0-213-generic (recovery mode)'
4 : menuentry 'Ubuntu, with Linux 4.15.0-212-generic' --class ubuntu
5 : menuentry 'Ubuntu, with Linux 4.15.0-212-generic (recovery mode)'
6 : menuentry 'Ubuntu, with Linux 4.8.0-39-generic' --class ubuntu
7 : menuentry 'Ubuntu, with Linux 4.8.0-39-generic (recovery mode)'
8 : menuentry 'Ubuntu, with Linux 4.8.0' --class ubuntu
9 : menuentry 'Ubuntu, with Linux 4.8.0 (recovery mode)'
Max config number:9
Select which of the above kernels you want to boot in by default: (eg. 0, 1, 2 ... etc)
Select kernel number:
```
If for example the user wants to load into the **safefetch** he must press 0 in this case (as safefetch non-recovery is
index 0 in the list).

  ### Adapting the load process to non-GRUB distros

  The **make load_kernel** command uses the [save_kernel.sh](save_kernel.sh) script under the hood to move kernels from **playground/kernels** to **/boot** from where **update-grub2** will add them to the boot process.

  Additionally the script is used to clean up kernels from the **/boot** directory or to create a kernel entry in **playground/kernels** after compiling a new kernel.

  It should be easy to adapt our scripts to run on non-Grub systems. Check the **save_kernel.sh** and **configure_grub.sh** in case you need to tailor the artifact for a different bootloader.

  ### What happens if a precompiled kernel does not boot?

  As explained in the artifact appendix this can happen on host machines that require kernel drivers that do not come with the default kernel build.

  To build kernels using the local config of your host machine boot into the default kernel from the host machine (in essence
  how your host machine runs prior to running the artifact).
  After that run the following command (from the root path of this repository):
  ```bat
  ./create_artifact_kernels.sh -midas
   ```

   This will create the following kernels: exploit-local, safefetch-local, midas-local
   You can use these kernels instead to run the security and performance artifacts (i.e., experiments E1, E2 and E3)

   For example to run the security artifact (E1) instead of using the -default suffix use the -local suffix:
   ```bat
    make load_kernel SAVED_DIR=exploit-local
   ```

   If you want to only create the kernels to evaluate E1 and E2 (and no midas) then simply run:
   ```bat
   ./create_artifact_kernels.sh
   ```
   Note that local compilation expects the host machine to be equipped with a gcc compiler (ideally v8.4 or newer) and binutils.

   ### Loading back in your default host kernel after you are done with the artifact

   To load back into the default kernel and clean up from Grub any other kernels installed with this artifact run
   the following command from the root of this repository:
   ```bat
   make clean_artifact
   sudo reboot
   ```

   ### Regenerating the pdf with artifact results

   To regenerate the pdf with artifact results simply run:
   ```bat
   make all-paper
   ```

   This command will first invoke **make result** which will create csv files for all performance results currently
   gathered using this artifact. (the csv files aggregate results across multiple iterations of the same benchmark 
   on the same kernel config obtaining means, meadians, standard deviations and so on).
   After that it will call the [generate_plots.py](playground/paper/scripts/generate_plots.py) to generate latex tables and pdf images containing graphs and then will use pdflatex to obtain the final pdf showing all results.


   ### Notes on running the Midas artifact

   As also discussed in the Midas artifact (for Usenix'22), Midas kernel might crash during the evaluation workflow (does not happen often).

   Our past occurences of the issue tipically happened in the Apache benchmark (which executes at the end of the performance artifact workflow).

   As a fail-safe, if this happens when running the Midas artifact you can still regenerate the artifact pdf, using the partial
   results obtained prior to the crash by simply running:
   ```bat
   make all-paper
   ```


  ### Notes on global configuration

  The [global_export.sh](global_export.sh) is imported by most of our other scripts and sets a couple of global configurable
  parameters (e.g., the SafeFetch and Midas public repos used to compile the kernels)

  Moreover, it can be used to set the number of benchmarking iterations during each of our artifact workflows as follows:
  - **RUNS** variable: sets the number of benchmarking iterations for LMBench and OSBench benchmarks
  - **FORCE_TIMES_TO_RUN** variable: sets the number of benchmarking iterations for running Phoronix benchmarks
  - **SECURITY_RUNS** variable: sets the number of iterations for running the security artifact.

  If evaluators want to execute more/less runs of each artifact workflow the must simply modify these variable as they chose.
