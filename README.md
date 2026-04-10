# Network Hardening Coursework

**Course:** Network Hardening  
**Program:** ESILV — 4th Year Engineering  
**Academic Year:** 2025–2026  
**Author:** Nathan Herbron - OCC2 

## Project Summary

This repository gathers the practical work completed during the Network Hardening module. Rather than treating each lab as an isolated exercise, the project brings them together as parts of a single security engineering workflow.

The purpose of the coursework was not only to configure tools or services, but to build a network that becomes progressively more secure from one session to the next. Each lab introduced a new layer of protection, and each protection had to be justified, tested, and documented with evidence.

The final result is therefore both a technical project and an evidence pack. It shows not just what was configured, but also how each security control was verified.

## General Objectives

The work carried out in this repository follows a simple logic:

- define the expected security posture
- implement the required controls
- test whether the system behaves as intended
- keep proof of the results in a reproducible form

This approach was used throughout the module so that every security claim could be linked to configuration extracts, command outputs, packet captures, scans, or logs.

## Course Scope

The coursework is organized around six practical sessions, each one focusing on a different aspect of infrastructure hardening.

### TD1 — Network Mapping and Reachability Rules

The first session established the base topology used in the rest of the project. The objective was to understand how the virtual machines were connected, document the addressing plan, and define which communications should or should not be allowed.

This phase served as the baseline for all later hardening work. Before filtering or encryption can be applied, the expected flows must be known clearly.

### TD2 — Firewall Policy Design and Verification

The second session focused on traffic filtering. Firewall rules were introduced to enforce the reachability policy defined earlier and to reduce unnecessary exposure between segments.

The work was not limited to writing rules. It also included verification, so that allowed flows, denied flows, and default handling could be demonstrated with real tests.

### TD3 — IDS/IPS Deployment and Detection Validation

The third session introduced traffic monitoring and detection with Suricata. The aim was to make suspicious or malicious-looking activity visible in the environment and to verify that alerts were generated under the expected conditions.

This stage added observability to the project. Hardening is more effective when attacks, scans, and abnormal behavior can be detected rather than only blocked.

### TD4 — TLS Audit and Hardening with Nginx

The fourth session examined transport security on the web server. A deliberately weak TLS configuration was first analyzed, then hardened step by step to align with more secure protocol and cipher choices.

The lab included before-and-after comparison, scan-based validation, and configuration review. The point was to show that secure HTTPS depends on careful configuration rather than simply enabling TLS.

### TD5 — SSH Hardening and Site-to-Site IPsec VPN

The fifth session moved to secure remote access. SSH on the server was restricted through account scoping and key-based authentication, while an IKEv2 IPsec tunnel was deployed between two sites to protect inter-site traffic.

This lab linked host-level access control with network-level confidentiality. It also highlighted the importance of routing, addressing, and service validation when multiple security layers interact.

### TD6 — Final Integration and Evidence Review

The last stage of the coursework was used to consolidate the previous labs into a coherent final package. This included checking that the different protections still worked together, reviewing the evidence, and producing a clean final deliverable.

In other words, TD6 was less about adding a new control and more about making sure the overall project was technically consistent and properly documented.

## Lab Environment

The practical work was performed in a segmented virtual lab built around several Linux virtual machines with fixed roles. Depending on the session, the exact topology evolved, but the main components remained consistent.

Typical roles included:

- a client machine used for testing, scanning, and administration
- a gateway or firewall used for routing and filtering
- a web server hosting the exposed services
- an IDS sensor used for packet capture and detection validation

This environment made it possible to study security controls in a contained setting while still keeping a realistic separation between LAN, DMZ, and transit networks.

## Working Method

A common method was used throughout the coursework.

First, the initial state was observed. This often meant checking services, routes, firewall behavior, or packet visibility before any change was applied.

Next, the target hardening measure was configured. This could be a firewall rule, a TLS policy, a Suricata rule, an SSH setting, or a VPN definition.

After that, the control was validated through direct testing. The intention was to avoid assuming that a service was secure just because a configuration file looked correct. Effective behavior always had to be checked in practice.

Finally, the results were preserved as evidence. Logs, screenshots, command outputs, and configuration extracts were collected to support the written conclusions.

## Repository Structure

A possible overview of the repository is shown below:

```text
Network-Hardening/
├── TD1/
│   ├── README.md
│   ├── report.md
│   ├── config/
│   └── evidence/
├── TD2/
│   ├── README.md
│   ├── report.md
│   ├── config/
│   └── evidence/
├── TD3/
│   ├── README.md
│   ├── report.md
│   ├── rules/
│   └── evidence/
├── TD4/
│   ├── README.md
│   ├── report.md
│   ├── config/
│   └── evidence/
├── TD5/
│   ├── README.md
│   ├── report.md
│   ├── config/
│   ├── evidence/
│   └── appendix/
├── TD6/
│   ├── README.md
│   ├── final_report.md
│   └── evidence/
└── README.md

The exact contents may vary by lab, but the overall logic remains the same: configuration, tests, and evidence are kept together so that each part of the work can be reviewed easily.

Security Themes Covered

Across the full coursework, the following security themes were addressed:

network segmentation
routing control
packet filtering
intrusion detection
secure transport protocols
secure remote administration
encrypted site-to-site communication
evidence-based validation

These themes were not treated separately in theory only. Each one was implemented in a lab context and then tested with concrete commands and observable results.

Main Lessons from the Project

Several practical lessons emerged from the module.

The first is that security controls are highly dependent on clean fundamentals. Many apparent “security problems” actually come from routing mistakes, interface confusion, leftover configurations, or service overrides.

The second is that validation matters as much as configuration. A firewall rule, TLS setting, or SSH policy is not trustworthy until its effect has been observed directly.

The third is that security engineering works best when it is layered. Filtering, monitoring, encryption, and access control each solve a different part of the problem. The project became stronger as these controls were combined rather than used in isolation.

Conclusion

This coursework documents the gradual hardening of a small virtual network through multiple practical sessions. From topology definition to firewalling, IDS deployment, TLS improvement, SSH restriction, and IPsec tunneling, each lab added another level of control to the environment.

The final repository is therefore not just a collection of commands. It is a structured record of how security requirements were translated into technical measures and how those measures were verified with evidence.

The overall goal of the project was to move from a functional network to a defensible one, with clear justification for each protection that was introduced.
