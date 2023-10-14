# cv

This repository is used to host, build, and deploy my curriculum vitae (CV).

## Requirements

To build the CV, you will need the following:

* [Docker](https://www.docker.com/)
* [fswatch](https://github.com/emcrisostomo/fswatch)

## Build

To build the CV, run the following command:

```bash
./build-cv.sh
```

This will build the CV using the `Dockerfile` in the root of the repository. The output will be a PDF file named `cv.pdf` and a webpage named `index.html` in the [`docs`](docs) directory.

### Preview

Next, you can preview the CV by navigating to [http://localhost:8000](http://localhost:8000) to view the CV.

By utilizing the *fswatch* command, the CV will be rebuilt and the preview will be refreshed *automagically* 🪄 whenever a change is made to the CV.

If you want to manually start the preview server, run the following command:

```bash
python3 -m http.server 8080 --directory docs
```

### To Stop the Preview

To stop the preview, you can terminate the process by pressing `CTRL + C`.

## License

© Nicholas Adamou.

It is free software, and may be redistributed under the terms specified in the [LICENSE](LICENSE) file.
