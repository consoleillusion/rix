# SekkOS — Contacts

SekkOS contacts are is a relationship-oriented computing environment that integrates identity management, networking, file sharing, communications and application deployment into a unified interface.

Its central concept is that relationships between people and groups should drive how resources are shared, how networks are provisioned and how applications are made accessible. Rather than manually configuring networking, permissions, storage and services, users manage these relationships through an intuitive interface.

## Contacts and Groups

The Contacts application provides a familiar interface inspired by mobile contact managers and applications such as Telegram.

Users can create contacts representing individuals, organisations or other entities and organise them into groups.

For example:

Friends

- Gary
- Mark
- Kim

Work

- Kim
- David
- Gary
- Nero

Contacts can belong to multiple groups simultaneously. Groups are first-class entities rather than simple contact labels.

Each contact can also have associated communication preferences, including a default method of communication such as Telegram, SMS or email.

## DuckNet — Relationship-Based Networking

Groups are integrated directly with DuckNet, SekkOS's networking infrastructure, which uses Netmaker to manage network connectivity.

Adding a contact to a group automatically provisions their network membership. Each group can have its own address space and network, allowing members to communicate with one another and access shared resources.

This makes network administration largely transparent to the user. Instead of manually configuring VPN connections, distributing credentials and managing network access, users manage membership through the Contacts application.

Group membership effectively becomes the starting point for establishing connectivity between people and their resources.

## File Management and Peer-to-Peer Sharing

The File Manager shares much of its underlying functionality with Contacts, particularly its group-oriented approach to resource management.

Users can share files directly with individuals or entire groups.

Files can be distributed in several ways:

- Direct sharing: Generate a download link and notify recipients through their preferred communication method.
- Group storage: Store files on a shared file server accessible to authorised group members.
- Peer-to-peer replication: Allow multiple participants to retain copies of shared files.

Iroh provides the peer-to-peer infrastructure for file distribution and replication.

An important feature is file pinning. Participants can pin files they want to retain, with the number of independent copies displayed in the interface. This creates a distributed backup mechanism in which group members contribute storage and help maintain data availability.

## Integrated Communications

SekkOS integrates external communication services into its resource-sharing workflows.

Each contact can have a preferred communication method, allowing SekkOS to select the appropriate delivery channel automatically.

For example, sharing a document with someone might automatically send a Telegram message containing the download link, while another contact might receive the same notification through email.

This makes communications an integrated part of the system rather than a separate application that users must manage independently.

## Application Deployment and Access

SekkOS also provides a unified interface for deploying and accessing applications.

Applications can be launched and managed through the local software interface, with deployment targeting different execution environments:

- Containers
- Virtual machines
- Kubernetes pods
- Declarative Nix expressions

Applications can be assigned to designated groups, making their services available to the appropriate participants through DuckNet.

For example, a user could deploy a Jellyfin server for their Friends group, a private Git server for Work, or a shared document management application for both.

The underlying infrastructure handles deployment, networking and access configuration, while the user interacts with applications and groups through SekkOS.

## Cryptographic Foundations

Alongside its networking and resource-management capabilities, SekkOS incorporates various cryptographic improvements, including DuckPAM.

Security, identity and access control are fundamental to the system. The intention is to provide secure communication, controlled resource sharing and independently manageable access without requiring users to understand the underlying cryptographic or networking infrastructure.

## Overall Vision

SekkOS aims to bring together several traditionally disconnected areas of computing into one coherent environment.

Its defining characteristic is the use of people, relationships and groups as the organising principle for computing resources.

A contact is more than an address-book entry. Adding someone to a group can establish network connectivity, grant access to shared files, enable peer-to-peer replication, deliver communications and make applications available.

Likewise, a group is more than a collection of people. It becomes a logical environment with its own network, resources, services and access policies.

The result is an integrated computing environment where users can establish relationships, share resources, deploy applications and manage infrastructure through a common interface, without having to interact directly with the complexity of the underlying systems.

---

Because you are sharing to those members only, you dont need to expose your home server to everyone to share with firends. everything is end to end encrypted beacuse everything is behind netmaker and everything is happening over a wireguard mesh. it allows for fully distributed social filesharing and social networking.

An IP network is the same as a friends network. everyone will have multiple overlapping networks.

---

Containers can have output modules, for network traffic or plain steams of data that handlers could be assigned to that can be integrated directly into the window manager. Like in hyprland you can set up permissions for appso to screengrab, inputgrab and such.

---

Another potential advantage of putting all networks behind something like netmaker is that since all network activity is wireguard encrypted, im pretty sure you dont really need application level encryption nearly so much, or at all. For example, NFS is used as a network filesystem on linux, but wasnt built with security in mind, so its sorta old school. Its not considered very secure. But behind wireguard i think man-in-the-middle attacks cant really occur, so you can use old school protocols without worry, maybe even telnet would be fine.


