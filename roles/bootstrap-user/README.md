
Put this in your `local-configure.yml` file, add as many users as you need:

    users:
      - name: fulvio
        sudoer: yes
        auth_key: ssh-rsa blahblahblahsomekey this is actually the public key in cleartext
      - name: plone_buildout
        group: plone_group
        sudoer: no
        auth_key: ssh-rsa blahblahblah ansible-generated on default
        keyfiles: keyfiles/plone_buildout

In your playbook root folder, create a folder `keyfiles`.  In it, create a subfolder for 
each username for which you want to copy keyfiles to the server.  Put the private and public key files,
as well as any other files, such as `known_hosts` in the user subfolder.

Add the follwing line in `playbook.yml` under `roles:` (e.g. right under `- role: ANXS.hostname`):

    - role: create_users

Copy the gist file `main.yml` to `/roles/create_users/tasks`.

Now run your playbook.
That's it!

ref: https://gist.github.com/fulv/3928d098e8c35af1cc5363a4d2d4fcd0
