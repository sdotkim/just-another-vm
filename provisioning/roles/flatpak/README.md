Flatpak
=========

Add flathub as default repo and install flatpak apps.

Requirements
------------

community.general.flatpak_remote
community.general.flatpak

Role Variables
--------------

flatpaks_list - list of apps to install

Dependencies
------------
Requires system `flatpak` to be present

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: flatpak }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
