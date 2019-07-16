* [Original Project Forked For Github with Customizations](https://gitlab.com/open-source-devex/containers/build/badges/master/pipeline.svg)](https://gitlab.com/open-source-devex/containers/build/commits/master)

# Docker container that provides acces to keybase volumes

Based on `alpine:latest` for accessing volumes that will be mounted in `/keybase`

The container supports parameters:

| Variable         | Default    | Usage   |
|------------------|---------|---------------|
| START_KEYBASE    | false | Set to "true" to actually start Keybase, this also requires: KEYBASE_USERNAME and KEYBASE_PAPERKEY   |
| KEYBASE_USERNAME | none  | The username |
| KEYBASE_PAPERKEY | none  | Create a "recovery device" paper key this will be used to access |
| DEBUG_ENTRYPOINT | false | Set to "true" to  of the entrypoint script |

When START_KEYBASE is set to true the container automatically waits for mounting to finish (or exits when credentials arn't provided).

If you write to files in the volumes. Keybase needs a little bit of time to flush the writes (generally <1 second).
The container provides a script that checks all content is flushed. To use it call it with the path of the file that was written to.
```bash
/opt/keybase/bin/wait-for-flush.sh "/keybase/team/folder-last-written-to/"
```

## Building new containers without code changes

Because every commit to master in this repository creates a release that tagged in git, the best way to trigger a new container build without the code having changed is to create an empty commit.
Such builds are needed for example when the base container has been updated.

```bash
git commit --allow-empty -m "Trigger build of new container on latest base image"
```
