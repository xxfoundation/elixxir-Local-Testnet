# LocalEnvironment

Contains the required configurations to execute a full local cMix system

The two scripts `download_cmix_binaries.sh` and  `run.sh` are written to run in
bash and call binaries for either Linux or Mac operating systems. To run the
scripts and binaries in Windows, the Windows Subsystem for Linux must be
installed. Refer to the article [Windows Subsystem for Linux Installation Guide
for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10) for
instructions to set it up.

## Flags

### `download_cmix_binaries.sh`
The script `download_cmix_binaries.sh` accepts a single, optional flag that
specifies which platform to download the binaries for. If no flag is specified,
then the script defaults to the Linux binaries. Refer to the table below for
details on the flags.

|Long flag|Short flag|Effect|
|---|---|---|
|linux|l|downloads the Linux binaries|
|mac|m|downloads the Mac binaries|

### `run.sh`
The script `run.sh` accepts four flags, in any order, that specifies which
binaries should **not** be run. Refer to the table below for details.

|Long flag|Short flag|Effect|
|---|---|---|
|permissioning|p|prevents the execution of the permissioning binary|
|server|s|prevents the execution of the server binary|
|gateway|g|prevents the execution of the gateway binary|
|udb|u|prevents the execution of the UDB binary|
|notls|N/A|Disables tls from servers, gateways, and permissioning|
|disablePermissioning|N/A|Disables the registration logic between servers and gateways
