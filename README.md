# veramount

Auto-mount a veracrypt or truecrypt partition from the inserted USB.
Supports only keyfile based encryption.

*Note about systemd*
Systemd/cryptsetup has a mechanism for mounting encrypted truecrypt/veracrypt
via /etc/crypttab. If the same name as used in /etc/crypttab is used also in
/etc/fstab like /dev/mapper/<name from crypttab> and adding
x-systemd.automount option, systemd should open and mount the encrypted
device. However, when I was trying to use this approach it was not working 
properly for me, so for now kept these hacky scripts.

*Note about udisks*
There is also experimental VeraCrypt support for `udisks` that can be enabled
by creating the `/etc/udisks2/tcrypt.conf` file. More info
[here](https://github.com/storaged-project/udisks/issues/589) and
[here](https://github.com/storaged-project/udisks/pull/495). When I tried this
it was sort of working, but only with password based encryption.


The tool consists of two scripts:
- veramount: the executable that does the mounting
- veramount-config: used to configure partitions to auto-mount
    - installs some files based on the templates in the shared folder:
        - a config file containing information on the encrypted volume
        - a systemd rule to mount/unmount the encrypted partition using veramount
        - an udev rule to trigger the mounting when the encrypted partition becomes available (attached)
    - once files are in place reload systemd daemons and udev rules

The scripts modify system files and should be executed as root.

## Installation:

```
sudo make install
````

## Uninstallation:

The uninstall command disables all configs and then deletes the files except
the disabled configs, so they can be easily reenabled after a reinstall.

```
sudo make uninstall
```

If we just want to get rid of everything:

```
sudo make purge
```

## Configuration:

Run `veramount-config --help` to see a description of command line options.

### Adding mount config

Example auto-mount config for a drive with partition ID 12345 using .keyfile in user's home folder, mounted under a
folder in /media with the provided filesystem options in Truecrypted compatible mode:

```
sudo veramount-config -n myencrypted-drive -p 123456 -m /media/myencrypted-drive -k /home/user/.keyfile --fs-opts
"uid=1000,gid=1000,noatime" --truecrypt
```

After running the above command, 3 files are created:
- a config file in the /etc/veramount.d folder
- an udev rule in /etc/udev/rules.d
- a systemd service in /etc/systemd/system

These three files are created for every disk config added by veramount-config.


### Listing configs

```
veramount-config ls
```

Files that are disabled are shown with .disabled extension.

### Enabling/Disabling/Deleting configs

```
sudo veramount-config disable --name config-name
sudo veramount-config enable --name config-name
sudo veramount-config del --name config-name
```

Disabling will mark the config disabled and remove the systemd service and
udev rule, which disables the functionality without losing the configuration
file. This allows to easily re-enable the config using the `enable` command.

Deleting means what it means, it removes systemd and udev files and also the
configuration.

The special name 'all' operates on all configs, but currently only works with
the `disable` command.

```
sudo veramount-config disable --name all
```



## (Un)Mounting:

Mounting should be automated upon insertion of drive once configs are in place. However, we can trigger mount or unmount
for configured volumes easily:

```
# Mount
veramount config-name
# Dismount
veramount -d config-name
```

The 'config-name' in above examples is the name of a config file, it can be an absolute path, relative to current folder
or relative to /etc/veramount.d where veramount-config places configuration automatically.

Note that the mount can be also unmounted normally via the file browser,
e.g. in Nautilus however this does not close the veracrypt volume.


---

## Issues:
- current sourcing of config files is dangerous
- does not work well for multiple users
