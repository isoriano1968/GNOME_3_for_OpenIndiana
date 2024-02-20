# GNOME_3_for_OpenIndiana
Make GNOME 3 available to OpenIndiana (borrowed from Solaris 11.4.42 CBE)

Welcome to the next quick and dirty approach to port GNOME 3 from Solaris to OpenIndiana as a valid alternative to the existing MATE desktop already existing in OpenIndiana.

The idea is leveraging solaris-userland's GNOME packages and adopt to oi-userland's build system and provide a fully installable pkg to the community.

# Where to start?

For sure it is important to have both userland components available (OpenIndiana and Solaris) to pick and modify as it looks like for several years both have developed separately and therefore we will have to do modify each indivodual component within the gnome components folder to be able to be build on OpenIndiana.

I do not want to provide a step by step approach but the following links should provide enough information to get the userland environments for OpenIndiana and Solaris 11.4.42 CBE to your local machine.

https://github.com/OpenIndiana/oi-userland

https://github.com/oracle/solaris-userland

Ok, great we do now have all the required components so lets copy the solaris-userland gnome components to oi-userland components folder. Once this is done we need to extract all the REQUIRED_PACKAGES dependencies from the 126 gnome components that build GNOME on Solaris.

awk seems to do the job (cd to the directory you copied the gnome components and execute): 

awk '/REQUIRED_PACKAGES/ {print FILENAME ": " $0}' */Makefile
awk '/REQUIRED_PACKAGES/ {print FILENAME ": " $0}' */Makefile > ~/solaris-gnome-dependencies

Now we do have all the dependencies found within the gnome components.

Then I use a little c program to identify the unique dependencies (system packages) and those linked to another component within the gnome components folder (see gnome-dep-check.c)

Ok, now we have to check whether the packages without dependencies are available on OpenIndiana (add) or not available at all (e.g. accountsservice exists on Solaris but not on OpenIndiana).







