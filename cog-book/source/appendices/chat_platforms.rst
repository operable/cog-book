Notes on Chat Platform Support
==============================

No Emoji or Auto-Linking in HipChat
-----------------------------------

Messages sent to HipChat will not render emoji, or auto-link URLs and
mention names. This is a limitation of HipChat’s APIs at the moment,
which do not allow for such things in HTML-formatted messages sent to
chat rooms.

HipChat issue
`HCPUB-1130 <https://jira.atlassian.com/browse/HCPUB-1130>`__ tracks
this situation.
