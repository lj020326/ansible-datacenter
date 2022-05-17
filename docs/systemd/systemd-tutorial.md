
systemd tutorial
===

- [How is systemd better than System V init for Linux?](#How_is_systemd_better_than_System_V_init_for_Linux "How is systemd better than System V init for Linux?")
- [Understanding Targets, Services and Units](#Understanding_Targets_Services_and_Units "Understanding Targets, Services and Units")
    -   [Units](#Units "Units")
    -   [What is the difference between Requires, Wants and Conflicts in systemd unit file?](#What_is_the_difference_between_Requires_Wants_and_Conflicts_in_systemd_unit_file "What is the difference between Requires, Wants and Conflicts in systemd unit file?")
    -   [Services](#Services "Services")
    -   [Targets](#Targets "Targets")
- [How systemd boots the system?](#How_systemd_boots_the_system "How systemd boots the system?")
- [How to create your own systemd service unit file?](#How_to_create_your_own_systemd_service_unit_file "How to create your own systemd service unit file?")

In this article I will give an overview of systemd which is nothing but system and service manager is responsible for controlling how services are started, stopped and otherwise managed on Linux. By offering on-demand service start-up and better transactional dependency controls, systemd dramatically reduces start up times. As a systemd user, you can prioritize critical services over less important services.

## How is systemd better than System V init for Linux?

-   Configuration is simpler and more logical, rather than the sometimes convoluted shell scripts of System V init, systemd has unit configuration files to set parameters
-   There are explicit dependencies between services rather than a two digit code that merely sets the sequence in which the scripts are run
-   It is easy to set the permissions and resource limits for each service, which is important for security
-   systemd can monitor services and restart them if needed
-   There are watchdogs for each service and for systemd itself
-   Services are started in parallel, reducing boot time

## Understanding Targets, Services and Units

Before we understand how systemd works, we need to know some basic terminologies

-   Firstly, a target is a group of services, similar to, but more general than, a System V runlevel. There is a default target which is the group of services that are started at boot time.
-   Secondly, a service is a daemon that can be started and stopped, very much like a SystemV service.
-   Finally, a unit is a configuration file that describes a target, a service, and several other things. Units are text files that contain properties and values.

### Units

The basic item of configuration is the unit file. Unit files are found in three different places:

-   `/etc/systemd/system:` Local configuration
-   `/run/systemd/system:` Runtime configuration
-   `/lib/systemd/system:` Distribution-wide configuration
-   `/usr/lib/systemd/system/:` Contains default systemd unit configurations as per contained in the rpm

When looking for a unit, systemd searches the directories in that order, stopping as soon as it finds a match, allowing you to override the behavior of a distribution-wide unit by placing a unit of the same name in `/etc/systemd/system`. You can disable a unit completely by creating a local file that is empty or linked to `/dev/null`.

NOTE:

`/etc/systemd/system` contains any custom and/or more permanent configurations which the user requires to set on a systemd unit. This is where it is advised to put custom configuration as it will not be lost upon package updates.

All unit files begin with a section marked `[Unit]` which contains basic information and dependencies, for example:

```
[Unit]
Description=D-Bus System Message Bus
Documentation=man:dbus-daemon(1)
Requires=dbus.socket
```

### What is the difference between Requires, Wants and Conflicts in systemd unit file?

Unit dependencies are expressed though `Requires`, `Wants`, and `Conflicts`:

-   **Requires:** A list of units that this unit depends on, which is started when this unit is started
-   **Wants:** A weaker form of Requires: the units listed are started but the current unit is not stopped if any of them fail
-   **Conflicts:** A negative dependency: the units listed are stopped when this one is started and, conversely, if one of them is started, this one is stopped

Processing the dependencies produces a list of units that should be started (or stopped). The keywords `Before` and `After` determine the order in which they are started. The order of stopping is just the reverse of the start order:

-   **Before:** This unit should be started before the units listed
-   **After:** This unit should be started after the units listed

In the following example, the After directive makes sure that the web server is started after the network:

```
[Unit]
Description=Lighttpd Web Server
After=network.target
```

In the absence of `Before` or `After` directives, the units will be started or stopped in parallel with no particular ordering.

### Services

A service is a daemon that can be started and stopped, equivalent to a System V service. for example, lighttpd.service.

A service unit has a `[Service]` section that describes how it should be run. Here is the relevant section from `lighttpd.service`:

```
[Service]
ExecStart=/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf -D
ExecReload=/bin/kill -HUP $MAINPID
```

These are the commands to run when starting the service and restarting it. There are many more configuration points you can add in here, so refer to the man page for systemd.service.

### Targets

A target is another type of unit which groups services (or other types of unit). It is a type of unit that only has dependencies. Targets have names ending in `.target`, for example, `multi-user.target`. A target is a desired state, which performs the same role as System V runlevels.

## How systemd boots the system?

Now we can see how systemd implements the bootstrap. systemd is run by the kernel as a result of `/sbin/init` being symbolically linked to `/lib/systemd/systemd`. It runs the default target, `default.target`, which is always a link to a desired target such as `multi-user.target` for a text login or graphical.target for a graphical environment. For example, if the default target is `multi-user.target`, you will find this symbolic link:

```
/etc/systemd/system/default.target -> /lib/systemd/system/multi-user.target
```

The default target may be overridden by passing `system.unit=<new target>` on the kernel command line. You can use systemctl to [find out the default target](https://www.golinuxhub.com/2017/12/how-do-i-set-or-change-default-runlevel.html), as shown here:

```
# systemctl get-default
multi-user.target
```

Starting a target such as `multi-user.target` creates a tree of dependencies that bring the system into a working state. In a typical system, `multi-user.target` depends on basic.target, which depends on `sysinit.target`, which depends on the services that need to be started early. You can print a graph using `systemctl list-dependencies`.

## How to create your own systemd service unit file?

Below is a sample systemd based service unit file. Here we call our custom script

```
# vim /etc/systemd/system/set_clock.service
[Unit]
Description=Syncing system and hardware clock

[Service]
Type=forking
ExecStart=/usr/bin/boot.clock_fix start
ExecStop=/usr/bin/boot.clock_fix stop
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

The `[Unit]` section only contains a description so that it shows up correctly when listed using systemctl and other commands. There are no dependencies; as I said, it is very simple.

The `[Service]` section points to the executable, and has a flag to indicate that it forks. If it were even simpler and ran in the foreground, systemd would do the daemonizing for us and `Type=forking` would not be needed.

The `[Install]` section makes it dependent on multi-user.target so that our server is started when the system goes into multi-user mode.

Next you need to refresh the systemd content

```
# systemctl daemon-reload
```

Start and check the status of the service

```
# systemctl start set_clock

# systemctl status set_clock.service
â set_clock.service - Syncing system and hardware clock
Loaded: loaded (/etc/systemd/system/set_clock.service; enabled; vendor preset: disabled)
Active: active (exited) since Fri 2018-11-16 12:37:20 IST; 9s ago
Process: 7964 ExecStop=/etc/init.d/boot.clock_fix stop (code=exited, status=0/SUCCESS)
Process: 7979 ExecStart=/etc/init.d/boot.clock_fix start (code=exited, status=0/SUCCESS)
Main PID: 1338 (code=exited, status=0/SUCCESS)

Nov 16 12:37:13 Ban17-inst01-a boot.clock_fix[7979]: Set Sys time according to Hardware Clock
Nov 16 12:37:20 Ban17-inst01-a systemd[1]: Started Syncing system and hardware clock.
```

At this point, it will only start and stop on command, as shown. To make it persistent, you need to add a permanent dependency to a target. That is the purpose of the \[Install\] section in the unit, it says that when this service is enabled it will become dependent on multi-user.target, and so will be started at boot time.

You enable it using systemctl enable, like this:

```
# systemctl enable set_clock.service
```

Lastly I hope this article on **systemd** was helpful. So, let me know your suggestions and feedback using the comment section.

_Reference:_

_[Linux: Embedded Development](https://www.safaribooksonline.com/library/view/linux-embedded-development/9781787124202/)_
