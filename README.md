<center><img src="ponzu.jpg"></center>

## Ponzu

Ponzu is a set of Dockerfiles to create a container to build LiME kernel modules, DwarfDump modules, and Volatilty profiles.

Presently RHEL/CentOS el[5,6,7], current Debian, and Ubuntu [14,18] releases are supported.
It will probably work with RedHat and Fedora but that is currently untested.


### Docker

A prebuilt el7 container is available at https://hub.docker.com/r/dannen/ponzu3/

### USAGE

CentOS
```
cd ponzu3
mkdir rpms
[pick your OS release and rename the files]
cp Dockerfile.el6 Dockerfile
cp build-volatility.el6.sh build-volatility.sh
docker build -t ponzu .
docker run -v /YourPath/rpms/:/rpms/ ponzu 2.6.32-573.26.1
```
  * if you prefer, you can do 'docker build -t ponzu:el7 .' to create specific os versions of the ponzu container.

Debian/Ubuntu
```
cd ponzu3
mkdir debs
[pick your OS release and rename the files]
cp Dockerfile.debian Dockerfile
[ or cp Dockerfile.ubuntu Dockerfile]
docker build -t ponzu .
docker run -v /YourPath/debs/:/debs/ ponzu 4.9.0-3
```
* if you prefer, you can do 'docker build -t ponzu:debian .' to create specific os versions of the ponzu container.


Append the kernel of your choice to the end to build modules and profiles for a specific kernel version.  The output will be in a zip file in ./debs or ./rpms on your host.

#### build
"docker build ..." will create the base container which contains compilers and builds DwarfDump.  You only need to do this once per release.

#### run
"docker run ..." will take the container you built above and either run against the default kernel in the Centos container or you can append the desired kernel release and it will build a specific Volatilty profile zip file for that kernel.

If you have an rpm for the kernel you want to build against, you can copy it into the ./rpms directory.  Ponzu will scan that directory first and use the local file if it exists.  If there are no rpms in that directory, Ponzu will reach out over the internet to the Centos vault repo to search for the desired kernel rpm.


The Volatilty profile zip will contain the following files:

```
lime-module/module.dwarf
lime-module/System.map-2.6.32-573.26.1.el6.x86_64
lime-module/lime-2.6.32-573.26.1.el6.x86_64.ko
```

#### build-volatility.sh

The build-volatility script runs inside the Ponzu container.  It installs the relevant kernel debs/rpms (local or remote), builds the lime module, builds the DwarfDump module, and concatenates the results into a standardized LiME profile formatted zip file.



#### Sample run

see https://github.com/dannen/ponzu3/blob/master/sample_run.txt.


#### build_vol_profile.sh script

If you want to skip the entire docker run and just build everything on a command line, I've added the script "build_vol_profile.sh".

#### faster LiME dumps

Try this for a significantly faster LiME memory dump.

```
(install pigz)
mkfifo ./zap; pigz -1 -c < zap > ram.lime.gz &
sudo /sbin/insmod lime-module.ko path=./zap format=lime
rm -f zap
```

#### manual_script_os.sh

Added two manual build scripts [RHEL/Debian] for testing.
