This is a set of dockerfiles that will build a container for use with the LandDA system. The base file
is the same as that used for the SRW and provides the intel compilers and intelmpi along with spack-stack.
A final container is built starting from the base container and includes a version of spack-stack with
all the libraries required to build the fv3-bundle. The final steps of the container build either clone
and build the fv3-bundle or untar the tarballs of the fv3-bundle that was pre-built in a secondary
container. The reason for the secondary container is that the fv3-bundle is cloned from jcsda's private
internal repos using a private key. In order to avoid storing the private key, the cloning is done in
a non-saved container, the fv3-bundle is built there and that compiled code is copied out as tarballs
to be copied back in later for the final docker build and push.

