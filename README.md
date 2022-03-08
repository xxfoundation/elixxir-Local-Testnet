# LocalEnvironment

Contains the required configurations to execute a full local cMix system

The two scripts `download_cmix_binaries.sh` and  `run.sh` are written to run in
bash and call binaries for either Linux or Mac operating systems. To run the
scripts and binaries in Windows, the Windows Subsystem for Linux must be
installed. Refer to the article [Windows Subsystem for Linux Installation Guide
for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10) for
instructions to set it up.

## Scripts

### `download_cmix_binaries.sh`
The script `download_cmix_binaries.sh` accepts a single, optional flag that
specifies which platform to download the binaries for. If no flag is specified,
then the script defaults to the Linux binaries. Refer to the table below for
details on the flags.

|Long flag|Short flag|Effect|
|---|---|---|
|linux|l|downloads the Linux binaries|
|mac|m|downloads the Mac binaries|

A second argument can be provided which changes where the script downloads from.
By default it downloads from a public bucket which includes release and master builds.

|Flag name|Short flag|Effect|
|---|---|---|
|dev downloads|d|downloads from internal CI |

This script will require additional set-up steps, see the Additional Set-Up section for 
details.

### `download.sh`

The script `download.sh` will download all network related repositories to the working 
directory. Each repository will be individually built, with the binary being moved
to the `binaries/` directory, for the run script (`run.sh`) to initiate. This
will not require additional steps like `download_cmix_binaries.sh`, it will use up more 
local storage. This will download binaries from release by default.

If you want to build and run custom binaries off of custom branches, you may create a branch in 
local environment styled as `feature/[INSERT_PROJECT_BRANCH]` and run the download script
checked out into that feature branch.

### `run.sh`
The script `run.sh` initiates the local network. No arguments are taken for this script. The script will 
check for successful network operation and output a message to the console. All network logs are outputted 
to `results/`. 


### Additional Set-Up 

You will need to add a personal access token to your environment vars to download binaries via the 
`download_cmix_binaries.sh`.  You can generate one [here](https://gitlab.com/-/profile/personal_access_tokens),
giving it the "api" scope.
Please add the following to your `~/.zshrc` or `~/.bash_profile` depending on your shell
(You could most likely find out what shell you're using by running `echo $0` in the terminal).

```
export GITLAB_ACCESS_TOKEN=token_here
```

You could also invoke the script with the var, if you don't want to set it in your file or use
a different token temporarily.

```
GITLAB_ACCESS_TOKEN=token_here ./download_cmix_binaries.sh [l/m] d
```

The script downloads from the CI when the second argument into it (the one after the platform flag) is `d`.