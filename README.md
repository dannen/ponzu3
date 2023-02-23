<center><img src="ponzu.jpg"></center>

## Ponzu

Ponzu is a set of Dockerfiles to create a container to build LiME kernel modules, Dwarfdump modules, and Volatilty profiles.

Presently RHEL/CentOS el[6,7,8], Oracle UEK [7], current Debian, and Ubuntu [18,20] releases are supported.
It will probably work with RedHat and Fedora but that is currently untested.

Support for el5 is now deprecated. Both curl and wget from that era are using unsupported tlsv1 which breaks downloading
of the git code. Git also is only available from rpmforge as an rpm and there are issues with rpmforge.

Support for Ubuntu 14 is now deprecated.  I've had to change the Dockerfile to include package not available to Ubuntu 14.


### Docker

A prebuilt el7 container is available at https://hub.docker.com/r/dannen/ponzu3/

### USAGE

OracleOS
```
cd ponzu3
mkdir rpms
# pick your OS release and kernel version, e.g. centos7 and kernel version 4.14.35-2047.503.1
docker build -f ./Dockerfile.oracle.el7 -t ponzu:oraclelinux7 .
# make sure you use the full path to your rpm target, not ./rpms/:/rpms/
docker run -v /YourPath/rpms/:/rpms/ ponzu:oraclelinux7 4.14.35-2047.503.1
```

CentOS
```
cd ponzu3
mkdir rpms
# pick your OS release and kernel version, e.g. centos7 and kernel version 3.10.0-957.38.3
docker build -f ./Dockerfile.el7 -t ponzu:el7 .
# make sure you use the full path to your rpm target, not ./rpms/:/rpms/
docker run -v /YourPath/rpms/:/rpms/ ponzu:el7 3.10.0-957.38.3
```

Oracle
```
cd ponzu3
mkdir rpms
# pick your OS release and kernel version, e.g. Oracle7 and kernel version 4.14.35-2047.503.1
docker build -f ./Dockerfile.Oracle7 -t ponzu:oracle7 .
# make sure you use the full path to your rpm target, not ./rpms/:/rpms/
docker run -v /YourPath/rpms/:/rpms/ ponzu:oracle7 4.14.35-2047.503.1
```


Debian/Ubuntu
```
cd ponzu3
mkdir debs
# pick your OS release and kernel version, e.g. ubuntu with kernel version 4.9.0-3
docker build -f ./Dockerfile.debian -t ponzu:debian .
# make sure you use the full path to your deb target, not ./debs/:/debs/
docker run -v /YourPath/debs/:/debs/ ponzu:debian 4.9.0-3
```


Append the kernel of your choice to the end to build modules and profiles for a specific kernel version.

The output will be in a zip file in ./debs or ./rpms on your host.


Further examples
```
docker build -f ./Dockerfile.el6 -t ponzu:el6 .
docker build -f ./Dockerfile.el7 -t ponzu:el7 .
docker build -f ./Dockerfile.el8 -t ponzu:el8 .
docker build -f ./Dockerfile.debian -t ponzu:debian .

docker run -v /YourPath/ponzu3/rpms:/rpms/ ponzu:el7 3.10.0-957.38.3
docker run -v /YourPath/ponzu3/debs:/debs/ ponzu:debian 5.4.0-113
```

#### build
"docker build ..." will create the base container which contains compilers and builds Dwarfdump.  You only need to do this once per release.

#### run
"docker run ..." will take the container you built above and either run against the default kernel in the Centos container or you can append the desired kernel release and it will build a specific Volatilty profile zip file for that kernel.

If you have an rpm for the kernel you want to build against, you can copy it into the ./rpms directory.  Ponzu will scan that directory first and use the local file if it exists.  If there are no rpms in that directory, Ponzu will reach out over the internet to the Centos vault repo to search for the desired kernel rpm.


The Volatilty profile zip will contain the following files:

```
lime-module/module.dwarf
lime-module/System.map-3.10.0-957.38.3.el7.x86_64
lime-module/lime-3.10.0-957.38.3.el7.x86_64.ko
```

#### build-volatility.sh

The build-volatility script runs inside the Ponzu container.  It installs the relevant kernel debs/rpms (local or remote), builds the lime module, builds the Dwarfdump module, and concatenates the results into a standardized LiME profile formatted zip file.



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

You can use any name, I just chose "zap" in this example.

#### manual_script_os.sh

Added two manual build scripts [RHEL/Debian] for testing.
