# Security

## Reporting a problem

If you find a security problem in the RBAi CLI, in the RBAi service or in anything in this repository, please tell
us privately rather than in a public issue.

Use GitHub's private reporting: open the **Security** tab of this repository and choose **Report a vulnerability**.
Only the maintainers can see what you send. If you can't use GitHub, email
[hari@thedreamlabinnovations.com](mailto:hari@thedreamlabinnovations.com) with "Security" in the subject.

Please include:

- what you found and where (the command, your `rbai --version`, the address or the file);
- the steps to reproduce it;
- what someone could do with it.

Never include a real API key, sign-in code or token, yours or anyone else's. If one of your keys may have been
exposed, revoke it in RBAi under **Settings → API keys**, then sign in again with `rbai auth login`.

## What we ask

- Test only with your own account and your own keys.
- Don't read, change or delete anyone else's data.
- Keep the load small: no stress tests, and no automated scanning at high rates.
- Give us a reasonable time to fix the problem before you describe it in public.

We'll confirm that we received your report, keep you updated while we work on it, and credit you when the fix is
out if you'd like to be named.

## Scope

This repository holds the CLI's documentation, installer scripts and agent kit. The CLI's own code isn't in it, but
reports about the CLI and the RBAi service are welcome through the same private form.

## Checking a download

The installers check every download against its SHA-256 checksum before they install it. To check a file
yourself, compare its SHA-256 with the list for its version at
`https://cli.thedreamlabinnovations.com/cli/<version>/SHA256SUMS`, for example
[the list for 1.6.9](https://cli.thedreamlabinnovations.com/cli/1.6.9/SHA256SUMS).
