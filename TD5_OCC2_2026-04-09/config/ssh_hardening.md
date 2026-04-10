# SSH Hardening Notes

The SSH hardening phase was carried out on `srv-web`, which served as the managed system on Site B.

For this lab, a dedicated account named `adminX` was used for administration. This made the access policy more precise and avoided depending on a shared or overly broad user account.

On `client-kali`, an Ed25519 key pair was generated and the public key was installed on the server for `adminX`. Key-based authentication was tested first, before password authentication was turned off. That order was important because it reduced the chance of losing remote access while the SSH service was being hardened.

The final SSH posture followed a few clear rules:

- password authentication disabled
- direct root login disabled
- SSH access restricted to the intended admin account
- limited authentication time window
- reduced number of login attempts
- successful and failed connection attempts kept visible in logs

One practical issue appeared during validation. Even though the main SSH configuration file had been updated correctly, password-based login still worked. The reason was that a cloud-init include file was still overriding the setting and re-enabling password authentication. The hardening only became effective once that secondary file was corrected as well.

In operational terms, the SSH configuration was validated with three simple checks:
- successful key-based login as `adminX`
- failed password-only login attempt
- failed direct root login attempt

These checks were sufficient to show that the final SSH setup was more restrictive, easier to control, and easier to audit than the default configuration.
