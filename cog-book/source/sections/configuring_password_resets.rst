Configuring password resets
===========================

Cog uses email for its password reset process. To enable Cog to send
emails you will need to configure SMTP. Like most things in Cog, SMTP is
configured via environment variables. See `SMTP
configuration <#Cog Server Configuration>`__ for information on which
vars to set.

Additionally you must provide who the password reset request email is
from. This would most likely be something like "\\support@mydoman.com"
or "\\no-reply@mydomain.com". This is done with the
```COG_EMAIL_FROM`` <#Cog Server Configuration>`__ var.

Optionally, if you are providing a custom form for password resets you
can set the ```COG_PASSWORD_RESET_BASE`` <#Cog Server Configuration>`__.
It should be noted that this is for advanced users wanting to provide
custom UI to their users.
