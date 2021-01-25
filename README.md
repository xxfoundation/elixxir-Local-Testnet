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

A second argument can be provided which changes where the script downloads from.
By default it downloads from a public bucket which includes release and master builds.

|Flag name|Short flag|Effect|
|---|---|---|
|dev downloads|d|downloads from internal CI (see the Team Only section)|

### `run.sh`
The script `run.sh` initiates the local network. No arguments are taken for this script.


### Team Only

You will need to add a personal access token to your env vars to download binaries from the CI.
You can generate one [here](https://gitlab.com/-/profile/personal_access_tokens), giving it the "api" scope.
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