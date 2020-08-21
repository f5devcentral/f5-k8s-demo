WAF Security Policies
=====================

Introduction
~~~~~~~~~~~~

The environment is setup with BOTH BIG-IP ASM and NGINX App Protect.

You may want to apply policies at one or both locations.  Used together you could apply a "broad" policy at BIG-IP vs. "app-specific" policy with NGINX App Protect.

Demo
~~~~

Postman is configured with 3 sets of requests under the "OpenShift Demo" 
collection.

- Via OCP Router: Via default OCP Router (shows output using default)
- Attack! via OCP Router: There is an "X-Hacker" header that is permitted by default router.
- Via BIG-IP Route: via route defined on BIG-IP (shows output)
- Attack! via BIG-IP Route: There is an "X-Hacker" header that is blocked by BIG-IP ASM
- via BIG-IP and NGINX: via Ingress (shows output via NGINX)
- Attack! via BIG-IP and NGINX: There is an "X-Hacker" header that is blocked by NGINX App Protect.  Logs are sent to syslog on the "web" host.

