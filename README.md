# multiple_cmake_install

Typically, when installing cmake with a package manager or from kitware's website, 
in a unix environment, a single install clobbers existing installs by placing into
/usr/bin, /usr/share/cmake/modules, etc. 

Since the cmake parser is backwards compatible, this normally does not have any issue,
howewer, between cmake versions, the default CMPxxxx policy choices can vary dramatically,
particularly when cross compiling. To prevent accidentally breaking build systems and 
CI/CD pipelines, this repository provides a script to install multiple cmake versions
in the same filesystem and uses the update-alternatives unix utility to manage them
