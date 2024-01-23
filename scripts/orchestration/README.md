# Orchestration Scripts

## start-hlfnet

> A bash automation script used to run off-chain containers and the blockchain network from the "manager" server via SSH protocol. When the script is run, there will be no need to log in one by one to the HLF server to run the network.

## shutdown-hlfnet

> A bash automation script used to shut down off-chain containers and blockchain networks from the "manager" server via SSH protocol. When the script is run, there is no need to log in individually to the HLF server to run the network.

# NFS Shared Storage Setup
A. **NFS-Server**
1. NFS Server Services Installation
    ```sh
    $ sudo apt install nfs-kernel rpcbind
    ```
2. Verify that all the NFS services are running
    ```sh
    $ sudo systemctl status nfs-server
    $ sudo systemctl status rpcbind
    ```
    if they are not already running, then enable it:
    ```sh
    $ sudo systemctl enable nfs-server
    $ sudo systemctl enable rpcbind
    ```
    __Optional__:
    If considering security concerns, also make sure to configure the firewall to allow incoming NFS services as follows:
    ```sh
    $ sudo firewall-cmd --permanent --add-service={nfs,rpc-bind,mountd}
    $ sudo firewall-cmd --reload
    ```
3. Create the NFS share directory, which is the directory that will contain files that will be accessed by NFS clients in the network
    ```sh
    $ mkdir -p <SERVER DIRECTORY PATH>
    ```
4. Set permissions so that any user on the client machine can access the directory (in the real world you need to consider if the folder needs more restrictive settings).
    ```sh
    $ sudo chown nobody:nogroup <SHARED DIRECTORY PATH>    #no-one is owner
    or
    $ sudo chmod 777 -R <SHARED DIRECTORY PATH>            #everyone can modify files
    ```
5. Export an Server NFS Share Directory
    ```sh
    $ sudo vim /etc/exports
    ```
    Add the following entry on exports file. Be sure to replace the SERVER-IP with your NFS server’s IP address:
    ```sh
    <SHARED DIRECTORY PATH> <SERVER-IP>/<CIDR>(DEFINED-NFS-SECURITY)
    
    example:
    /home/novaldy/pharma-chain/fabric/bc-hospital 10.42.29.133/19(rw,sync,no_subtree_check)
    ```
6. Finally export the NFS share directory or filesystem:
    ```sh
    $ sudo exportfs -rv
    ```
7. Run the following command to view the NFS shares.
    ```sh
    $ showmount -e localhost
    ```

B. **NFS-Client**
1. Installing NFS Client Packages
    ```sh
    $ sudo apt install nfs-common
    ```
2. Confirm that you can view the export list the available shares at the remote server or NFS shares on the NFS server.
    ```sh
    $ showmount -e 10.42.10.132
    ```
2. Create a directory that will be used for mounting the NFS-Server storage
    ```sh
    $ mkdir <CLIENT-MOUNTED DIRECTORY>
    ```
3. Mount the NFS share to the mount directory that you have just created
    ```sh
    $ sudo mount -t nfs <IP ADDRES FROM NFS-SERVER>:<DIRECTORY PATH> <CLIENT-MOUNTED DIRECTORY>
    
    example:
    $ sudo mount -t nfs 10.42.10.132:/home/novaldy/pharma-chain/fabric/bc-hospital /home/gdputra/shared/hospital
    ```
4. To persist the NFS share, edit the /etc/fstab file
    ```sh
    $ sudo vim /etc/fstab
    ```
    Then add the following entry:
    ```sh
    <IP ADDRES FROM NFS-SERVER>:<DIRECTORY PATH>    <CLIENT-MOUNTED DIRECTORY>   nfs 
    
    example:
    10.42.10.132:/home/novaldy/pharma-chain/fabric/bc-hospital  /home/gdputra/shared/hospital   nfs     defaults 0 0
    ```
    Save and exit the configuration file.
    
C. **Removing NFS Mount**
if you no longer need the mounted directory on your system, you can unmount them from the client side using the following umount command:

```sh
$ umount <CLIENT-MOUNTED DIRECTORY>
or
$ umount -f <CLIENT-MOUNTED DIRECTORY>
```

## NFS Configuration Services
Here are some of the key configuration files for NFS:

- ``/etc/exports`` – The main configuration file, which stipulates the filesystems or directories to be exported and accessed by remote users.
- ``/etc/fstab`` – This is a file that contains entries of mounted partitions. In NFS, the file contains entries of NFS share directories or filesystems which are permanently mounted and can persist a reboot.

## Basic NFS Security Configuration
Basic options for /etc/exports can include:

- ``no_root_squash``: This option basically gives authority to the root user on the client to access files on the NFS server as root. And this can lead to serious security implications.
- ``no_all_squash``: This is similar to no_root_squash option but applies to non-root users. Imagine, you have a shell as nobody user; checked /etc/exports file; no_all_squash option is present; check /etc/passwd file; emulate a non-root user; create a suid file as that user (by mounting using nfs). Execute the suid as nobody user and become different user.
- ``rw``: This option enables the NFS server to use both read and write requests on a NFS volume.
- ``ro``: This option enables the NFS server to use read-only requests on a NFS volume.
- ``sync``: This option enables the NFS server to reply to requests only after the changes have been committed to stable 
- ``async``: This option enables the NFS server to violate the NFS protocol and reply to requests before any changes have been committed to stable 
- ``secure``: This option requires that requests originate on an Internet 
- ``insecure``: This option accepts any or all 
- ``wdelay``: This option enables the NFS server to delay committing a write request to a disc if it suspects that another related write request may be in progress or may arrive
- ``no_wdelay``: This option enables the NFS server to allow multiple write requests to be committed to disc within a single operation. This feature can improve performance, but if an NFS server receives many small requests, this behavior can serve to degrade performance. You should be aware that this option has no effect if async is also set.
- ``subtree_check``: This option enables subtree checking.
- ``no_subtree_check``: This option disables subtree checking, which has some implied security issues, but it can improve reliability.
- ``anonuid=UID``: These options explicitly set the uid and gid of the anonymous account; this can be useful when you want all requests to appear as though they are from a single user.
- ``anongid=GID``: This option will disable anonuid=UID.
