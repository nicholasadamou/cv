# cv

This repository is used to host, build, and deploy my curriculum vitae (CV).

## Requirements

To build the CV, you will need the following:

* [Docker](https://www.docker.com/)

## Docker

To build the CV, run the following command:

```bash
docker compose build
```

To view the CV, run the following command:

```bash
docker compose up
```

You can preview the CV by navigating to [http://localhost:3000](http://localhost:3000) to view the CV.

By utilizing the `inotifywait` and `browser-sync` commands, the CV will be rebuilt and the preview will be refreshed *automagically* 🪄 whenever a change is made to the CV.

## License

© Nicholas Adamou.

It is free software, and may be redistributed under the terms specified in the [LICENSE](LICENSE) file.
